/// Listes de choix du profil (en dur en attendant les référentiels de l'API).
abstract final class ProfileOptions {
  static const startDates = [
    'Septembre 2027',
    'Janvier 2027',
    'Dès que possible',
  ];

  static const durations = [12, 24];

  static const rhythms = [
    '3 sem / 1 sem',
    '1 sem / 1 sem',
    '3 j / 2 j',
    'Indifférent',
  ];

  /// Compétences proposées quand l'étudiant·e ne les a pas encore.
  static const suggestedSkills = ['Docker', 'CI/CD', 'AWS'];

  /// Nombre minimal de compétences pour un profil complet.
  static const minSkills = 5;

  /// Longueur minimale d'une présentation complète.
  static const minBioLength = 80;
}
