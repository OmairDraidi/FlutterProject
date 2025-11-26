/// Domain DTO for predicted maintenance
/// This is a pure data transfer object with no Isar annotations
class PredictedMaintenance {
  /// Type of maintenance (e.g., "Oil Change", "Brake Inspection")
  final String maintenanceType;

  /// Estimated mileage when maintenance is due
  final double? estimatedNextMileage;

  /// Estimated date when maintenance is due
  final DateTime? estimatedNextDate;

  /// Confidence score for this prediction (0.0 to 1.0)
  /// - 0.8-1.0: High confidence
  /// - 0.5-0.8: Medium confidence
  /// - <0.5: Low confidence
  final double confidenceScore;

  /// Human-readable explanation of how this prediction was made
  final String? explanation;

  const PredictedMaintenance({
    required this.maintenanceType,
    this.estimatedNextMileage,
    this.estimatedNextDate,
    required this.confidenceScore,
    this.explanation,
  });

  /// Copy with method for immutability
  PredictedMaintenance copyWith({
    String? maintenanceType,
    double? estimatedNextMileage,
    DateTime? estimatedNextDate,
    double? confidenceScore,
    String? explanation,
  }) {
    return PredictedMaintenance(
      maintenanceType: maintenanceType ?? this.maintenanceType,
      estimatedNextMileage: estimatedNextMileage ?? this.estimatedNextMileage,
      estimatedNextDate: estimatedNextDate ?? this.estimatedNextDate,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      explanation: explanation ?? this.explanation,
    );
  }

  @override
  String toString() {
    return 'PredictedMaintenance(type: $maintenanceType, nextMileage: $estimatedNextMileage, nextDate: $estimatedNextDate, confidence: $confidenceScore)';
  }
}
