import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/wavy_progress_bar.dart';
import '../widgets/background_pattern.dart';
import '../providers/onboarding_provider.dart';
import '../utils/permission_helper.dart';
import '../utils/audio_recorder_helper.dart';
import '../widgets/audio_recording_widget.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/video_player_widget.dart';
import '../screens/video_recording_screen.dart';

/// Onboarding Question Screen
class OnboardingQuestionScreen extends ConsumerStatefulWidget {
  const OnboardingQuestionScreen({super.key});

  @override
  ConsumerState<OnboardingQuestionScreen> createState() =>
      _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState
    extends ConsumerState<OnboardingQuestionScreen> {
  final TextEditingController _answerController = TextEditingController();
  final int maxCharacters = 600;
  AudioRecorderHelper? _audioRecorderHelper;
  bool _isRecordingAudio = false;

  @override
  void dispose() {
    _answerController.dispose();
    _audioRecorderHelper?.dispose();
    super.dispose();
  }

  Future<void> _startAudioRecording() async {
    final hasPermission = await PermissionHelper.requestMicrophonePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }

    setState(() {
      _audioRecorderHelper = AudioRecorderHelper();
      _isRecordingAudio = true;
    });

    final path = await _audioRecorderHelper!.startRecording();
    if (path == null) {
      setState(() {
        _isRecordingAudio = false;
        _audioRecorderHelper?.dispose();
        _audioRecorderHelper = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start recording')),
      );
    }
  }

  void _onAudioRecordingComplete(String path) {
    ref.read(onboardingQuestionProvider.notifier).setAudioPath(path);
    setState(() {
      _isRecordingAudio = false;
      _audioRecorderHelper?.dispose();
      _audioRecorderHelper = null;
    });
  }

  void _onAudioRecordingCancel() {
    setState(() {
      _isRecordingAudio = false;
      _audioRecorderHelper?.dispose();
      _audioRecorderHelper = null;
    });
  }

  Future<void> _startVideoRecording() async {
    final hasPermission = await PermissionHelper.requestCameraPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera permission denied')));
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No cameras available')));
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoRecordingScreen(camera: cameras.first),
      ),
    );

    if (result != null && result is String) {
      ref.read(onboardingQuestionProvider.notifier).setVideoPath(result);
    }
  }

  void _deleteAudio() {
    setState(() {
      // Clear local state
      _audioRecorderHelper?.dispose();
      _audioRecorderHelper = null;
      _isRecordingAudio = false;
    });
    // Update provider state
    ref.read(onboardingQuestionProvider.notifier).deleteAudio();
  }

  void _deleteVideo() {
    // Update provider state
    ref.read(onboardingQuestionProvider.notifier).deleteVideo();
  }

  void _handleNext() {
    final state = ref.read(onboardingQuestionProvider);
    final answer = _answerController.text.trim();

    // Validation - answer is compulsory
    if (answer.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please provide an answer')));
      return;
    }

    // Update answer in state
    ref.read(onboardingQuestionProvider.notifier).updateAnswer(answer);

    print('Answer: ${state.answer}');
    print('Audio Path: ${state.audioPath}');
    print('Video Path: ${state.videoPath}');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Questionnaire submitted successfully!'),
        backgroundColor: AppColors.positive,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back to home screen (first page) after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionState = ref.watch(onboardingQuestionProvider);
    // Answer is compulsory, audio and video are optional
    final canProceed = questionState.answer.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.base,
      body: BackgroundPattern(
        child: SafeArea(
          child: Column(
            children: [
              // Header with progress bar
              _buildHeader(context),
              // Main content - push to bottom
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 40,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Step number
                            Text(
                              '02',
                              style: AppTextStyles.s1Regular(
                                context,
                              ).copyWith(color: AppColors.text3),
                            ),
                            const SizedBox(height: 8),
                            // Question
                            Text(
                              'Why do you want to host with us?',
                              style: AppTextStyles.h1Bold(context),
                            ),
                            const SizedBox(height: 8),
                            // Description
                            Text(
                              'Tell us about your intent and what motivates you to create experiences.',
                              style: AppTextStyles.b1Regular(
                                context,
                              ).copyWith(color: AppColors.text2),
                            ),
                            const SizedBox(height: 24),
                            // Answer textfield
                            _buildAnswerField(context),
                            const SizedBox(height: 24),
                            // Audio recording widget (if recording)
                            if (_isRecordingAudio &&
                                _audioRecorderHelper != null)
                              AudioRecordingWidget(
                                recorderHelper: _audioRecorderHelper!,
                                onRecordingComplete: _onAudioRecordingComplete,
                                onCancel: _onAudioRecordingCancel,
                              ),
                            // Audio player widget (if recorded)
                            if (questionState.audioPath != null &&
                                !_isRecordingAudio)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: AudioPlayerWidget(
                                  key: ValueKey(
                                    'audio_${questionState.audioPath}',
                                  ),
                                  audioPath: questionState.audioPath!,
                                  onDelete: _deleteAudio,
                                ),
                              ),
                            // Video player widget (if recorded)
                            if (questionState.videoPath != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: VideoPlayerWidget(
                                  key: ValueKey(
                                    'video_${questionState.videoPath}',
                                  ),
                                  videoPath: questionState.videoPath!,
                                  onDelete: _deleteVideo,
                                ),
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom action bar
              _buildBottomActionBar(context, questionState, canProceed),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.text1),
            onPressed: () => Navigator.pop(context),
          ),
          // Progress bar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: WavyProgressBar(currentStep: 2, totalSteps: 2, height: 4),
            ),
          ),
          // Close button
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.text1),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerField(BuildContext context) {
    final questionState = ref.watch(onboardingQuestionProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.base2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: questionState.answer.isNotEmpty
              ? AppColors.primaryAccent
              : AppColors.border1,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _answerController,
            maxLines: 8,
            maxLength: maxCharacters,
            style: AppTextStyles.b1Regular(context),
            decoration: InputDecoration(
              hintText: '/ Start typing here',
              hintStyle: AppTextStyles.b1Regular(
                context,
              ).copyWith(color: AppColors.text3),
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (value) {
              ref.read(onboardingQuestionProvider.notifier).updateAnswer(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${_answerController.text.length}/$maxCharacters',
            style: AppTextStyles.s1Regular(
              context,
            ).copyWith(color: AppColors.text3),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    OnboardingQuestionState questionState,
    bool canProceed,
  ) {
    final showAudioButton =
        questionState.audioPath == null && !_isRecordingAudio;
    final showVideoButton = questionState.videoPath == null;
    final showRecordingButtons = showAudioButton || showVideoButton;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Recording buttons (if not recorded) - animated width
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: showRecordingButtons ? null : 0,
            child: showRecordingButtons
                ? Expanded(
                    child: Row(
                      children: [
                        if (showAudioButton)
                          Expanded(
                            child: _buildRecordButton(
                              context,
                              icon: Icons.mic,
                              onTap: _startAudioRecording,
                            ),
                          ),
                        if (showAudioButton && showVideoButton)
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.border1,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        if (showVideoButton)
                          Expanded(
                            child: _buildRecordButton(
                              context,
                              icon: Icons.videocam,
                              onTap: _startVideoRecording,
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Spacer - animated
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: showRecordingButtons ? 12 : 0,
          ),
          // Next button - ALWAYS visible with animated width
          Expanded(
            flex: showRecordingButtons ? 2 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: canProceed ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.base2,
                    disabledBackgroundColor: AppColors.base2.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next',
                        style: AppTextStyles.b1Bold(context).copyWith(
                          color: canProceed ? AppColors.text1 : AppColors.text3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Double arrow icon (arrow + chevron)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            color: canProceed
                                ? AppColors.text1
                                : AppColors.text3,
                            size: 18,
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: canProceed
                                ? AppColors.text1
                                : AppColors.text3,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.base2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border1, width: 1),
        ),
        child: Center(child: Icon(icon, color: AppColors.text1, size: 24)),
      ),
    );
  }
}
