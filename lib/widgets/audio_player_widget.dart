import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Audio Player Widget for recorded audio
class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final VoidCallback onDelete;

  const AudioPlayerWidget({
    super.key,
    required this.audioPath,
    required this.onDelete,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    if (_isDisposed) return;

    try {
      await _audioPlayer.setFilePath(widget.audioPath);

      // Set volume to maximum
      await _audioPlayer.setVolume(1.0);

      if (!_isDisposed && mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      // Listen for state changes
      _audioPlayer.playerStateStream.listen((state) {
        if (!_isDisposed && mounted) {
          setState(() {
            _isPlaying = state.playing;
          });

          // Check if completed
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              _isPlaying = false;
            });
          }
        }
      });
    } catch (e) {
      print('Error initializing audio: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  Future<void> _togglePlay() async {
    if (!_isInitialized || _isDisposed) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // Ensure volume is set to maximum before playing
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.play();
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> _handleDelete() async {
    try {
      if (_isInitialized && !_isDisposed) {
        await _audioPlayer.stop();
        await _audioPlayer.dispose();
        _isDisposed = true;
      }
    } catch (e) {
      print('Error stopping audio: $e');
    }

    // Delete the file
    try {
      final file = File(widget.audioPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting audio file: $e');
    }

    // Call the callback
    widget.onDelete();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.base2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Success icon (tick) - tappable to play
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryAccent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.check,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Audio info
          Expanded(
            child: GestureDetector(
              onTap: _togglePlay,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audio recorded',
                    style: AppTextStyles.b1Regular(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isPlaying ? 'Playing...' : 'Tap to play',
                    style: AppTextStyles.s1Regular(
                      context,
                    ).copyWith(color: AppColors.text3),
                  ),
                ],
              ),
            ),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.negative),
            onPressed: _handleDelete,
          ),
        ],
      ),
    );
  }
}
