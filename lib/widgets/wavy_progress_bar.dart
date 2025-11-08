import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

/// Wavy Progress Bar Widget
class WavyProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double height;

  const WavyProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.height = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: WavyProgressPainter(
        progress: currentStep / totalSteps,
        height: height,
      ),
    );
  }
}

class WavyProgressPainter extends CustomPainter {
  final double progress;
  final double height;

  WavyProgressPainter({required this.progress, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    final progressWidth = size.width * progress;
    final waveAmplitude = height * 0.5;
    final waveLength = 20.0;

    // Paint for completed progress (purple)
    final completedPaint = Paint()
      ..color = AppColors.primaryAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = height
      ..strokeCap = StrokeCap.round;

    // Paint for remaining progress (gray)
    final remainingPaint = Paint()
      ..color = AppColors.text4
      ..style = PaintingStyle.stroke
      ..strokeWidth = height
      ..strokeCap = StrokeCap.round;

    // Draw completed wavy line
    if (progressWidth > 0) {
      final completedPath = Path();
      for (double x = 0; x < progressWidth; x += 1) {
        final y =
            size.height / 2 +
            waveAmplitude * math.sin((x / waveLength) * 2 * math.pi);
        if (x == 0) {
          completedPath.moveTo(x, y);
        } else {
          completedPath.lineTo(x, y);
        }
      }
      canvas.drawPath(completedPath, completedPaint);
    }

    // Draw remaining wavy line
    if (progressWidth < size.width) {
      final remainingPath = Path();
      for (double x = progressWidth; x < size.width; x += 1) {
        final y =
            size.height / 2 +
            waveAmplitude * math.sin((x / waveLength) * 2 * math.pi);
        if (x == progressWidth) {
          remainingPath.moveTo(x, y);
        } else {
          remainingPath.lineTo(x, y);
        }
      }
      canvas.drawPath(remainingPath, remainingPaint);
    }
  }

  @override
  bool shouldRepaint(WavyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
