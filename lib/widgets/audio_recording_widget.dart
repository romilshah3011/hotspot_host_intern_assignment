import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/audio_recorder_helper.dart';

/// Audio Recording Widget
class AudioRecordingWidget extends ConsumerStatefulWidget {
  final Function(String) onRecordingComplete;
  final Function() onCancel;
  final AudioRecorderHelper recorderHelper;

  const AudioRecordingWidget({
    super.key,
    required this.onRecordingComplete,
    required this.onCancel,
    required this.recorderHelper,
  });

  @override
  ConsumerState<AudioRecordingWidget> createState() =>
      _AudioRecordingWidgetState();
}

class _AudioRecordingWidgetState extends ConsumerState<AudioRecordingWidget> {
  Duration _duration = Duration.zero;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<double>? _amplitudeSubscription;
  List<double> _amplitudes = [];

  @override
  void initState() {
    super.initState();
    _durationSubscription = widget.recorderHelper.durationStream.listen((
      duration,
    ) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _amplitudeSubscription = widget.recorderHelper.amplitudeStream.listen((
      amplitude,
    ) {
      if (mounted) {
        setState(() {
          // Add new amplitude value and keep last 20
          _amplitudes.add(amplitude);
          if (_amplitudes.length > 20) {
            _amplitudes = _amplitudes.sublist(_amplitudes.length - 20);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _amplitudeSubscription?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _stopRecording() async {
    final path = await widget.recorderHelper.stopRecording();
    if (path != null) {
      widget.onRecordingComplete(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.base2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recording Audio...', style: AppTextStyles.b1Regular(context)),
          const SizedBox(height: 16),
          Row(
            children: [
              // Microphone icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              // Waveform
              Expanded(child: _buildWaveform()),
              const SizedBox(width: 16),
              // Timer
              Text(
                _formatDuration(_duration),
                style: AppTextStyles.b1Bold(
                  context,
                ).copyWith(color: AppColors.primaryAccent),
              ),
              const SizedBox(width: 16),
              // Cancel button
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.text1),
                onPressed: () async {
                  await widget.recorderHelper.cancelRecording();
                  widget.onCancel();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stop button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _stopRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Stop Recording',
                style: AppTextStyles.b1Bold(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    // Generate waveform bars with up/down pattern
    final barCount = 20;
    final bars = List.generate(barCount, (index) {
      if (_amplitudes.isNotEmpty && index < _amplitudes.length) {
        final amplitude = _amplitudes[index];
        final height = (amplitude * 30).clamp(4.0, 30.0);
        return height;
      } else {
        // Default pattern: up/down waves
        final baseHeight = 15.0;
        final wave = (index % 4 < 2) ? 1.0 : 0.5; // Up/down pattern
        return baseHeight * wave;
      }
    });

    return SizedBox(
      height: 40,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: bars.map((height) {
          return Container(
            width: 3,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: _amplitudes.isNotEmpty
                  ? AppColors.primaryAccent
                  : AppColors.text3,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }).toList(),
      ),
    );
  }
}
