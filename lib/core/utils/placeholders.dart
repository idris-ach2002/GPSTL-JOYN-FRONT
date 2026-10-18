/// Affichage des valeurs absentes (`null`), tant que le backend n'est pas
/// branché ou quand une donnée n'est pas renseignée.
abstract final class Placeholders {
  /// Texte affiché à la place d'une valeur manquante.
  static const String missing = '—';

  static String text(String? value) =>
      (value == null || value.trim().isEmpty) ? missing : value;

  /// Pourcentage (ex. `92 %`), ou [missing].
  static String percent(int? value) => value == null ? missing : '$value %';
}
