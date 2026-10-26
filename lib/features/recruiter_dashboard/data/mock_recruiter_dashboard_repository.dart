import 'dart:math' as math;

import '../domain/recruiter_dashboard_models.dart';
import 'recruiter_dashboard_repository.dart';

class MockRecruiterDashboardRepository implements RecruiterDashboardRepository {
  MockRecruiterDashboardRepository({
    this.latency = const Duration(milliseconds: 320),
  });

  final Duration latency;

  Future<void> _wait() async {
    if (latency != Duration.zero) await Future<void>.delayed(latency);
  }

  @override
  Future<RecruiterDashboardData> fetchOverview(DashboardPeriod period) async {
    await _wait();
    final trend = _trend(period);
    return RecruiterDashboardData(
      period: period,
      kpis: const [
        DashboardKpi(
          id: 'applications',
          label: 'Candidatures reçues',
          value: '248',
          deltaPercent: 12,
          deltaLabel: 'vs période précédente',
        ),
        DashboardKpi(
          id: 'matches',
          label: 'Matches qualifiés',
          value: '86',
          deltaPercent: 28,
          deltaLabel: 'vs période précédente',
        ),
        DashboardKpi(
          id: 'offers',
          label: 'Offres actives',
          value: '5',
          deltaPercent: 1,
          deltaLabel: 'nouvelle offre active',
        ),
        DashboardKpi(
          id: 'response',
          label: 'Délai de réponse moyen',
          value: '3,2 jours',
          deltaPercent: -18,
          deltaLabel: 'plus rapide',
        ),
      ],
      trend: trend,
      profileDistribution: const [
        DashboardDistributionItem(label: 'Très compatibles', value: 38),
        DashboardDistributionItem(label: 'Compatibles', value: 34),
        DashboardDistributionItem(label: 'À approfondir', value: 18),
        DashboardDistributionItem(label: 'Autres', value: 10),
      ],
      topOffers: _offers,
      activities: const [
        DashboardActivity(
          kind: ActivityKind.application,
          title: 'Nouvelle candidature',
          subtitle: 'Développeur·se Full-Stack en alternance',
          whenLabel: 'il y a 2 h',
        ),
        DashboardActivity(
          kind: ActivityKind.match,
          title: 'Match qualifié',
          subtitle: 'Product Manager',
          whenLabel: 'il y a 5 h',
        ),
        DashboardActivity(
          kind: ActivityKind.interview,
          title: 'Entretien planifié',
          subtitle: 'UX/UI Designer',
          whenLabel: 'demain · 14 h',
        ),
        DashboardActivity(
          kind: ActivityKind.offer,
          title: 'Offre publiée',
          subtitle: 'Data Analyst',
          whenLabel: 'il y a 1 j',
        ),
        DashboardActivity(
          kind: ActivityKind.application,
          title: 'Nouvelle candidature',
          subtitle: 'UX/UI Designer · profil compatible à 91 %',
          whenLabel: 'il y a 1 j',
        ),
        DashboardActivity(
          kind: ActivityKind.match,
          title: 'Match qualifié',
          subtitle: 'Talent Acquisition Specialist · score 87 %',
          whenLabel: 'il y a 2 j',
        ),
        DashboardActivity(
          kind: ActivityKind.interview,
          title: 'Compte-rendu ajouté',
          subtitle: 'Développeur·se Full-Stack · entretien technique',
          whenLabel: 'il y a 2 j',
        ),
        DashboardActivity(
          kind: ActivityKind.system,
          title: 'Analyse mise à jour',
          subtitle: 'Les indicateurs de conversion ont été recalculés.',
          whenLabel: 'il y a 3 j',
        ),
      ],
      priorityActions: const [
        DashboardPriorityAction(
          title: '5 profils à évaluer',
          subtitle: 'Des candidats très proches de vos critères attendent une décision.',
          actionLabel: 'Examiner',
        ),
        DashboardPriorityAction(
          title: '2 entretiens à planifier',
          subtitle: 'Deux profils qualifiés n’ont pas encore de créneau.',
          actionLabel: 'Planifier',
        ),
        DashboardPriorityAction(
          title: 'Optimiser l’offre Data Analyst',
          subtitle: 'Le taux de conversion est inférieur à votre moyenne.',
          actionLabel: 'Analyser',
        ),
      ],
    );
  }

  @override
  Future<RecruiterAnalyticsData> fetchAnalytics(DashboardPeriod period) async {
    await _wait();
    return RecruiterAnalyticsData(
      period: period,
      trend: _trend(period),
      funnel: const [
        AnalyticsFunnelStep(label: 'Candidatures', value: 420),
        AnalyticsFunnelStep(label: 'Qualifiés', value: 280),
        AnalyticsFunnelStep(label: 'Entretiens', value: 120),
        AnalyticsFunnelStep(label: 'Offres envoyées', value: 48),
        AnalyticsFunnelStep(label: 'Recrutés', value: 22),
      ],
      channels: const [
        AnalyticsChannelValue(label: 'LinkedIn', value: 482),
        AnalyticsChannelValue(label: 'Indeed', value: 320),
        AnalyticsChannelValue(label: 'Site carrière', value: 186),
        AnalyticsChannelValue(label: 'Cooptation', value: 164),
        AnalyticsChannelValue(label: 'Autres', value: 98),
      ],
      heatmap: AnalyticsHeatmap(
        rows: const ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
        columns: const ['8h', '10h', '12h', '14h', '16h', '18h'],
        values: const [
          [12, 28, 46, 58, 52, 31],
          [18, 34, 62, 70, 66, 42],
          [16, 40, 68, 78, 71, 38],
          [21, 43, 74, 82, 69, 35],
          [14, 37, 63, 72, 61, 29],
          [7, 18, 29, 34, 27, 13],
          [5, 12, 22, 25, 18, 9],
        ],
      ),
      surface: AnalyticsSurface(
        xLabels: const ['0-1', '1-2', '2-3', '3-5', '5+'],
        yLabels: const ['Junior', 'Intermédiaire', 'Confirmé', 'Senior'],
        values: const [
          [18, 25, 32, 24, 14],
          [22, 38, 55, 42, 20],
          [12, 31, 68, 61, 35],
          [7, 18, 42, 73, 64],
        ],
      ),
    );
  }

  @override
  Future<OfferAnalyticsData> fetchOfferAnalytics(
    int offerId,
    DashboardPeriod period,
  ) async {
    await _wait();
    final offer = _offers.firstWhere(
      (item) => item.id == offerId,
      orElse: () => _offers.first,
    );
    return OfferAnalyticsData(
      offer: offer,
      kpis: [
        DashboardKpi(
          id: 'applications',
          label: 'Candidatures reçues',
          value: '${offer.applications}',
          deltaPercent: 33,
        ),
        DashboardKpi(
          id: 'matches',
          label: 'Matches qualifiés',
          value: '${offer.matches}',
          deltaPercent: 45,
        ),
        DashboardKpi(
          id: 'interviews',
          label: 'Entretiens planifiés',
          value: '${offer.interviews}',
          deltaPercent: 21,
        ),
        DashboardKpi(
          id: 'conversion',
          label: 'Taux de conversion',
          value: '${offer.conversionRate.toStringAsFixed(1)} %',
          deltaPercent: 3,
        ),
      ],
      trend: _trend(period),
      sources: const [
        DashboardDistributionItem(label: 'Site carrière', value: 38),
        DashboardDistributionItem(label: 'Matching JOYN', value: 26),
        DashboardDistributionItem(label: 'Recommandations', value: 16),
        DashboardDistributionItem(label: 'Recherche active', value: 12),
        DashboardDistributionItem(label: 'Cooptation', value: 8),
      ],
      pipeline: const [
        AnalyticsFunnelStep(label: 'Nouveaux', value: 18),
        AnalyticsFunnelStep(label: 'En revue', value: 12),
        AnalyticsFunnelStep(label: 'Entretien', value: 8),
        AnalyticsFunnelStep(label: 'Shortlist', value: 6),
        AnalyticsFunnelStep(label: 'Acceptés', value: 2),
      ],
      skills: const [
        DashboardDistributionItem(label: 'React', value: 78),
        DashboardDistributionItem(label: 'TypeScript', value: 67),
        DashboardDistributionItem(label: 'Node.js', value: 61),
        DashboardDistributionItem(label: 'PostgreSQL', value: 52),
        DashboardDistributionItem(label: 'Docker', value: 44),
      ],
      actions: const [
        DashboardPriorityAction(
          title: 'Relancer 4 candidats',
          subtitle: 'Sans réponse depuis plus de 5 jours.',
          actionLabel: 'Relancer',
        ),
        DashboardPriorityAction(
          title: 'Planifier 2 entretiens',
          subtitle: 'Deux matches qualifiés attendent un créneau.',
          actionLabel: 'Planifier',
        ),
        DashboardPriorityAction(
          title: 'Améliorer le titre',
          subtitle:
              'Une formulation plus précise peut augmenter la visibilité.',
          actionLabel: 'Modifier',
        ),
      ],
    );
  }

  List<DashboardTrendPoint> _trend(DashboardPeriod period) {
    final count = switch (period) {
      DashboardPeriod.sevenDays => 7,
      DashboardPeriod.thirtyDays => 30,
      DashboardPeriod.all => 42,
    };
    final start = DateTime(2026, 9, 1);
    return List.generate(count, (index) {
      final wave = math.sin(index * .62) * 3.4;
      final longWave = math.cos(index * .23) * 2.2;
      final applications = 8 + index * .85 + wave + longWave;
      final matches = 3 + index * .39 + math.sin(index * .48 + .8) * 1.9;
      final interviews = 1 + index * .18 + math.sin(index * .52 + 1.4) * 1.2;
      return DashboardTrendPoint(
        date: start.add(Duration(days: index)),
        applications: applications.clamp(0, double.infinity).toDouble(),
        matches: matches.clamp(0, double.infinity).toDouble(),
        interviews: interviews.clamp(0, double.infinity).toDouble(),
        previousApplications: (applications * .78 + math.sin(index * .31) * 2)
            .clamp(0, double.infinity)
            .toDouble(),
      );
    });
  }

  static const _offers = [
    DashboardOfferPerformance(
      id: 1,
      title: 'Développeur·se Full-Stack en alternance',
      location: 'Paris, France',
      contract: 'Alternance',
      status: 'Publiée',
      applications: 128,
      matches: 32,
      interviews: 12,
      views: 1240,
      conversionRate: 25,
      lastActivity: 'il y a 2 h',
      tagline: 'Construisez les outils qui feront évoluer l’expérience JOYN.',
    ),
    DashboardOfferPerformance(
      id: 3,
      title: 'Product Manager',
      location: 'Paris, France',
      contract: 'CDI',
      status: 'Publiée',
      applications: 64,
      matches: 18,
      interviews: 6,
      views: 856,
      conversionRate: 28.1,
      lastActivity: 'il y a 1 j',
      tagline:
          'Pilotez des expériences produit utiles, mesurables et ambitieuses.',
    ),
    DashboardOfferPerformance(
      id: 2,
      title: 'Data Analyst',
      location: 'Lyon, France',
      contract: 'CDI',
      status: 'Publiée',
      applications: 42,
      matches: 12,
      interviews: 4,
      views: 620,
      conversionRate: 28.6,
      lastActivity: 'il y a 3 j',
      tagline: 'Transformez les données de recrutement en décisions concrètes.',
    ),
    DashboardOfferPerformance(
      id: 4,
      title: 'UX/UI Designer',
      location: 'Paris, France',
      contract: 'CDI',
      status: 'Publiée',
      applications: 38,
      matches: 14,
      interviews: 7,
      views: 548,
      conversionRate: 36.8,
      lastActivity: 'il y a 4 j',
      tagline: 'Donnez une forme simple et forte aux parcours candidats et recruteurs.',
    ),
    DashboardOfferPerformance(
      id: 5,
      title: 'Talent Acquisition Specialist',
      location: 'Bordeaux, France',
      contract: 'CDI',
      status: 'Publiée',
      applications: 31,
      matches: 11,
      interviews: 5,
      views: 431,
      conversionRate: 35.5,
      lastActivity: 'il y a 5 j',
      tagline: 'Créez des rencontres pertinentes et accélérez les recrutements qui comptent.',
    ),
  ];
}
