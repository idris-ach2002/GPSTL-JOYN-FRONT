/// Règles de validation des adresses e-mail à l'inscription.
class EmailRules {
  EmailRules._();

  static final RegExp _format = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static final RegExp _studentSegment = RegExp(
    r'(^|[.-])(etu|etud|student|students|univ|edu|ecole|iut|insa|polytech)([.-]|$)',
  );
  static final RegExp _universityPrefix = RegExp(r'^u-[a-z]+\.');
  static final RegExp _studentKeyword = RegExp(r'(univ|sorbonne|ecole|etu\.)');

  static final RegExp _personalProvider = RegExp(
    r'^(gmail|googlemail|yahoo|hotmail|outlook|live|icloud|free|orange|laposte|sfr|wanadoo|proton|protonmail)\.',
  );

  /// Domaine en minuscules (« nebulapay.fr »), vide si l'adresse est invalide.
  static String domainOf(String email) {
    final trimmed = email.trim();
    if (!isValid(trimmed)) return '';
    return trimmed.split('@').last.toLowerCase();
  }

  /// Adresse d'une messagerie grand public (Gmail, Outlook, Orange…).
  static bool isPersonalEmail(String email) =>
      _personalProvider.hasMatch(domainOf(email));

  /// L'adresse a un format plausible (quelque@chose.tld).
  static bool isValid(String email) => _format.hasMatch(email.trim());

  /// Le domaine ressemble à celui d'une école ou d'une université.
  ///
  /// Heuristique côté front, pour afficher le badge « vérifié » en aperçu.
  /// La vérification réelle se fera côté serveur.
  static bool looksLikeStudentEmail(String email) {
    final trimmed = email.trim();
    if (!isValid(trimmed)) return false;

    final domain = trimmed.split('@').last.toLowerCase();
    return _studentSegment.hasMatch(domain) ||
        _universityPrefix.hasMatch(domain) ||
        _studentKeyword.hasMatch(domain);
  }
}
