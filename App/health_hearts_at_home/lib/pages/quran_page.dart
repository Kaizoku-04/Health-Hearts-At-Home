// lib/pages/quran_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../widgets/app_bar_widget.dart';
import '../models/themes.dart';
import '../data/spiritual_texts.dart';
import '../models/spiritual_item.dart';

class QuranPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const QuranPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final _player = AudioPlayer();
  int? _currentlyPlayingIndex;
  int? _loadingIndex; // <- track which item is currently loading/buffering
  StreamSubscription<PlayerState>? _playerStateSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppService>().fetchSpiritualContent();
    });

    // Listen to player state so UI reflects loading/buffering/ready states.
    _playerStateSub = _player.playerStateStream.listen((playerState) {
      final processing = playerState.processingState;
      // If player is loading or buffering, mark the currently playing index as loading.
      if (processing == ProcessingState.loading ||
          processing == ProcessingState.buffering) {
        if (_currentlyPlayingIndex != _loadingIndex) {
          setState(() {
            _loadingIndex = _currentlyPlayingIndex;
          });
        }
      } else {
        // Not loading/buffering anymore: clear loading index
        if (_loadingIndex != null) {
          setState(() {
            _loadingIndex = null;
          });
        }
      }

      // Optional: if playback stopped/ended, you can clear current index:
      if (processing == ProcessingState.completed) {
        setState(() {
          _currentlyPlayingIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayFromItem(SpiritualItem item) async {
    final index = item.index;
    final audioUrl = item.audioUrl; // from backend

    try {
      // If same item is playing -> pause
      if (_currentlyPlayingIndex == index && _player.playing) {
        await _player.pause();
        setState(() {}); // update icon
        return;
      }

      // If playing a different item, stop it first
      if (_currentlyPlayingIndex != null && _currentlyPlayingIndex != index) {
        await _player.stop();
      }

      // Mark as the item we're working on (used by the player stream too)
      setState(() {
        _currentlyPlayingIndex = index;
        _loadingIndex = index; // optimistic: show loading spinner for this item
      });

      // Load & play
      await _player.setUrl(audioUrl);
      await _player.play();

      // NOTE: we don't manually set _loadingIndex = null here,
      // the playerStateStream listener will clear it when ready.
    } catch (e) {
      // clear loading flag on error
      setState(() {
        if (_loadingIndex == index) _loadingIndex = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e', maxLines: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;
    final items = appService.spiritualItems; // expose getter in AppService
    final isLoading = appService.isLoading;
    final error = appService.errorMessage;

    return Scaffold(
      appBar: CHDAppBar(
        title: lang == 'ar' ? 'آيات من القرآن الكريم' : 'Qur\'an Verses',
        onToggleTheme: widget.onToggleTheme,
        isDark: widget.isDark,
      ),
      body: Builder(
        builder: (_) {
          if (isLoading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null && items.isEmpty) {
            return Center(child: Text(error));
          }
          if (items.isEmpty) {
            return Center(
              child: Text(lang == 'ar' ? 'لا توجد تلاوات' : 'No recitations'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final index = item.index; // 1..8 from DB
              final body = SpiritualTexts.getBody(index, lang);
              final isCurrent = _currentlyPlayingIndex == index;
              final isPlaying = isCurrent && _player.playing;
              final isThisLoading = _loadingIndex == index;

              return Card(
                elevation: 3,
                shadowColor: customTheme[500]?.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: lang == 'ar'
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        body,
                        textAlign: lang == 'ar'
                            ? TextAlign.right
                            : TextAlign.left,
                        style: const TextStyle(fontSize: 14, height: 1.6),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: lang == 'ar'
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: customTheme[500],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          // Only disable this specific button while it's loading
                          onPressed: isThisLoading
                              ? null
                              : () => _togglePlayFromItem(item),
                          icon: isThisLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                ),
                          label: Text(
                            isPlaying
                                ? (lang == 'ar' ? 'إيقاف' : 'Pause')
                                : (lang == 'ar' ? 'تشغيل التلاوة' : 'Play'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
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
