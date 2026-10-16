// Expose le thème clair partagé par l’application.
//
// Référence : doc/landing/fichiers/app_theme.md.

import 'package:flutter/material.dart';

import 'app_theme_data.dart';
/// Accès au thème clair de l’application.
class AppTheme {
  /// Initialise les paramètres de AppTheme ; les valeurs par défaut figurent dans la signature.
  AppTheme._();
  /// Construit le thème clair à partir des jetons partagés.
  static ThemeData get light => buildJoynLightTheme();
}
