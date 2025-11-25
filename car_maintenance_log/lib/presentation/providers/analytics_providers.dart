import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:car_maintenance_log/data/models/analytics/monthly_cost.dart';
import 'package:car_maintenance_log/data/models/analytics/category_cost.dart';
import 'package:car_maintenance_log/data/models/analytics/log_point.dart';
import 'package:car_maintenance_log/data/services/analytics_service.dart';
import 'package:car_maintenance_log/presentation/providers/maintenance_log_provider.dart';
import 'package:car_maintenance_log/presentation/providers/vehicle_provider.dart';

/// Provider for AnalyticsService
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final logRepository = ref.watch(maintenanceLogRepositoryProvider);
  return AnalyticsService(logRepository);
});

/// Provider for total cost for the current vehicle (auto-updates with stream)
final analyticsTotalCostProvider = StreamProvider<double>((ref) {
  final logsAsync = ref.watch(maintenanceLogsStreamProvider);

  return logsAsync.when(
    data: (logs) {
      final totalCost = logs.fold<double>(0.0, (sum, log) => sum + log.cost);
      return Stream.value(totalCost);
    },
    loading: () => Stream.value(0.0),
    error: (_, __) => Stream.value(0.0),
  );
});

/// Provider for monthly cost breakdown for the current vehicle
final monthlyCostProvider = FutureProvider<List<MonthlyCost>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final vehicleAsync = ref.watch(firstVehicleProvider);

  return vehicleAsync.when(
    data: (vehicle) async {
      if (vehicle == null) return [];
      return await service.getMonthlyCost(vehicle.id);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for category cost distribution for the current vehicle
final categoryCostProvider = FutureProvider<List<CategoryCost>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final vehicleAsync = ref.watch(firstVehicleProvider);

  return vehicleAsync.when(
    data: (vehicle) async {
      if (vehicle == null) return [];
      return await service.getCategoryCost(vehicle.id);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for trend points for the current vehicle
final trendProvider = FutureProvider<List<LogPoint>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final vehicleAsync = ref.watch(firstVehicleProvider);

  return vehicleAsync.when(
    data: (vehicle) async {
      if (vehicle == null) return [];
      return await service.getTrendPoints(vehicle.id);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for average cost per month for the current vehicle
final averageCostPerMonthProvider = FutureProvider<double>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final vehicleAsync = ref.watch(firstVehicleProvider);

  return vehicleAsync.when(
    data: (vehicle) async {
      if (vehicle == null) return 0.0;
      return await service.getAverageCostPerMonth(vehicle.id);
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Provider for total log count for the current vehicle
final analyticsLogCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final vehicleAsync = ref.watch(firstVehicleProvider);

  return vehicleAsync.when(
    data: (vehicle) async {
      if (vehicle == null) return 0;
      return await service.getTotalLogCount(vehicle.id);
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});
