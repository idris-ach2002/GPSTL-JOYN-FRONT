import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Logo Joyn : pastille orange + texte « joyn ».
///
/// TODO(design): remplacer la pastille dessinée par le logo officiel (SVG/PNG)
/// dès qu'il est disponible dans `assets/`.
class JoynLogo extends StatelessWidget {
  const JoynLogo({
    super.key,
    this.size = 36,
    this.showWordmark = true,
    this.wordmarkColor = AppColors.ink,
  });

  /// Diamètre de la pastille ; le texte s'adapte proportionnellement.
  final double size;
  final bool showWordmark;

  /// Couleur du texte « joyn » (blanc sur fond sombre).
  final Color wordmarkColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Joyn',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.logoGradient,
            ),
            child: const CustomPaint(painter: _LogoMarkPainter()),
          ),
          if (showWordmark) ...[
            SizedBox(width: size * 0.3),
            Text(
              'joyn',
              style: TextStyle(
                fontSize: size * 0.6,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: wordmarkColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dessine le motif blanc de la pastille : un anneau ouvert et un point.
class _LogoMarkPainter extends CustomPainter {
  const _LogoMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.22;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.11
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: center.translate(0, size.height * 0.05),
        radius: radius,
      ),
      -0.6,
      5.2,
      false,
      stroke,
    );
    canvas.drawCircle(
      center.translate(radius * 0.9, -radius * 1.1),
      size.width * 0.07,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
