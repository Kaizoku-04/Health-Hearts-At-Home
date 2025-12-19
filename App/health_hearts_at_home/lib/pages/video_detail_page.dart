import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/video_player_widget.dart';
import '../models/content_model.dart';

class VideoDetailPage extends StatelessWidget {
  final ContentItem video;
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
    return Scaffold(
      appBar: CHDAppBar(
        title: video.title,
        onToggleTheme: onToggleTheme,
        isDark: isDark,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (video.videoUrl != null)
              CustomVideoPlayer(videoUrl: video.videoUrl!, title: video.title),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                  if (video.externalLink != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Implement URL launcher here later
                      },
                      child: const Text('Visit External Link'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
