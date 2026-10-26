import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../recruiter_offers/presentation/web/recruiter_offers_top_bar.dart';
import '../../domain/recruiter_dashboard_models.dart';
import '../recruiter_dashboard_controller.dart';
import '../shared/analytics_charts.dart';
import '../shared/dashboard_components.dart';

class WebRecruiterOfferAnalyticsScreen extends StatelessWidget {
  const WebRecruiterOfferAnalyticsScreen({super.key, required this.offerId});

  final int offerId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecruiterDashboardController>();
    final data = controller.offerAnalytics;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 250,
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
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const RecruiterOffersTopBar(
                                active: RecruiterTopTab.offers,
                              ),
                              const Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => context.go(
                                            AppRoutes.recruiterJobs,
                                          ),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                          ),
                                          icon: const Icon(
                                            Icons.arrow_back_rounded,
                                            size: 17,
                                          ),
                                          label: const Text(
                                            'Retour aux offres',
                                          ),
                                        ),
                                        const Text(
                                          'Performance de l’offre',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -.7,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DashboardPeriodSelector(
                                    value: controller.period,
                                    onChanged: (period) => controller.setPeriod(
                                      period,
                                      offerId: offerId,
                                    ),
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _body(context, controller, data),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    RecruiterDashboardController controller,
    OfferAnalyticsData? data,
  ) {
    if (controller.isLoading && data == null) {
      return const SizedBox(
        height: 450,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.errorMessage != null && data == null) {
      return DashboardCard(
        child: Center(
          child: Text(
            controller.errorMessage!,
            style: const TextStyle(color: dashboardNavy),
          ),
        ),
      );
    }
    if (data == null) return const SizedBox.shrink();

    return Column(
      children: [
        DashboardCard(
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: dashboardBlue.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.code_rounded, color: dashboardBlue),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.offer.title,
                      style: const TextStyle(
                        color: dashboardNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data.offer.location} · ${data.offer.contract} · ${data.offer.status}',
                      style: const TextStyle(
                        color: dashboardMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    context.go(AppRoutes.recruiterJobDetail(offerId)),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Voir l’offre'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 42) / 4;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final kpi in data.kpis)
                  SizedBox(
                    width: width,
                    child: DashboardKpiCard(kpi: kpi),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: DashboardCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashboardSectionTitle(
                      title: 'Évolution des performances',
                      subtitle: 'Candidatures, matches et entretiens sur la période sélectionnée.',
                    ),
                    const SizedBox(height: 8),
                    InteractiveMultiSeriesChart(
                      points: data.trend,
                      height: 300,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashboardSectionTitle(
                      title: 'Sources des candidatures',
                    ),
                    const SizedBox(height: 16),
                    DistributionDonut(
                      items: data.sources,
                      centerLabel: '${data.offer.applications}\ncandidatures',
                      size: 142,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DashboardCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashboardSectionTitle(
                      title: 'Pipeline de recrutement',
                    ),
                    const SizedBox(height: 15),
                    FunnelChart(steps: data.pipeline),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashboardSectionTitle(
                      title: 'Compétences dominantes',
                    ),
                    const SizedBox(height: 14),
                    for (final skill in data.skills)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 82,
                              child: Text(
                                skill.label,
                                style: const TextStyle(
                                  color: dashboardMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: skill.value / 100,
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFFE8EEF3),
                                  color: dashboardBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 32,
                              child: Text(
                                '${skill.value.round()}%',
                                style: const TextStyle(
                                  color: dashboardNavy,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashboardSectionTitle(title: 'Actions prioritaires'),
                    const SizedBox(height: 8),
                    for (final action in data.actions)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.arrow_circle_right_outlined,
                          size: 19,
                          color: dashboardBlue,
                        ),
                        title: Text(
                          action.title,
                          style: const TextStyle(
                            color: dashboardNavy,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(
                          action.subtitle,
                          style: const TextStyle(
                            color: dashboardMuted,
                            fontSize: 9.2,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                        ),
                        onTap: () {},
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
