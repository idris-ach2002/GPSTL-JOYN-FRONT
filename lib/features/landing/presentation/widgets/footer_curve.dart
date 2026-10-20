import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';

/// Ligne orange très fine inspirée du footer fourni.
///
/// Seul le canvas se repeint grâce à [CustomPainter.repaint]. La frontière de
/// repaint évite de reconstruire les colonnes de liens à chaque image.
class FooterCurve extends StatefulWidget {
  const FooterCurve({super.key});

  @override
  State<FooterCurve> createState() => _FooterCurveState();
}

class _FooterCurveState extends State<FooterCurve>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this, duration: const Duration(seconds: 8));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) || !TickerMode.of(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(child: SizedBox(height: 64, width: double.infinity,
      child: CustomPaint(painter: _CurvePainter(_controller)))),
  );
}

class _CurvePainter extends CustomPainter {
  _CurvePainter(this.animation) : super(repaint: animation);
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (var x = 0.0; x <= size.width; x += 2) {
      final y = size.height / 2 + math.sin(
        x / size.width * math.pi * 2 + animation.value * math.pi * 2) * 12;
      if (x == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path, Paint()..color = AppColors.orange
      ..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) =>
    oldDelegate.animation != animation;
}
