import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:car_maintenance_log/core/constants/app_constants.dart';
import 'package:car_maintenance_log/presentation/providers/vehicle_provider.dart';
import 'package:car_maintenance_log/presentation/providers/maintenance_log_provider.dart';
import 'package:car_maintenance_log/presentation/providers/reminder_provider.dart';
import 'package:car_maintenance_log/presentation/providers/analytics_providers.dart';
import 'package:car_maintenance_log/presentation/providers/theme_mode_provider.dart';
import 'package:car_maintenance_log/presentation/screens/add_edit_vehicle_screen.dart';
import 'package:car_maintenance_log/presentation/screens/reminders_screen.dart';
import 'package:car_maintenance_log/presentation/screens/timeline_screen.dart';
import 'package:car_maintenance_log/presentation/screens/analytics_screen.dart';
import 'package:car_maintenance_log/presentation/providers/smart/smart_prediction_providers.dart';

/// Dashboard screen - main overview of vehicle maintenance
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.dashboardTitle),
        actions: [
          // Theme toggle button
          Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeModeProvider);
              IconData icon;
              String tooltip;

              if (themeMode == ThemeMode.dark) {
                icon = Icons.dark_mode;
                tooltip = 'Dark Mode';
              } else if (themeMode == ThemeMode.light) {
                icon = Icons.light_mode;
                tooltip = 'Light Mode';
              } else {
                icon = Icons.brightness_auto;
                tooltip = 'System Mode';
              }

              return IconButton(
                icon: Icon(icon),
                tooltip: tooltip,
                onPressed: () {
                  ref.read(themeModeProvider.notifier).toggle();
                },
              );
            },
          ),
          // Edit vehicle button
          vehicleAsync.when(
            data: (vehicle) => vehicle != null
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Vehicle',
                    onPressed: () => _navigateToAddEdit(context, vehicle),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: vehicleAsync.when(
        data: (vehicle) {
          if (vehicle == null) {
            return _buildEmptyState(context);
          }
          return _buildDashboardContent(context, vehicle);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: AppConstants.spacing16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
      floatingActionButton: vehicleAsync.when(
        data: (vehicle) => vehicle == null
            ? FloatingActionButton.extended(
                heroTag: 'dashboard_fab',
                onPressed: () => _navigateToAddEdit(context, null),
                icon: const Icon(Icons.add),
                label: const Text('Add Vehicle'),
              )
            : null,
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: AppConstants.spacing24),
            Text(
              'No Vehicle Added',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Add your vehicle to start tracking maintenance',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing32),
            FilledButton.icon(
              onPressed: () => _navigateToAddEdit(context, null),
              icon: const Icon(Icons.add),
              label: const Text('Add Your Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, vehicle) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      children: [
        // Vehicle Info Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMedium,
                        ),
                      ),
                      child: Hero(
                        tag: 'vehicle_icon_${vehicle.id}',
                        child: Icon(
                          Icons.directions_car,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.displayName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${vehicle.mileage.toStringAsFixed(0)} km',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing24),

        // Smart Insights Section
        Text(
          'Smart Insights',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.spacing12),
        Consumer(
          builder: (context, ref, child) {
            final predictionAsync = ref.watch(nextPredictedMaintenanceProvider);

            return predictionAsync.when(
              data: (prediction) {
                final colorScheme = Theme.of(context).colorScheme;
                final textTheme = Theme.of(context).textTheme;

                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prediction == null
                                  ? 'No Smart Insights Yet'
                                  : 'Next Suggested Maintenance',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (prediction != null) ...[
                              Text(
                                prediction.maintenanceType,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (prediction.estimatedNextMileage != null)
                                Text(
                                  'At ~${prediction.estimatedNextMileage!.round()} km',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              if (prediction.explanation != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  prediction.explanation!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ] else ...[
                              Text(
                                'Add more maintenance logs to enable smart insights.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
        ),
        const SizedBox(height: AppConstants.spacing24),

        // Summary Cards with real data
        Consumer(
          builder: (context, ref, child) {
            final logCountAsync = ref.watch(logCountProvider);
            final totalCostAsync = ref.watch(totalCostProvider);
            final upcomingRemindersCountAsync = ref.watch(
              upcomingRemindersCountProvider,
            );

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: logCountAsync.when(
                        data: (count) => _buildSummaryCard(
                          context,
                          icon: Icons.build,
                          title: 'Total Logs',
                          value: count.toString(),
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TimelineScreen(),
                              ),
                            );
                          },
                        ),
                        loading: () => _buildSummaryCard(
                          context,
                          icon: Icons.build,
                          title: 'Total Logs',
                          value: '...',
                          color: Colors.blue,
                        ),
                        error: (_, __) => _buildSummaryCard(
                          context,
                          icon: Icons.build,
                          title: 'Total Logs',
                          value: '0',
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: totalCostAsync.when(
                        data: (cost) => _buildSummaryCard(
                          context,
                          icon: Icons.attach_money,
                          title: 'Total Cost',
                          value: '\$${cost.toStringAsFixed(0)}',
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TimelineScreen(),
                              ),
                            );
                          },
                        ),
                        loading: () => _buildSummaryCard(
                          context,
                          icon: Icons.attach_money,
                          title: 'Total Cost',
                          value: '...',
                          color: Colors.green,
                        ),
                        error: (_, __) => _buildSummaryCard(
                          context,
                          icon: Icons.attach_money,
                          title: 'Total Cost',
                          value: '\$0',
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing12),
                Row(
                  children: [
                    Expanded(
                      child: upcomingRemindersCountAsync.when(
                        data: (count) => _buildSummaryCard(
                          context,
                          icon: Icons.notifications_active,
                          title: 'Reminders',
                          value: count.toString(),
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RemindersScreen(),
                              ),
                            );
                          },
                        ),
                        loading: () => _buildSummaryCard(
                          context,
                          icon: Icons.notifications_active,
                          title: 'Reminders',
                          value: '...',
                          color: Colors.orange,
                        ),
                        error: (_, __) => _buildSummaryCard(
                          context,
                          icon: Icons.notifications_active,
                          title: 'Reminders',
                          value: '0',
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final totalSpentAsync = ref.watch(
                            analyticsTotalCostProvider,
                          );
                          return totalSpentAsync.when(
                            data: (cost) => _buildSummaryCard(
                              context,
                              icon: Icons.analytics,
                              title: 'Total Spent',
                              value: '\$${cost.toStringAsFixed(0)}',
                              color: Colors.teal,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AnalyticsScreen(),
                                  ),
                                );
                              },
                            ),
                            loading: () => _buildSummaryCard(
                              context,
                              icon: Icons.analytics,
                              title: 'Total Spent',
                              value: '...',
                              color: Colors.teal,
                            ),
                            error: (_, __) => _buildSummaryCard(
                              context,
                              icon: Icons.analytics,
                              title: 'Total Spent',
                              value: '\$0',
                              color: Colors.teal,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppConstants.spacing24),

        // Next Reminder Section
        Consumer(
          builder: (context, ref, child) {
            final nextReminderAsync = ref.watch(nextReminderProvider);

            return nextReminderAsync.when(
              data: (reminder) {
                if (reminder == null) return const SizedBox.shrink();

                final typeData = MaintenanceTypes.getTypeData(reminder.type);
                final isOverdue = reminder.dueDate.isBefore(DateTime.now());

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Reminder',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing12),
                    Card(
                      color: isOverdue
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RemindersScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.spacing16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: typeData.color.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  typeData.icon,
                                  color: typeData.color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacing16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reminder.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isOverdue
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.onErrorContainer
                                                : null,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Due: ${DateFormat.yMMMd().format(reminder.dueDate)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: isOverdue
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.onErrorContainer
                                                : null,
                                            fontWeight: isOverdue
                                                ? FontWeight.bold
                                                : null,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: isOverdue
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer
                                    : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing24),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
        ),

        // Last Maintenance Section
        Text(
          'Last Maintenance',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.spacing12),
        Consumer(
          builder: (context, ref, child) {
            final lastLogAsync = ref.watch(lastLogProvider);

            return lastLogAsync.when(
              data: (log) {
                if (log == null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacing24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.timeline_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: AppConstants.spacing8),
                            Text(
                              'No maintenance logs yet',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final typeData = MaintenanceTypes.getTypeData(log.type);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacing16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: typeData.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            typeData.icon,
                            color: typeData.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${log.type} • ${DateFormat('MMM dd, yyyy').format(log.date)}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          log.formattedCost,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.spacing24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, __) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing24),
                  child: Center(
                    child: Text(
                      'Error loading last maintenance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppConstants.spacing24),

        // Analytics Section
        Text(
          'Analytics',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.spacing12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'View Analytics',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'See cost per month, categories & trends',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToAddEdit(BuildContext context, vehicle) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditVehicleScreen(vehicle: vehicle),
      ),
    );

    // Refresh is handled automatically by Riverpod
    if (result == true) {
      // Vehicle was saved successfully
    }
  }
}
