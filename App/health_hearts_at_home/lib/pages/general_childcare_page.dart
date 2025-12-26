import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';

class GeneralChildcarePage extends StatelessWidget {
  final bool isDark; // Kept for consistency, but we check dynamically
  final VoidCallback onToggleTheme;

  const GeneralChildcarePage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    // --- DYNAMIC THEME CHECK ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // --- NEUTRAL PLATINUM PALETTE ---
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);

    // Accent Color: Burnt Sienna (Matches Home Page "General Childcare" Icon)
    const accentColor = Color(0xFFE76F51);

    // Enhanced Data with Icons
    final childcareItems = [
      {
        'title': lang == 'en' ? 'Nutrition & Diet' : 'التغذية والحمية',
        'description': lang == 'en'
            ? 'Proper nutrition guides for CHD'
            : 'دليل التغذية السليمة لأمراض القلب',
        'icon': Icons.restaurant_rounded,
      },
      {
        'title': lang == 'en' ? 'Sleep & Rest' : 'النوم والراحة',
        'description': lang == 'en'
            ? 'Ensuring quality sleep'
            : 'ضمان نوم وراحة جيدة',
        'icon': Icons.bedtime_rounded,
      },
      {
        'title': lang == 'en' ? 'Activity & Play' : 'النشاط واللعب',
        'description': lang == 'en'
            ? 'Age-appropriate activities'
            : 'أنشطة مناسبة لعمر الطفل',
        'icon': Icons.toys_rounded,
      },
      {
        'title': lang == 'en' ? 'Immunization' : 'التطعيمات',
        'description': lang == 'en'
            ? 'Vaccination schedules'
            : 'جدول التطعيمات',
        'icon': Icons.vaccines,
      },
    ];

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
          AppStrings.get('generalChildcare', lang),
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // --- LANGUAGE TOGGLE ---
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
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: childcareItems.length,
        itemBuilder: (context, index) {
          final item = childcareItems[index];
          return _buildSophisticatedCard(
            title: item['title'] as String,
            description: item['description'] as String,
            icon: item['icon'] as IconData,
            cardColor: cardColor,
            primaryText: primaryText,
            secondaryText: secondaryText,
            accentColor: accentColor,
            isDark: isDark,
            onTap: () {
              // Navigate to detailed view
            },
          );
        },
      ),
    );
  }

  // --- HELPER: SOPHISTICATED LIST CARD ---
  Widget _buildSophisticatedCard({
    required String title,
    required String description,
    required IconData icon,
    required Color cardColor,
    required Color primaryText,
    required Color secondaryText,
    required Color accentColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1)),
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
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor, size: 26),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryText,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Chevron
                const SizedBox(width: 12),
                Icon(Icons.chevron_right, color: Colors.grey.withOpacity(0.4), size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}