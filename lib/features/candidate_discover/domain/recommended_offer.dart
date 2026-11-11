/// Offre recommandée au candidat sur la page « Matchs » (CA82).
///
/// Le modèle est volontairement indépendant du backend : c'est au dépôt
/// (`ApiRecommendedOffersRepository`) de convertir la réponse JSON.
class RecommendedOffer {
  const RecommendedOffer({
    required this.id,
    required this.title,
    required this.company,
    required this.compatibility,
    this.location = '',
    this.commuteMinutes,
    this.rhythm = '',
    this.remoteDays,
    this.monthlySalary,
    this.contractType = '',
    this.description = '',
    this.skills = const [],
    this.criteria = const [],
    this.alumniCount = 0,
  });

  final String id;

  /// Intitulé du poste (ex. « Développeur·euse Full-Stack en alternance »).
  final String title;
  final OfferCompany company;

  /// Score de compatibilité global, de 0 à 100.
  final int compatibility;

  /// Ville ou arrondissement (ex. « Paris 9e »).
  final String location;

  /// Temps de trajet estimé depuis le domicile du candidat.
  final int? commuteMinutes;

  /// Rythme d'alternance (ex. « 3 sem / 1 sem »).
  final String rhythm;

  /// Nombre de jours de télétravail par semaine.
  final int? remoteDays;

  /// Rémunération brute mensuelle, en euros.
  final int? monthlySalary;

  /// Type de contrat (ex. « Alternance », « Stage »).
  final String contractType;
  final String description;

  /// Compétences demandées, marquées selon qu'elles figurent dans le profil.
  final List<OfferSkill> skills;

  /// Détail du score : « Pourquoi 92 % ? ».
  final List<MatchCriterion> criteria;

  /// Anciens de l'école du candidat qui travaillent dans l'entreprise.
  final int alumniCount;
}

/// Entreprise qui publie l'offre.
class OfferCompany {
  const OfferCompany({
    required this.name,
    this.sector = '',
    this.headcount,
    this.city = '',
    this.logoUrl,
  });

  final String name;
  final String sector;
  final int? headcount;
  final String city;
  final String? logoUrl;

  /// Initiale affichée quand il n'y a pas de logo.
  String get initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

  /// Ligne descriptive (ex. « Fintech · 120 pers. · Paris 9e »).
  String get summary => [
    sector,
    if (headcount != null) '$headcount pers.',
    city,
  ].where((part) => part.trim().isNotEmpty).join(' · ');
}

/// Compétence demandée par l'offre.
class OfferSkill {
  const OfferSkill({required this.name, required this.matched});

  final String name;

  /// `true` si le candidat possède la compétence.
  final bool matched;
}

/// Un critère du score de compatibilité (technos, rythme, trajet…).
class MatchCriterion {
  const MatchCriterion({required this.label, required this.score});

  final String label;

  /// Score du critère, de 0 à 100.
  final int score;
}

/// Geste du candidat sur une carte.
enum SwipeDecision {
  /// Glissé à droite : l'offre rejoint la colonne « Intéressé » des
  /// candidatures, d'où le candidat l'envoie en un clic.
  interested,

  /// Glissé à gauche : l'offre est ignorée.
  skip,

  /// Glissé vers le haut : l'offre est mise de côté.
  save;

  /// Libellé court, utilisé dans les retours visuels et l'accessibilité.
  String get label => switch (this) {
    SwipeDecision.interested => 'Intéressé',
    SwipeDecision.skip => 'Passer',
    SwipeDecision.save => 'Sauvegarder',
  };
}

/// Préférences qui filtrent les recommandations (pastilles en haut de page).
class DiscoverFilters {
  const DiscoverFilters({this.rhythm, this.location});

  final String? rhythm;
  final String? location;

  Map<String, String?> toQueryParameters() => {
    'rhythm': rhythm,
    'location': location,
  };
}

/// Réponse complète du flux de recommandations.
class DiscoverFeed {
  const DiscoverFeed({
    required this.offers,
    this.filters = const DiscoverFilters(),
    int? totalCompatible,
  }) : totalCompatible = totalCompatible ?? offers.length;

  final List<RecommendedOffer> offers;

  /// Préférences appliquées par le backend (issues du profil par défaut).
  final DiscoverFilters filters;

  /// Nombre total d'offres compatibles aujourd'hui.
  final int totalCompatible;
}
