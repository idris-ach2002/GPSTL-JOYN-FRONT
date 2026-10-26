import 'dart:async';

import '../domain/recruiter_candidate_models.dart';
import 'recruiter_candidate_repository.dart';

class MockRecruiterCandidateRepository implements RecruiterCandidateRepository {
  MockRecruiterCandidateRepository({
    this.latency = const Duration(milliseconds: 260),
  }) : _statuses = {for (final item in _seedCandidates) item.id: item.status};

  final Duration latency;
  final Map<String, CandidateRecommendationStatus> _statuses;

  static const _offers = <RecruiterCandidateOffer>[
    RecruiterCandidateOffer(
      id: 1,
      title: 'Développeur·se Full-Stack en alternance',
      location: 'Paris',
      contract: 'Alternance',
    ),
    RecruiterCandidateOffer(
      id: 2,
      title: 'Product Manager',
      location: 'Paris',
      contract: 'CDI',
    ),
    RecruiterCandidateOffer(
      id: 3,
      title: 'UX/UI Designer',
      location: 'Paris',
      contract: 'CDI',
    ),
  ];

  static const _seedCandidates = <RecruiterCandidateRecommendation>[
    RecruiterCandidateRecommendation(
      id: 'cand-001',
      firstName: 'Alex',
      lastName: 'Dupont',
      jobTitle: 'Développeur Full-Stack',
      avatarUrl: 'assets/images/candidate_avatar_1.png',
      location: 'Paris',
      education: 'Master Informatique · Bac+5',
      experienceYears: 3.2,
      availability: 'Disponible sous 2 semaines',
      contractPreference: 'CDI / Alternance',
      remotePreference: 'Hybride',
      skills: ['React', 'TypeScript', 'Node.js', 'PostgreSQL', 'Docker'],
      compatibilityScore: 92,
      match: CandidateMatchBreakdown(
        skills: 94,
        experience: 88,
        education: 100,
        location: 82,
        availability: 96,
      ),
      strengths: [
        'Très bon niveau React / TypeScript',
        'Expérience SaaS B2B',
        'Disponible rapidement',
      ],
      warnings: ['Docker à confirmer en entretien'],
      summary: 'Recherche une équipe produit où progresser sur React, Node.js et DevOps, avec une vraie culture de collaboration.',
      status: CandidateRecommendationStatus.recommended,
      reciprocalMatch: false,
      connections: 2,
    ),
    RecruiterCandidateRecommendation(
      id: 'cand-002',
      firstName: 'Sarah',
      lastName: 'Martin',
      jobTitle: 'Frontend Engineer',
      avatarUrl: 'assets/images/candidate_avatar_2.png',
      location: 'Boulogne-Billancourt',
      education: 'École d’ingénieur · Bac+5',
      experienceYears: 2.8,
      availability: 'Disponible en septembre',
      contractPreference: 'CDI',
      remotePreference: 'Hybride',
      skills: ['React', 'TypeScript', 'Flutter', 'Figma', 'Jest'],
      compatibilityScore: 89,
      match: CandidateMatchBreakdown(
        skills: 91,
        experience: 82,
        education: 100,
        location: 88,
        availability: 84,
      ),
      strengths: [
        'Très forte qualité UI',
        'Expérience produit mobile',
        'Tests automatisés solides',
      ],
      warnings: ['Node.js peu présent dans les expériences récentes'],
      summary: 'Ingénieure frontend orientée produit, attentive à l’accessibilité et à la qualité d’interface.',
      status: CandidateRecommendationStatus.saved,
      reciprocalMatch: false,
      connections: 4,
    ),
    RecruiterCandidateRecommendation(
      id: 'cand-003',
      firstName: 'Thomas',
      lastName: 'Bernard',
      jobTitle: 'Software Engineer',
      avatarUrl: 'assets/images/candidate_avatar_3.png',
      location: 'Paris',
      education: 'Master Logiciel · Bac+5',
      experienceYears: 4.1,
      availability: 'Disponible immédiatement',
      contractPreference: 'CDI',
      remotePreference: 'Télétravail partiel',
      skills: ['Node.js', 'AWS', 'Docker', 'PostgreSQL', 'TypeScript'],
      compatibilityScore: 87,
      match: CandidateMatchBreakdown(
        skills: 88,
        experience: 96,
        education: 100,
        location: 82,
        availability: 100,
      ),
      strengths: [
        'Backend et cloud très solides',
        'Autonome sur les déploiements',
        'Disponible immédiatement',
      ],
      warnings: ['React intermédiaire'],
      summary: 'Profil backend/cloud autonome, habitué aux environnements à forte exigence de disponibilité.',
      status: CandidateRecommendationStatus.interested,
      reciprocalMatch: true,
      connections: 1,
    ),
    RecruiterCandidateRecommendation(
      id: 'cand-004',
      firstName: 'Inès',
      lastName: 'Leroy',
      jobTitle: 'Développeuse Full-Stack',
      avatarUrl: 'assets/images/candidate_avatar_4.png',
      location: 'Saint-Denis',
      education: 'BUT Informatique · Bac+3',
      experienceYears: 2.4,
      availability: 'Disponible sous 1 mois',
      contractPreference: 'Alternance / CDI',
      remotePreference: 'Hybride',
      skills: ['React', 'Node.js', 'MongoDB', 'GitHub Actions'],
      compatibilityScore: 85,
      match: CandidateMatchBreakdown(
        skills: 89,
        experience: 78,
        education: 76,
        location: 90,
        availability: 88,
      ),
      strengths: [
        'Bonne polyvalence front/back',
        'CI/CD déjà pratiquée',
        'Localisation favorable',
      ],
      warnings: ['Niveau de diplôme sous le niveau cible'],
      summary: 'Profil full-stack très opérationnel, motivé par les équipes à taille humaine et les cycles courts.',
      status: CandidateRecommendationStatus.recommended,
      reciprocalMatch: false,
      connections: 3,
    ),
    RecruiterCandidateRecommendation(
      id: 'cand-005',
      firstName: 'Lucas',
      lastName: 'Moreau',
      jobTitle: 'Product Manager',
      avatarUrl: 'assets/images/candidate_avatar_5.png',
      location: 'Paris',
      education: 'Master Management Produit · Bac+5',
      experienceYears: 4.6,
      availability: 'Disponible sous 3 semaines',
      contractPreference: 'CDI',
      remotePreference: 'Hybride',
      skills: ['Discovery', 'Analytics', 'Roadmap', 'SQL', 'Figma'],
      compatibilityScore: 94,
      match: CandidateMatchBreakdown(
        skills: 96,
        experience: 95,
        education: 100,
        location: 92,
        availability: 86,
      ),
      strengths: [
        'Très bonne culture data',
        'Discovery structurée',
        'Expérience SaaS',
      ],
      warnings: ['Préavis à confirmer'],
      summary: 'PM orienté impact, à l’aise entre discovery, analytics et coordination d’équipes techniques.',
      status: CandidateRecommendationStatus.recommended,
      reciprocalMatch: false,
      connections: 5,
    ),
    RecruiterCandidateRecommendation(
      id: 'cand-006',
      firstName: 'Camille',
      lastName: 'Roux',
      jobTitle: 'Product Designer',
      avatarUrl: 'assets/images/candidate_avatar_6.png',
      location: 'Montreuil',
      education: 'DSAA Design · Bac+5',
      experienceYears: 3.5,
      availability: 'Disponible immédiatement',
      contractPreference: 'CDI',
      remotePreference: 'Hybride',
      skills: ['Figma', 'Design System', 'UX Research', 'Prototypage'],
      compatibilityScore: 91,
      match: CandidateMatchBreakdown(
        skills: 95,
        experience: 90,
        education: 100,
        location: 88,
        availability: 100,
      ),
      strengths: [
        'Design system très solide',
        'Recherche utilisateur',
        'Disponible immédiatement',
      ],
      warnings: ['Peu d’expérience B2B'],
      summary: 'Designer produit complet, capable d’aller de la recherche au prototype haute fidélité.',
      status: CandidateRecommendationStatus.matched,
      reciprocalMatch: true,
      connections: 2,
    ),
    RecruiterCandidateRecommendation(
      id: 'cand-007',
      firstName: 'Nora',
      lastName: 'Petit',
      jobTitle: 'Frontend Developer',
      location: 'Cergy',
      education: 'Licence Pro Web · Bac+3',
      experienceYears: 2.1,
      availability: 'Disponible sous 2 mois',
      contractPreference: 'CDI',
      remotePreference: 'Télétravail partiel',
      skills: ['Vue.js', 'TypeScript', 'CSS', 'Cypress'],
      compatibilityScore: 78,
      match: CandidateMatchBreakdown(
        skills: 74,
        experience: 72,
        education: 76,
        location: 68,
        availability: 64,
      ),
      strengths: ['Très bonne qualité frontend', 'Cypress maîtrisé'],
      warnings: ['React non confirmé', 'Disponibilité à 2 mois'],
      summary:
          'Développeuse frontend très appliquée, orientée qualité et tests.',
      status: CandidateRecommendationStatus.rejected,
      reciprocalMatch: false,
      connections: 0,
    ),
  ];

  @override
  Future<CandidateRecommendationData> fetchRecommendations(
    CandidateRecommendationQuery query,
  ) async {
    await Future<void>.delayed(latency);
    final selectedOfferId = query.offerId ?? _offers.first.id;
    const offerCandidates = <int, Set<String>>{
      1: {'cand-001', 'cand-002', 'cand-003', 'cand-004'},
      2: {'cand-003', 'cand-005'},
      3: {'cand-002', 'cand-006', 'cand-007'},
    };
    final eligibleIds = offerCandidates[selectedOfferId] ?? const <String>{};
    var items = _seedCandidates
        .map((item) => item.copyWith(status: _statuses[item.id]))
        .where((item) => eligibleIds.isEmpty || eligibleIds.contains(item.id))
        .where((item) => item.status == query.status)
        .where((item) => item.compatibilityScore >= query.scoreMin)
        .toList();

    if (query.location != null && query.location!.trim().isNotEmpty) {
      final needle = query.location!.toLowerCase();
      items = items
          .where((item) => item.location.toLowerCase().contains(needle))
          .toList();
    }
    if (query.skills.isNotEmpty) {
      final requiredSkills = query.skills
          .map((item) => item.toLowerCase())
          .toSet();
      items = items.where((item) {
        final candidateSkills = item.skills
            .map((skill) => skill.toLowerCase())
            .toSet();
        return requiredSkills.every(candidateSkills.contains);
      }).toList();
    }
    if (query.experienceMin != null) {
      items = items
          .where((item) => item.experienceYears >= query.experienceMin!)
          .toList();
    }
    if (query.experienceMax != null) {
      items = items
          .where((item) => item.experienceYears <= query.experienceMax!)
          .toList();
    }
    if (query.contractType != null && query.contractType!.trim().isNotEmpty) {
      final contract = query.contractType!.toLowerCase();
      items = items
          .where(
            (item) => item.contractPreference.toLowerCase().contains(contract),
          )
          .toList();
    }

    items.sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));
    final totalItems = items.length;
    final start = ((query.page - 1) * query.limit).clamp(0, totalItems).toInt();
    final end = (start + query.limit).clamp(0, totalItems).toInt();
    final pageItems = items.sublist(start, end);
    final totalPages = totalItems == 0
        ? 1
        : ((totalItems + query.limit - 1) ~/ query.limit);

    return CandidateRecommendationData(
      items: pageItems,
      offers: _offers,
      stats: _stats(eligibleIds),
      page: query.page,
      totalPages: totalPages,
      totalItems: totalItems,
      selectedOfferId: selectedOfferId,
    );
  }

  @override
  Future<RecruiterCandidateRecommendation> fetchCandidate(
    String candidateId,
  ) async {
    await Future<void>.delayed(latency);
    final item = _seedCandidates.firstWhere(
      (candidate) => candidate.id == candidateId,
    );
    return item.copyWith(status: _statuses[item.id]);
  }

  @override
  Future<RecruiterCandidateRecommendation> updateStatus(
    String candidateId,
    CandidateRecommendationStatus status,
  ) async {
    await Future<void>.delayed(latency);
    final item = _seedCandidates.firstWhere(
      (candidate) => candidate.id == candidateId,
    );
    _statuses[candidateId] = status;
    final reciprocal =
        status == CandidateRecommendationStatus.interested &&
        (candidateId == 'cand-001' ||
            candidateId == 'cand-003' ||
            candidateId == 'cand-006');
    return item.copyWith(
      status: status,
      reciprocalMatch: reciprocal || item.reciprocalMatch,
    );
  }

  CandidateRecommendationStats _stats(Set<String> eligibleIds) {
    int count(CandidateRecommendationStatus status) =>
        eligibleIds.where((id) => _statuses[id] == status).length;
    return CandidateRecommendationStats(
      recommended: count(CandidateRecommendationStatus.recommended),
      saved: count(CandidateRecommendationStatus.saved),
      interested: count(CandidateRecommendationStatus.interested),
      matches: count(CandidateRecommendationStatus.matched),
    );
  }
}
