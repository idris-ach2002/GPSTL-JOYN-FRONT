import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';

/// Lighting stays within JOYN's original navy, cyan and blue palette.
class ProductAtmosphere extends StatelessWidget {
  const ProductAtmosphere({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(color: JoynTokens.ink),
    child: Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.1,
                colors: [
                  JoynTokens.blue.withValues(alpha: JoynTokens.glowAlpha),
                  JoynTokens.ink.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        const Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _ConnectionGrid())),
        ),
        child,
      ],
    ),
  );
}

class _ConnectionGrid extends CustomPainter {
  const _ConnectionGrid();
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = JoynTokens.cyan.withValues(alpha: JoynTokens.gridAlpha)
      ..strokeWidth = JoynTokens.hairline;
    for (double x = 0; x < size.width; x += JoynTokens.grid) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (double y = 0; y < size.height; y += JoynTokens.grid) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionGrid oldDelegate) => false;
}

class ProductSurface extends StatelessWidget {
  const ProductSurface({
    super.key,
    required this.child,
    this.dark = false,
    this.accent = false,
  });
  final Widget child;
  final bool dark;
  final bool accent;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(JoynTokens.md),
    decoration: BoxDecoration(
      color: dark ? JoynTokens.navyLight : JoynTokens.paper,
      borderRadius: BorderRadius.circular(JoynTokens.radius),
      border: Border.all(
        color: accent
            ? JoynTokens.orange
            : dark
            ? JoynTokens.cyan.withValues(alpha: .5)
            : JoynTokens.ink.withValues(alpha: JoynTokens.subtleAlpha),
      ),
      boxShadow: [
        BoxShadow(
          color: JoynTokens.ink.withValues(alpha: JoynTokens.subtleAlpha),
          blurRadius: JoynTokens.shadowBlur,
          offset: JoynTokens.shadowOffset,
        ),
      ],
    ),
    child: child,
  );
}
