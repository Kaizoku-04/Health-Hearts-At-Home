import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import 'quran_page.dart';

class SpiritualPage extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const SpiritualPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    // --- DYNAMIC THEME CHECK ---
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // --- NEUTRAL PLATINUM PALETTE ---
    final bgColor = isDarkTheme ? const Color(0xFF121212) : const Color(0xFFE7E7EC);
    final cardColor = isDarkTheme ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDarkTheme ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDarkTheme ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);

    // Accent: Serene Purple (Spiritual)
    const accentColor = Color(0xFF7E57C2);

    final spiritualItems = [
      {
        'title': lang == 'en' ? 'Daily Devotionals' : 'التأملات اليومية',
        'description': lang == 'en'
            ? 'Inspirational devotionals for caregivers'
            : 'تأملات ملهمة لمقدمي الرعاية',
        'icon': Icons.menu_book_rounded,
        'type': 'devotionals',
      },
      {
        'title': lang == 'en' ? 'Prayer Resources' : 'موارد الصلاة',
        'description': lang == 'en'
            ? 'Collection of prayers for strength and healing'
            : 'مجموعة من الصلوات للقوة والشفاء',
        'icon': Icons.volunteer_activism_rounded,
        'type': 'prayer',
      },
      {
        'title': lang == 'en' ? 'Chapel Services' : 'خدمات الكنيسة',
        'description': lang == 'en'
            ? 'Chapel services and spiritual counseling'
            : 'خدمات الكنيسة والاستشارة الروحية',
        'icon': Icons.church_rounded,
        'type': 'chapel',
      },
      {
        'title': lang == 'en'
            ? 'Meditation & Mindfulness'
            : 'التأمل واليقظة الذهنية',
        'description': lang == 'en'
            ? 'Guided meditation for peace and calmness'
            : 'تأمل موجه للسلام والهدوء',
        'icon': Icons.self_improvement_rounded,
        'type': 'meditation',
      },
      {
        'title': lang == 'en' ? 'Qur\'an Verses' : 'آيات من القرآن الكريم',
        'description': lang == 'en'
            ? 'Selected Qur\'an verses with audio and translation'
            : 'آيات مختارة مع التلاوة والترجمة',
        'icon': Icons.auto_stories_rounded,
        'type': 'quran',
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
          AppStrings.get('spiritual', lang),
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
            onPressed: () {
              final newLang = lang == 'en' ? 'ar' : 'en';
              appService.setLanguage(newLang);
            },
          ),
          IconButton(
            icon: Icon(
              isDarkTheme ? Icons.light_mode : Icons.dark_mode,
              color: primaryText,
            ),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: spiritualItems.length,
        itemBuilder: (context, index) {
          final item = spiritualItems[index];
          final type = item['type'];

          return _buildSophisticatedCard(
            title: item['title'] as String,
            description: item['description'] as String,
            icon: item['icon'] as IconData,
            cardColor: cardColor,
            primaryText: primaryText,
            secondaryText: secondaryText,
            accentColor: accentColor,
            isDark: isDarkTheme,
            onTap: () {
              if (type == 'quran') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        QuranPage(isDark: isDarkTheme, onToggleTheme: onToggleTheme),
                  ),
                );
              } else {
                // Placeholder for other pages
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Coming Soon: ${item['title']}")),
                );
              }
            },
          );
        },
      ),
    );
  }

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