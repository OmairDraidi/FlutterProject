import 'package:isar/isar.dart';

part 'vehicle.g.dart';

/// Vehicle model representing a car in the maintenance log
@collection
class Vehicle {
  Id id = Isar.autoIncrement;

  @Index()
  late String make;

  late String model;

  late int year;

  late int mileage;

  @Index()
  late DateTime createdAt;

  /// Display name for the vehicle
  String get displayName => '$year $make $model';
}
