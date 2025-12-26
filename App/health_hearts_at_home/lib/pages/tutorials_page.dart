import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/content_card.dart';
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
    // ✅ Fetch tutorials when page loads
    Future.microtask(() {
      context.read<AppService>().fetchTutorials();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    return Scaffold(
      appBar: CHDAppBar(
        title: AppStrings.get('tutorials', lang),
        onToggleTheme: widget.onToggleTheme, // ✅ FIX: Use widget.onToggleTheme
        isDark: widget.isDark, // ✅ FIX: Use widget.isDark
      ),
      body: appService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : appService.errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.get('errorLoading', lang),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appService.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => appService.fetchTutorials(),
                    child: Text(AppStrings.get('tryAgain', lang)),
                  ),
                ],
              ),
            )
          : appService.tutorialsItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.get('noData', lang),
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: appService.tutorialsItems.length,
              itemBuilder: (context, index) {
                final tutorial = appService.tutorialsItems[index];
                return ContentCard(
                  title: tutorial.title,
                  description: tutorial.description!,
                  imageUrl: tutorial.imageUrl,
                  hasVideo: tutorial.videoUrl != null,
                  onTap: () {
                    // ✅ Navigate to video player
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoDetailPage(
                          video: tutorial,
                          isDark: widget.isDark,
                          onToggleTheme: widget.onToggleTheme,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
