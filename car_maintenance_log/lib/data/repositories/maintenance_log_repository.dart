import 'package:isar/isar.dart';
import 'package:car_maintenance_log/data/models/maintenance_log.dart';
import 'package:car_maintenance_log/data/services/database_service.dart';

/// Repository for MaintenanceLog CRUD operations
class MaintenanceLogRepository {
  final Isar _isar = DatabaseService.isar;

  /// Add a new maintenance log
  Future<Id> addLog(MaintenanceLog log) async {
    return await _isar.writeTxn(() async {
      return await _isar.maintenanceLogs.put(log);
    });
  }

  /// Update an existing maintenance log
  Future<Id> updateLog(MaintenanceLog log) async {
    return await _isar.writeTxn(() async {
      return await _isar.maintenanceLogs.put(log);
    });
  }

  /// Delete a maintenance log
  Future<bool> deleteLog(Id id) async {
    return await _isar.writeTxn(() async {
      return await _isar.maintenanceLogs.delete(id);
    });
  }

  /// Get a single log by ID
  Future<MaintenanceLog?> getLogById(Id id) async {
    return await _isar.maintenanceLogs.get(id);
  }

  /// Get all logs for a specific vehicle
  Future<List<MaintenanceLog>> getLogsByVehicle(int vehicleId) async {
    return await _isar.maintenanceLogs
        .where()
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .sortByDateDesc()
        .findAll();
  }

  /// Get logs within a date range
  Future<List<MaintenanceLog>> getLogsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await _isar.maintenanceLogs
        .where()
        .filter()
        .dateBetween(start, end)
        .sortByDateDesc()
        .findAll();
  }

  /// Get logs by vehicle and date range
  Future<List<MaintenanceLog>> getLogsByVehicleAndDateRange(
    int vehicleId,
    DateTime start,
    DateTime end,
  ) async {
    return await _isar.maintenanceLogs
        .where()
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .dateBetween(start, end)
        .sortByDateDesc()
        .findAll();
  }

  /// Watch all logs for a vehicle (stream for real-time updates)
  Stream<List<MaintenanceLog>> watchLogsByVehicle(int vehicleId) {
    return _isar.maintenanceLogs
        .where()
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .sortByDateDesc()
        .watch(fireImmediately: true);
  }

  /// Get total count of logs for a vehicle
  Future<int> getLogCount(int vehicleId) async {
    return await _isar.maintenanceLogs
        .where()
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .count();
  }

  /// Get total maintenance cost for a vehicle
  Future<double> getTotalCost(int vehicleId) async {
    final logs = await getLogsByVehicle(vehicleId);
    return logs.fold<double>(0.0, (sum, log) => sum + log.cost);
  }

  /// Get the most recent log for a vehicle
  Future<MaintenanceLog?> getLastLog(int vehicleId) async {
    return await _isar.maintenanceLogs
        .where()
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .sortByDateDesc()
        .findFirst();
  }

  /// Get logs by maintenance type
  Future<List<MaintenanceLog>> getLogsByType(int vehicleId, String type) async {
    return await _isar.maintenanceLogs
        .where()
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .typeEqualTo(type)
        .sortByDateDesc()
        .findAll();
  }
}
