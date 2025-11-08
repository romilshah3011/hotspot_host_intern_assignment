import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

/// Background Pattern Widget with wavy lines
class BackgroundPattern extends StatelessWidget {
  final Widget child;

  const BackgroundPattern({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(size: Size.infinite, painter: WavyPatternPainter()),
        child,
      ],
    );
  }
}

class WavyPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.text4.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final waveLength = 50.0;
    final waveAmplitude = 10.0;
    final spacing = 90.0;

    // Draw diagonal wavy lines
    for (
      double offset = -size.height;
      offset < size.width + size.height;
      offset += spacing
    ) {
      final path = Path();
      bool isFirstPoint = true;

      for (double x = 0; x < size.width + size.height; x += 2) {
        final y =
            offset +
            x +
            waveAmplitude * math.sin((x / waveLength) * 2 * math.pi);

        if (isFirstPoint) {
          path.moveTo(x, y);
          isFirstPoint = false;
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WavyPatternPainter oldDelegate) => false;
}
