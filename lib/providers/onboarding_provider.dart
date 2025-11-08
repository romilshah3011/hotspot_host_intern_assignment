import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State model for onboarding question
class OnboardingQuestionState {
  final String answer;
  final String? audioPath;
  final String? videoPath;
  final bool isRecordingAudio;
  final bool isRecordingVideo;

  OnboardingQuestionState({
    this.answer = '',
    this.audioPath,
    this.videoPath,
    this.isRecordingAudio = false,
    this.isRecordingVideo = false,
  });

  OnboardingQuestionState copyWith({
    String? answer,
    String? audioPath,
    String? videoPath,
    bool? isRecordingAudio,
    bool? isRecordingVideo,
  }) {
    return OnboardingQuestionState(
      answer: answer ?? this.answer,
      audioPath: audioPath ?? this.audioPath,
      videoPath: videoPath ?? this.videoPath,
      isRecordingAudio: isRecordingAudio ?? this.isRecordingAudio,
      isRecordingVideo: isRecordingVideo ?? this.isRecordingVideo,
    );
  }
}

/// Provider for onboarding question state
final onboardingQuestionProvider =
    StateNotifierProvider<OnboardingQuestionNotifier, OnboardingQuestionState>(
      (ref) => OnboardingQuestionNotifier(),
    );

class OnboardingQuestionNotifier
    extends StateNotifier<OnboardingQuestionState> {
  OnboardingQuestionNotifier() : super(OnboardingQuestionState());

  void updateAnswer(String answer) {
    state = state.copyWith(answer: answer);
  }

  void setAudioPath(String? path) {
    state = state.copyWith(audioPath: path, isRecordingAudio: false);
  }

  void setVideoPath(String? path) {
    state = state.copyWith(videoPath: path, isRecordingVideo: false);
  }

  void setRecordingAudio(bool isRecording) {
    state = state.copyWith(isRecordingAudio: isRecording);
  }

  void setRecordingVideo(bool isRecording) {
    state = state.copyWith(isRecordingVideo: isRecording);
  }

  void deleteAudio() {
    state = state.copyWith(audioPath: null, isRecordingAudio: false);
  }

  void deleteVideo() {
    state = state.copyWith(videoPath: null, isRecordingVideo: false);
  }

  void reset() {
    state = OnboardingQuestionState();
  }
}
