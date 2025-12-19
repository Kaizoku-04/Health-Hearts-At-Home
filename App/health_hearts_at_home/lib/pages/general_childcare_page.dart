import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/content_card.dart';

class GeneralChildcarePage extends StatelessWidget {
  final bool isDark;
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

    // Mock data - replace with API call
    final childcareItems = [
      {
        'title': lang == 'en' ? 'Nutrition & Diet' : 'التغذية والحمية',
        'description': lang == 'en'
            ? 'Learn about proper nutrition for children with CHD'
            : 'تعرف على التغذية السليمة للأطفال المصابين بأمراض القلب',
      },
      {
        'title': lang == 'en' ? 'Sleep & Rest' : 'النوم والراحة',
        'description': lang == 'en'
            ? 'Tips for ensuring quality sleep and rest'
            : 'نصائح لضمان نوم وراحة جيدة',
      },
      {
        'title': lang == 'en' ? 'Activity & Play' : 'النشاط واللعب',
        'description': lang == 'en'
            ? 'Age-appropriate activities for your child'
            : 'أنشطة مناسبة لعمر الطفل',
      },
      {
        'title': lang == 'en' ? 'Immunization' : 'التطعيمات',
        'description': lang == 'en'
            ? 'Vaccination schedule for CHD patients'
            : 'جدول التطعيمات لمرضى أمراض القلب',
      },
    ];

    return Scaffold(
      appBar: CHDAppBar(
        title: AppStrings.get('generalChildcare', lang),
        onToggleTheme: onToggleTheme,
        isDark: isDark,
      ),
      body: ListView.builder(
        itemCount: childcareItems.length,
        itemBuilder: (context, index) {
          final item = childcareItems[index];
          return ContentCard(
            title: item['title']!,
            description: item['description']!,
            onTap: () {
              // Navigate to detailed view
            },
          );
        },
      ),
    );
  }
}
