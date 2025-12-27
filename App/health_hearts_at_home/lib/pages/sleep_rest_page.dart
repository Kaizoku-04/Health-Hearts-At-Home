import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';

class SleepRestPage extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const SleepRestPage({
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
    final bgColor = isDarkTheme ? const Color(0xFF121212) : const Color(0xFFE7E7EC);
    final cardColor = isDarkTheme ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDarkTheme ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDarkTheme ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);

    // Accent: Calming Indigo (Sleep)
    const accentColor = Color(0xFF5C6BC0);

    // --- CONTENT DATA ---
    final title = lang == 'en' ? 'Sleep & Rest' : 'النوم والراحة';

    final introText = lang == 'en'
        ? "Rest reduces the workload on the heart. Children with CHD may tire easily and require frequent rest periods, even during play."
        : "الراحة تقلل من عبء العمل على القلب. قد يتعب الأطفال المصابون بأمراض القلب الخلقية بسهولة ويحتاجون إلى فترات راحة متكررة، حتى أثناء اللعب.";

    final chartTitle = lang == 'en' ? "RECOMMENDED SLEEP" : "النوم الموصى به";
    final sleepChart = [
      {
        'age': lang == 'en' ? 'Newborns (0-3 months)' : 'حديثي الولادة (0-3 أشهر)',
        'hours': lang == 'en' ? '14-17 hours' : '14-17 ساعة',
      },
      {
        'age': lang == 'en' ? 'Infants (4-11 months)' : 'الرضع (4-11 شهر)',
        'hours': lang == 'en' ? '12-15 hours' : '12-15 ساعة',
      },
      {
        'age': lang == 'en' ? 'Toddlers (1-2 years)' : 'الأطفال الصغار (1-2 سنة)',
        'hours': lang == 'en' ? '11-14 hours' : '11-14 ساعة',
      },
    ];

    final tipsTitle = lang == 'en' ? 'Safe Sleep Guidelines' : 'إرشادات النوم الآمن';
    final tips = [
      {
        'title': lang == 'en' ? 'Back to Sleep' : 'النوم على الظهر',
        'desc': lang == 'en'
            ? 'Always place your baby on their back to sleep to reduce SIDS risk.'
            : 'ضع طفلك دائماً على ظهره للنوم لتقليل خطر الموت المفاجئ.',
        'icon': Icons.baby_changing_station,
      },
      {
        'title': lang == 'en' ? 'Firm Surface' : 'سطح ثابت',
        'desc': lang == 'en'
            ? 'Use a firm mattress with a fitted sheet. Avoid soft bedding or toys in the crib.'
            : 'استخدم مرتبة ثابتة مع ملاءة مناسبة. تجنب الفراش الناعم أو الألعاب في السرير.',
        'icon': Icons.bed_rounded,
      },
      {
        'title': lang == 'en' ? 'Elevated Head' : 'رفع الرأس',
        'desc': lang == 'en'
            ? 'Some heart conditions cause breathing issues lying flat. Ask your doctor about elevating the head.'
            : 'تسبب بعض حالات القلب مشاكل في التنفس عند الاستلقاء بشكل مسطح. اسأل طبيبك عن رفع الرأس.',
        'icon': Icons.arrow_upward_rounded,
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
          title,
          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold, fontSize: 20),
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
            icon: Icon(isDarkTheme ? Icons.light_mode : Icons.dark_mode, color: primaryText),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- INTRO CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.nightlight_round, size: 32, color: accentColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      introText,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- SLEEP CHART SECTION ---
            _buildSectionHeader(chartTitle, secondaryText),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(isDarkTheme ? 0.2 : 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkTheme ? 0.0 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: sleepChart.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == sleepChart.length - 1;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      border: isLast ? null : Border(bottom: BorderSide(color: secondaryText.withOpacity(0.1))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['age']!,
                          style: TextStyle(fontWeight: FontWeight.w600, color: primaryText),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item['hours']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),

            // --- TIPS GUIDE SECTION ---
            _buildSectionHeader(tipsTitle.toUpperCase(), secondaryText),
            const SizedBox(height: 12),
            ...tips.map((tip) => _buildTipCard(
              title: tip['title'] as String,
              desc: tip['desc'] as String,
              icon: tip['icon'] as IconData,
              cardColor: cardColor,
              primaryText: primaryText,
              secondaryText: secondaryText,
              accentColor: accentColor,
              isDark: isDarkTheme,
            )),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTipCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color cardColor,
    required Color primaryText,
    required Color secondaryText,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(fontSize: 14, color: secondaryText, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}