import 'package:car_maintenance_log/data/models/predicted_maintenance.dart';
import 'package:car_maintenance_log/data/models/vehicle.dart';
import 'package:car_maintenance_log/data/repositories/maintenance_log_repository.dart';
import 'package:car_maintenance_log/data/repositories/vehicle_repository.dart';

/// Service for smart prediction of maintenance based on historical data
///
/// This service analyzes maintenance logs and vehicle usage patterns
/// to predict when future maintenance will be needed.
class SmartPredictionService {
  final MaintenanceLogRepository _logRepository;
  final VehicleRepository _vehicleRepository;

  SmartPredictionService({
    required MaintenanceLogRepository logRepository,
    required VehicleRepository vehicleRepository,
  }) : _logRepository = logRepository,
       _vehicleRepository = vehicleRepository;

  /// Calculate average kilometers driven per day for a vehicle
  ///
  /// Analyzes maintenance log history to estimate daily driving patterns.
  /// Returns null if insufficient data is available (less than 2 logs).
  ///
  /// Algorithm:
  /// - Fetches all maintenance logs for the vehicle
  /// - Finds earliest and latest logs by date
  /// - Calculates mileage difference and time difference
  /// - Returns km/day average
  ///
  /// Edge cases handled:
  /// - Less than 2 logs: returns null
  /// - Zero or negative time difference: returns null
  /// - Zero or negative mileage difference: returns null
  Future<double?> calculateAverageKmPerDay(Vehicle vehicle) async {
    // Fetch all maintenance logs for this vehicle
    final logs = await _logRepository.getLogsByVehicle(vehicle.id);

    // Need at least 2 logs to calculate an average
    if (logs.length < 2) {
      return null;
    }

    // Sort logs by date to find earliest and latest
    final sortedLogs = List.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    final earliestLog = sortedLogs.first;
    final latestLog = sortedLogs.last;

    // Calculate mileage difference
    final mileageDifference = latestLog.mileage - earliestLog.mileage;

    // Calculate time difference in days
    final timeDifference = latestLog.date.difference(earliestLog.date).inDays;

    // Handle edge cases
    if (timeDifference <= 0 || mileageDifference <= 0) {
      return null;
    }

    // Calculate and return average km per day
    return mileageDifference / timeDifference;
  }

  /// Predict the next maintenance for a specific maintenance type
  ///
  /// Analyzes historical patterns for the given maintenance type
  /// and predicts when it will be needed next.
  ///
  /// Returns null if insufficient data exists for prediction (less than 2 logs)
  ///
  /// Algorithm:
  /// - Fetches logs of the specified type
  /// - Calculates average mileage interval between occurrences
  /// - Estimates next mileage based on last log + average interval
  /// - Uses calculateAverageKmPerDay to estimate date from mileage
  /// - Computes confidence score based on data consistency
  /// - Generates human-readable explanation
  Future<PredictedMaintenance?> predictNextMaintenanceForType({
    required Vehicle vehicle,
    required String maintenanceType,
  }) async {
    // Fetch all logs of this type for the vehicle
    final typeLogs = await _logRepository.getLogsByType(
      vehicle.id,
      maintenanceType,
    );

    // Need at least 2 logs to establish a pattern
    if (typeLogs.length < 2) {
      return null;
    }

    // Sort logs by date chronologically
    final sortedLogs = List.from(typeLogs)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calculate intervals between consecutive logs
    final mileageIntervals = <int>[];
    final dayIntervals = <int>[];

    for (int i = 1; i < sortedLogs.length; i++) {
      final mileageDiff = sortedLogs[i].mileage - sortedLogs[i - 1].mileage;
      final dayDiff = sortedLogs[i].date
          .difference(sortedLogs[i - 1].date)
          .inDays;

      if (mileageDiff > 0) mileageIntervals.add(mileageDiff);
      if (dayDiff > 0) dayIntervals.add(dayDiff);
    }

    // Need valid intervals to make predictions
    if (mileageIntervals.isEmpty) {
      return null;
    }

    // Calculate average mileage interval
    final avgMileageInterval =
        mileageIntervals.reduce((a, b) => a + b) / mileageIntervals.length;

    // Estimate next mileage
    final lastLog = sortedLogs.last;
    final estimatedNextMileage = lastLog.mileage + avgMileageInterval;

    // Try to estimate next date using km/day calculation
    DateTime? estimatedNextDate;
    final kmPerDay = await calculateAverageKmPerDay(vehicle);

    if (kmPerDay != null && kmPerDay > 0) {
      final daysUntilNext = avgMileageInterval / kmPerDay;
      estimatedNextDate = lastLog.date.add(
        Duration(days: daysUntilNext.round()),
      );
    } else if (dayIntervals.isNotEmpty) {
      // Fallback: use average day interval if km/day not available
      final avgDayInterval =
          dayIntervals.reduce((a, b) => a + b) / dayIntervals.length;
      estimatedNextDate = lastLog.date.add(
        Duration(days: avgDayInterval.round()),
      );
    }

    // Calculate confidence score based on data consistency
    final confidenceScore = _calculateConfidenceScore(
      dataPoints: sortedLogs.length,
      mileageIntervals: mileageIntervals,
      dayIntervals: dayIntervals,
    );

    // Generate explanation
    final explanation = _generateExplanation(
      maintenanceType: maintenanceType,
      logCount: sortedLogs.length,
      avgMileageInterval: avgMileageInterval,
    );

    return PredictedMaintenance(
      maintenanceType: maintenanceType,
      estimatedNextMileage: estimatedNextMileage,
      estimatedNextDate: estimatedNextDate,
      confidenceScore: confidenceScore,
      explanation: explanation,
    );
  }

  /// Get all predicted maintenances for a vehicle
  ///
  /// Analyzes key maintenance types and returns predictions
  /// for those with sufficient historical data.
  ///
  /// Returns empty list if no predictions can be made
  ///
  /// Algorithm:
  /// - Defines key maintenance types to analyze
  /// - Calls predictNextMaintenanceForType for each type
  /// - Filters out null results
  /// - Sorts by estimated date (earliest first)
  Future<List<PredictedMaintenance>> getPredictedMaintenancesForVehicle(
    Vehicle vehicle,
  ) async {
    // Define key maintenance types to analyze
    const keyMaintenanceTypes = [
      'Oil Change',
      'Brake Inspection',
      'Tire Rotation',
      'Air Filter',
      'Battery Check',
      'Coolant Flush',
      'Transmission Service',
    ];

    // Get predictions for each key type
    final predictions = <PredictedMaintenance>[];

    for (final type in keyMaintenanceTypes) {
      final prediction = await predictNextMaintenanceForType(
        vehicle: vehicle,
        maintenanceType: type,
      );

      if (prediction != null) {
        predictions.add(prediction);
      }
    }

    // Sort by estimated date (earliest first), then by mileage
    predictions.sort((a, b) {
      // If both have dates, sort by date
      if (a.estimatedNextDate != null && b.estimatedNextDate != null) {
        return a.estimatedNextDate!.compareTo(b.estimatedNextDate!);
      }

      // If only one has a date, prioritize it
      if (a.estimatedNextDate != null) return -1;
      if (b.estimatedNextDate != null) return 1;

      // If neither has a date, sort by mileage
      if (a.estimatedNextMileage != null && b.estimatedNextMileage != null) {
        return a.estimatedNextMileage!.compareTo(b.estimatedNextMileage!);
      }

      // Fallback: sort by confidence score (higher first)
      return b.confidenceScore.compareTo(a.confidenceScore);
    });

    return predictions;
  }

  /// Calculate confidence score based on data consistency
  ///
  /// Higher scores indicate more reliable predictions
  /// - 0.8-1.0: High confidence (4+ data points, consistent intervals)
  /// - 0.5-0.8: Medium confidence (2-3 data points)
  /// - 0.0-0.5: Low confidence (sparse or inconsistent data)
  double _calculateConfidenceScore({
    required int dataPoints,
    required List<int> mileageIntervals,
    required List<int> dayIntervals,
  }) {
    // Base score on number of data points
    double score = 0.3; // Base score

    if (dataPoints >= 5) {
      score = 0.85;
    } else if (dataPoints >= 4) {
      score = 0.75;
    } else if (dataPoints >= 3) {
      score = 0.65;
    } else if (dataPoints >= 2) {
      score = 0.50;
    }

    // Adjust based on consistency of intervals
    if (mileageIntervals.length >= 2) {
      final avgInterval =
          mileageIntervals.reduce((a, b) => a + b) / mileageIntervals.length;
      final variance =
          mileageIntervals
              .map((interval) {
                final diff = interval - avgInterval;
                return diff * diff;
              })
              .reduce((a, b) => a + b) /
          mileageIntervals.length;

      final standardDeviation = variance.isFinite ? variance : 0.0;
      final coefficientOfVariation = avgInterval > 0
          ? standardDeviation / avgInterval
          : 1.0;

      // Lower coefficient of variation = more consistent = higher confidence
      if (coefficientOfVariation < 0.2) {
        score += 0.1; // Very consistent
      } else if (coefficientOfVariation > 0.5) {
        score -= 0.15; // Inconsistent
      }
    }

    // Ensure score is within valid range
    return score.clamp(0.0, 1.0);
  }

  /// Generate human-readable explanation for the prediction
  String _generateExplanation({
    required String maintenanceType,
    required int logCount,
    required double avgMileageInterval,
  }) {
    final intervalKm = avgMileageInterval.round();

    if (logCount >= 4) {
      return 'Based on your last $logCount $maintenanceType records (avg. every $intervalKm km).';
    } else if (logCount == 3) {
      return 'Based on 3 $maintenanceType records (avg. every $intervalKm km).';
    } else {
      return 'Based on 2 $maintenanceType records (avg. every $intervalKm km).';
    }
  }
}
