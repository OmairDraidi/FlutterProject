import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:car_maintenance_log/data/models/vehicle.dart';
import 'package:car_maintenance_log/data/models/maintenance_log.dart';
import 'package:car_maintenance_log/data/models/reminder.dart';

/// Service to initialize and manage Isar database
class DatabaseService {
  static Isar? _isar;

  /// Get the Isar instance
  static Isar get isar {
    if (_isar == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  /// Initialize the Isar database
  static Future<void> initialize() async {
    if (_isar != null) return; // Already initialized

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [VehicleSchema, MaintenanceLogSchema, ReminderSchema],
      directory: dir.path,
      name: 'car_maintenance_db',
    );
  }

  /// Close the database
  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
