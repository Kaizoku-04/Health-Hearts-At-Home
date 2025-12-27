import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';

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

    // --- DYNAMIC THEME CHECK ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // --- NEUTRAL PLATINUM PALETTE ---
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFE7E7EC);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);

    // Accent: Medical Blue (Professional & Trustworthy)
    const accentColor = Color(0xFF0077B6);

    // Content with Icons added
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
          'icon': Icons.help_outline_rounded,
        },
        {
          'heading': 'Types of CHD',
          'content':
          'There are many different types of CHD, ranging from simple conditions that may not need treatment to complex conditions that require several surgeries.',
          'icon': Icons.category_rounded,
        },
        {
          'heading': 'Symptoms',
          'content':
          'Common symptoms may include: shortness of breath, cyanosis (bluish discoloration), poor feeding, failure to thrive, and delayed growth.',
          'icon': Icons.warning_amber_rounded,
        },
        {
          'heading': 'Treatment Options',
          'content':
          'Treatment depends on the type and severity of the condition. Options may include medications, catheter procedures, or surgery.',
          'icon': Icons.medical_services_outlined,
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
          'icon': Icons.help_outline_rounded,
        },
        {
          'heading': 'أنواع أمراض القلب الخلقية',
          'content':
          'هناك أنواع عديدة من أمراض القلب الخلقية، تتراوح من حالات بسيطة قد لا تحتاج إلى علاج إلى حالات معقدة تتطلب عدة جراحات.',
          'icon': Icons.category_rounded,
        },
        {
          'heading': 'الأعراض',
          'content':
          'تشمل الأعراض الشائعة: ضيق التنفس، الزرقة (التلون الأزرق)، سوء التغذية، الفشل في النمو، والنمو المتأخر.',
          'icon': Icons.warning_amber_rounded,
        },
        {
          'heading': 'خيارات العلاج',
          'content':
          'يعتمد العلاج على نوع وشدة الحالة. قد تشمل الخيارات الأدوية أو إجراءات القسطرة أو الجراحة.',
          'icon': Icons.medical_services_outlined,
        },
      ],
    };

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
          AppStrings.get('aboutCHD', lang),
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HERO INTRODUCTION CARD ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [accentColor.withOpacity(0.4), accentColor.withOpacity(0.1)]
                      : [accentColor, accentColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aboutCHDContent['title'] as String,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    aboutCHDContent['description'] as String,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- SECTION HEADING ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                lang == 'en' ? "DETAILS & INFORMATION" : "التفاصيل والمعلومات",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: secondaryText,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- SECTIONS LIST ---
            ...(aboutCHDContent['sections'] as List).map((section) {
              return _buildInfoSection(
                heading: section['heading'],
                content: section['content'],
                icon: section['icon'],
                cardColor: cardColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                accentColor: accentColor,
                isDark: isDark,
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- HELPER: SOPHISTICATED INFO CARD ---
  Widget _buildInfoSection({
    required String heading,
    required String content,
    required IconData icon,
    required Color cardColor,
    required Color primaryText,
    required Color secondaryText,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    heading,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
            const SizedBox(height: 16),

            // Content Body
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: secondaryText.withOpacity(isDark ? 0.9 : 1.0), // Slightly brighter in dark mode
                height: 1.6, // Readable line height
              ),
            ),
          ],
        ),
      ),
    );
  }
}