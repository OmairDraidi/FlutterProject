import 'package:isar/isar.dart';

part 'reminder.g.dart';

@collection
class Reminder {
  Id id = Isar.autoIncrement;

  /// Reference to the vehicle this reminder belongs to
  @Index()
  late int vehicleId;

  /// Title of the reminder (e.g., "Oil Change", "Tire Rotation")
  late String title;

  /// Type of maintenance (linked to MaintenanceTypes)
  @Index()
  late String type;

  /// When the reminder is due
  @Index()
  late DateTime dueDate;

  /// Mileage target for the reminder (optional)
  int? dueMileage;

  /// Whether the reminder has been completed
  @Index()
  bool isCompleted = false;

  /// ID for the system notification (to cancel it if needed)
  int? notificationId;

  /// Creation timestamp
  late DateTime createdAt;

  /// Completion timestamp
  DateTime? completedAt;
}
