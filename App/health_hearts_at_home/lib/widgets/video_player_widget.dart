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
  // ✅ FIX 1: Make controller nullable to avoid LateInitializationError
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
      // Create the controller
      final controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

      // Assign it to state variable
      _controller = controller;

      await controller.initialize();

      // ✅ FIX 2: Check mounted before setState (prevents crash if user left already)
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    // ✅ FIX 3: safe dispose logic
    final controller = _controller;
    if (controller != null) {
      // Stop playback to prevent audio leak or background playing
      if (controller.value.isPlaying) {
        controller.pause();
      }
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

        // Auto-hide controls
        Future.delayed(const Duration(seconds: 2), () {
          // ✅ FIX 4: Safety checks inside async delay
          if (mounted && controller.value.isPlaying) {
            setState(() => _showControls = false);
          }
        });
      }
    });
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

    // Safely unwrap controller for UI usage
    final controller = _controller;

    if (!_isInitialized || controller == null) {
      return Container(
        height: 220,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Video
          GestureDetector(
            onTap: () {
              setState(() => _showControls = !_showControls);
            },
            child: VideoPlayer(controller),
          ),

          // 2. Play/Pause Overlay
          if (_showControls || !controller.value.isPlaying)
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),

          // 3. Progress Bar
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF2A9D8F),
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}