import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Styles de texte Joyn.
///
/// Police : celle du système pour l'instant (Roboto / SF Pro). Pour utiliser
/// la police officielle, ajouter les fichiers dans `assets/fonts/`, les
/// déclarer dans `pubspec.yaml` et renseigner [fontFamily].
abstract final class AppTextStyles {
  static const String? fontFamily = null;

  /// Thème de texte global, construit à partir de celui de Material.
  static TextTheme textTheme(TextTheme base) {
    final themed = base.apply(
      fontFamily: fontFamily,
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );
    return themed.copyWith(
      headlineMedium: themed.headlineMedium?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.15,
      ),
      titleMedium: themed.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  /// Libellé au-dessus d'un champ.
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  /// Texte secondaire (sous-titres, explications).
  static const TextStyle muted = TextStyle(
    fontSize: 15,
    height: 1.5,
    color: AppColors.textMuted,
  );

  /// Petit texte secondaire (mentions, séparateurs).
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    height: 1.4,
    color: AppColors.textMuted,
  );
}
