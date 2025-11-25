import 'package:car_maintenance_log/data/models/analytics/monthly_cost.dart';
import 'package:car_maintenance_log/data/models/analytics/category_cost.dart';
import 'package:car_maintenance_log/data/models/analytics/log_point.dart';
import 'package:car_maintenance_log/data/repositories/maintenance_log_repository.dart';

/// Service for computing analytics from maintenance logs
class AnalyticsService {
  final MaintenanceLogRepository _logRepository;

  AnalyticsService(this._logRepository);

  /// Get total cost of all maintenance for a vehicle
  Future<double> getTotalCost(int vehicleId) async {
    return await _logRepository.getTotalCost(vehicleId);
  }

  /// Get monthly cost breakdown for a vehicle
  /// Returns list of MonthlyCost objects grouped by year and month
  Future<List<MonthlyCost>> getMonthlyCost(int vehicleId) async {
    final logs = await _logRepository.getLogsByVehicle(vehicleId);

    // Group logs by year and month
    final Map<String, double> monthlyTotals = {};

    for (final log in logs) {
      final year = log.date.year;
      final month = log.date.month;
      final key = '$year-$month';

      monthlyTotals[key] = (monthlyTotals[key] ?? 0.0) + log.cost;
    }

    // Convert to MonthlyCost objects
    final monthlyCosts = monthlyTotals.entries.map((entry) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      return MonthlyCost(year: year, month: month, totalCost: entry.value);
    }).toList();

    // Sort by year and month (most recent first)
    monthlyCosts.sort((a, b) {
      final yearCompare = b.year.compareTo(a.year);
      if (yearCompare != 0) return yearCompare;
      return b.month.compareTo(a.month);
    });

    return monthlyCosts;
  }

  /// Get cost distribution by maintenance category/type
  /// Returns list of CategoryCost objects with totals and counts
  Future<List<CategoryCost>> getCategoryCost(int vehicleId) async {
    final logs = await _logRepository.getLogsByVehicle(vehicleId);

    // Group logs by type/category
    final Map<String, Map<String, dynamic>> categoryData = {};

    for (final log in logs) {
      final category = log.type;

      if (!categoryData.containsKey(category)) {
        categoryData[category] = {'totalCost': 0.0, 'count': 0};
      }

      categoryData[category]!['totalCost'] =
          (categoryData[category]!['totalCost'] as double) + log.cost;
      categoryData[category]!['count'] =
          (categoryData[category]!['count'] as int) + 1;
    }

    // Convert to CategoryCost objects
    final categoryCosts = categoryData.entries.map((entry) {
      return CategoryCost(
        category: entry.key,
        totalCost: entry.value['totalCost'] as double,
        count: entry.value['count'] as int,
      );
    }).toList();

    // Sort by total cost (highest first)
    categoryCosts.sort((a, b) => b.totalCost.compareTo(a.totalCost));

    return categoryCosts;
  }

  /// Get trend points for line chart visualization
  /// Returns list of LogPoint objects with date and cost
  Future<List<LogPoint>> getTrendPoints(int vehicleId) async {
    final logs = await _logRepository.getLogsByVehicle(vehicleId);

    // Convert logs to LogPoint objects
    final trendPoints = logs.map((log) {
      return LogPoint(date: log.date, cost: log.cost);
    }).toList();

    // Sort by date (oldest first for trend visualization)
    trendPoints.sort((a, b) => a.date.compareTo(b.date));

    return trendPoints;
  }

  /// Get average cost per month for a vehicle
  Future<double> getAverageCostPerMonth(int vehicleId) async {
    final monthlyCosts = await getMonthlyCost(vehicleId);

    if (monthlyCosts.isEmpty) return 0.0;

    final totalCost = monthlyCosts.fold<double>(
      0.0,
      (sum, monthly) => sum + monthly.totalCost,
    );

    return totalCost / monthlyCosts.length;
  }

  /// Get total number of maintenance logs for a vehicle
  Future<int> getTotalLogCount(int vehicleId) async {
    return await _logRepository.getLogCount(vehicleId);
  }
}
