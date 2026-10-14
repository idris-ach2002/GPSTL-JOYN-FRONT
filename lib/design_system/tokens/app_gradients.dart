import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradients réutilisables du design system JOYN.
class AppGradients {
  AppGradients._();

  /// Fond principal de la landing page / Hero.
  ///
  /// Il part du bleu nuit historique de JOYN vers un bleu plus lumineux
  /// afin de concentrer naturellement le regard sur la partie produit.
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.navy, AppColors.navyLight, Color(0xFF123A70)],
    stops: [0.0, 0.55, 1.0],
  );

  /// Halo lumineux bleu derrière les cartes du Hero.
  static const RadialGradient heroBlueGlow = RadialGradient(
    colors: [Color(0x9960A0FF), Color(0x3360A0FF), Color(0x0060A0FF)],
    stops: [0.0, 0.48, 1.0],
  );

  /// Accent chaud extrêmement léger derrière l'interface de matching.
  static const RadialGradient heroOrangeGlow = RadialGradient(
    colors: [Color(0x33FF6731), Color(0x00FF6731)],
  );

  /// Gradient destiné aux CTA principaux lorsqu'un gradient est pertinent.
  static const LinearGradient orange = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.orange, AppColors.orangeLight],
  );

  /// Surface translucide pour les futures cartes "glass".
  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x338395BC), Color(0x148395BC)],
  );
}
