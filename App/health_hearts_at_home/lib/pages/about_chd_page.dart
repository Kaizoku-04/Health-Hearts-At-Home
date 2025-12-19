import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../widgets/app_bar_widget.dart';
import '../models/themes.dart';

class AboutCHDPage extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const AboutCHDPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    final aboutCHDContent = lang == 'en'
        ? {
            'title': 'Congenital Heart Disease (CHD)',
            'description':
                'A congenital heart defect is a problem with the heart\'s structure that exists at birth.',
            'sections': [
              {
                'heading': 'What is CHD?',
                'content':
                    'CHD occurs when one or more parts of the heart don\'t develop properly before birth. It\'s the most common birth defect, affecting about 1 percent of all newborns.',
              },
              {
                'heading': 'Types of CHD',
                'content':
                    'There are many different types of CHD, ranging from simple conditions that may not need treatment to complex conditions that require several surgeries.',
              },
              {
                'heading': 'Symptoms',
                'content':
                    'Common symptoms may include: shortness of breath, cyanosis (bluish discoloration), poor feeding, failure to thrive, and delayed growth.',
              },
              {
                'heading': 'Treatment Options',
                'content':
                    'Treatment depends on the type and severity of the condition. Options may include medications, catheter procedures, or surgery.',
              },
            ],
          }
        : {
            'title': 'أمراض القلب الخلقية',
            'description':
                'عيب القلب الخلقي هو مشكلة في بنية القلب موجودة عند الولادة.',
            'sections': [
              {
                'heading': 'ما هي أمراض القلب الخلقية؟',
                'content':
                    'تحدث أمراض القلب الخلقية عندما لا يتطور جزء واحد أو أكثر من أجزاء القلب بشكل صحيح قبل الولادة. إنه العيب الخلقي الأكثر شيوعاً، مما يؤثر على حوالي 1 في المئة من جميع الأطفال حديثي الولادة.',
              },
              {
                'heading': 'أنواع أمراض القلب الخلقية',
                'content':
                    'هناك أنواع عديدة من أمراض القلب الخلقية، تتراوح من حالات بسيطة قد لا تحتاج إلى علاج إلى حالات معقدة تتطلب عدة جراحات.',
              },
              {
                'heading': 'الأعراض',
                'content':
                    'تشمل الأعراض الشائعة: ضيق التنفس، الزرقة (التلون الأزرق)، سوء التغذية، الفشل في النمو، والنمو المتأخر.',
              },
              {
                'heading': 'خيارات العلاج',
                'content':
                    'يعتمد العلاج على نوع وشدة الحالة. قد تشمل الخيارات الأدوية أو إجراءات القسطرة أو الجراحة.',
              },
            ],
          };

    return Scaffold(
      appBar: CHDAppBar(
        title: AppStrings.get('aboutCHD', lang),
        onToggleTheme: onToggleTheme,
        isDark: isDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              aboutCHDContent['title'] as String,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: customTheme[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              aboutCHDContent['description'] as String,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ...(aboutCHDContent['sections'] as List).map((section) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    section['heading'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: customTheme[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section['content'],
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
