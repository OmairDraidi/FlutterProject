import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:car_maintenance_log/data/models/reminder.dart';
import 'package:car_maintenance_log/data/repositories/reminder_repository.dart';
import 'package:car_maintenance_log/data/services/notification_service.dart';
import 'package:car_maintenance_log/presentation/providers/vehicle_provider.dart';

/// Provider for ReminderRepository
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository();
});

/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for upcoming reminders stream for the current vehicle
final upcomingRemindersStreamProvider = StreamProvider<List<Reminder>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  final vehicleAsync = ref.watch(firstVehicleProvider);

  return vehicleAsync.when(
    data: (vehicle) {
      if (vehicle == null) {
        return Stream.value([]);
      }
      return repository.watchUpcomingReminders(vehicle.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Provider for upcoming reminders count
final upcomingRemindersCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  final vehicleAsync = ref.watch(firstVehicleProvider);

  return vehicleAsync.when(
    data: (vehicle) {
      if (vehicle == null) return Stream.value(0);
      return repository
          .watchUpcomingReminders(vehicle.id)
          .map((reminders) => reminders.length);
    },
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});

/// Provider for the next upcoming reminder (single most urgent)
final nextReminderProvider = StreamProvider<Reminder?>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  final vehicleAsync = ref.watch(firstVehicleProvider);

  return vehicleAsync.when(
    data: (vehicle) {
      if (vehicle == null) return Stream.value(null);
      return repository.watchUpcomingReminders(vehicle.id).map((reminders) {
        if (reminders.isEmpty) return null;
        // Reminders are already sorted by due date in the repository
        return reminders.first;
      });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// State notifier for reminder operations
class ReminderNotifier extends StateNotifier<AsyncValue<void>> {
  final ReminderRepository _repository;
  final NotificationService _notificationService;

  ReminderNotifier(this._repository, this._notificationService)
    : super(const AsyncValue.data(null));

  /// Add a new reminder and schedule notification
  Future<void> addReminder(Reminder reminder) async {
    state = const AsyncValue.loading();
    try {
      // Save to database
      final id = await _repository.addReminder(reminder);

      // Schedule notification
      final notificationId = await _notificationService.scheduleNotification(
        id: id, // Use Isar ID as notification ID (assuming it fits in int)
        title: 'Maintenance Due: ${reminder.title}',
        body: 'Your ${reminder.type} is due today.',
        scheduledDate: reminder.dueDate,
      );

      // Update reminder with notification ID if needed (though we used the same ID)
      if (notificationId != -1) {
        reminder.notificationId = notificationId;
        await _repository.updateReminder(reminder);
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update an existing reminder and reschedule notification
  Future<void> updateReminder(Reminder reminder) async {
    state = const AsyncValue.loading();
    try {
      // Cancel old notification if exists
      if (reminder.notificationId != null) {
        await _notificationService.cancelNotification(reminder.notificationId!);
      }

      // Schedule new notification
      final notificationId = await _notificationService.scheduleNotification(
        id: reminder.id,
        title: 'Maintenance Due: ${reminder.title}',
        body: 'Your ${reminder.type} is due today.',
        scheduledDate: reminder.dueDate,
      );

      reminder.notificationId = notificationId != -1 ? notificationId : null;

      // Update in database
      await _repository.updateReminder(reminder);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Mark reminder as completed
  Future<void> completeReminder(Reminder reminder) async {
    state = const AsyncValue.loading();
    try {
      // Cancel notification
      if (reminder.notificationId != null) {
        await _notificationService.cancelNotification(reminder.notificationId!);
      }

      reminder.isCompleted = true;
      reminder.completedAt = DateTime.now();
      reminder.notificationId = null;

      await _repository.updateReminder(reminder);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Delete a reminder
  Future<void> deleteReminder(Reminder reminder) async {
    state = const AsyncValue.loading();
    try {
      // Cancel notification
      if (reminder.notificationId != null) {
        await _notificationService.cancelNotification(reminder.notificationId!);
      }

      await _repository.deleteReminder(reminder.id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider for ReminderNotifier
final reminderNotifierProvider =
    StateNotifierProvider<ReminderNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(reminderRepositoryProvider);
      final notificationService = ref.watch(notificationServiceProvider);
      return ReminderNotifier(repository, notificationService);
    });
