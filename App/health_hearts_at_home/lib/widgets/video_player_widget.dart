import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;

  const CustomVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      _controller = controller;

      await controller.initialize();

      // Add listener to update UI for timestamps
      controller.addListener(() {
        // Only rebuild if controls are visible (optimization)
        if (_showControls && mounted) {
          setState(() {});
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) {
      if (controller.value.isPlaying) controller.pause();
      controller.dispose();
    }
    super.dispose();
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;

    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
        _showControls = true;
      } else {
        controller.play();
        _showControls = false;
      }
    });
  }

  void _seekRelative(int seconds) {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;

    final current = controller.value.position;
    final duration = controller.value.duration;

    // Calculate new position
    var newPos = current + Duration(seconds: seconds);

    // Clamp between 0 and total duration
    if (newPos < Duration.zero) newPos = Duration.zero;
    if (newPos > duration) newPos = duration;

    controller.seekTo(newPos);

    // Keep controls visible when seeking
    setState(() => _showControls = true);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 220,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white54, size: 40),
              SizedBox(height: 8),
              Text("Video unavailable", style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      );
    }

    final controller = _controller;
    if (!_isInitialized || controller == null) {
      return Container(
        height: 220,
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Video Layer
          GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
            child: VideoPlayer(controller),
          ),

          // 2. Controls Overlay
          if (_showControls || !controller.value.isPlaying)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- Main Buttons Row (Rewind | Play | Forward) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Rewind 10s
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                        onPressed: () => _seekRelative(-10),
                      ),
                      const SizedBox(width: 24),

                      // Play/Pause Button
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            controller.value.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Forward 10s
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                        onPressed: () => _seekRelative(10),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // 3. Bottom Bar (Progress + Timestamp)
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    // Play/Pause Icon Small
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Icon(
                        controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Progress Text (e.g., 01:20 / 03:45)
                    Text(
                      "${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),

                    const SizedBox(width: 12),

                    // Progress Bar
                    Expanded(
                      child: VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFF2A9D8F),
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white12,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}