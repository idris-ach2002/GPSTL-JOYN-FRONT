import 'package:flutter/material.dart';

import '../../design_system/tokens/app_colors.dart' as brand;

/// Compatibilité pour les écrans connexion / dashboard issus de la branche
/// `connexion-dashboard`.
///
/// Les couleurs de marque pointent désormais vers la palette officielle JOYN
/// utilisée par la landing et l'inscription.
abstract final class AppColors {
  static const Color navy = brand.AppColors.navy;
  static const Color navyLight = brand.AppColors.navyLight;
  static const Color teal = brand.AppColors.cyanBlue;

  static const Color ink = brand.AppColors.blueGreyDark;
  static const Color textMuted = brand.AppColors.grey;

  static const Color coral = brand.AppColors.orange;
  static const Color coralSoft = Color(0xFFFFE7DE);

  static const Color skySoft = Color(0xFFEAF4FF);
  static const Color sky = brand.AppColors.blue;

  static const Color background = brand.AppColors.background;
  static const Color surface = brand.AppColors.white;
  static const Color surfaceMuted = Color(0xFFF1F4F7);
  static const Color border = brand.AppColors.greyLight;

  static const Color error = brand.AppColors.error;
  static const Color errorSoft = Color(0xFFFFEAEA);
  static const Color success = brand.AppColors.success;
  static const Color successSoft = Color(0xFFE9F5E8);
  static const Color info = brand.AppColors.blue;

  static const List<(Color, Color)> tilePalette = [
    (Color(0xFFFFE6F5), Color(0xFFC0269C)),
    (Color(0xFFEDE7FF), Color(0xFF6D3FD6)),
    (Color(0xFFEAF4FF), brand.AppColors.navyLight),
  ];

  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [brand.AppColors.navy, brand.AppColors.navyLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient logoGradient = LinearGradient(
    colors: [brand.AppColors.orangeLight, brand.AppColors.orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [
      brand.AppColors.navy,
      brand.AppColors.navyLight,
      brand.AppColors.cyanBlue,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [brand.AppColors.navy, brand.AppColors.cyanBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
