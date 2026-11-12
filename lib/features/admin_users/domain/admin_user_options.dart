/// Réglages de la gestion des utilisateurs.
abstract final class AdminUserOptions {
  /// Délai de la recherche pendant la saisie (debounce).
  static const searchDebounce = Duration(milliseconds: 300);

  /// Motifs proposés pour une suspension ou un bannissement.
  static const sanctionReasons = [
    'Comportement inapproprié',
    'Spam ou démarchage abusif',
    'Faux profil',
    'Fraude ou usurpation',
    'Signalements répétés',
  ];
}
