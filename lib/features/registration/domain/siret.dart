/// Règles du numéro SIRET (14 chiffres).
class Siret {
  Siret._();

  static const int length = 14;

  /// Garde uniquement les chiffres, dans la limite de 14.
  static String digitsOf(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    return digits.length > length ? digits.substring(0, length) : digits;
  }

  /// Présentation lisible : « 123 456 789 00012 » (SIREN + NIC).
  static String format(String raw) {
    final digits = digitsOf(raw);
    final groups = <String>[];
    const cuts = [3, 6, 9, 14];
    var start = 0;
    for (final cut in cuts) {
      if (start >= digits.length) break;
      final end = cut < digits.length ? cut : digits.length;
      groups.add(digits.substring(start, end));
      start = end;
    }
    return groups.join(' ');
  }

  static bool hasValidLength(String raw) => digitsOf(raw).length == length;
}
