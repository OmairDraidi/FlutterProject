import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:car_maintenance_log/core/constants/app_constants.dart';
import 'package:car_maintenance_log/presentation/providers/analytics_providers.dart';

/// Analytics screen showing maintenance cost insights and charts
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page title and subtitle
              Text(
                'Analytics',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Insights about your maintenance costs',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Summary Cards Section
              _buildSummarySection(context, ref),
              const SizedBox(height: 24),

              // Bar Chart Section - Monthly Cost
              _buildMonthlyChartSection(context, ref),
              const SizedBox(height: 24),

              // Pie Chart Section - Category Distribution
              _buildCategoryChartSection(context, ref),
              const SizedBox(height: 24),

              // Line Chart Section - Trend
              _buildTrendChartSection(context, ref),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Summary Cards Section
  Widget _buildSummarySection(BuildContext context, WidgetRef ref) {
    final totalCostAsync = ref.watch(analyticsTotalCostProvider);
    final averageCostAsync = ref.watch(averageCostPerMonthProvider);
    final logCountAsync = ref.watch(analyticsLogCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: totalCostAsync.when(
                data: (cost) => _buildSummaryCard(
                  context,
                  icon: Icons.attach_money,
                  label: 'Total Spent',
                  value: '\$${cost.toStringAsFixed(2)}',
                  isPrimary: true,
                ),
                loading: () => _buildLoadingSummaryCard(context),
                error: (_, __) => _buildSummaryCard(
                  context,
                  icon: Icons.attach_money,
                  label: 'Total Spent',
                  value: '\$0.00',
                  isPrimary: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: averageCostAsync.when(
                data: (avg) => _buildSummaryCard(
                  context,
                  icon: Icons.trending_up,
                  label: 'Avg/Month',
                  value: '\$${avg.toStringAsFixed(2)}',
                  isPrimary: true,
                ),
                loading: () => _buildLoadingSummaryCard(context),
                error: (_, __) => _buildSummaryCard(
                  context,
                  icon: Icons.trending_up,
                  label: 'Avg/Month',
                  value: '\$0.00',
                  isPrimary: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: logCountAsync.when(
                data: (count) => _buildSummaryCard(
                  context,
                  icon: Icons.list_alt,
                  label: 'Total Logs',
                  value: count.toString(),
                  isPrimary: false,
                ),
                loading: () => _buildLoadingSummaryCard(context),
                error: (_, __) => _buildSummaryCard(
                  context,
                  icon: Icons.list_alt,
                  label: 'Total Logs',
                  value: '0',
                  isPrimary: false,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()), // Placeholder for symmetry
          ],
        ),
      ],
    );
  }

  /// Build summary card widget
  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isPrimary,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPrimary ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSummaryCard(BuildContext context) {
    return Card(
      child: Container(
        height: 100,
        alignment: Alignment.center,
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  /// Monthly Cost Bar Chart Section
  Widget _buildMonthlyChartSection(BuildContext context, WidgetRef ref) {
    final monthlyCostAsync = ref.watch(monthlyCostProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cost per Month',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Monthly spending breakdown',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: monthlyCostAsync.when(
              data: (monthlyCosts) {
                if (monthlyCosts.isEmpty) {
                  return _buildEmptyChartState(context);
                }

                final displayData = monthlyCosts
                    .take(6)
                    .toList()
                    .reversed
                    .toList();
                final maxCost = displayData
                    .map((e) => e.totalCost)
                    .reduce((a, b) => a > b ? a : b);

                return SizedBox(
                  height: 240,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxCost * 1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) =>
                              colorScheme.inverseSurface,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '\$${rod.toY.toStringAsFixed(2)}',
                              TextStyle(
                                color: colorScheme.onInverseSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < displayData.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    displayData[value.toInt()].monthLabel,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '\$${value.toInt()}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: colorScheme.outline.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      barGroups: displayData.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.totalCost,
                              color: colorScheme.primary,
                              width: 16,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => _buildLoadingChartState(),
              error: (_, __) => _buildErrorChartState(context),
            ),
          ),
        ),
      ],
    );
  }

  /// Category Distribution Pie Chart Section
  Widget _buildCategoryChartSection(BuildContext context, WidgetRef ref) {
    final categoryCostAsync = ref.watch(categoryCostProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cost by Category',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Spending distribution by maintenance type',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: categoryCostAsync.when(
              data: (categoryCosts) {
                if (categoryCosts.isEmpty) {
                  return _buildEmptyChartState(context);
                }

                final totalCost = categoryCosts.fold<double>(
                  0,
                  (sum, cat) => sum + cat.totalCost,
                );

                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 50,
                          sections: categoryCosts.asMap().entries.map((entry) {
                            final index = entry.key;
                            final category = entry.value;
                            final percentage =
                                (category.totalCost / totalCost * 100);

                            return PieChartSectionData(
                              value: category.totalCost,
                              title: '${percentage.toStringAsFixed(1)}%',
                              color: _getCategoryColor(context, index),
                              radius: 60,
                              titleStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Legend
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: categoryCosts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(context, index),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${category.category} (\$${category.totalCost.toStringAsFixed(0)})',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
              loading: () => _buildLoadingChartState(),
              error: (_, __) => _buildErrorChartState(context),
            ),
          ),
        ),
      ],
    );
  }

  /// Trend Line Chart Section
  Widget _buildTrendChartSection(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(trendProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cost Trend',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Cost changes over time',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: trendAsync.when(
              data: (trendPoints) {
                if (trendPoints.isEmpty) {
                  return _buildEmptyChartState(context);
                }

                final maxCost = trendPoints
                    .map((e) => e.cost)
                    .reduce((a, b) => a > b ? a : b);
                final minCost = trendPoints
                    .map((e) => e.cost)
                    .reduce((a, b) => a < b ? a : b);

                return SizedBox(
                  height: 240,
                  child: LineChart(
                    LineChartData(
                      minY: minCost > 0 ? 0 : minCost * 1.1,
                      maxY: maxCost * 1.2,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) =>
                              colorScheme.inverseSurface,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final point = trendPoints[spot.spotIndex];
                              return LineTooltipItem(
                                '\$${point.cost.toStringAsFixed(2)}\n${DateFormat('MMM dd').format(point.date)}',
                                TextStyle(
                                  color: colorScheme.onInverseSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (trendPoints.length / 4).ceilToDouble(),
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < trendPoints.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateFormat(
                                      'MMM',
                                    ).format(trendPoints[value.toInt()].date),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '\$${value.toInt()}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: colorScheme.outline.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: trendPoints.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.cost,
                            );
                          }).toList(),
                          isCurved: true,
                          color: colorScheme.tertiary,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: colorScheme.tertiary,
                                strokeWidth: 2,
                                strokeColor: colorScheme.surface,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: colorScheme.tertiary.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => _buildLoadingChartState(),
              error: (_, __) => _buildErrorChartState(context),
            ),
          ),
        ),
      ],
    );
  }

  /// Build empty state for charts
  Widget _buildEmptyChartState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights_outlined,
              size: 40,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text('Not enough data yet', style: textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              'Add more maintenance logs to see analytics',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingChartState() {
    return const SizedBox(
      height: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorChartState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 200,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 20),
            const SizedBox(width: 8),
            Text(
              'Failed to load analytics',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }

  /// Get color for category pie chart using theme colors
  Color _getCategoryColor(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];
    return colors[index % colors.length];
  }
}
