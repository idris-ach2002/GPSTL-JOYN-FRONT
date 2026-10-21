import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_fonts.dart';

/// Anneau de score de compatibilité (0 à 100).
class JoynScoreRing extends StatelessWidget {
  const JoynScoreRing({required this.score, this.size = 40, super.key})
    : assert(score >= 0 && score <= 100);

  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Compatibilité $score %',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            progress: score / 100,
            strokeWidth: size * 0.11,
          ),
          child: Center(
            child: Text(
              '$score%',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: size * 0.25,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.strokeWidth});

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      paint..color = AppColors.skyMist,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      paint..color = AppColors.navy,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
