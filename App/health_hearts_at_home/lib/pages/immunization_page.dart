import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/url_launcher_service.dart'; // ✅ Import your service

class ImmunizationPage extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const ImmunizationPage({
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

    // Accent: Protective Teal
    const accentColor = Color(0xFF009688);

    // --- CONTENT DATA ---
    final title = lang == 'en' ? 'Immunization' : 'التطعيمات';

    final introText = lang == 'en'
        ? "Children with CHD are at higher risk for complications from common illnesses. Staying up to date with vaccines is the best way to protect their hearts."
        : "الأطفال المصابون بأمراض القلب الخلقية أكثر عرضة لمضاعفات الأمراض الشائعة. البقاء على اطلاع دائم بالتطعيمات هو أفضل وسيلة لحماية قلوبهم.";

    final standardTitle = lang == 'en' ? 'Standard Schedule' : 'الجدول القياسي';
    final standardDesc = lang == 'en'
        ? "In most cases, children with CHD follow the same immunization schedule as other children. Do not delay vaccines unless advised by your cardiologist."
        : "في معظم الحالات، يتبع الأطفال المصابون بأمراض القلب نفس جدول التطعيمات كباقي الأطفال. لا تؤخر التطعيمات إلا بنصيحة طبيب القلب.";

    final specialTitle = lang == 'en' ? 'Special Protections' : 'حماية خاصة';
    final specialVaccines = [
      {
        'title': lang == 'en' ? 'RSV Protection (Synagis)' : 'حماية الفيروس المخلوي (سيناجيس)',
        'desc': lang == 'en'
            ? 'A monthly shot given during winter to prevent severe lung infections caused by RSV.'
            : 'حقنة شهرية تُعطى خلال فصل الشتاء لمنع التهابات الرئة الحادة التي يسببها الفيروس المخلوي التنفسي.',
        'icon': Icons.shield_rounded,
      },
      {
        'title': lang == 'en' ? 'Flu Shot (Influenza)' : 'لقاح الإنفلونزا',
        'desc': lang == 'en'
            ? 'Recommended every year for the child and all family members (6 months and older).'
            : 'يوصى به كل عام للطفل وجميع أفراد الأسرة (6 أشهر فما فوق).',
        'icon': Icons.medication_liquid_rounded,
      },
      {
        'title': lang == 'en' ? 'Pre-Surgery Caution' : 'تنبيه قبل الجراحة',
        'desc': lang == 'en'
            ? 'Live vaccines (like MMR or Chickenpox) might need to be timed around heart surgery. Ask your team.'
            : 'قد تحتاج اللقاحات الحية (مثل الحصبة أو الجدري) إلى توقيت معين حول موعد جراحة القلب. اسأل فريقك الطبي.',
        'icon': Icons.access_alarm_rounded,
      },
    ];

    final sideEffectsTitle = lang == 'en' ? 'Managing Side Effects' : 'إدارة الآثار الجانبية';
    final sideEffects = [
      {
        'title': lang == 'en' ? 'Fever Management' : 'إدارة الحمى',
        'desc': lang == 'en'
            ? 'Fever increases heart rate. Keep the child cool and ask your doctor about using fever reducers (like Tylenol).'
            : 'الحمى تزيد من معدل ضربات القلب. حافظ على برودة الطفل واسأل طبيبك عن استخدام خافضات الحرارة.',
      },
      {
        'title': lang == 'en' ? 'Watch for Reactions' : 'مراقبة ردود الفعل',
        'desc': lang == 'en'
            ? 'Mild soreness is normal. Call the doctor if you see difficulty breathing, extreme fatigue, or high fever (>38.5°C).'
            : 'الألم الخفيف طبيعي. اتصل بالطبيب إذا لاحظت صعوبة في التنفس، أو تعباً شديداً، أو حمى عالية (>38.5).',
      }
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
                  Icon(Icons.vaccines_rounded, size: 32, color: accentColor),
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

            // --- STANDARD SCHEDULE SECTION ---
            _buildSectionHeader(standardTitle.toUpperCase(), secondaryText),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: secondaryText, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          standardDesc,
                          style: TextStyle(fontSize: 15, color: primaryText, height: 1.5),
                        ),

                        // ✅ LINK BUTTON (Using URLLauncherService)
                        const SizedBox(height: 12),
                        InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: () {
                            // Uses the service you provided to open the CDC link
                            URLLauncherService.openWebsite('https://www.cdc.gov/vaccines/imz-schedules/child-easyread.html');
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  lang == 'en' ? "View Official Schedule" : "عرض الجدول الرسمي",
                                  style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.open_in_new_rounded, size: 16, color: accentColor),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- SPECIAL PROTECTIONS SECTION ---
            _buildSectionHeader(specialTitle.toUpperCase(), secondaryText),
            const SizedBox(height: 12),
            ...specialVaccines.map((item) => _buildVaccineCard(
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

            // --- SIDE EFFECTS SECTION ---
            _buildSectionHeader(sideEffectsTitle.toUpperCase(), Colors.orangeAccent),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(isDarkTheme ? 0.2 : 0.1)),
              ),
              child: Column(
                children: sideEffects.map((item) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: const Icon(Icons.info_outline_rounded, color: Colors.orangeAccent),
                    title: Text(item['title']!, style: TextStyle(fontWeight: FontWeight.bold, color: primaryText)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(item['desc']!, style: TextStyle(color: secondaryText, fontSize: 13, height: 1.4)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 40),
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

  Widget _buildVaccineCard({
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