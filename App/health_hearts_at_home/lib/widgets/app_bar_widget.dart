import 'package:flutter/material.dart';

class CHDAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback onToggleTheme;
  final bool isDark;

  // Add these two new optional fields
  final Color? backgroundColor;
  final Color? textColor;

  const CHDAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    required this.onToggleTheme,
    required this.isDark,
    // Add them to the constructor
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Use the passed background color, or fall back to the default transparent/white
      backgroundColor: backgroundColor ?? (isDark ? Colors.grey[900] : Colors.white),
      elevation: 0,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
        icon: Icon(Icons.arrow_back_ios, color: textColor ?? (isDark ? Colors.white : Colors.black)),
        onPressed: () => Navigator.pop(context),
      )
          : null,
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? (isDark ? Colors.white : Colors.black),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: textColor ?? (isDark ? Colors.white : Colors.black),
          ),
          onPressed: onToggleTheme,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}