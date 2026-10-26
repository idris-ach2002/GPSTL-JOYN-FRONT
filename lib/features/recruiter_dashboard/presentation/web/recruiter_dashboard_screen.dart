import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../recruiter_offers/presentation/web/recruiter_offers_top_bar.dart';
import '../../domain/recruiter_dashboard_models.dart';
import '../recruiter_dashboard_controller.dart';
import '../shared/advanced_visualization_panel.dart';
import '../shared/analytics_charts.dart';
import '../shared/dashboard_business_sections.dart';
import '../shared/dashboard_components.dart';
import '../shared/visualization_settings.dart';

class WebRecruiterDashboardScreen extends StatefulWidget {
  const WebRecruiterDashboardScreen({super.key});

  @override
  State<WebRecruiterDashboardScreen> createState() =>
      _WebRecruiterDashboardScreenState();
}

class _WebRecruiterDashboardScreenState
    extends State<WebRecruiterDashboardScreen> {
  VisualizationSettings _settings = VisualizationSettings.standard;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecruiterDashboardController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      body: RefreshIndicator(
        onRefresh: controller.loadDashboard,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _DashboardHero(
                period: controller.period,
                onPeriodChanged: (period) =>
                    controller.setPeriod(period, loadDashboard: true),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1320),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _DashboardBody(
                        controller: controller,
                        overview: controller.overview,
                        analytics: controller.analytics,
                        settings: _settings,
                        onSettingsChanged: (value) =>
                            setState(() => _settings = value),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.period, required this.onPeriodChanged});

  final DashboardPeriod period;
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 286,
    child: ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const RecruiterDashboardHeaderBackground(),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 44),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const RecruiterOffersTopBar(
                        active: RecruiterTopTab.dashboard,
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bonjour Camille 👋',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 37,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.1,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Voici la performance de vos recrutements et les actions qui méritent votre attention.',
                                  style: TextStyle(
                                    color: Color(0xFFE5EEF6),
                                    fontSize: 14,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          DashboardPeriodSelector(
                            value: period,
                            onChanged: onPeriodChanged,
                            onDark: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.controller,
    required this.overview,
    required this.analytics,
    required this.settings,
    required this.onSettingsChanged,
  });

  final RecruiterDashboardController controller;
  final RecruiterDashboardData? overview;
  final RecruiterAnalyticsData? analytics;
  final VisualizationSettings settings;
  final ValueChanged<VisualizationSettings> onSettingsChanged;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && overview == null && analytics == null) {
      return const SizedBox(
        height: 520,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.errorMessage != null && overview == null) {
      return DashboardCard(
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 34,
              color: dashboardMuted,
            ),
            const SizedBox(height: 10),
            Text(
              controller.errorMessage!,
              style: const TextStyle(color: dashboardNavy),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: controller.loadDashboard,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final dashboard = overview;
    if (dashboard == null) return const SizedBox.shrink();
    final advanced = analytics;
    final trend = advanced?.trend ?? dashboard.trend;
    final dataMax = _trendMax(trend, settings);

    final chartCard = DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionTitle(
            title: 'Évolution et analyse des candidatures',
          ),
          const SizedBox(height: 12),
          _SeriesLegend(settings: settings),
          const SizedBox(height: 8),
          InteractiveMultiSeriesChart(
            points: trend,
            height: 330,
            settings: settings,
          ),
        ],
      ),
    );

    final settingsCard = DashboardCard(
      child: AdvancedVisualizationPanel(
        settings: settings,
        onChanged: onSettingsChanged,
        dataMax: dataMax,
      ),
    );

    final heatmapCard = advanced == null
        ? null
        : DashboardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardSectionTitle(
                  title: 'Concentration des candidatures',
                  subtitle:
                      'Répartition interactive par jour et créneau horaire.',
                ),
                const SizedBox(height: 14),
                HeatmapChart(data: advanced.heatmap),
              ],
            ),
          );

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final count = dashboard.kpis.length;
            final columns = constraints.maxWidth < 850 ? 2 : math.max(1, count);
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final kpi in dashboard.kpis)
                  SizedBox(
                    width: width,
                    child: DashboardKpiCard(kpi: kpi),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 860) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: chartCard),
                  const SizedBox(width: 14),
                  SizedBox(width: 340, child: settingsCard),
                ],
              );
            }

            return Column(
              children: [chartCard, const SizedBox(height: 14), settingsCard],
            );
          },
        ),
        if (heatmapCard != null) ...[const SizedBox(height: 16), heatmapCard],
        const SizedBox(height: 16),
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardSectionTitle(
                title: 'Activité récente',
                subtitle: 'Les événements importants à consulter ou à traiter maintenant.',
              ),
              const SizedBox(height: 12),
              PaginatedActivityFeed(
                activities: dashboard.activities,
                pageSize: 5,
                onAction: (item) => _openActivity(context, item),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardSectionTitle(
                title: 'Top des offres',
                trailing: TextButton(
                  onPressed: () => context.go(AppRoutes.recruiterJobs),
                  child: const Text('Voir toutes les offres →'),
                ),
              ),
              const SizedBox(height: 12),
              PaginatedOfferCards(
                offers: dashboard.topOffers,
                pageSize: 5,
                onOpen: (id) =>
                    context.go(AppRoutes.recruiterDashboardOffer(id)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  void _openActivity(BuildContext context, DashboardActivity item) {
    switch (item.kind) {
      case ActivityKind.offer:
        context.go(AppRoutes.recruiterJobs);
        return;
      case ActivityKind.application:
      case ActivityKind.match:
      case ActivityKind.interview:
        context.go(AppRoutes.recruiterCandidates);
        return;
      case ActivityKind.system:
        context.go(AppRoutes.recruiterDashboard);
        return;
    }
  }

  double _trendMax(
    List<DashboardTrendPoint> trend,
    VisualizationSettings settings,
  ) {
    var maxValue = 1.0;
    final series = <DashboardSeriesKind>{
      ...settings.visibleSeries,
      if (settings.showPrevious) DashboardSeriesKind.previousApplications,
    };
    for (final point in trend) {
      for (final kind in series) {
        maxValue = math.max(maxValue, point.valueFor(kind));
      }
    }
    return math.max(10, (maxValue / 10).ceil() * 10).toDouble();
  }
}

class _SeriesLegend extends StatelessWidget {
  const _SeriesLegend({required this.settings});
  final VisualizationSettings settings;

  @override
  Widget build(BuildContext context) {
    final kinds = <DashboardSeriesKind>[
      ...settings.visibleSeries,
      if (settings.showPrevious) DashboardSeriesKind.previousApplications,
    ];
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final kind in kinds)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: settings.colorFor(kind),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                kind.label,
                style: TextStyle(
                  color: dashboardMuted,
                  fontFamily: settings.fontFamily,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
