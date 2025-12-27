// lib/pages/quran_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
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
  int? _loadingIndex;
  StreamSubscription<PlayerState>? _playerStateSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppService>().fetchSpiritualContent();
    });

    _playerStateSub = _player.playerStateStream.listen((playerState) {
      final processing = playerState.processingState;
      if (processing == ProcessingState.loading ||
          processing == ProcessingState.buffering) {
        if (_currentlyPlayingIndex != _loadingIndex) {
          setState(() {
            _loadingIndex = _currentlyPlayingIndex;
          });
        }
      } else {
        if (_loadingIndex != null) {
          setState(() {
            _loadingIndex = null;
          });
        }
      }

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
    final audioUrl = item.audioUrl;

    try {
      if (_currentlyPlayingIndex == index && _player.playing) {
        await _player.pause();
        setState(() {});
        return;
      }

      if (_currentlyPlayingIndex != null && _currentlyPlayingIndex != index) {
        await _player.stop();
      }

      setState(() {
        _currentlyPlayingIndex = index;
        _loadingIndex = index;
      });

      await _player.setUrl(audioUrl);
      await _player.play();
    } catch (e) {
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
    final items = appService.spiritualItems;
    final isLoading = appService.isLoading;
    final error = appService.errorMessage;

    // --- DYNAMIC THEME CHECK ---
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // --- NEUTRAL PLATINUM PALETTE ---
    final bgColor = isDarkTheme ? const Color(0xFF121212) : const Color(0xFFE7E7EC);
    final cardColor = isDarkTheme ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDarkTheme ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDarkTheme ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);

    // Accent: Serene Emerald (Spiritual/Calm)
    const accentColor = Color(0xFF10B981);

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
          lang == 'ar' ? 'آيات من القرآن الكريم' : 'Qur\'an Verses',
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
            onPressed: () {
              final newLang = lang == 'en' ? 'ar' : 'en';
              appService.setLanguage(newLang);
            },
          ),
          IconButton(
            icon: Icon(isDarkTheme ? Icons.light_mode : Icons.dark_mode, color: primaryText),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          // 1. Loading State
          if (isLoading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: accentColor));
          }

          // 2. Error State
          if (error != null && items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent.withOpacity(0.8)),
                    const SizedBox(height: 16),
                    Text(error, textAlign: TextAlign.center, style: TextStyle(color: secondaryText)),
                  ],
                ),
              ),
            );
          }

          // 3. Empty State
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, size: 64, color: secondaryText.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    lang == 'ar' ? 'لا توجد تلاوات' : 'No recitations found',
                    style: TextStyle(fontSize: 16, color: secondaryText),
                  ),
                ],
              ),
            );
          }

          // 4. Content List
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final index = item.index;
              final body = SpiritualTexts.getBody(index, lang);
              final isCurrent = _currentlyPlayingIndex == index;
              final isPlaying = isCurrent && _player.playing;
              final isThisLoading = _loadingIndex == index;

              return _buildVerseCard(
                body: body,
                lang: lang,
                isCurrent: isCurrent,
                isPlaying: isPlaying,
                isLoading: isThisLoading,
                onPlayTap: () => _togglePlayFromItem(item),
                cardColor: cardColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                accentColor: accentColor,
                isDark: isDarkTheme,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVerseCard({
    required String body,
    required String lang,
    required bool isCurrent,
    required bool isPlaying,
    required bool isLoading,
    required VoidCallback onPlayTap,
    required Color cardColor,
    required Color primaryText,
    required Color secondaryText,
    required Color accentColor,
    required bool isDark,
  }) {
    // Highlight border if playing
    final borderColor = isCurrent
        ? accentColor.withOpacity(0.6)
        : Colors.grey.withOpacity(isDark ? 0.2 : 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: isCurrent ? 1.5 : 1.0),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? accentColor.withOpacity(0.15)
                : Colors.black.withOpacity(isDark ? 0.0 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: lang == 'ar' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Verse Icon
            Row(
              mainAxisAlignment: lang == 'ar' ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Icon(Icons.format_quote_rounded, color: accentColor.withOpacity(0.5), size: 24),
              ],
            ),
            const SizedBox(height: 8),

            // Verse Text
            Text(
              body,
              textAlign: lang == 'ar' ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                height: 1.8,
                color: primaryText,
                fontFamily: lang == 'ar' ? 'Amiri' : null, // Optional: if you have Arabic font
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Play Button Area
            Align(
              alignment: lang == 'ar' ? Alignment.centerLeft : Alignment.centerRight,
              child: SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrent ? Colors.redAccent : accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : onPlayTap,
                  icon: isLoading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 20,
                  ),
                  label: Text(
                    isPlaying
                        ? (lang == 'ar' ? 'إيقاف' : 'Pause')
                        : (lang == 'ar' ? 'استماع' : 'Listen'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}