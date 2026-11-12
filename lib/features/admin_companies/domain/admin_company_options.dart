/// Listes de choix de la gestion des entreprises.
abstract final class AdminCompanyOptions {
  static const sectors = [
    'Fintech',
    'E-commerce',
    'SaaS B2B',
    'Santé',
    'Industrie',
    'Conseil',
    'Recrutement',
    'Jeux vidéo',
    'Banque',
    'Retail',
    'Mobilité',
    'Autre',
  ];

  /// Motifs proposés pour un rejet ou une suspension.
  static const moderationReasons = [
    'Informations légales invalides',
    'Suspicion de fraude',
    'Activité incompatible avec l’alternance',
    'Entreprise inactive',
    'Signalements d’étudiant·e·s',
  ];

  /// Délai avant de lancer la recherche pendant la saisie.
  static const searchDebounce = Duration(milliseconds: 350);
}
