import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:car_maintenance_log/core/constants/app_constants.dart';
import 'package:car_maintenance_log/core/utils/error_handler.dart';
import 'package:car_maintenance_log/data/models/reminder.dart';
import 'package:car_maintenance_log/presentation/providers/reminder_provider.dart';
import 'package:car_maintenance_log/presentation/providers/vehicle_provider.dart';

class AddEditReminderScreen extends ConsumerStatefulWidget {
  final Reminder? reminder;

  const AddEditReminderScreen({super.key, this.reminder});

  @override
  ConsumerState<AddEditReminderScreen> createState() =>
      _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends ConsumerState<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _mileageController;
  String? _selectedType;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reminder?.title);
    _mileageController = TextEditingController(
      text: widget.reminder?.dueMileage?.toString() ?? '',
    );
    _selectedType = widget.reminder?.type;
    _selectedDate = widget.reminder?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a maintenance type')),
        );
        return;
      }
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a due date')),
        );
        return;
      }

      final vehicle = ref.read(firstVehicleProvider).value;
      if (vehicle == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No vehicle selected')));
        return;
      }

      final reminder = widget.reminder ?? Reminder()
        ..vehicleId = vehicle.id
        ..createdAt = DateTime.now();

      reminder
        ..title = _titleController.text
        ..type = _selectedType!
        ..dueDate = _selectedDate!
        ..dueMileage = int.tryParse(_mileageController.text);

      final notifier = ref.read(reminderNotifierProvider.notifier);

      try {
        if (widget.reminder == null) {
          await notifier.addReminder(reminder);
        } else {
          await notifier.updateReminder(reminder);
        }

        if (mounted) {
          Navigator.pop(context);
          ErrorHandler.showSuccess(
            context,
            widget.reminder != null
                ? 'Reminder updated successfully'
                : 'Reminder set successfully',
          );
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showError(context, 'Error saving reminder: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Reminder' : 'Add Reminder')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Maintenance Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Maintenance Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: MaintenanceTypes.all.map((type) {
                  final typeData = MaintenanceTypes.getTypeData(type);
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(typeData.icon, color: typeData.color, size: 20),
                        const SizedBox(width: 10),
                        Text(type),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                    if (_titleController.text.isEmpty) {
                      _titleController.text = value!;
                    }
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a type' : null,
              ),
              const SizedBox(height: 16),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Due Date Picker
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : DateFormat.yMMMd().format(_selectedDate!),
                    style: TextStyle(
                      color: _selectedDate == null
                          ? Theme.of(context).hintColor
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Due Mileage Field (Optional)
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Due Mileage (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed),
                  suffixText: 'km',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Save Button
              FilledButton.icon(
                onPressed: _saveReminder,
                icon: const Icon(Icons.save),
                label: Text(isEditing ? 'Update Reminder' : 'Set Reminder'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
