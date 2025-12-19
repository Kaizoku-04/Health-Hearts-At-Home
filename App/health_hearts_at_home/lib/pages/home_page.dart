import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/themes.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/home_menu_button.dart';
import 'general_childcare_page.dart';
import 'tutorials_page.dart';
import 'spiritual_page.dart';
import 'hospital_info_page.dart';
import 'caregiver_support_page.dart';
import 'track_child_page.dart';
import 'about_chd_page.dart';
import 'contacts_page.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const HomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    return Scaffold(
      appBar: CHDAppBar(
        title: AppStrings.get('appTitle', lang),
        showBackButton: false,
        onToggleTheme: onToggleTheme,
        isDark: isDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.get('welcome', lang),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: customTheme[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an option below to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                HomeMenuButton(
                  label: AppStrings.get('trackChild', lang),
                  icon: Icons.track_changes,
                  onPressed: () => _navigateTo(
                    context,
                    TrackChildPage(
                      isDark: isDark,
                      onToggleTheme: onToggleTheme,
                    ),
                  ),
                ),
                HomeMenuButton(
                  label: AppStrings.get('generalChildcare', lang),
                  icon: Icons.child_care,
                  onPressed: () => _navigateTo(
                    context,
                    GeneralChildcarePage(
                      isDark: isDark,
                      onToggleTheme: onToggleTheme,
                    ),
                  ),
                ),
                HomeMenuButton(
                  label: AppStrings.get('tutorials', lang),
                  icon: Icons.play_circle_outline,
                  onPressed: () => _navigateTo(
                    context,
                    TutorialsPage(isDark: isDark, onToggleTheme: onToggleTheme),
                  ),
                ),
                HomeMenuButton(
                  label: AppStrings.get('spiritual', lang),
                  icon: Icons.favorite,
                  onPressed: () => _navigateTo(
                    context,
                    SpiritualPage(isDark: isDark, onToggleTheme: onToggleTheme),
                  ),
                ),
                HomeMenuButton(
                  label: AppStrings.get('hospitalInfo', lang),
                  icon: Icons.local_hospital,
                  onPressed: () => _navigateTo(
                    context,
                    HospitalInfoPage(
                      isDark: isDark,
                      onToggleTheme: onToggleTheme,
                    ),
                  ),
                ),
                HomeMenuButton(
                  label: AppStrings.get('caregiverSupport', lang),
                  icon: Icons.support_agent,
                  onPressed: () => _navigateTo(
                    context,
                    CaregiverSupportPage(
                      isDark: isDark,
                      onToggleTheme: onToggleTheme,
                    ),
                  ),
                ),
                HomeMenuButton(
                  label: AppStrings.get('aboutCHD', lang),
                  icon: Icons.info_outline,
                  onPressed: () => _navigateTo(
                    context,
                    AboutCHDPage(isDark: isDark, onToggleTheme: onToggleTheme),
                  ),
                ),
                HomeMenuButton(
                  label: AppStrings.get('contacts', lang),
                  icon: Icons.phone,
                  onPressed: () => _navigateTo(
                    context,
                    ContactsPage(isDark: isDark, onToggleTheme: onToggleTheme),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
