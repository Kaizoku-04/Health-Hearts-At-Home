import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../services/url_launcher_service.dart'; // ✅ Import for link handling
import '../widgets/video_player_widget.dart';
// Note: Ensure this model import matches your project structure
// It might be 'tutorial_model.dart' or 'tutorials_item.dart' depending on your file naming
import '../models/tutorials_item.dart';

class VideoDetailPage extends StatelessWidget {
  final TutorialsItem video;
  final bool isDark;
  final VoidCallback onToggleTheme;

  const VideoDetailPage({
    super.key,
    required this.video,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    // --- DYNAMIC THEME CHECK ---
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // --- NEUTRAL PLATINUM PALETTE ---
    final bgColor = isDarkTheme ? const Color(0xFF121212) : const Color(0xFFE7E7EC);
    final cardColor = isDarkTheme ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDarkTheme ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDarkTheme ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);

    // Accent: Video Teal
    const accentColor = Color(0xFF2A9D8F);

    return Scaffold(
      backgroundColor: bgColor,
      // Standardized AppBar to match other pages
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          video.title,
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkTheme ? Icons.light_mode : Icons.dark_mode,
              color: primaryText,
            ),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- VIDEO PLAYER SECTION ---
            if (video.videoUrl != null)
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkTheme ? 0.0 : 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CustomVideoPlayer(
                  videoUrl: video.videoUrl!,
                  title: video.title,
                ),
              )
            else
            // Fallback if no URL
              Container(
                height: 200,
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.videocam_off, color: Colors.white54, size: 50),
                ),
              ),

            // --- DETAILS SECTION ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withOpacity(isDarkTheme ? 0.2 : 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkTheme ? 0.0 : 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      video.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: primaryText,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: secondaryText.withOpacity(0.2)),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      video.description ?? "",
                      style: TextStyle(
                        fontSize: 15,
                        color: secondaryText,
                        height: 1.6,
                      ),
                    ),

                    // External Link Button
                    if (video.externalLink != null && video.externalLink!.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: accentColor.withOpacity(0.4),
                          ),
                          onPressed: () {
                            URLLauncherService.openWebsite(video.externalLink!);
                          },
                          icon: const Icon(Icons.open_in_new_rounded, size: 20),
                          label: Text(
                            AppStrings.get('visitLink', lang) == 'visitLink'
                                ? 'Visit Link' // Fallback if string missing
                                : AppStrings.get('visitLink', lang),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}