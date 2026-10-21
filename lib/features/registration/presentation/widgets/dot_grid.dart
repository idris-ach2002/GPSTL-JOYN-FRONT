import 'package:flutter/material.dart';

/// Trame de points blancs posée sur les fonds bleu nuit.
class DotGrid extends StatelessWidget {
  const DotGrid({this.spacing = 22, this.opacity = 0.5, super.key});

  final double spacing;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(painter: _DotGridPainter(spacing: spacing)),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.spacing});

  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x24FFFFFF);
    for (var y = spacing / 2; y < size.height; y += spacing) {
      for (var x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) {
    return oldDelegate.spacing != spacing;
  }
}
