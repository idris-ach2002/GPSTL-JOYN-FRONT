import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';

/// Fil orange dont la phase dépend exclusivement du défilement de la landing.
/// Il s'immobilise dès que le scroll s'arrête : aucun ticker ni API dépréciée.
class FooterCurve extends StatelessWidget {
  const FooterCurve({required this.scrollController, super.key});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: CustomPaint(
          painter: _CurvePainter(
            scrollController,
            reduced: MediaQuery.disableAnimationsOf(context),
          ),
        ),
      ),
    ),
  );
}

class _CurvePainter extends CustomPainter {
  _CurvePainter(this.scroll, {required this.reduced}) : super(repaint: scroll);
  final ScrollController scroll;
  final bool reduced;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0) return;
    final phase = !reduced && scroll.hasClients ? scroll.offset / 240 : 0.0;
    final path = Path();
    for (var x = 0.0; x <= size.width; x += 2) {
      final y =
          size.height / 2 + math.sin(x / size.width * math.pi * 2 + phase) * 10;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) =>
      oldDelegate.scroll != scroll || oldDelegate.reduced != reduced;
}
