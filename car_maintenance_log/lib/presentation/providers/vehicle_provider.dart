import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:car_maintenance_log/data/models/vehicle.dart';
import 'package:car_maintenance_log/data/repositories/vehicle_repository.dart';

/// Provider for VehicleRepository
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository();
});

/// Provider for all vehicles stream
final vehiclesStreamProvider = StreamProvider<List<Vehicle>>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.watchAllVehicles();
});

/// Provider for the first vehicle (MVP single vehicle support)
final firstVehicleProvider = FutureProvider<Vehicle?>((ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return await repository.getFirstVehicle();
});

/// Provider to check if any vehicles exist
final hasVehiclesProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return await repository.hasVehicles();
});

/// State notifier for vehicle operations
class VehicleNotifier extends StateNotifier<AsyncValue<Vehicle?>> {
  final VehicleRepository _repository;

  VehicleNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadFirstVehicle();
  }

  Future<void> _loadFirstVehicle() async {
    state = const AsyncValue.loading();
    try {
      final vehicle = await _repository.getFirstVehicle();
      state = AsyncValue.data(vehicle);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Add a new vehicle
  Future<void> addVehicle(Vehicle vehicle) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addVehicle(vehicle);
      final newVehicle = await _repository.getFirstVehicle();
      state = AsyncValue.data(newVehicle);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update existing vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateVehicle(vehicle);
      state = AsyncValue.data(vehicle);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Delete vehicle
  Future<void> deleteVehicle(Id id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteVehicle(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refresh vehicle data
  Future<void> refresh() async {
    await _loadFirstVehicle();
  }
}

/// Provider for VehicleNotifier
final vehicleNotifierProvider =
    StateNotifierProvider<VehicleNotifier, AsyncValue<Vehicle?>>((ref) {
      final repository = ref.watch(vehicleRepositoryProvider);
      return VehicleNotifier(repository);
    });
