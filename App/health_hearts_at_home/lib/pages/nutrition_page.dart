import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';

class NutritionPage extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const NutritionPage({
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

    // Accent: Fresh Green (Nutrition)
    const accentColor = Color(0xFF43A047);

    // --- CONTENT DATA ---
    final title = lang == 'en' ? 'Nutrition & Diet' : 'التغذية والحمية';

    final introText = lang == 'en'
        ? "Proper nutrition is vital for children with congenital heart disease to grow and fight infections. Some children may need more calories than usual because their hearts work harder."
        : "التغذية السليمة حيوية للأطفال المصابين بأمراض القلب الخلقية للنمو ومكافحة العدوى. قد يحتاج بعض الأطفال إلى سعرات حرارية أكثر من المعتاد لأن قلوبهم تعمل بجهد أكبر.";

    final tableHeaders = lang == 'en'
        ? ['Foods to Encourage', 'Foods to Limit']
        : ['أطعمة يُنصح بها', 'أطعمة يجب الحد منها'];

    final dietData = [
      {
        'good': lang == 'en' ? 'High-calorie formulas' : 'تركيبات عالية السعرات',
        'bad': lang == 'en' ? 'Excessive salt (Sodium)' : 'الملح الزائد (الصوديوم)',
      },
      {
        'good': lang == 'en' ? 'Lean proteins (Chicken, Fish)' : 'بروتينات خالية من الدهون',
        'bad': lang == 'en' ? 'Sugary drinks & soda' : 'المشروبات الغازية والسكرية',
      },
      {
        'good': lang == 'en' ? 'Fruits & Vegetables' : 'الفواكه والخضروات',
        'bad': lang == 'en' ? 'Processed snack foods' : 'الأطعمة المصنعة والوجبات الخفيفة',
      },
      {
        'good': lang == 'en' ? 'Whole grains' : 'الحبوب الكاملة',
        'bad': lang == 'en' ? 'Saturated fats' : 'الدهون المشبعة',
      },
    ];

    final tipsTitle = lang == 'en' ? 'Feeding Tips' : 'نصائح التغذية';
    final tips = [
      {
        'title': lang == 'en' ? 'Small, Frequent Meals' : 'وجبات صغيرة ومتكررة',
        'desc': lang == 'en'
            ? 'Offering food every 2-3 hours helps prevent fatigue during eating.'
            : 'تقديم الطعام كل 2-3 ساعات يساعد على منع التعب أثناء الأكل.',
        'icon': Icons.access_time_rounded,
      },
      {
        'title': lang == 'en' ? 'Boost Calories' : 'زيادة السعرات الحرارية',
        'desc': lang == 'en'
            ? 'Add healthy oils, butter, or fortified milk to meals as prescribed.'
            : 'أضف الزيوت الصحية أو الزبدة أو الحليب المدعم إلى الوجبات حسب الوصفة.',
        'icon': Icons.local_fire_department_rounded,
      },
      {
        'title': lang == 'en' ? 'Monitor Fluids' : 'مراقبة السوائل',
        'desc': lang == 'en'
            ? 'Some heart conditions require fluid restriction. Consult your doctor.'
            : 'تتطلب بعض حالات القلب تقييد السوائل. استشر طبيبك.',
        'icon': Icons.water_drop_rounded,
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
            // FIXED: Removed 'widget.'
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
                  Icon(Icons.restaurant_rounded, size: 32, color: accentColor),
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

            // --- DIET TABLE SECTION ---
            _buildSectionHeader(lang == 'en' ? "DIET CHART" : "جدول الحمية", secondaryText),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      color: accentColor.withOpacity(0.15),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(child: Text(tableHeaders[0], style: TextStyle(fontWeight: FontWeight.bold, color: primaryText, fontSize: 13))),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 20, color: Colors.grey.withOpacity(0.3)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.cancel, size: 16, color: Colors.redAccent),
                                const SizedBox(width: 8),
                                Expanded(child: Text(tableHeaders[1], style: TextStyle(fontWeight: FontWeight.bold, color: primaryText, fontSize: 13))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    // Table Body
                    ...dietData.map((row) => _buildTableRow(row['good']!, row['bad']!, primaryText, secondaryText)).toList(),
                  ],
                ),
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

  Widget _buildTableRow(String good, String bad, Color primary, Color secondary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: secondary.withOpacity(0.1))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(good, style: TextStyle(fontSize: 14, color: primary, height: 1.3))),
          const SizedBox(width: 16),
          Expanded(child: Text(bad, style: TextStyle(fontSize: 14, color: secondary, height: 1.3))),
        ],
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