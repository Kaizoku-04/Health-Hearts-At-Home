import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/content_card.dart';

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

    final supportItems = [
      {
        'title': lang == 'en' ? 'Patient Stories' : 'قصص المرضى',
        'description': lang == 'en'
            ? 'Inspiring stories from other families'
            : 'قصص ملهمة من عائلات أخرى',
        'hasVideo': true,
      },
      {
        'title': lang == 'en' ? 'Support Groups' : 'مجموعات الدعم',
        'description': lang == 'en'
            ? 'Connect with other caregivers'
            : 'تواصل مع مقدمي رعاية آخرين',
        'hasVideo': false,
      },
      {
        'title': lang == 'en'
            ? 'Mental Health Resources'
            : 'موارد الصحة العقلية',
        'description': lang == 'en'
            ? 'Counseling and mental health support'
            : 'الاستشارة والدعم النفسي',
        'hasVideo': false,
      },
      {
        'title': lang == 'en' ? 'Coping Strategies' : 'استراتيجيات التعامل',
        'description': lang == 'en'
            ? 'Effective strategies for managing stress'
            : 'استراتيجيات فعالة لإدارة التوتر',
        'hasVideo': true,
      },
    ];

    return Scaffold(
      appBar: CHDAppBar(
        title: AppStrings.get('caregiverSupport', lang),
        onToggleTheme: onToggleTheme,
        isDark: isDark,
      ),
      body: ListView.builder(
        itemCount: supportItems.length,
        itemBuilder: (context, index) {
          final item = supportItems[index];
          return ContentCard(
            title: item['title']?.toString() ?? '',
            description: item['description']?.toString() ?? '',
            hasVideo: item['hasVideo'] as bool,
            onTap: () {},
          );
        },
      ),
    );
  }
}
