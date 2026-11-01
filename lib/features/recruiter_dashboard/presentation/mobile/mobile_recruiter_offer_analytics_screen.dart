import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/mobile/mobile_bottom_navigation.dart';
import '../recruiter_dashboard_controller.dart';
import '../shared/analytics_charts.dart';
import '../shared/dashboard_components.dart';

class MobileRecruiterOfferAnalyticsScreen extends StatelessWidget {
  const MobileRecruiterOfferAnalyticsScreen({super.key, required this.offerId});
  final int offerId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecruiterDashboardController>();
    final data = controller.offerAnalytics;
    return MobileAppSurface(
      systemUiOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: const Color(0xFFF5F7F8),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 265,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const RecruiterDashboardHeaderBackground(),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const RecruiterMobileHeaderBar(),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () =>
                                    context.go(AppRoutes.recruiterJobs),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                ),
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 16,
                                ),
                                label: const Text('Retour aux offres'),
                              ),
                              const Text(
                                'Performance de l’offre',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -.6,
                                ),
                              ),
                              const SizedBox(height: 12),
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
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: data == null
                        ? SizedBox(
                            height: 380,
                            child: Center(
                              child: controller.isLoading
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      controller.errorMessage ??
                                          'Aucune donnée.',
                                    ),
                            ),
                          )
                        : Column(
                            children: [
                              DashboardCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.offer.title,
                                      style: const TextStyle(
                                        color: dashboardNavy,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${data.offer.location} · ${data.offer.contract} · ${data.offer.status}',
                                      style: const TextStyle(
                                        color: dashboardMuted,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton.icon(
                                      onPressed: () => context.go(
                                        AppRoutes.recruiterJobDetail(offerId),
                                      ),
                                      icon: const Icon(
                                        Icons.open_in_new_rounded,
                                        size: 15,
                                      ),
                                      label: const Text('Voir l’offre'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 9,
                                      mainAxisSpacing: 9,
                                      childAspectRatio: 1.35,
                                    ),
                                itemCount: data.kpis.length,
                                itemBuilder: (context, index) =>
                                    DashboardKpiCard(kpi: data.kpis[index]),
                              ),
                              const SizedBox(height: 10),
                              DashboardCard(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  16,
                                  10,
                                  12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const DashboardSectionTitle(
                                      title: 'Évolution des performances',
                                    ),
                                    const SizedBox(height: 8),
                                    InteractiveMultiSeriesChart(
                                      points: data.trend,
                                      height: 245,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              DashboardCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const DashboardSectionTitle(
                                      title: 'Pipeline de recrutement',
                                    ),
                                    const SizedBox(height: 14),
                                    FunnelChart(steps: data.pipeline),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              DashboardCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const DashboardSectionTitle(
                                      title: 'Sources des candidatures',
                                    ),
                                    const SizedBox(height: 14),
                                    DistributionDonut(
                                      items: data.sources,
                                      centerLabel:
                                          '${data.offer.applications}\ncandidatures',
                                      size: 120,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          MobileBottomNavigation(
            selectedIndex: 2,
            onSelected: (index) {
              if (index == 0) context.go(AppRoutes.recruiterDashboard);
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
