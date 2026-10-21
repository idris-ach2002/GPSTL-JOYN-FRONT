import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/tokens/app_colors.dart';

/// Première proposition du symbole JOYN.
///
/// Concept : "Joyn Link"
///
/// Les deux boucles représentent les deux parties qui se rejoignent :
/// candidat + entreprise.
///
/// Le petit point rappelle l'idée de connexion et reprend le langage
/// graphique du point orange utilisé dans "joy.".
///
/// Ce symbole est volontairement dessiné en Flutter pour le prototypage.
/// Une fois la direction artistique validée, le logo final pourra être
/// exporté proprement en SVG depuis Figma.
class JoynMark extends StatelessWidget {
  const JoynMark({this.size = 44, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.orangeLight, AppColors.orange],
          ),
        ),
        child: CustomPaint(painter: const _JoynMarkPainter()),
      ),
    );
  }
}

class _JoynMarkPainter extends CustomPainter {
  const _JoynMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.075;

    final linkPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.save();

    canvas.translate(size.width / 2, size.height / 2);

    canvas.rotate(-math.pi / 5.5);

    final leftLoop = Rect.fromCenter(
      center: Offset(-size.width * 0.10, 0),
      width: size.width * 0.31,
      height: size.height * 0.53,
    );

    final rightLoop = Rect.fromCenter(
      center: Offset(size.width * 0.10, 0),
      width: size.width * 0.31,
      height: size.height * 0.53,
    );

    canvas.drawOval(leftLoop, linkPaint);

    canvas.drawOval(rightLoop, linkPaint);

    canvas.restore();

    final dotPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.69, size.height * 0.22),
      size.width * 0.045,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _JoynMarkPainter oldDelegate) {
    return false;
  }
}
