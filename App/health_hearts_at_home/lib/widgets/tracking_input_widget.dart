import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController _feedingAmountController = TextEditingController();
  final TextEditingController _oxygenController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Theme Constants (Matching your other pages)
  static const Color accentColor = Color(0xFF3A1C71); // Royal Purple

  @override
  Widget build(BuildContext context) {
    // Dynamic Theme Check
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colors
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final inputFillColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F7);
    final primaryText = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER ---
            Text(
              "New Entry",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 20),

            // --- DATE PICKER (Styled as a card) ---
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: accentColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('date', widget.language),
                            style: TextStyle(
                                fontSize: 12,
                                color: secondaryText,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('yyyy-MM-dd').format(_selectedDate),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryText
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit, size: 18, color: secondaryText),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- ROW 1: Weight & Oxygen ---
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _weightController,
                    label: AppStrings.get('weight', widget.language),
                    icon: Icons.monitor_weight_outlined,
                    isNumber: true,
                    isDark: isDark,
                    fillColor: inputFillColor,
                    textColor: primaryText,
                    hintText: "kg",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _oxygenController,
                    label: "O2 Saturation", // Shortened for fit
                    icon: Icons.air,
                    isNumber: true,
                    isDark: isDark,
                    fillColor: inputFillColor,
                    textColor: primaryText,
                    hintText: "%",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Feeding Section ---
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: inputFillColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Feeding Type Dropdown
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _feedingType,
                      icon: Icon(Icons.arrow_drop_down_circle, color: secondaryText),
                      dropdownColor: cardColor,
                      decoration: InputDecoration(
                        labelText: AppStrings.get('feedingType', widget.language),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        labelStyle: TextStyle(color: secondaryText),
                      ),
                      style: TextStyle(
                        color: primaryText,
                        fontWeight: FontWeight.bold,
                        fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
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
                      onChanged: (value) => setState(() => _feedingType = value!),
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                  // Feeding Amount Input
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _feedingAmountController,
                      style: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppStrings.get('feedingAmount', widget.language),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        labelStyle: TextStyle(color: secondaryText),
                        suffixText: "ml",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Equipment ---
            _buildTextField(
              controller: _equipmentController,
              label: AppStrings.get('equipment', widget.language),
              icon: Icons.medical_services_outlined,
              isDark: isDark,
              fillColor: inputFillColor,
              textColor: primaryText,
            ),
            const SizedBox(height: 16),

            // --- Notes ---
            _buildTextField(
              controller: _notesController,
              label: AppStrings.get('notes', widget.language),
              icon: Icons.note_alt_outlined,
              isDark: isDark,
              fillColor: inputFillColor,
              textColor: primaryText,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // --- SAVE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: accentColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _saveEntry,
                child: Text(
                  AppStrings.get('save', widget.language),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER: Custom Text Field ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color fillColor,
    required Color textColor,
    bool isNumber = false,
    int maxLines = 1,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: maxLines > 1
            ? Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: Icon(icon, color: Colors.grey[500])
        )
            : Icon(icon, color: Colors.grey[500]),
        filled: true,
        fillColor: fillColor,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none, // Clean look
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Customize Date Picker Colors to match theme
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: accentColor, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: const Color(0xFF1D1D1F), // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  void _saveEntry() {
    // 1. Force the keyboard to close immediately
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // 2. Wrap the callback in a tiny delay to let the keyboard animation finish
      Future.delayed(const Duration(milliseconds: 100), () {
        widget.onSave({
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'weight': _weightController.text,
          'feedingAmount': _feedingAmountController.text,
          'feedingType': _feedingType,
          'oxygenSaturation': _oxygenController.text,
          'equipment': _equipmentController.text,
          'notes': _notesController.text,
        });
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