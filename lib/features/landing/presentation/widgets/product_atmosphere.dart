// Dessine le fond sombre quadrillé et les surfaces de présentation.
//
// Référence : doc/landing/fichiers/product_atmosphere.md.

import 'package:flutter/material.dart';
import '../../../../design_system/joyn_tokens.dart';
/// Fond bleu nuit avec éclairage et quadrillage vectoriel.
class ProductAtmosphere extends StatelessWidget {
  /// Initialise les paramètres de ProductAtmosphere ; les valeurs par défaut figurent dans la signature.
  const ProductAtmosphere({super.key, required this.child});
  /// Contenu enveloppé par le composant.
  final Widget child;
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(color: JoynTokens.ink),
    child: Stack(children: [
      Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.bottomRight, radius: 1.1,
          colors: [JoynTokens.blue.withValues(alpha: JoynTokens.glowAlpha), JoynTokens.ink.withValues(alpha: 0)],
        ),
      ))),
      const Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _ConnectionGrid()))),
      child,
    ]),
  );
}
/// Tracé du quadrillage du fond sans état d’animation.
class _ConnectionGrid extends CustomPainter {
  /// Initialise les paramètres de _ConnectionGrid ; les valeurs par défaut figurent dans la signature.
  const _ConnectionGrid();
  /// Dessine la géométrie dans le repère du canevas fourni.
  @override
  void paint(Canvas canvas, Size size) {
    // Style du trait utilisé pour le dessin.
    final line = Paint()..color = JoynTokens.cyan.withValues(alpha: JoynTokens.gridAlpha)..strokeWidth = JoynTokens.hairline;
    for (double x = 0; x < size.width; x += JoynTokens.grid) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (double y = 0; y < size.height; y += JoynTokens.grid) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }
  /// Indique si les données du dessin diffèrent du peintre précédent.
  @override
  bool shouldRepaint(covariant _ConnectionGrid oldDelegate) => false;
}
/// Surface de contenu avec variantes sombre et accentuée.
class ProductSurface extends StatelessWidget {
  /// Initialise les paramètres de ProductSurface ; les valeurs par défaut figurent dans la signature.
  const ProductSurface({super.key, required this.child, this.dark = false, this.accent = false});
  /// Contenu enveloppé par le composant.
  final Widget child;
  /// Applique la variante sombre de la surface.
  final bool dark;
  /// Applique la variante accentuée de la surface.
  final bool accent;
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(JoynTokens.md),
    decoration: BoxDecoration(
      color: dark ? JoynTokens.navyLight : JoynTokens.paper,
      borderRadius: BorderRadius.circular(JoynTokens.radius),
      border: Border.all(color: accent ? JoynTokens.orange : dark
        ? JoynTokens.cyan.withValues(alpha: .5) : JoynTokens.ink.withValues(alpha: JoynTokens.subtleAlpha)),
      boxShadow: [BoxShadow(color: JoynTokens.ink.withValues(alpha: JoynTokens.subtleAlpha),
        blurRadius: JoynTokens.shadowBlur, offset: JoynTokens.shadowOffset)],
    ),
    child: child,
  );
}
