import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:car_maintenance_log/core/constants/app_constants.dart';
import 'package:car_maintenance_log/core/utils/error_handler.dart';
import 'package:car_maintenance_log/data/models/maintenance_log.dart';
import 'package:car_maintenance_log/presentation/providers/maintenance_log_provider.dart';
import 'package:car_maintenance_log/presentation/providers/vehicle_provider.dart';

/// Screen for adding or editing a maintenance log
class AddEditLogScreen extends ConsumerStatefulWidget {
  final MaintenanceLog? log;

  const AddEditLogScreen({super.key, this.log});

  @override
  ConsumerState<AddEditLogScreen> createState() => _AddEditLogScreenState();
}

class _AddEditLogScreenState extends ConsumerState<AddEditLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _costController = TextEditingController();
  final _mileageController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = MaintenanceTypes.oilChange;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.log != null) {
      _titleController.text = widget.log!.title;
      _costController.text = widget.log!.cost.toString();
      _mileageController.text = widget.log!.mileage.toString();
      _notesController.text = widget.log!.notes;
      _selectedType = widget.log!.type;
      _selectedDate = widget.log!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.log != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Scaffold(
            appBar: AppBar(
              title: Text(isEdit ? 'Edit Log' : 'Add Maintenance Log'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppConstants.spacing16),
                children: [
                  // Maintenance Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Maintenance Type',
                      prefixIcon: Icon(
                        IconData(
                          MaintenanceTypes.getIconCodePoint(_selectedType),
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Color(
                          MaintenanceTypes.getColorValue(_selectedType),
                        ),
                      ),
                    ),
                    items: MaintenanceTypes.all.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(
                              IconData(
                                MaintenanceTypes.getIconCodePoint(type),
                                fontFamily: 'MaterialIcons',
                              ),
                              color: Color(
                                MaintenanceTypes.getColorValue(type),
                              ),
                              size: 20,
                            ),
                            const SizedBox(width: AppConstants.spacing12),
                            Text(type),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing16),

                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g., Regular oil change',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing16),

                  // Cost
                  TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: 'Cost',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the cost';
                      }
                      final cost = double.tryParse(value);
                      if (cost == null || cost < 0) {
                        return 'Please enter a valid cost';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing16),

                  // Mileage
                  TextFormField(
                    controller: _mileageController,
                    decoration: const InputDecoration(
                      labelText: 'Mileage (km)',
                      hintText: 'Current odometer reading',
                      prefixIcon: Icon(Icons.speed),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the mileage';
                      }
                      final mileage = int.tryParse(value);
                      if (mileage == null || mileage < 0) {
                        return 'Please enter a valid mileage';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing16),

                  // Date Picker
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('MMMM dd, yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing16),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Additional details...',
                      prefixIcon: Icon(Icons.notes),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: AppConstants.spacing24),

                  // Save Button
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _saveLog,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(isEdit ? Icons.save : Icons.add),
                    label: Text(isEdit ? 'Update Log' : 'Add Log'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final vehicleAsync = ref.read(firstVehicleProvider);
      final vehicle = vehicleAsync.value;

      if (vehicle == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please add a vehicle first')),
          );
        }
        return;
      }

      final log = MaintenanceLog()
        ..vehicleId = vehicle.id
        ..type = _selectedType
        ..title = _titleController.text.trim()
        ..cost = double.parse(_costController.text.trim())
        ..mileage = int.parse(_mileageController.text.trim())
        ..date = _selectedDate
        ..notes = _notesController.text.trim()
        ..createdAt = widget.log?.createdAt ?? DateTime.now();

      if (widget.log != null) {
        log.id = widget.log!.id;
        await ref.read(maintenanceLogNotifierProvider.notifier).updateLog(log);
      } else {
        await ref.read(maintenanceLogNotifierProvider.notifier).addLog(log);
      }

      if (mounted) {
        Navigator.pop(context);
        ErrorHandler.showSuccess(
          context,
          widget.log != null
              ? 'Log updated successfully'
              : 'Log added successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
