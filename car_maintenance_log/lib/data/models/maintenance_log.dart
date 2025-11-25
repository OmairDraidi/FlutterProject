import 'package:isar/isar.dart';

part 'maintenance_log.g.dart';

/// MaintenanceLog model representing a maintenance activity record
@collection
class MaintenanceLog {
  Id id = Isar.autoIncrement;

  /// Reference to the vehicle this log belongs to
  @Index()
  late int vehicleId;

  /// Type of maintenance (Oil Change, Tire Rotation, etc.)
  @Index()
  late String type;

  /// Brief title/description of the maintenance
  late String title;

  /// Detailed notes (optional)
  late String notes;

  /// Cost of the maintenance service
  late double cost;

  /// Odometer reading at time of service
  late int mileage;

  /// Date when maintenance was performed
  @Index()
  late DateTime date;

  /// Timestamp when this record was created
  late DateTime createdAt;

  /// Display formatted cost
  String get formattedCost => '\$${cost.toStringAsFixed(2)}';
}
