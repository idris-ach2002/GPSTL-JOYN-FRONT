import 'package:flutter/material.dart';

/// Palette officielle JOYN.

class AppColors {
  AppColors._();

  // -------------------------------------------------------------------------
  // Brand
  // -------------------------------------------------------------------------

  /// Bleu nuit principal JOYN.
  static const Color navy = Color(0xFF001E3B);

  /// Variante légèrement plus claire du bleu principal.
  static const Color navyLight = Color(0xFF00254A);

  /// Bleu sombre secondaire.
  static const Color blueGreyDark = Color(0xFF102A43);

  /// Bleu lumineux utilisé pour les accents et halos.
  static const Color blue = Color(0xFF60A0FF);

  /// Bleu cyan secondaire.
  static const Color cyanBlue = Color(0xFF489EC9);

  /// Orange principal JOYN.
  static const Color orange = Color(0xFFFF6731);

  /// Orange secondaire plus doux.
  static const Color orangeLight = Color(0xFFFF8559);

  // -------------------------------------------------------------------------
  // Neutral
  // -------------------------------------------------------------------------

  static const Color white = Color(0xFFFFFFFF);

  static const Color grey = Color(0xFF9DA5AC);

  static const Color greyLight = Color(0xFFD9D9D9);

  // -------------------------------------------------------------------------
  // Feedback
  // -------------------------------------------------------------------------

  static const Color success = Color(0xFF68B266);

  /// Avertissement.
  static const Color warning = Color(0xFFF5A623);

  /// Erreur / action destructive.
  static const Color error = Color(0xFFE24B4B);


  /// #8395BC à 10%.
  static const Color blueGrey10 = Color(0x1A8395BC);

  /// #60A0FF à 88%.
  static const Color blue88 = Color(0xE060A0FF);

  /// #60A0FF à 75%.
  static const Color blue75 = Color(0xBF60A0FF);

  /// #D9D9D9 à 20%.
  static const Color grey20 = Color(0x33D9D9D9);

  /// #D9D9D9 à 8%.
  static const Color grey08 = Color(0x14D9D9D9);

  /// #73B266 à 25%.
  static const Color success25 = Color(0x4073B266);

  static const Color primary = navy;
  static const Color primaryLight = navyLight;

  static const Color accent = orange;

  static const Color background = Color(0xFFF5F8FB);
  static const Color surface = white;

  static const Color textPrimary = blueGreyDark;
  static const Color textSecondary = grey;
  static const Color textOnDark = white;

  static const Color border = grey20;
}
