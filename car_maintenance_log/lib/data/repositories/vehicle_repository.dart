import 'package:isar/isar.dart';
import 'package:car_maintenance_log/data/models/vehicle.dart';
import 'package:car_maintenance_log/data/services/database_service.dart';

/// Repository for Vehicle CRUD operations
class VehicleRepository {
  final Isar _isar = DatabaseService.isar;

  /// Get all vehicles
  Future<List<Vehicle>> getAllVehicles() async {
    return await _isar.vehicles.where().sortByCreatedAtDesc().findAll();
  }

  /// Get vehicle by ID
  Future<Vehicle?> getVehicleById(Id id) async {
    return await _isar.vehicles.get(id);
  }

  /// Get the first vehicle (for single vehicle MVP)
  Future<Vehicle?> getFirstVehicle() async {
    return await _isar.vehicles.where().findFirst();
  }

  /// Add a new vehicle
  Future<Id> addVehicle(Vehicle vehicle) async {
    return await _isar.writeTxn(() async {
      return await _isar.vehicles.put(vehicle);
    });
  }

  /// Update an existing vehicle
  Future<Id> updateVehicle(Vehicle vehicle) async {
    return await _isar.writeTxn(() async {
      return await _isar.vehicles.put(vehicle);
    });
  }

  /// Delete a vehicle
  Future<bool> deleteVehicle(Id id) async {
    return await _isar.writeTxn(() async {
      return await _isar.vehicles.delete(id);
    });
  }

  /// Check if any vehicles exist
  Future<bool> hasVehicles() async {
    final count = await _isar.vehicles.count();
    return count > 0;
  }

  /// Get total vehicle count
  Future<int> getVehicleCount() async {
    return await _isar.vehicles.count();
  }

  /// Watch all vehicles (stream for real-time updates)
  Stream<List<Vehicle>> watchAllVehicles() {
    return _isar.vehicles.where().sortByCreatedAtDesc().watch(
      fireImmediately: true,
    );
  }

  /// Watch a specific vehicle
  Stream<Vehicle?> watchVehicle(Id id) {
    return _isar.vehicles.watchObject(id, fireImmediately: true);
  }
}
