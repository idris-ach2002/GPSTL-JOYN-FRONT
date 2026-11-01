import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/mobile/mobile_bottom_navigation.dart';
import '../../domain/recruiter_dashboard_models.dart';
import '../recruiter_dashboard_controller.dart';
import '../shared/advanced_visualization_panel.dart';
import '../shared/analytics_charts.dart';
import '../shared/dashboard_business_sections.dart';
import '../shared/dashboard_components.dart';
import '../shared/visualization_settings.dart';

class MobileRecruiterDashboardScreen extends StatefulWidget {
  const MobileRecruiterDashboardScreen({super.key});

  @override
  State<MobileRecruiterDashboardScreen> createState() =>
      _MobileRecruiterDashboardScreenState();
}

class _MobileRecruiterDashboardScreenState
    extends State<MobileRecruiterDashboardScreen> {
  VisualizationSettings _settings = VisualizationSettings.standard.copyWith(
    showPrevious: false,
  );

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecruiterDashboardController>();
    return MobileAppSurface(
      systemUiOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: const Color(0xFFF5F7F8),
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadDashboard,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _MobileHero(
                    period: controller.period,
                    onChanged: (period) =>
                        controller.setPeriod(period, loadDashboard: true),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _MobileBody(
                        controller: controller,
                        overview: controller.overview,
                        analytics: controller.analytics,
                        settings: _settings,
                        onSettingsChanged: (value) =>
                            setState(() => _settings = value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          MobileBottomNavigation(
            selectedIndex: 0,
            onSelected: (index) {
              if (index == 0) return;
              if (index == 1) context.go(AppRoutes.recruiterCandidates);
              if (index == 2) context.go(AppRoutes.recruiterJobs);
            },
            items: const [
              MobileNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
              MobileNavItem(icon: Icons.people_alt_rounded, label: 'Talents'),
              MobileNavItem(icon: Icons.work_rounded, label: 'Offres'),
              MobileNavItem(icon: Icons.chat_bubble_rounded, label: 'Messages'),
              MobileNavItem(icon: Icons.more_horiz_rounded, label: 'Plus'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileHero extends StatelessWidget {
  const _MobileHero({required this.period, required this.onChanged});
  final DashboardPeriod period;
  final ValueChanged<DashboardPeriod> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 310,
    child: Stack(
      fit: StackFit.expand,
      children: [
        const RecruiterDashboardHeaderBackground(),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RecruiterMobileHeaderBar(),
                const Spacer(),
                const Text(
                  'Bonjour Camille 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.8,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Vos recrutements en un coup d’œil.',
                  style: TextStyle(color: Color(0xFFE5EEF6), fontSize: 13),
                ),
                const SizedBox(height: 16),
                DashboardPeriodSelector(
                  value: period,
                  onChanged: onChanged,
                  onDark: true,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _MobileBody extends StatelessWidget {
  const _MobileBody({
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
        height: 420,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.errorMessage != null && overview == null) {
      return DashboardCard(
        child: Column(
          children: [
            Text(
              controller.errorMessage!,
              style: const TextStyle(color: dashboardNavy),
            ),
            const SizedBox(height: 10),
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

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.42,
          ),
          itemCount: dashboard.kpis.length,
          itemBuilder: (context, index) =>
              DashboardKpiCard(kpi: dashboard.kpis[index]),
        ),
        const SizedBox(height: 12),
        DashboardCard(
          padding: const EdgeInsets.fromLTRB(14, 16, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardSectionTitle(
                title: 'Évolution et analyse des candidatures',
                subtitle: 'Touchez le graphique pour inspecter les valeurs.',
              ),
              const SizedBox(height: 10),
              _MobileLegend(settings: settings),
              const SizedBox(height: 6),
              InteractiveMultiSeriesChart(
                points: trend,
                height: 280,
                settings: settings,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DashboardCard(
          padding: EdgeInsets.zero,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            leading: const Icon(Icons.tune_rounded, color: dashboardBlue),
            title: const Text(
              'Paramètres de visualisation',
              style: TextStyle(
                color: dashboardNavy,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: const Text(
              'Basique, avancé et expert',
              style: TextStyle(color: dashboardMuted, fontSize: 10),
            ),
            children: [
              AdvancedVisualizationPanel(
                settings: settings,
                onChanged: onSettingsChanged,
                dataMax: dataMax,
                compact: true,
              ),
            ],
          ),
        ),
        if (advanced != null) ...[
          const SizedBox(height: 12),
          DashboardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardSectionTitle(
                  title: 'Concentration des candidatures',
                  subtitle: 'Touchez une cellule pour inspecter un créneau.',
                ),
                const SizedBox(height: 14),
                HeatmapChart(data: advanced.heatmap),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardSectionTitle(
                title: 'Top des offres',
                trailing: TextButton(
                  onPressed: () => context.go(AppRoutes.recruiterJobs),
                  child: const Text('Voir tout'),
                ),
              ),
              const SizedBox(height: 10),
              PaginatedOfferCards(
                offers: dashboard.topOffers,
                pageSize: 2,
                compact: true,
                onOpen: (id) =>
                    context.go(AppRoutes.recruiterDashboardOffer(id)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardSectionTitle(title: 'Activité récente'),
              const SizedBox(height: 10),
              PaginatedActivityFeed(
                activities: dashboard.activities,
                pageSize: 4,
                onAction: (item) {
                  if (item.kind == ActivityKind.offer) {
                    context.go(AppRoutes.recruiterJobs);
                  } else {
                    context.go(AppRoutes.recruiterCandidates);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
      ],
    );
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

class _MobileLegend extends StatelessWidget {
  const _MobileLegend({required this.settings});
  final VisualizationSettings settings;

  @override
  Widget build(BuildContext context) {
    final kinds = <DashboardSeriesKind>[
      ...settings.visibleSeries,
      if (settings.showPrevious) DashboardSeriesKind.previousApplications,
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        for (final kind in kinds)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: settings.colorFor(kind),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                kind.label,
                style: TextStyle(
                  color: dashboardMuted,
                  fontFamily: settings.fontFamily,
                  fontSize: 9,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
