import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_gradients.dart';

/// Fond graphique du Hero de la landing page.
///
/// Composition:
/// - gradient bleu JOYN
/// - grille technique discrète
/// - halo bleu
/// - halo orange
///
/// Aucun asset bitmap n'est nécessaire pour ce fond :
/// il reste ainsi net et responsive quelle que soit la résolution.
class HeroBackground extends StatelessWidget {
  const HeroBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // -------------------------------------------------------------------
        // Fond principal
        // -------------------------------------------------------------------
        const DecoratedBox(
          decoration: BoxDecoration(gradient: AppGradients.hero),
        ),

        // -------------------------------------------------------------------
        // Halo bleu principal
        // -------------------------------------------------------------------
        Positioned(
          right: -220,
          bottom: -240,
          width: 820,
          height: 820,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.heroBlueGlow),
            ),
          ),
        ),

        // -------------------------------------------------------------------
        // Halo orange subtil
        // -------------------------------------------------------------------
        Positioned(
          right: 20,
          top: 70,
          width: 500,
          height: 500,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.heroOrangeGlow),
            ),
          ),
        ),

        // -------------------------------------------------------------------
        // Grille technique
        // -------------------------------------------------------------------
        const Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _HeroGridPainter())),
        ),

        // -------------------------------------------------------------------
        // Contenu du Hero
        // -------------------------------------------------------------------
        child,
      ],
    );
  }
}

/// Dessine la grille visible très légèrement derrière le Hero.
///
/// Le painter évite d'avoir besoin d'une image répétée et conserve
/// une grille parfaitement nette sur desktop comme sur mobile.
class _HeroGridPainter extends CustomPainter {
  const _HeroGridPainter();

  static const double _spacing = 48;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0CFFFFFF)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += _spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += _spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroGridPainter oldDelegate) {
    return false;
  }
}
