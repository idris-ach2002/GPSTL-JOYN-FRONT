import '../../candidate_applications/data/mock_candidate_applications_repository.dart';
import '../domain/recommended_offer.dart';
import 'recommended_offers_repository.dart';

/// Implémentation SIMULÉE de [RecommendedOffersRepository], pour la démo.
///
/// Les gestes sont mémorisés le temps de la session : une offre traitée ne
/// revient pas au rechargement, sauf si le geste est annulé.
///
/// Si [applications] est fourni, une offre glissée à droite y est ajoutée
/// dans la colonne « Intéressé » (et retirée si le geste est annulé), comme
/// le fera le backend.
class MockRecommendedOffersRepository implements RecommendedOffersRepository {
  MockRecommendedOffersRepository({
    this.latency = const Duration(milliseconds: 500),
    List<RecommendedOffer>? offers,
    this.applications,
  }) : _offers = offers ?? demoRecommendedOffers;

  /// Délai simulé de chaque appel (mettre `Duration.zero` dans les tests).
  final Duration latency;
  final List<RecommendedOffer> _offers;

  /// Candidatures simulées, partagées avec la page « Mes candidatures ».
  final MockCandidateApplicationsRepository? applications;

  /// Gestes enregistrés, par identifiant d'offre.
  final Map<String, SwipeDecision> decisions = {};

  @override
  Future<DiscoverFeed> fetchFeed({
    DiscoverFilters filters = const DiscoverFilters(),
  }) async {
    await Future<void>.delayed(latency);
    final remaining =
        _offers.where((offer) => !decisions.containsKey(offer.id)).toList()
          ..sort((a, b) => b.compatibility.compareTo(a.compatibility));
    return DiscoverFeed(
      offers: remaining,
      filters: DiscoverFilters(
        rhythm: filters.rhythm ?? '3 sem / 1 sem',
        location: filters.location ?? 'Paris',
      ),
    );
  }

  @override
  Future<void> submitDecision(String offerId, SwipeDecision decision) async {
    await Future<void>.delayed(latency);
    decisions[offerId] = decision;
    if (decision != SwipeDecision.interested) return;
    final offer = _offers.where((o) => o.id == offerId).firstOrNull;
    if (offer == null) return;
    applications?.addInterested(
      offerId: offer.id,
      companyName: offer.company.name,
      jobTitle: offer.title,
      matchScore: offer.compatibility,
    );
  }

  @override
  Future<void> cancelDecision(String offerId) async {
    await Future<void>.delayed(latency);
    decisions.remove(offerId);
    applications?.removeForOffer(offerId);
  }
}

/// Offres de démonstration, cohérentes avec le profil d'Alex Dupont
/// (alternance développement web, Paris).
const List<RecommendedOffer> demoRecommendedOffers = [
  RecommendedOffer(
    id: 'demo-1',
    title: 'Développeur·euse Full-Stack en alternance',
    company: OfferCompany(
      name: 'Entreprise Beta',
      sector: 'Fintech',
      headcount: 120,
      city: 'Paris 9e',
    ),
    compatibility: 92,
    location: 'Paris 9e',
    commuteMinutes: 35,
    rhythm: '3 sem / 1 sem',
    remoteDays: 2,
    monthlySalary: 1450,
    contractType: 'Alternance',
    description:
        "Rejoins l'équipe Paiements pour construire le nouveau tableau de "
        'bord marchands, de la maquette Figma à la mise en production.',
    skills: [
      OfferSkill(name: 'React', matched: true),
      OfferSkill(name: 'TypeScript', matched: true),
      OfferSkill(name: 'Node.js', matched: true),
      OfferSkill(name: 'PostgreSQL', matched: true),
      OfferSkill(name: 'Docker', matched: false),
    ],
    criteria: [
      MatchCriterion(label: 'Technos', score: 90),
      MatchCriterion(label: 'Formation & niveau', score: 100),
      MatchCriterion(label: 'Rythme', score: 100),
      MatchCriterion(label: 'Trajet', score: 75),
    ],
    alumniCount: 2,
  ),
  RecommendedOffer(
    id: 'demo-2',
    title: 'Développeur·euse Front-End React',
    company: OfferCompany(
      name: 'Lumen Studio',
      sector: 'Agence produit',
      headcount: 45,
      city: 'Paris 11e',
    ),
    compatibility: 88,
    location: 'Paris 11e',
    commuteMinutes: 25,
    rhythm: '3 sem / 1 sem',
    remoteDays: 1,
    monthlySalary: 1350,
    contractType: 'Alternance',
    description:
        'Intègre une équipe de 6 développeurs pour concevoir des interfaces '
        'web accessibles pour des clients du secteur culturel.',
    skills: [
      OfferSkill(name: 'React', matched: true),
      OfferSkill(name: 'TypeScript', matched: true),
      OfferSkill(name: 'Accessibilité', matched: false),
      OfferSkill(name: 'Figma', matched: true),
    ],
    criteria: [
      MatchCriterion(label: 'Technos', score: 85),
      MatchCriterion(label: 'Formation & niveau', score: 90),
      MatchCriterion(label: 'Rythme', score: 100),
      MatchCriterion(label: 'Trajet', score: 85),
    ],
    alumniCount: 1,
  ),
  RecommendedOffer(
    id: 'demo-3',
    title: 'Développeur·euse Back-End Java / Spring',
    company: OfferCompany(
      name: 'Nova Assurances',
      sector: 'Assurance',
      headcount: 2400,
      city: 'La Défense',
    ),
    compatibility: 84,
    location: 'La Défense',
    commuteMinutes: 40,
    rhythm: '3 sem / 1 sem',
    remoteDays: 2,
    monthlySalary: 1600,
    contractType: 'Alternance',
    description:
        'Participe à la refonte des API de souscription, en binôme avec un '
        'développeur senior, dans une équipe agile.',
    skills: [
      OfferSkill(name: 'Java', matched: true),
      OfferSkill(name: 'Spring Boot', matched: true),
      OfferSkill(name: 'PostgreSQL', matched: true),
      OfferSkill(name: 'Kafka', matched: false),
    ],
    criteria: [
      MatchCriterion(label: 'Technos', score: 80),
      MatchCriterion(label: 'Formation & niveau', score: 100),
      MatchCriterion(label: 'Rythme', score: 100),
      MatchCriterion(label: 'Trajet', score: 60),
    ],
  ),
  RecommendedOffer(
    id: 'demo-4',
    title: 'Développeur·euse Mobile Flutter',
    company: OfferCompany(
      name: 'Greenly',
      sector: 'Climat tech',
      headcount: 80,
      city: 'Paris 2e',
    ),
    compatibility: 81,
    location: 'Paris 2e',
    commuteMinutes: 30,
    rhythm: '4 j / 1 j',
    remoteDays: 2,
    monthlySalary: 1400,
    contractType: 'Alternance',
    description:
        "Fais évoluer l'application mobile qui aide les PME à mesurer leur "
        'empreinte carbone, du design system aux tests.',
    skills: [
      OfferSkill(name: 'Flutter', matched: true),
      OfferSkill(name: 'Dart', matched: true),
      OfferSkill(name: 'Firebase', matched: false),
      OfferSkill(name: 'CI/CD', matched: false),
    ],
    criteria: [
      MatchCriterion(label: 'Technos', score: 70),
      MatchCriterion(label: 'Formation & niveau', score: 100),
      MatchCriterion(label: 'Rythme', score: 70),
      MatchCriterion(label: 'Trajet', score: 80),
    ],
    alumniCount: 3,
  ),
  RecommendedOffer(
    id: 'demo-5',
    title: 'Data Analyst junior',
    company: OfferCompany(
      name: 'Mobilis',
      sector: 'Transport',
      headcount: 650,
      city: 'Saint-Denis',
    ),
    compatibility: 76,
    location: 'Saint-Denis',
    commuteMinutes: 45,
    rhythm: '3 sem / 1 sem',
    remoteDays: 1,
    monthlySalary: 1300,
    contractType: 'Alternance',
    description:
        'Construis les tableaux de bord de fréquentation du réseau et '
        "automatise les extractions de données pour l'équipe exploitation.",
    skills: [
      OfferSkill(name: 'SQL', matched: true),
      OfferSkill(name: 'Python', matched: true),
      OfferSkill(name: 'Power BI', matched: false),
    ],
    criteria: [
      MatchCriterion(label: 'Technos', score: 70),
      MatchCriterion(label: 'Formation & niveau', score: 90),
      MatchCriterion(label: 'Rythme', score: 100),
      MatchCriterion(label: 'Trajet', score: 50),
    ],
  ),
  RecommendedOffer(
    id: 'demo-6',
    title: 'Développeur·euse DevOps',
    company: OfferCompany(
      name: 'Cloudéo',
      sector: 'Hébergement',
      headcount: 200,
      city: 'Issy-les-Moulineaux',
    ),
    compatibility: 71,
    location: 'Issy-les-Moulineaux',
    commuteMinutes: 50,
    rhythm: '2 sem / 2 sem',
    remoteDays: 3,
    monthlySalary: 1500,
    contractType: 'Alternance',
    description:
        'Automatise les déploiements de la plateforme et améliore '
        "l'observabilité des services aux côtés de l'équipe SRE.",
    skills: [
      OfferSkill(name: 'Docker', matched: false),
      OfferSkill(name: 'Kubernetes', matched: false),
      OfferSkill(name: 'Linux', matched: true),
      OfferSkill(name: 'Git', matched: true),
    ],
    criteria: [
      MatchCriterion(label: 'Technos', score: 55),
      MatchCriterion(label: 'Formation & niveau', score: 90),
      MatchCriterion(label: 'Rythme', score: 80),
      MatchCriterion(label: 'Trajet', score: 55),
    ],
    alumniCount: 1,
  ),
];
