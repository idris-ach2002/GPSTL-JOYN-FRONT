import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';

/// Fond dessiné dans Flutter : dégradés, lumière diffuse, grille et parallaxe.
///
/// Aucun timer ni boucle autonome. Le scroll est le seul moteur de mouvement ;
/// seule cette couche décorative se repeint, pas le contenu interactif.
class ScrollAtmosphere extends StatelessWidget {
  const ScrollAtmosphere({required this.child, this.scrollController,
    this.universe = false, super.key});
  final Widget child;
  final ScrollController? scrollController;
  final bool universe;

  @override
  Widget build(BuildContext context) => Stack(children: [
    Positioned.fill(child: ExcludeSemantics(child: RepaintBoundary(
      child: CustomPaint(painter: _AtmospherePainter(
        scrollController,
        universe: universe,
        reduced: MediaQuery.disableAnimationsOf(context),
      )),
    ))),
    child,
  ]);
}

class _AtmospherePainter extends CustomPainter {
  _AtmospherePainter(this.scroll, {required this.universe, required this.reduced})
    : super(repaint: scroll);
  final ScrollController? scroll;
  final bool universe;
  final bool reduced;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final position = !reduced && (scroll?.hasClients ?? false) ? scroll!.offset : 0.0;
    final shift = math.sin(position / 850) * size.width * .06;
    canvas.drawRect(rect, Paint()..shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: universe
        ? const [AppColors.navy, AppColors.orange, AppColors.orange, AppColors.background]
        : const [AppColors.background, AppColors.white, AppColors.background],
      stops: universe ? const [0, .25, .65, 1] : const [0, .48, 1],
    ).createShader(rect));
    canvas.save();
    canvas.clipRect(rect);
    void glow(Offset center, double radius, Color color, double opacity) {
      final area = Rect.fromCircle(center: center, radius: radius);
      canvas.drawOval(area, Paint()
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 52)
        ..shader = RadialGradient(colors: [color.withValues(alpha: opacity),
          color.withValues(alpha: 0)]).createShader(area));
    }
    glow(Offset(size.width * .72 + shift, size.height * .33),
      size.width * .38, universe ? AppColors.orangeLight : AppColors.orange, .38);
    glow(Offset(size.width * .15 - shift, size.height * .6),
      size.width * .3, AppColors.blue, universe ? .2 : .1);
    final grid = Paint()..color = (universe ? AppColors.white : AppColors.navy)
      .withValues(alpha: universe ? .055 : .025)..strokeWidth = .7;
    for (var x = 0.0; x < size.width; x += 54) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += 54) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    // Voiles de lumière courbes : aucun cercle qui traverse la page en boucle.
    final ribbon = Path()..moveTo(-40, size.height * .34)
      ..cubicTo(size.width * .3, size.height * .15,
        size.width * .7, size.height * .73, size.width + 40, size.height * .48);
    canvas.drawPath(ribbon, Paint()..color = AppColors.white.withValues(alpha: .12)
      ..style = PaintingStyle.stroke..strokeWidth = universe ? 1.2 : .6);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) =>
    oldDelegate.scroll != scroll || oldDelegate.universe != universe || oldDelegate.reduced != reduced;
}
