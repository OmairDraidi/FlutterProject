/// Data transfer object for monthly cost aggregation
/// Used for bar chart visualization of spending trends
class MonthlyCost {
  final int year;
  final int month;
  final double totalCost;

  MonthlyCost({
    required this.year,
    required this.month,
    required this.totalCost,
  });

  /// Returns a formatted month-year string (e.g., "Jan 2024")
  String get monthYearLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[month - 1]} $year';
  }

  /// Returns a short month label (e.g., "Jan")
  String get monthLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
