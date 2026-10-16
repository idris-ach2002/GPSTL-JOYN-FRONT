// Déplace légèrement une illustration selon le pointeur sur les grands écrans.
//
// Référence : doc/landing/fichiers/gentle_depth.md.

import 'package:flutter/material.dart';
import '../../../../design_system/joyn_tokens.dart';
/// Enveloppe d’illustration avec déplacement borné au passage du pointeur.
class GentleDepth extends StatefulWidget {
  /// Initialise les paramètres de GentleDepth ; les valeurs par défaut figurent dans la signature.
  const GentleDepth({super.key, required this.child});
  /// Contenu enveloppé par le composant.
  final Widget child;
  /// Crée l’état local associé au widget.
  @override
  State<GentleDepth> createState() => _GentleDepthState();
}
/// État de GentleDepth ; définit ses données mutables et son rendu.
class _GentleDepthState extends State<GentleDepth> {
  /// Cible d’ancre ou de route transmise à la navigation.
  Offset target = Offset.zero;
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context) || MediaQuery.sizeOf(context).width < JoynTokens.tablet) { return widget.child; }
    return LayoutBuilder(builder: (context, constraints) => MouseRegion(
      onHover: (event) {
        // Boîte de rendu mesurée pour calculer une position ou une taille.
        final box = context.findRenderObject() as RenderBox?;
        if (box == null || box.size.height == 0 || box.size.width == 0) { return; }
        // Abscisse du dessin ou position horizontale normalisée, selon la portée.
        final x = (event.localPosition.dx / box.size.width * 2 - 1).clamp(-1.0, 1.0).toDouble();
        // Ordonnée du dessin ou position verticale normalisée, selon la portée.
        final y = (event.localPosition.dy / box.size.height * 2 - 1).clamp(-1.0, 1.0).toDouble();
        setState(() => target = Offset(x * JoynTokens.parallaxTravel, y * JoynTokens.parallaxTravel));
      },
      onExit: (_) => setState(() => target = Offset.zero),
      child: TweenAnimationBuilder<Offset>(
        tween: Tween(begin: Offset.zero, end: target), duration: JoynTokens.menuDuration,
        curve: Curves.easeOutCubic,
        builder: (context, offset, child) => Transform.translate(offset: offset, child: child),
        child: widget.child,
      ),
    ));
  }
}
