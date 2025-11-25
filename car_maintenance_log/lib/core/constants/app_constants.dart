import 'package:flutter/material.dart';

/// App-wide constants for spacing, strings, and configuration
class AppConstants {
  // Spacing constants following 8px rhythm
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // App strings
  static const String appName = 'Car Maintenance Log';
  static const String dashboardTitle = 'Dashboard';
  static const String timelineTitle = 'Timeline';
  static const String remindersTitle = 'Reminders';

  // Database
  static const String databaseName = 'car_maintenance_db';
}

class MaintenanceTypeData {
  final IconData icon;
  final Color color;

  const MaintenanceTypeData({required this.icon, required this.color});
}

/// Maintenance type categories with icons and colors
class MaintenanceTypes {
  // Type constants
  static const String oilChange = 'Oil Change';
  static const String tireRotation = 'Tire Rotation';
  static const String brakes = 'Brakes';
  static const String battery = 'Battery';
  static const String filters = 'Filters';
  static const String inspection = 'Inspection';
  static const String repair = 'Repair';
  static const String other = 'Other';

  static const List<String> all = [
    oilChange,
    tireRotation,
    brakes,
    battery,
    filters,
    inspection,
    repair,
    other,
  ];

  static MaintenanceTypeData getTypeData(String type) {
    return MaintenanceTypeData(
      icon: IconData(getIconCodePoint(type), fontFamily: 'MaterialIcons'),
      color: Color(getColorValue(type)),
    );
  }

  /// Get icon data for maintenance type
  static int getIconCodePoint(String type) {
    switch (type) {
      case oilChange:
        return 0xe4f7; // Icons.oil_barrel
      case tireRotation:
        return 0xe558; // Icons.tire_repair
      case brakes:
        return 0xe1e8; // Icons.brake_alert
      case battery:
        return 0xe1a3; // Icons.battery_charging_full
      case filters:
        return 0xe3be; // Icons.filter_alt
      case inspection:
        return 0xe8f4; // Icons.search
      case repair:
        return 0xe869; // Icons.build
      case other:
      default:
        return 0xe86f; // Icons.more_horiz
    }
  }

  /// Get color value for maintenance type
  static int getColorValue(String type) {
    switch (type) {
      case oilChange:
        return 0xFFEF6C00; // Deep Orange 800
      case tireRotation:
        return 0xFF424242; // Grey 800
      case brakes:
        return 0xFFC62828; // Red 800
      case battery:
        return 0xFF2E7D32; // Green 800
      case filters:
        return 0xFF1565C0; // Blue 800
      case inspection:
        return 0xFF6A1B9A; // Purple 800
      case repair:
        return 0xFFD84315; // Deep Orange 700
      case other:
      default:
        return 0xFF616161; // Grey 700
    }
  }
}
