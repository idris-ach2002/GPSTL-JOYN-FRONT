/// Niveau déclaré sur une technologie.
enum SkillLevel {
  beginner('Débutant'),
  intermediate('Intermédiaire'),
  advanced('Avancé');

  const SkillLevel(this.label);

  final String label;
}

/// Un rythme d'alternance et sa précision.
class RhythmOption {
  const RhythmOption(this.label, this.detail);

  final String label;
  final String detail;
}

/// Listes de choix de l'onboarding.
///
/// En dur pour l'instant : elles viendront de l'API (référentiels) plus tard.
class OnboardingOptions {
  OnboardingOptions._();

  static const searchKinds = ['Une alternance', 'Un stage'];

  static const levels = ['Bac+2', 'Bac+3', 'Bac+4', 'Bac+5', 'Doctorat'];

  static const graduationYears = [2026, 2027, 2028, 2029];

  static const rhythms = [
    RhythmOption('3 sem / 1 sem', 'Entreprise / école'),
    RhythmOption('1 sem / 1 sem', 'Alterné'),
    RhythmOption('3 j / 2 j', 'Chaque semaine'),
    RhythmOption('Indifférent', 'Selon l’offre'),
  ];

  static const domains = [
    'Développement web',
    'Mobile',
    'Data & IA',
    'Cybersécurité',
    'DevOps / Cloud',
    'Produit / UX',
    'Marketing digital',
    'Finance',
    'Commerce',
    'RH',
  ];

  /// Nombre maximum de domaines sélectionnables.
  static const maxDomains = 5;

  static const remoteModes = [
    'Sur site',
    'Hybride',
    'Full remote',
    'Indifférent',
  ];

  static const companySizes = [
    'Startup',
    'PME / ETI',
    'Grand groupe',
    'Association / public',
  ];

  /// Bornes du curseur « Trajet maximum », en minutes.
  static const minCommute = 10;
  static const maxCommute = 90;
}
