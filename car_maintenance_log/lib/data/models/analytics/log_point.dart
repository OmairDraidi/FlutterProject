/// Data transfer object for individual log points in trend analysis
/// Used for line chart visualization of cost trends over time
class LogPoint {
  final DateTime date;
  final double cost;

  LogPoint({required this.date, required this.cost});

  /// Returns the day of the year (1-365/366) for x-axis positioning
  int get dayOfYear {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    return date.difference(firstDayOfYear).inDays + 1;
  }

  /// Returns milliseconds since epoch for x-axis positioning
  double get timestamp {
    return date.millisecondsSinceEpoch.toDouble();
  }

  /// Returns a formatted date string
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }
}
