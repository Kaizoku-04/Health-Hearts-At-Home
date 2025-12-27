import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';

class ActivityPlayPage extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const ActivityPlayPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // --- NEUTRAL PLATINUM PALETTE ---
    final bgColor = isDarkTheme ? const Color(0xFF121212) : const Color(0xFFE7E7EC);
    final cardColor = isDarkTheme ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDarkTheme ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDarkTheme ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);

    // Accent: Energetic Orange (Play)
    const accentColor = Color(0xFFFB8C00);

    // --- CONTENT DATA ---
    final title = lang == 'en' ? 'Activity & Play' : 'النشاط واللعب';

    final introText = lang == 'en'
        ? "Play is essential for development. Most children with CHD can participate in regular activities, but some may need specific limits to avoid overexertion."
        : "اللعب ضروري للنمو. يمكن لمعظم الأطفال المصابين بأمراض القلب الخلقية المشاركة في الأنشطة العادية، لكن قد يحتاج البعض إلى حدود معينة لتجنب الإجهاد المفرط.";

    final guidelinesTitle = lang == 'en' ? 'Age-Appropriate Activities' : 'أنشطة مناسبة للعمر';
    final activities = [
      {
        'title': lang == 'en' ? 'Infants (0-1 yr)' : 'الرضع (0-1 سنة)',
        'desc': lang == 'en'
            ? 'Tummy time, reaching for soft toys, and floor play. Allow frequent breaks if baby breathes fast.'
            : 'وقت الاستلقاء على البطن، الوصول للألعاب اللينة، واللعب على الأرض. اسمح بفترات راحة متكررة إذا كان الطفل يتنفس بسرعة.',
        'icon': Icons.child_friendly_rounded,
      },
      {
        'title': lang == 'en' ? 'Toddlers (1-3 yrs)' : 'الأطفال الصغار (1-3 سنوات)',
        'desc': lang == 'en'
            ? 'Building blocks, walking, and supervised park play. Let the child set their own pace.'
            : 'مكعبات البناء، المشي، واللعب في الحديقة تحت الإشراف. دع الطفل يحدد سرعته الخاصة.',
        'icon': Icons.toys_rounded,
      },
      {
        'title': lang == 'en' ? 'School Age (4+ yrs)' : 'سن المدرسة (4+ سنوات)',
        'desc': lang == 'en'
            ? 'Cycling on flat ground, swimming (recreational), and non-competitive games.'
            : 'ركوب الدراجات على أرض مسطحة، السباحة (الترفيهية)، والألعاب غير التنافسية.',
        'icon': Icons.directions_bike_rounded,
      },
    ];

    final warningTitle = lang == 'en' ? 'When to Stop?' : 'متى يجب التوقف؟';
    final warnings = [
      lang == 'en' ? 'Extreme shortness of breath' : 'ضيق شديد في التنفس',
      lang == 'en' ? 'Chest pain or pressure' : 'ألم أو ضغط في الصدر',
      lang == 'en' ? 'Dizziness or fainting' : 'دوخة أو إغماء',
      lang == 'en' ? 'Blue lips or nails (Cyanosis)' : 'زرقة الشفاه أو الأظافر',
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
                  Icon(Icons.sports_soccer_rounded, size: 32, color: accentColor),
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

            // --- AGE APPROPRIATE ACTIVITIES ---
            _buildSectionHeader(guidelinesTitle.toUpperCase(), secondaryText),
            const SizedBox(height: 12),
            ...activities.map((item) => _buildActivityCard(
              title: item['title'] as String,
              desc: item['desc'] as String,
              icon: item['icon'] as IconData,
              cardColor: cardColor,
              primaryText: primaryText,
              secondaryText: secondaryText,
              accentColor: accentColor,
              isDark: isDarkTheme,
            )),

            const SizedBox(height: 30),

            // --- WARNING SIGNS SECTION ---
            _buildSectionHeader(warningTitle.toUpperCase(), Colors.redAccent),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: warnings.map((text) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: primaryText
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
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

  Widget _buildActivityCard({
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