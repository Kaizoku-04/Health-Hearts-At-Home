import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/content_card.dart';
import 'quran_page.dart'; // ✅ new page

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

    final spiritualItems = [
      {
        'title': lang == 'en' ? 'Daily Devotionals' : 'التأملات اليومية',
        'description': lang == 'en'
            ? 'Inspirational devotionals for caregivers'
            : 'تأملات ملهمة لمقدمي الرعاية',
        'hasVideo': true,
        'type': 'devotionals',
      },
      {
        'title': lang == 'en' ? 'Prayer Resources' : 'موارد الصلاة',
        'description': lang == 'en'
            ? 'Collection of prayers for strength and healing'
            : 'مجموعة من الصلوات للقوة والشفاء',
        'hasVideo': false,
        'type': 'prayer',
      },
      {
        'title': lang == 'en' ? 'Chapel Services' : 'خدمات الكنيسة',
        'description': lang == 'en'
            ? 'Chapel services and spiritual counseling'
            : 'خدمات الكنيسة والاستشارة الروحية',
        'hasVideo': false,
        'type': 'chapel',
      },
      {
        'title': lang == 'en'
            ? 'Meditation & Mindfulness'
            : 'التأمل واليقظة الذهنية',
        'description': lang == 'en'
            ? 'Guided meditation for peace and calmness'
            : 'تأمل موجه للسلام والهدوء',
        'hasVideo': true,
        'type': 'meditation',
      },
      {
        'title': lang == 'en' ? 'Qur\'an Verses' : 'آيات من القرآن الكريم',
        'description': lang == 'en'
            ? 'Selected Qur\'an verses with audio and translation'
            : 'آيات مختارة مع التلاوة والترجمة',
        'hasVideo': false,
        'type': 'quran', // ✅ special type
      },
    ];

    return Scaffold(
      appBar: CHDAppBar(
        title: AppStrings.get('spiritual', lang),
        onToggleTheme: onToggleTheme,
        isDark: isDark,
      ),
      body: ListView.builder(
        itemCount: spiritualItems.length,
        itemBuilder: (context, index) {
          final item = spiritualItems[index];
          final type = item['type'];

          return ContentCard(
            title: item['title']?.toString() ?? '',
            description: item['description']?.toString() ?? '',
            hasVideo: item['hasVideo'] as bool,
            onTap: () {
              if (type == 'quran') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        QuranPage(isDark: isDark, onToggleTheme: onToggleTheme),
                  ),
                );
              } else {
                // TODO: handle other spiritual items later if needed
              }
            },
          );
        },
      ),
    );
  }
}
