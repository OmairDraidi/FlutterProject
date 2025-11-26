import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:car_maintenance_log/core/constants/app_constants.dart';
import 'package:car_maintenance_log/data/models/reminder.dart';
import 'package:car_maintenance_log/presentation/providers/reminder_provider.dart';
import 'package:car_maintenance_log/presentation/providers/smart/smart_prediction_providers.dart';
import 'package:car_maintenance_log/presentation/screens/add_edit_reminder_screen.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(upcomingRemindersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance Reminders')),
      body: CustomScrollView(
        slivers: [
          // Smart Suggestions Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Suggestions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI-powered maintenance reminders based on your driving pattern',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (context, ref, child) {
                      final predictionsAsync = ref.watch(
                        smartPredictedMaintenancesProvider,
                      );

                      return predictionsAsync.when(
                        data: (predictions) {
                          if (predictions.isEmpty) {
                            return _buildEmptySmartSuggestions(context);
                          }

                          return Column(
                            children: predictions.map((prediction) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildSmartSuggestionCard(
                                  context,
                                  prediction,
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => _buildLoadingSmartSuggestions(context),
                        error: (_, __) => _buildErrorSmartSuggestions(context),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your Reminders',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Manual Reminders List
          remindersAsync.when(
            data: (reminders) {
              if (reminders.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No upcoming reminders',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add a reminder to stay on track',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final reminder = reminders[index];
                    final typeData = MaintenanceTypes.getTypeData(
                      reminder.type,
                    );
                    final isOverdue = reminder.dueDate.isBefore(DateTime.now());

                    return Dismissible(
                      key: Key(reminder.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Theme.of(context).colorScheme.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Reminder?'),
                            content: const Text(
                              'Are you sure you want to delete this reminder?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        ref
                            .read(reminderNotifierProvider.notifier)
                            .deleteReminder(reminder);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reminder deleted')),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: typeData.color.withOpacity(0.2),
                            child: Icon(typeData.icon, color: typeData.color),
                          ),
                          title: Text(
                            reminder.title,
                            style: TextStyle(
                              decoration: reminder.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due: ${DateFormat.yMMMd().format(reminder.dueDate)}',
                                style: TextStyle(
                                  color: isOverdue
                                      ? Theme.of(context).colorScheme.error
                                      : null,
                                  fontWeight: isOverdue
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                              if (reminder.dueMileage != null)
                                Text('Target: ${reminder.dueMileage} km'),
                            ],
                          ),
                          trailing: Checkbox(
                            value: reminder.isCompleted,
                            onChanged: (value) {
                              if (value == true) {
                                ref
                                    .read(reminderNotifierProvider.notifier)
                                    .completeReminder(reminder);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Reminder marked as completed',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddEditReminderScreen(reminder: reminder),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }, childCount: reminders.length),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'reminders_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditReminderScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_alert),
        label: const Text('Add Reminder'),
      ),
    );
  }

  Widget _buildSmartSuggestionCard(BuildContext context, prediction) {
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
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: colorScheme.tertiary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction.maintenanceType,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Mileage and date info
                if (prediction.estimatedNextMileage != null ||
                    prediction.estimatedNextDate != null)
                  Text(
                    [
                      if (prediction.estimatedNextMileage != null)
                        'Around ${prediction.estimatedNextMileage!.round()} km',
                      if (prediction.estimatedNextDate != null)
                        _formatDate(prediction.estimatedNextDate!),
                    ].join(' • '),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                // Explanation
                if (prediction.explanation != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    prediction.explanation!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // AI Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'AI',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySmartSuggestions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 40,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'No smart suggestions yet',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add more maintenance logs to enable AI insights',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSmartSuggestions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading smart suggestions...',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSmartSuggestions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Couldn\'t load smart suggestions',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return 'In $difference days';
    } else if (difference < 14) {
      return 'In ~${(difference / 7).round()} week';
    } else if (difference < 30) {
      return 'In ~${(difference / 7).round()} weeks';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}
