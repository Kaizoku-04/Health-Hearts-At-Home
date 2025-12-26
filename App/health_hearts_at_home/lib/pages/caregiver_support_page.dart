import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';

class CaregiverSupportPage extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const CaregiverSupportPage({
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
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFE7E7EC);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);

    // Accent: Saffron Gold (Matches Home Page "Caregiver Support" Icon)
    const accentColor = Color(0xFFe3b23e);

    // Enhanced Data with Icons
    final supportItems = [
      {
        'title': lang == 'en' ? 'Patient Stories' : 'قصص المرضى',
        'description': lang == 'en'
            ? 'Inspiring stories from other families'
            : 'قصص ملهمة من عائلات أخرى',
        'hasVideo': true,
        'icon': Icons.auto_stories_rounded, // Story book icon
      },
      {
        'title': lang == 'en' ? 'Support Groups' : 'مجموعات الدعم',
        'description': lang == 'en'
            ? 'Connect with other caregivers'
            : 'تواصل مع مقدمي رعاية آخرين',
        'hasVideo': false,
        'icon': Icons.diversity_3_rounded, // Group icon
      },
      {
        'title': lang == 'en'
            ? 'Mental Health Resources'
            : 'موارد الصحة العقلية',
        'description': lang == 'en'
            ? 'Counseling and mental health support'
            : 'الاستشارة والدعم النفسي',
        'hasVideo': false,
        'icon': Icons.psychology_rounded, // Brain/Mental health icon
      },
      {
        'title': lang == 'en' ? 'Coping Strategies' : 'استراتيجيات التعامل',
        'description': lang == 'en'
            ? 'Effective strategies for managing stress'
            : 'استراتيجيات فعالة لإدارة التوتر',
        'hasVideo': true,
        'icon': Icons.self_improvement_rounded, // Meditation/Coping icon
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
          AppStrings.get('caregiverSupport', lang),
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            color: primaryText,
            tooltip: 'Change Language',
            onPressed: () {
              final newLang = lang == 'en' ? 'ar' : 'en';
              appService.setLanguage(newLang);
            },
          ),
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
        itemCount: supportItems.length,
        itemBuilder: (context, index) {
          final item = supportItems[index];
          return _buildSupportCard(
            title: item['title'] as String,
            description: item['description'] as String,
            icon: item['icon'] as IconData,
            hasVideo: item['hasVideo'] as bool,
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
  Widget _buildSupportCard({
    required String title,
    required String description,
    required IconData icon,
    required bool hasVideo,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor.withOpacity(0.9), size: 26),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryText,
                              ),
                            ),
                          ),
                          // Video Badge
                          if (hasVideo)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.play_circle_fill, size: 12, color: Colors.redAccent),
                                  SizedBox(width: 4),
                                  Text(
                                    "VIDEO",
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent
                                    ),
                                  )
                                ],
                              ),
                            )
                        ],
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
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Icon(Icons.chevron_right, color: Colors.grey.withOpacity(0.4), size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}