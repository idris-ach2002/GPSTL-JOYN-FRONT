import 'package:flutter/material.dart';

/// Palette de couleurs Joyn.
///
/// Valeurs relevées sur les maquettes : à ajuster ici uniquement si le
/// design évolue, jamais en dur dans les widgets.
abstract final class AppColors {
  // --- Bleus ---------------------------------------------------------------
  /// Bleu nuit : panneaux sombres, bouton principal.
  static const Color navy = Color(0xFF0B1F3A);

  /// Bleu plus clair, utilisé en fin de dégradé du bouton principal.
  static const Color navyLight = Color(0xFF1E4A78);

  /// Bleu-vert des fonds en dégradé (écrans de swipe, etc.).
  static const Color teal = Color(0xFF1B6B7A);

  // --- Textes --------------------------------------------------------------
  /// Texte principal (bleu nuit foncé).
  static const Color ink = Color(0xFF10233F);

  /// Texte secondaire (sous-titres, aides).
  static const Color textMuted = Color(0xFF5B6B80);

  // --- Accent --------------------------------------------------------------
  /// Orange / corail : CTA secondaires, cœur, badges.
  static const Color coral = Color(0xFFFF6B3D);
  static const Color coralSoft = Color(0xFFFFE4D9);

  /// Bleu très clair des badges / tags.
  static const Color skySoft = Color(0xFFDCEBF7);

  /// Bleu ciel des avatars à initiales.
  static const Color sky = Color(0xFF5AAEE0);

  // --- Surfaces ------------------------------------------------------------
  static const Color background = Color(0xFFF1F4F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF2F7);
  static const Color border = Color(0xFFDCE3EC);

  // --- États ---------------------------------------------------------------
  static const Color error = Color(0xFFD93025);
  static const Color errorSoft = Color(0xFFFDECEA);
  static const Color success = Color(0xFF1E8E5A);
  static const Color successSoft = Color(0xFFDDF3E6);

  /// Bleu des badges d'information (ex. « Conforme »).
  static const Color info = Color(0xFF2F6FB5);

  // --- Pastilles du parcours (fond, lettre), utilisées à tour de rôle -------
  static const List<(Color, Color)> tilePalette = [
    (Color(0xFFFCE4F3), Color(0xFFC0269C)),
    (Color(0xFFEDE4FD), Color(0xFF6D3FD6)),
    (Color(0xFFDCEBF7), Color(0xFF1E4A78)),
  ];

  // --- Dégradés ------------------------------------------------------------
  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [Color(0xFF12294A), navyLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient logoGradient = LinearGradient(
    colors: [Color(0xFFFF8A3D), Color(0xFFE8432E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Bandeau du haut des pages connectées (dashboard…).
  static const LinearGradient headerGradient = LinearGradient(
    colors: [navy, Color(0xFF1B4F72), Color(0xFF3D7FA6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Fond bleu nuit → bleu-vert des écrans principaux de l'application.
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [navy, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
