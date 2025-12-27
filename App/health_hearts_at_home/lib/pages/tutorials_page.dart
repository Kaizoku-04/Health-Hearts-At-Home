import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import 'video_detail_page.dart';

class TutorialsPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const TutorialsPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<TutorialsPage> createState() => _TutorialsPageState();
}

class _TutorialsPageState extends State<TutorialsPage> {
  @override
  void initState() {
    super.initState();
    // ✅ Keep backend logic: Fetch tutorials when page loads
    Future.microtask(() {
      context.read<AppService>().fetchTutorials();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch AppService for changes
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    // --- DYNAMIC THEME CHECK ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // --- NEUTRAL PLATINUM PALETTE ---
    // ✅ Updated to your specific platinum color
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFE7E7EC);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);

    // Accent: Video Teal (Matches Home Page "Tutorials" Icon)
    const accentColor = Color(0xFF2A9D8F);

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
          AppStrings.get('tutorials', lang),
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // --- LANGUAGE TOGGLE ---
          IconButton(
            icon: const Icon(Icons.language),
            color: primaryText,
            tooltip: 'Change Language',
            onPressed: () {
              final newLang = lang == 'en' ? 'ar' : 'en';
              appService.setLanguage(newLang);
            },
          ),
          // --- THEME TOGGLE ---
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: primaryText,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: _buildBody(appService, lang, bgColor, cardColor, primaryText, secondaryText, accentColor, isDark),
    );
  }

  Widget _buildBody(
      AppService appService,
      String lang,
      Color bgColor,
      Color cardColor,
      Color primaryText,
      Color secondaryText,
      Color accentColor,
      bool isDark
      ) {
    // 1. Loading State
    if (appService.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: accentColor),
      );
    }

    // 2. Error State
    if (appService.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent.withOpacity(0.8)),
              const SizedBox(height: 16),
              Text(
                AppStrings.get('errorLoading', lang),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryText),
              ),
              const SizedBox(height: 8),
              Text(
                appService.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: secondaryText),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => appService.fetchTutorials(),
                icon: const Icon(Icons.refresh),
                label: Text(AppStrings.get('tryAgain', lang)),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty State
    if (appService.tutorialsItems.isEmpty) {
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
              child: Icon(Icons.video_library_outlined, size: 64, color: accentColor.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.get('noData', lang),
              style: TextStyle(fontSize: 16, color: secondaryText, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    // 4. Success State (List)
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: appService.tutorialsItems.length,
      itemBuilder: (context, index) {
        final tutorial = appService.tutorialsItems[index];
        return _buildVideoCard(
          context: context,
          tutorial: tutorial,
          cardColor: cardColor,
          primaryText: primaryText,
          secondaryText: secondaryText,
          accentColor: accentColor,
          isDark: isDark,
        );
      },
    );
  }

  // --- HELPER: VIDEO CARD ---
  Widget _buildVideoCard({
    required BuildContext context,
    required dynamic tutorial,
    required Color cardColor,
    required Color primaryText,
    required Color secondaryText,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        // ✅ ADDED: Border to match other pages
        border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoDetailPage(
                  video: tutorial,
                  isDark: isDark,
                  onToggleTheme: widget.onToggleTheme,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- THUMBNAIL SECTION ---
              Stack(
                alignment: Alignment.center,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: tutorial.imageUrl != null
                          ? Image.network(
                        tutorial.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                          child: Icon(Icons.broken_image, color: secondaryText),
                        ),
                      )
                          : Container(
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                        child: Icon(Icons.ondemand_video, size: 50, color: secondaryText),
                      ),
                    ),
                  ),

                  // Dark Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ),
                  ),

                  // Play Button
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 30),
                  ),
                ],
              ),

              // --- TEXT CONTENT ---
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutorial.title ?? "Untitled Video",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                        height: 1.2,
                      ),
                    ),
                    if (tutorial.description != null && tutorial.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        tutorial.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryText,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}