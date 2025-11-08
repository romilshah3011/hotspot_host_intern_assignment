import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Video Recording Screen
class VideoRecordingScreen extends StatefulWidget {
  final CameraDescription camera;

  const VideoRecordingScreen({super.key, required this.camera});

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  List<CameraDescription>? _cameras;
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      // Find the index of the initial camera
      _currentCameraIndex = _cameras!.indexWhere(
        (camera) => camera.lensDirection == widget.camera.lensDirection,
      );
      if (_currentCameraIndex == -1) {
        _currentCameraIndex = 0;
      }
      await _initializeCamera(_cameras![_currentCameraIndex]);
    }
  }

  Future<void> _initializeCamera(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _controller!.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    try {
      // Save current recording state
      final wasRecording = _isRecording;
      String? recordingPath;

      if (wasRecording) {
        // Stop current recording temporarily
        try {
          final file = await _controller!.stopVideoRecording();
          if (file != null) {
            recordingPath = file.path;
          }
        } catch (e) {
          print('Error stopping recording for camera switch: $e');
        }
        setState(() {
          _isRecording = false;
        });
      }

      // Dispose current controller
      await _controller?.dispose();
      _controller = null;

      // Wait a bit for camera to release
      await Future.delayed(const Duration(milliseconds: 300));

      // Switch camera
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
      await _initializeCamera(_cameras![_currentCameraIndex]);

      // Wait for camera to initialize
      await Future.delayed(const Duration(milliseconds: 200));

      // Resume recording if it was recording
      if (wasRecording &&
          _controller != null &&
          _controller!.value.isInitialized) {
        try {
          await _controller!.startVideoRecording();
          setState(() {
            _isRecording = true;
          });
        } catch (e) {
          print('Error resuming recording: $e');
          // If we can't resume, delete the partial recording
          if (recordingPath != null) {
            try {
              final file = File(recordingPath);
              if (await file.exists()) {
                await file.delete();
              }
            } catch (_) {}
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not resume recording after camera switch'),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error switching camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error switching camera: $e')));
      }
    }
  }

  Future<void> _startRecording() async {
    if (!_controller!.value.isInitialized || _isRecording) {
      return;
    }

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) {
      return;
    }

    try {
      final file = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });

      // The file path is returned from stopVideoRecording
      if (mounted && file != null) {
        Navigator.pop(context, file.path);
      }
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    if (_isRecording) {
      final file = await _controller!.stopVideoRecording();
      if (file != null) {
        try {
          final videoFile = File(file.path);
          if (await videoFile.exists()) {
            await videoFile.delete();
          }
        } catch (e) {
          // Ignore file deletion errors
        }
      }
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          SizedBox.expand(child: CameraPreview(_controller!)),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _cancelRecording,
                  ),
                  if (_isRecording)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.negative,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Recording',
                                style: AppTextStyles.b1Regular(
                                  context,
                                ).copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        // Camera switch button (available during recording)
                        if (_cameras != null && _cameras!.length > 1) ...[
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(
                              Icons.flip_camera_ios,
                              color: Colors.white,
                            ),
                            onPressed: _switchCamera,
                          ),
                        ],
                      ],
                    )
                  else
                  // Camera switch button (when not recording)
                  if (_cameras != null && _cameras!.length > 1)
                    IconButton(
                      icon: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                      ),
                      onPressed: _switchCamera,
                    ),
                ],
              ),
            ),
          ),
          // Bottom controls
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isRecording)
                      ElevatedButton(
                        onPressed: _startRecording,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: const Icon(Icons.videocam, size: 32),
                      )
                    else
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _cancelRecording,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.base2,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                            ),
                            child: const Icon(Icons.close, size: 32),
                          ),
                          const SizedBox(width: 24),
                          ElevatedButton(
                            onPressed: _stopRecording,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.negative,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                            ),
                            child: const Icon(Icons.stop, size: 32),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
