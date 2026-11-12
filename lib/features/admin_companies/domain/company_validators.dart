/// Règles de saisie du formulaire entreprise.
abstract final class CompanyValidators {
  static const int siretLength = 14;

  /// SIREN de La Poste : ses SIRET suivent une règle de contrôle différente.
  static const String _laPosteSiren = '356000000';

  static final RegExp _url = RegExp(
    r'^(https?:\/\/)?([a-z0-9-]+\.)+[a-z]{2,}(:\d{2,5})?(\/[^\s]*)?$',
    caseSensitive: false,
  );

  /// Garde uniquement les chiffres (14 au maximum).
  static String siretDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    return digits.length > siretLength
        ? digits.substring(0, siretLength)
        : digits;
  }

  /// Présentation lisible : « 123 456 789 00012 ».
  static String formatSiret(String raw) {
    final digits = siretDigits(raw);
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6 || i == 9) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Message d'erreur du SIRET, ou `null` s'il est valide.
  ///
  /// Vérifie les 14 chiffres et la clé de contrôle (algorithme de Luhn,
  /// avec l'exception de La Poste).
  static String? siretError(String raw) {
    final digits = siretDigits(raw);
    if (digits.isEmpty) return 'Indiquez le numéro SIRET.';
    if (digits.length != siretLength) {
      return 'Un numéro SIRET compte 14 chiffres.';
    }
    if (!_hasValidChecksum(digits)) {
      return 'Ce numéro SIRET est invalide (clé de contrôle incorrecte).';
    }
    return null;
  }

  static bool _hasValidChecksum(String digits) {
    if (digits.startsWith(_laPosteSiren)) {
      final sum = digits.split('').map(int.parse).reduce((a, b) => a + b);
      return sum % 5 == 0;
    }
    var sum = 0;
    for (var i = 0; i < digits.length; i++) {
      var value = int.parse(digits[digits.length - 1 - i]);
      if (i.isOdd) {
        value *= 2;
        if (value > 9) value -= 9;
      }
      sum += value;
    }
    return sum % 10 == 0;
  }

  /// Message d'erreur du site web, ou `null` s'il est valide ou vide
  /// (le site est facultatif).
  static String? websiteError(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return _url.hasMatch(value)
        ? null
        : 'Saisissez une adresse valide, par exemple https://entreprise.fr';
  }

  /// Ajoute `https://` si l'adresse n'a pas de protocole.
  static String normalizeWebsite(String raw) {
    final value = raw.trim();
    if (value.isEmpty || value.contains('://')) return value;
    return 'https://$value';
  }

  static String? requiredError(String raw, String label) =>
      raw.trim().isEmpty ? 'Indiquez $label.' : null;
}
