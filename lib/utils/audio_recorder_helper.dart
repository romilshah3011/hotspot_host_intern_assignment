import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Audio Recorder Helper
class AudioRecorderHelper {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;
  Duration _duration = Duration.zero;
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();

  Stream<Duration> get durationStream => _durationController.stream;
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  Future<bool> get isRecording => _recorder.isRecording();

  /// Start recording audio
  Future<String?> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );

        _duration = Duration.zero;
        _startTimer();
        _startAmplitudeListener();

        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Stop recording audio
  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _stopTimer();
      _stopAmplitudeListener();
      _duration = Duration.zero;
      return path;
    } catch (e) {
      return null;
    }
  }

  /// Cancel recording
  Future<void> cancelRecording() async {
    try {
      final path = await _recorder.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _stopTimer();
      _stopAmplitudeListener();
      _duration = Duration.zero;
    } catch (e) {
      // Ignore errors
    }
  }

  /// Dispose resources
  void dispose() {
    _stopTimer();
    _stopAmplitudeListener();
    _durationController.close();
    _amplitudeController.close();
    _recorder.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration = _duration + const Duration(seconds: 1);
      _durationController.add(_duration);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startAmplitudeListener() {
    _recorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen((
      amp,
    ) {
      // Convert amplitude to a single value for waveform visualization
      final amplitude = amp.current;
      final normalizedAmplitude = (amplitude / 160).clamp(0.0, 1.0);
      // Send single value - the widget will handle creating the wave pattern
      _amplitudeController.add(normalizedAmplitude);
    });
  }

  void _stopAmplitudeListener() {
    // Amplitude stream will automatically stop when recording stops
  }
}
