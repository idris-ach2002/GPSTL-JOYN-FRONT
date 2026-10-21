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

  /// Fond du haut des écrans d'inscription : bleu nuit qui s'éclaircit
  /// jusqu'au fond de page, pour poser les cartes de choix sur du clair.
  static const LinearGradient registrationBackdrop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.navy,
      AppColors.navyLight,
      Color(0xFF123A70),
      Color(0xFF6F9FDA),
      Color(0xFFD3E2F1),
      AppColors.background,
    ],
    stops: [0.0, 0.3, 0.52, 0.72, 0.88, 1.0],
  );

  /// Fond de l'illustration de la carte « Étudiant·e ».
  static const LinearGradient studentCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEAF5FB), Color(0xFFD9EDF8)],
  );

  /// Fond de l'illustration de la carte « Entreprise ».
  static const LinearGradient companyCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF4EE), Color(0xFFFFE4D8)],
  );

  /// Surface translucide pour les futures cartes "glass".
  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x338395BC), Color(0x148395BC)],
  );
}
