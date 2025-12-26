import 'package:flutter/material.dart';
import 'package:health_hearts_at_home/pages/hospital_maps_page.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../services/url_launcher_service.dart';

class HospitalInfoPage extends StatefulWidget {
  final bool isDark; // Keep for passing to next page, but don't rely on it for UI
  final VoidCallback onToggleTheme;

  const HospitalInfoPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HospitalInfoPage> createState() => _HospitalInfoPageState();
}

class _HospitalInfoPageState extends State<HospitalInfoPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    // --- DYNAMIC THEME CHECK ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // --- NEUTRAL PLATINUM PALETTE ---
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFE7E7EC);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);
    const hospitalAccent = Color(0xFF5d9bb5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Hospital Information",
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // --- LANGUAGE TOGGLE ADDED HERE ---
          IconButton(
            icon: const Icon(Icons.language),
            color: primaryText,
            tooltip: 'Change Language',
            onPressed: () {
              final newLang = lang == 'en' ? 'ar' : 'en';
              appService.setLanguage(newLang);
            },
          ),

          // --- THEME TOGGLE ---
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: primaryText,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER ---
            Text(
              "Contact & Details",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: secondaryText,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            // Hospital Name Card
            _buildInfoCard(
              title: AppStrings.get('hospitalName', lang),
              content: 'Loma Linda University Children\'s Hospital',
              icon: Icons.local_hospital_rounded,
              cardColor: cardColor,
              textColor: primaryText,
              subTextColor: secondaryText,
              accentColor: hospitalAccent,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Cafeteria Hours Card
            _buildInfoCard(
              title: AppStrings.get('cafeteriaHours', lang),
              content: '6AM - 8PM',
              icon: Icons.restaurant_menu_rounded,
              cardColor: cardColor,
              textColor: primaryText,
              subTextColor: secondaryText,
              accentColor: Colors.orange[800]!,
              isDark: isDark,
            ),
            const SizedBox(height: 32),

            // --- LINKS HEADER ---
            Text(
              "QUICK LINKS",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: secondaryText,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            // Website Card
            _buildContactCard(
              title: AppStrings.get('hospitalWebsite', lang),
              content: 'lluch.org',
              icon: Icons.language,
              onTap: () => URLLauncherService.openWebsite('https://lluch.org/'),
              cardColor: cardColor,
              textColor: primaryText,
              subTextColor: secondaryText,
              accentColor: hospitalAccent,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Heart Care Website
            _buildContactCard(
              title: AppStrings.get('Heart Care Service Website', lang),
              content: 'lluch.org/heart-care',
              icon: Icons.monitor_heart_outlined,
              onTap: () => URLLauncherService.openWebsite('https://lluch.org/heart-care'),
              cardColor: cardColor,
              textColor: primaryText,
              subTextColor: secondaryText,
              accentColor: Colors.redAccent,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Emergency Room
            _buildContactCard(
              title: AppStrings.get('Children\'s emergency room website', lang),
              content: 'Services / Emergency Room',
              icon: Icons.local_pharmacy_outlined,
              onTap: () => URLLauncherService.openWebsite('https://lluch.org/services/childrens-emergency-room'),
              cardColor: cardColor,
              textColor: primaryText,
              subTextColor: secondaryText,
              accentColor: hospitalAccent,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Billing
            _buildContactCard(
              title: "Billing & Insurance",
              content: 'Patients & Families / Billing',
              icon: Icons.receipt_long_rounded,
              onTap: () => URLLauncherService.openWebsite('https://lluch.org/patients-families/patients/billing-insurance'),
              cardColor: cardColor,
              textColor: primaryText,
              subTextColor: secondaryText,
              accentColor: hospitalAccent,
              isDark: isDark,
            ),
            const SizedBox(height: 40),

            // Map Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: hospitalAccent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hospitalAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HospitalMapsPage(
                        isDark: isDark,
                        onToggleTheme: widget.onToggleTheme,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map_rounded, size: 24),
                label: const Text(
                  'View Hospital Map',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.1 : 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: subTextColor, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Text(content, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String content,
    required IconData icon,
    required VoidCallback onTap,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.1 : 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subTextColor)),
                      const SizedBox(height: 4),
                      Text(content, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.chevron_right, color: Colors.grey[300], size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}