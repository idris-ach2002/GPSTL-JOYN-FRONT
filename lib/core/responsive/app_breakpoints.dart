// Expose les seuils de largeur partagés avec les jetons de la landing.
//
// Référence : doc/landing/fichiers/app_breakpoints.md.

import '../../design_system/joyn_tokens.dart';

/// Seuils de largeur réutilisables dans les helpers responsives.
abstract final class AppBreakpoints {
  /// Seuil ou contenu de la variante mobile, selon la déclaration.
  static const mobile = JoynTokens.mobile;

  /// Seuil ou contenu de la variante tablette, selon la déclaration.
  static const tablet = JoynTokens.tablet;

  /// Seuil ou contenu de la variante ordinateur, selon la déclaration.
  static const desktop = JoynTokens.tablet;

  /// Largeur de contenu maximale partagée avec les jetons.
  static const wide = JoynTokens.content;
}
