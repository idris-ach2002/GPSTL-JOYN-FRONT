import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_gradients.dart';

/// Fond graphique du Hero JOYN.
///
/// Le contenu non positionné détermine la hauteur naturelle du Stack.
/// Cela permet au widget de fonctionner correctement dans une page scrollable.
class HeroBackground extends StatelessWidget {
  const HeroBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.hero),
          ),
        ),

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

        const Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _HeroGridPainter())),
        ),

        child,
      ],
    );
  }
}

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
