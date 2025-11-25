import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:car_maintenance_log/core/constants/app_constants.dart';
import 'package:car_maintenance_log/data/models/maintenance_log.dart';
import 'package:car_maintenance_log/presentation/providers/maintenance_log_provider.dart';
import 'package:car_maintenance_log/presentation/screens/add_edit_log_screen.dart';

/// Timeline screen - displays maintenance logs in chronological order
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(maintenanceLogsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Timeline')),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildTimelineContent(context, logs, ref);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Failed to load logs',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'timeline_fab',
        onPressed: () => _showAddLogSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Log'),
      ),
    );
  }

  Widget _buildTimelineContent(
    BuildContext context,
    List<MaintenanceLog> logs,
    WidgetRef ref,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(maintenanceLogsStreamProvider);
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Page title and subtitle
          const SizedBox(height: 12),
          Text(
            'Maintenance Timeline',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Your complete service history',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Log cards with animations
          ...logs.asMap().entries.map((entry) {
            final index = entry.key;
            final log = entry.value;
            return _buildAnimatedLogCard(context, log, index, ref);
          }),

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildAnimatedLogCard(
    BuildContext context,
    MaintenanceLog log,
    int index,
    WidgetRef ref,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: Duration(milliseconds: 220 + (index * 30)),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Opacity(opacity: scale, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildLogCard(context, log, ref),
      ),
    );
  }

  Widget _buildLogCard(
    BuildContext context,
    MaintenanceLog log,
    WidgetRef ref,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get maintenance type icon and color
    final typeData = MaintenanceTypes.getTypeData(log.type);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(isDark ? 0.2 : 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showEditLogSheet(context, log),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Leading icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  typeData.icon,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title: log title
                    Text(
                      log.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Subtitle: date + mileage
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(log.date)} • ${log.mileage.toStringAsFixed(0)} km',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Cost (right aligned)
              Text(
                log.formattedCost,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No maintenance logs yet',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first service record to begin tracking',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddLogSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add First Log'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddEditLogScreen(),
    );
  }

  void _showEditLogSheet(BuildContext context, MaintenanceLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddEditLogScreen(log: log),
    );
  }
}
