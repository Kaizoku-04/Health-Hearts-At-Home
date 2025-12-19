import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../models/themes.dart';

class CHDAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onToggleTheme;
  final bool isDark;

  const CHDAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.onToggleTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();

    return AppBar(
      elevation: 0,
      backgroundColor: customTheme[500],
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: [
        IconButton(
          icon: Icon(
            appService.currentLanguage == 'en'
                ? Icons.language
                : Icons.language,
            color: Colors.white,
          ),
          onPressed: () => appService.toggleLanguage(),
          tooltip: AppStrings.get('language', appService.currentLanguage),
        ),
        if (onToggleTheme != null)
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: onToggleTheme,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
