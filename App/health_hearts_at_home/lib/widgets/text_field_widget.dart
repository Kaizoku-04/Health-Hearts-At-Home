import 'package:health_hearts_at_home/models/themes.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final bool isDark;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.prefixIcon,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.textInputAction = TextInputAction.next,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          prefixIcon,
          color: (isDark ? Colors.white : Colors.black),
        ),
        labelStyle: TextStyle(color: (isDark ? Colors.white : Colors.black)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: customTheme, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: customTheme, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }
}
