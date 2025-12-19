import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/themes.dart';
import '../services/localization_service.dart';

class TrackingInputWidget extends StatefulWidget {
  final String language;
  final Function(Map<String, dynamic>) onSave;

  const TrackingInputWidget({
    super.key,
    required this.language,
    required this.onSave,
  });

  @override
  State<TrackingInputWidget> createState() => _TrackingInputWidgetState();
}

class _TrackingInputWidgetState extends State<TrackingInputWidget> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String _feedingType = 'breast';

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _feedingAmountController =
      TextEditingController();
  final TextEditingController _oxygenController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Picker
              ListTile(
                title: Text(
                  AppStrings.get('date', widget.language),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('weight', widget.language),
                  prefixIcon: const Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Feeding Type
              DropdownButtonFormField<String>(
                value: _feedingType,
                decoration: InputDecoration(
                  labelText: AppStrings.get('feedingType', widget.language),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'breast',
                    child: Text(AppStrings.get('breast', widget.language)),
                  ),
                  DropdownMenuItem(
                    value: 'bottle',
                    child: Text(AppStrings.get('bottle', widget.language)),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _feedingType = value!);
                },
              ),
              const SizedBox(height: 16),

              // Feeding Amount
              TextFormField(
                controller: _feedingAmountController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('feedingAmount', widget.language),
                  prefixIcon: const Icon(Icons.local_drink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Oxygen Saturation
              TextFormField(
                controller: _oxygenController,
                decoration: InputDecoration(
                  labelText: AppStrings.get(
                    'oxygenSaturation',
                    widget.language,
                  ),
                  prefixIcon: const Icon(Icons.favorite),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Equipment
              TextFormField(
                controller: _equipmentController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('equipment', widget.language),
                  prefixIcon: const Icon(Icons.medical_services),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('notes', widget.language),
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: customTheme[500],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveEntry,
                child: Text(
                  AppStrings.get('save', widget.language),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      widget.onSave({
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'weight': _weightController.text,
        'feedingAmount': _feedingAmountController.text,
        'feedingType': _feedingType,
        'oxygenSaturation': _oxygenController.text,
        'equipment': _equipmentController.text,
        'notes': _notesController.text,
      });
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _feedingAmountController.dispose();
    _oxygenController.dispose();
    _equipmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
