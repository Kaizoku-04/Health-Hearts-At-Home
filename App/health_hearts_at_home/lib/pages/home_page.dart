import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
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

    // --- REFINED "LIVELY" PALETTE ---

    // Background:
    // Light Mode: 'Morning Sky' (EBF2FA) - A fresh, lively blue-white tint.
    // Dark Mode: Deep Black/Grey.
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7);

    // Text:
    final primaryText = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDark ? Colors.grey[400] : const Color(0xFF5A5A60);

    // Hero Gradient
    final heroGradient = const LinearGradient(
      colors: [Color(0xFF3A1C71), Color(0xFFD76D77), Color(0xFFFFAF7B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Accent Colors
    final colorChildcare = const Color(0xFFE76F51);
    final colorTutorials = const Color(0xFF2A9D8F);
    final colorHospital  = const Color(0xFF264653);
    final colorSupport   = const Color(0xFFE9C46A);
    final colorSpiritual = const Color(0xFF8E44AD);
    final colorInfo      = const Color(0xFF457B9D);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: null,
        title: Text(
          AppStrings.get('appTitle', lang),
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // --- LANGUAGE ICON BUTTON ---
          IconButton(
            icon: const Icon(Icons.language),
            color: primaryText,
            tooltip: 'Change Language',
            onPressed: () {
              final newLang = lang == 'en' ? 'ar' : 'en';
              appService.setLanguage(newLang);
            },
          ),

          // Theme Toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            color: primaryText,
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('welcome', lang),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Select an option to get started',
              style: TextStyle(
                fontSize: 16,
                color: secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            _buildHeroCard(
              context,
              title: AppStrings.get('trackChild', lang),
              subtitle: 'Monitor growth & milestones',
              icon: Icons.timeline_rounded,
              gradient: heroGradient,
              onTap: () => _navigateTo(context, TrackChildPage(isDark: isDark, onToggleTheme: onToggleTheme)),
            ),

            const SizedBox(height: 32),

            _buildSectionHeader("RESOURCES", isDark),
            const SizedBox(height: 12),

            Column(
              children: [
                _buildListRow(
                  context,
                  label: AppStrings.get('generalChildcare', lang),
                  subtitle: "Daily care guides",
                  icon: Icons.child_friendly_outlined,
                  accentColor: colorChildcare,
                  isDark: isDark,
                  textColor: primaryText,
                  onTap: () => _navigateTo(context, GeneralChildcarePage(isDark: isDark, onToggleTheme: onToggleTheme)),
                ),
                _buildListRow(
                  context,
                  label: AppStrings.get('tutorials', lang),
                  subtitle: "Video lessons",
                  icon: Icons.play_circle_outline_rounded,
                  accentColor: colorTutorials,
                  isDark: isDark,
                  textColor: primaryText,
                  onTap: () => _navigateTo(context, TutorialsPage(isDark: isDark, onToggleTheme: onToggleTheme)),
                ),
                _buildListRow(
                  context,
                  label: AppStrings.get('hospitalInfo', lang),
                  subtitle: "Find locations",
                  icon: Icons.local_hospital_outlined,
                  accentColor: colorHospital,
                  isDark: isDark,
                  textColor: primaryText,
                  onTap: () => _navigateTo(context, HospitalInfoPage(isDark: isDark, onToggleTheme: onToggleTheme)),
                ),
                _buildListRow(
                  context,
                  label: AppStrings.get('caregiverSupport', lang),
                  subtitle: "Get help",
                  icon: Icons.favorite_border_rounded,
                  accentColor: colorSupport,
                  isDark: isDark,
                  textColor: primaryText,
                  onTap: () => _navigateTo(context, CaregiverSupportPage(isDark: isDark, onToggleTheme: onToggleTheme)),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionHeader("INFORMATION", isDark),
            const SizedBox(height: 12),

            Column(
              children: [
                _buildListRow(
                  context,
                  label: AppStrings.get('spiritual', lang),
                  subtitle: "Encouragement",
                  icon: Icons.spa_outlined,
                  accentColor: colorSpiritual,
                  isDark: isDark,
                  textColor: primaryText,
                  onTap: () => _navigateTo(context, SpiritualPage(isDark: isDark, onToggleTheme: onToggleTheme)),
                ),
                _buildListRow(
                  context,
                  label: AppStrings.get('aboutCHD', lang),
                  subtitle: "About us",
                  icon: Icons.info_outline_rounded,
                  accentColor: colorInfo,
                  isDark: isDark,
                  textColor: primaryText,
                  onTap: () => _navigateTo(context, AboutCHDPage(isDark: isDark, onToggleTheme: onToggleTheme)),
                ),
                _buildListRow(
                  context,
                  label: AppStrings.get('contacts', lang),
                  subtitle: "Contact us",
                  icon: Icons.phone_outlined,
                  accentColor: colorInfo,
                  isDark: isDark,
                  textColor: primaryText,
                  onTap: () => _navigateTo(context, ContactsPage(isDark: isDark, onToggleTheme: onToggleTheme)),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF3A1C71).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6)
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildListRow(BuildContext context, {
    required String label,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required Color textColor,
    required VoidCallback onTap
  }) {
    // Pure white cards on light mode, dark grey on dark mode
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.1 : 0.05), width: 1),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF3A1C71).withOpacity(isDark ? 0.0 : 0.03), // Subtle colored shadow for "liveliness"
                      blurRadius: 10,
                      offset: const Offset(0, 4)
                  )
                ]
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[300], size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}