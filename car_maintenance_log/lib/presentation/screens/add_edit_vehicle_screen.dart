import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:car_maintenance_log/core/constants/app_constants.dart';
import 'package:car_maintenance_log/core/utils/error_handler.dart';
import 'package:car_maintenance_log/data/models/vehicle.dart';
import 'package:car_maintenance_log/presentation/providers/vehicle_provider.dart';

/// Screen for adding or editing a vehicle
class AddEditVehicleScreen extends ConsumerStatefulWidget {
  final Vehicle? vehicle;

  const AddEditVehicleScreen({super.key, this.vehicle});

  @override
  ConsumerState<AddEditVehicleScreen> createState() =>
      _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends ConsumerState<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();

  bool get isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _makeController.text = widget.vehicle!.make;
      _modelController.text = widget.vehicle!.model;
      _yearController.text = widget.vehicle!.year.toString();
      _mileageController.text = widget.vehicle!.mileage.toString();
    }
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vehicle = Vehicle()
      ..id = widget.vehicle?.id ?? 0
      ..make = _makeController.text.trim()
      ..model = _modelController.text.trim()
      ..year = int.parse(_yearController.text)
      ..mileage = int.parse(_mileageController.text)
      ..createdAt = widget.vehicle?.createdAt ?? DateTime.now();

    try {
      if (isEditing) {
        await ref.read(vehicleNotifierProvider.notifier).updateVehicle(vehicle);
      } else {
        await ref.read(vehicleNotifierProvider.notifier).addVehicle(vehicle);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ErrorHandler.showSuccess(
          context,
          isEditing
              ? 'Vehicle updated successfully'
              : 'Vehicle added successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, 'Error saving vehicle: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Vehicle' : 'Add Vehicle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          children: [
            // Vehicle icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Hero(
                  tag: 'vehicle_icon_${widget.vehicle?.id ?? 'new'}',
                  child: Icon(
                    Icons.directions_car,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing32),

            // Make field
            TextFormField(
              controller: _makeController,
              decoration: const InputDecoration(
                labelText: 'Make',
                hintText: 'e.g., Toyota, Honda, Ford',
                prefixIcon: Icon(Icons.business),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter vehicle make';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacing16),

            // Model field
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model',
                hintText: 'e.g., Camry, Civic, F-150',
                prefixIcon: Icon(Icons.car_rental),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter vehicle model';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacing16),

            // Year field
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                hintText: 'e.g., 2020',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vehicle year';
                }
                final year = int.tryParse(value);
                if (year == null) {
                  return 'Please enter a valid year';
                }
                final currentYear = DateTime.now().year;
                if (year < 1900 || year > currentYear + 1) {
                  return 'Please enter a year between 1900 and ${currentYear + 1}';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacing16),

            // Mileage field
            TextFormField(
              controller: _mileageController,
              decoration: const InputDecoration(
                labelText: 'Current Mileage (km)',
                hintText: 'e.g., 50000',
                prefixIcon: Icon(Icons.speed),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter current mileage';
                }
                final mileage = int.tryParse(value);
                if (mileage == null || mileage < 0) {
                  return 'Please enter a valid mileage';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacing32),

            // Save button
            FilledButton.icon(
              onPressed: _saveVehicle,
              icon: const Icon(Icons.save),
              label: Text(isEditing ? 'Update Vehicle' : 'Add Vehicle'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
