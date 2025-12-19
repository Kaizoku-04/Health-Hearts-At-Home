import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/themes.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final bool autoPlay;

  const CustomVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    this.autoPlay = true,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    // Initialize video controller
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..addListener(() {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      });

    _initializeVideoPlayerFuture = _controller.initialize();

    // Auto-play if set
    if (widget.autoPlay) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Video player with controls
              GestureDetector(
                onTap: () => setState(() => _showControls = !_showControls),
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      if (_showControls)
                        Container(
                          color: Colors.black26,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Play/Pause button
                              FloatingActionButton(
                                mini: true,
                                backgroundColor: customTheme[500],
                                onPressed: () {
                                  setState(() {
                                    _isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  });
                                },
                                child: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                              // Seek backward
                              FloatingActionButton(
                                mini: true,
                                backgroundColor: customTheme[500],
                                onPressed: () {
                                  _controller.seekTo(
                                    _controller.value.position -
                                        const Duration(seconds: 10),
                                  );
                                },
                                child: const Icon(
                                  Icons.replay_10,
                                  color: Colors.white,
                                ),
                              ),
                              // Seek forward
                              FloatingActionButton(
                                mini: true,
                                backgroundColor: customTheme[500],
                                onPressed: () {
                                  _controller.seekTo(
                                    _controller.value.position +
                                        const Duration(seconds: 10),
                                  );
                                },
                                child: const Icon(
                                  Icons.forward_10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Video progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: customTheme[500]!,
                    bufferedColor: Colors.grey[300]!,
                    backgroundColor: Colors.grey[200]!,
                  ),
                ),
              ),
              // Duration info
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_controller.value.position)),
                    Text(_formatDuration(_controller.value.duration)),
                  ],
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Container(
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Error loading video',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initializeVideoPlayerFuture = _controller.initialize();
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          return Container(
            color: Colors.black,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
                SizedBox(height: 16),
                Text('Loading video...', style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        }
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours == 0) {
      return '$minutes:$seconds';
    } else {
      return '$hours:$minutes:$seconds';
    }
  }
}
