import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../widgets/tracking_input_widget.dart';

class TrackChildPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const TrackChildPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<TrackChildPage> createState() => _TrackChildPageState();
}

class _TrackChildPageState extends State<TrackChildPage> {
  final List<Map<String, dynamic>> _trackingHistory = [];
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    // --- DYNAMIC THEME CHECK ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // --- NEUTRAL PLATINUM PALETTE ---
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);

    // Hero Color (Royal Purple)
    const accentColor = Color(0xFF3A1C71);

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
          AppStrings.get('trackChild', lang),
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
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: _showForm
          ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: TrackingInputWidget(language: lang, onSave: _addTrackingEntry),
        ),
      )
          : _buildHistoryView(lang, bgColor, cardColor, primaryText, secondaryText, accentColor, isDark),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () => setState(() => _showForm = !_showForm),
        icon: Icon(_showForm ? Icons.close : Icons.add_rounded),
        label: Text(
          _showForm
              ? AppStrings.get('cancel', lang)
              : AppStrings.get('addEntry', lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHistoryView(
      String lang,
      Color bgColor,
      Color cardColor,
      Color primaryText,
      Color secondaryText,
      Color accentColor,
      bool isDark
      ) {
    if (_trackingHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history_edu, size: 64, color: accentColor.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.get('noData', lang),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: secondaryText),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the + button to add the first record.",
              style: TextStyle(fontSize: 14, color: secondaryText.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemCount: _trackingHistory.length,
      itemBuilder: (context, index) {
        final entry = _trackingHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.0 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          entry['date'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 16),

                // Stats Grid
                Row(
                  children: [
                    // Weight - Wrapped in Expanded to share width
                    if (entry['weight'].isNotEmpty)
                      Expanded(
                        child: _buildStatBadge(
                          icon: Icons.monitor_weight_outlined,
                          label: AppStrings.get('weight', lang),
                          value: '${entry['weight']} kg',
                          color: Colors.blueAccent,
                          isDark: isDark,
                        ),
                      ),

                    if (entry['weight'].isNotEmpty && entry['feedingAmount'].isNotEmpty)
                      const SizedBox(width: 12),

                    // Feeding - Wrapped in Expanded to share width
                    if (entry['feedingAmount'].isNotEmpty)
                      Expanded(
                        child: _buildStatBadge(
                          icon: Icons.water_drop_outlined,
                          label: AppStrings.get('feedingAmount', lang),
                          value: '${entry['feedingAmount']} ml',
                          color: Colors.orangeAccent,
                          isDark: isDark,
                        ),
                      ),
                  ],
                ),

                // Oxygen - NOT wrapped in Expanded because it's in a Column (avoids the crash)
                if (entry['oxygenSaturation'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildStatBadge(
                    icon: Icons.air,
                    label: AppStrings.get('oxygenSaturation', lang),
                    value: '${entry['oxygenSaturation']}%',
                    color: Colors.redAccent,
                    isDark: isDark,
                    fullWidth: true,
                  ),
                ],

                // Equipment Note
                if (entry['equipment'] != null && entry['equipment'].isNotEmpty) ...[
                  const SizedBox(height: 16), // A bit more space
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.transparent, // No solid fill (looks cleaner)
                      borderRadius: BorderRadius.circular(12),
                      // A subtle colored border instead of a grey box
                      border: Border.all(
                          color: accentColor.withOpacity(0.3),
                          width: 1.5
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label Row
                        Row(
                          children: [
                            Icon(Icons.medical_services_outlined, size: 18, color: accentColor),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.get('equipment', lang).toUpperCase(),
                              style: TextStyle(
                                fontSize: 12, // Label size
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // The Actual Content (Bigger Font)
                        Text(
                          entry['equipment'],
                          style: TextStyle(
                            fontSize: 14, // Increased from 13
                            fontWeight: FontWeight.w600, // Semi-bold for readability
                            color: primaryText,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (entry['notes'] != null && entry['notes'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: accentColor.withOpacity(0.3),
                          width: 1.5
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label Row
                        Row(
                          children: [
                            Icon(Icons.note_alt_outlined, size: 18, color: accentColor),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.get('notes', lang).toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // The Actual Note Content
                        Text(
                          entry['notes'],
                          style: TextStyle(
                            fontSize: 14, // Large readable font
                            fontWeight: FontWeight.w600,
                            color: primaryText,
                            height: 1.4, // Slightly taller line height for paragraph text
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }


  // --- FIXED HELPER (Removed Expanded) ---
  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    bool fullWidth = false,
  }) {
    // We return a simple Container now.
    // The parent determines if it should expand.
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Flexible( // Use Flexible instead of Expanded here for text safety
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color.withOpacity(0.8),
                      letterSpacing: 0.5
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addTrackingEntry(Map<String, dynamic> entry) {
    // 1. Close Keyboard first to prevent freeze
    FocusScope.of(context).unfocus();

    setState(() {
      _trackingHistory.insert(0, entry);
      _showForm = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF3A1C71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              AppStrings.get('save', context.read<AppService>().currentLanguage),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}