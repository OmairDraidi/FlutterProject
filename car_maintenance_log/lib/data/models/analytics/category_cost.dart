/// Data transfer object for cost distribution by maintenance category
/// Used for pie/doughnut chart visualization
class CategoryCost {
  final String category;
  final double totalCost;
  final int count;

  CategoryCost({
    required this.category,
    required this.totalCost,
    required this.count,
  });

  /// Returns the percentage of this category relative to a total
  double getPercentage(double grandTotal) {
    if (grandTotal == 0) return 0;
    return (totalCost / grandTotal) * 100;
  }

  /// Returns average cost per maintenance in this category
  double get averageCost {
    if (count == 0) return 0;
    return totalCost / count;
  }
}
