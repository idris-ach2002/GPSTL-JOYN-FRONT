/// Espacements, rayons et points de rupture communs à toute l'application.
///
/// Utiliser ces constantes plutôt que des nombres en dur permet de garder
/// une interface homogène.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class AppRadius {
  /// Champs de saisie et boutons secondaires.
  static const double field = 14;

  /// Grandes cartes blanches « très arrondies ».
  static const double card = 28;

  /// Forme pilule (boutons principaux, badges).
  static const double pill = 999;
}

abstract final class AppBreakpoints {
  /// À partir de cette largeur, on affiche la mise en page « web » à 2 colonnes.
  static const double desktop = 900;

  /// Hauteur minimale pour afficher le panneau illustré à côté du formulaire.
  static const double minShowcaseHeight = 600;

  /// Largeur maximale des formulaires, pour rester lisibles sur grand écran.
  static const double formMaxWidth = 420;
}
