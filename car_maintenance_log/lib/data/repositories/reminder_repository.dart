import 'package:isar/isar.dart';
import 'package:car_maintenance_log/data/models/reminder.dart';
import 'package:car_maintenance_log/data/services/database_service.dart';

/// Repository for Reminder CRUD operations
class ReminderRepository {
  final Isar _isar = DatabaseService.isar;

  /// Add a new reminder
  Future<Id> addReminder(Reminder reminder) async {
    return await _isar.writeTxn(() async {
      return await _isar.reminders.put(reminder);
    });
  }

  /// Update an existing reminder
  Future<Id> updateReminder(Reminder reminder) async {
    return await _isar.writeTxn(() async {
      return await _isar.reminders.put(reminder);
    });
  }

  /// Delete a reminder
  Future<bool> deleteReminder(Id id) async {
    return await _isar.writeTxn(() async {
      return await _isar.reminders.delete(id);
    });
  }

  /// Get a single reminder by ID
  Future<Reminder?> getReminderById(Id id) async {
    return await _isar.reminders.get(id);
  }

  /// Get all reminders for a specific vehicle
  Future<List<Reminder>> getRemindersByVehicle(int vehicleId) async {
    return await _isar.reminders
        .where()
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .sortByDueDate()
        .findAll();
  }

  /// Get upcoming (incomplete) reminders for a vehicle
  Future<List<Reminder>> getUpcomingReminders(int vehicleId) async {
    return await _isar.reminders
        .where()
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isCompletedEqualTo(false)
        .sortByDueDate()
        .findAll();
  }

  /// Get overdue reminders for a vehicle
  Future<List<Reminder>> getOverdueReminders(int vehicleId) async {
    final now = DateTime.now();
    return await _isar.reminders
        .where()
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isCompletedEqualTo(false)
        .and()
        .dueDateLessThan(now)
        .sortByDueDate()
        .findAll();
  }

  /// Get completed reminders for a vehicle
  Future<List<Reminder>> getCompletedReminders(int vehicleId) async {
    return await _isar.reminders
        .where()
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isCompletedEqualTo(true)
        .sortByDueDateDesc()
        .findAll();
  }

  /// Watch all reminders for a vehicle (stream for real-time updates)
  Stream<List<Reminder>> watchRemindersByVehicle(int vehicleId) {
    return _isar.reminders
        .where()
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .sortByDueDate()
        .watch(fireImmediately: true);
  }

  /// Watch upcoming reminders for a vehicle
  Stream<List<Reminder>> watchUpcomingReminders(int vehicleId) {
    return _isar.reminders
        .where()
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isCompletedEqualTo(false)
        .sortByDueDate()
        .watch(fireImmediately: true);
  }

  /// Get count of upcoming reminders
  Future<int> getUpcomingCount(int vehicleId) async {
    return await _isar.reminders
        .where()
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isCompletedEqualTo(false)
        .count();
  }
}
