import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:car_maintenance_log/data/models/maintenance_log.dart';
import 'package:car_maintenance_log/data/repositories/maintenance_log_repository.dart';
import 'package:car_maintenance_log/presentation/providers/vehicle_provider.dart';

/// Provider for MaintenanceLogRepository
final maintenanceLogRepositoryProvider = Provider<MaintenanceLogRepository>((
  ref,
) {
  return MaintenanceLogRepository();
});

/// Provider for maintenance logs stream for the current vehicle
final maintenanceLogsStreamProvider = StreamProvider<List<MaintenanceLog>>((
  ref,
) {
  final repository = ref.watch(maintenanceLogRepositoryProvider);
  final vehicleAsync = ref.watch(firstVehicleProvider);

  return vehicleAsync.when(
    data: (vehicle) {
      if (vehicle == null) {
        return Stream.value([]);
      }
      return repository.watchLogsByVehicle(vehicle.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Provider for total log count for the current vehicle
final logCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(maintenanceLogRepositoryProvider);
  final vehicleAsync = ref.watch(firstVehicleProvider);

  return vehicleAsync.when(
    data: (vehicle) {
      if (vehicle == null) return Stream.value(0);
      return repository
          .watchLogsByVehicle(vehicle.id)
          .map((logs) => logs.length);
    },
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});

/// Provider for total maintenance cost for the current vehicle
final totalCostProvider = StreamProvider<double>((ref) {
  final repository = ref.watch(maintenanceLogRepositoryProvider);
  final vehicleAsync = ref.watch(firstVehicleProvider);

  return vehicleAsync.when(
    data: (vehicle) {
      if (vehicle == null) return Stream.value(0.0);
      return repository.watchLogsByVehicle(vehicle.id).map((logs) {
        return logs.fold(0.0, (sum, log) => sum + log.cost);
      });
    },
    loading: () => Stream.value(0.0),
    error: (_, __) => Stream.value(0.0),
  );
});

/// Provider for the last maintenance log (auto-updates with stream)
final lastLogProvider = StreamProvider<MaintenanceLog?>((ref) {
  final logsAsync = ref.watch(maintenanceLogsStreamProvider);

  return logsAsync.when(
    data: (logs) {
      if (logs.isEmpty) return Stream.value(null);
      return Stream.value(logs.first); // First item is the most recent
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// State notifier for maintenance log operations
class MaintenanceLogNotifier
    extends StateNotifier<AsyncValue<MaintenanceLog?>> {
  final MaintenanceLogRepository _repository;

  MaintenanceLogNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Add a new maintenance log
  Future<void> addLog(MaintenanceLog log) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addLog(log);
      state = AsyncValue.data(log);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update an existing maintenance log
  Future<void> updateLog(MaintenanceLog log) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateLog(log);
      state = AsyncValue.data(log);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Delete a maintenance log
  Future<void> deleteLog(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteLog(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider for MaintenanceLogNotifier
final maintenanceLogNotifierProvider =
    StateNotifierProvider<MaintenanceLogNotifier, AsyncValue<MaintenanceLog?>>((
      ref,
    ) {
      final repository = ref.watch(maintenanceLogRepositoryProvider);
      return MaintenanceLogNotifier(repository);
    });
