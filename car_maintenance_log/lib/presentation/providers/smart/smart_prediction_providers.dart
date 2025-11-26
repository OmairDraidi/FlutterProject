import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:car_maintenance_log/data/models/predicted_maintenance.dart';
import 'package:car_maintenance_log/data/services/smart/smart_prediction_service.dart';
import 'package:car_maintenance_log/presentation/providers/vehicle_provider.dart';
import 'package:car_maintenance_log/presentation/providers/maintenance_log_provider.dart';

/// Provider for SmartPredictionService
///
/// Creates a SmartPredictionService instance with required dependencies
final smartPredictionServiceProvider = Provider<SmartPredictionService>((ref) {
  final logRepository = ref.watch(maintenanceLogRepositoryProvider);
  final vehicleRepository = ref.watch(vehicleRepositoryProvider);

  return SmartPredictionService(
    logRepository: logRepository,
    vehicleRepository: vehicleRepository,
  );
});

/// Provider for average kilometers per day
///
/// Calculates the average daily mileage for the active vehicle
/// Returns null if:
/// - No active vehicle exists
/// - Insufficient data (less than 2 maintenance logs)
final averageKmPerDayProvider = FutureProvider<double?>((ref) async {
  // Get the active vehicle
  final vehicleAsync = ref.watch(firstVehicleProvider);

  return vehicleAsync.when(
    data: (vehicle) async {
      if (vehicle == null) return null;

      final service = ref.watch(smartPredictionServiceProvider);
      return await service.calculateAverageKmPerDay(vehicle);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for the next predicted maintenance
///
/// Predicts the next "Oil Change" maintenance for the active vehicle
/// This is used for the main smart insight card in the Dashboard
///
/// Returns null if:
/// - No active vehicle exists
/// - Insufficient data for prediction
final nextPredictedMaintenanceProvider = FutureProvider<PredictedMaintenance?>((
  ref,
) async {
  // Get the active vehicle
  final vehicleAsync = ref.watch(firstVehicleProvider);

  return vehicleAsync.when(
    data: (vehicle) async {
      if (vehicle == null) return null;

      final service = ref.watch(smartPredictionServiceProvider);

      // Predict next oil change as the primary maintenance type
      return await service.predictNextMaintenanceForType(
        vehicle: vehicle,
        maintenanceType: 'Oil Change',
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for all smart predicted maintenances
///
/// Gets predictions for all key maintenance types for the active vehicle
/// Returns empty list if:
/// - No active vehicle exists
/// - No predictions can be made
///
/// This provider is used for:
/// - Smart suggestions section in RemindersScreen
/// - Full predictions view
final smartPredictedMaintenancesProvider =
    FutureProvider<List<PredictedMaintenance>>((ref) async {
      // Get the active vehicle
      final vehicleAsync = ref.watch(firstVehicleProvider);

      return vehicleAsync.when(
        data: (vehicle) async {
          if (vehicle == null) return [];

          final service = ref.watch(smartPredictionServiceProvider);
          return await service.getPredictedMaintenancesForVehicle(vehicle);
        },
        loading: () => [],
        error: (_, __) => [],
      );
    });
