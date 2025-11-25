import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:car_maintenance_log/core/constants/app_constants.dart';
import 'package:car_maintenance_log/data/models/reminder.dart';
import 'package:car_maintenance_log/presentation/providers/reminder_provider.dart';
import 'package:car_maintenance_log/presentation/screens/add_edit_reminder_screen.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(upcomingRemindersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance Reminders')),
      body: remindersAsync.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No upcoming reminders',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Add a reminder to stay on track'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              final typeData = MaintenanceTypes.getTypeData(reminder.type);
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
                            fontWeight: isOverdue ? FontWeight.bold : null,
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
                              content: Text('Reminder marked as completed'),
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
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
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
}
