import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/mobile/mobile_bottom_navigation.dart';
import '../../domain/recruiter_dashboard_models.dart';
import '../recruiter_dashboard_controller.dart';
import '../shared/analytics_charts.dart';
import '../shared/dashboard_components.dart';
import '../shared/visualization_settings.dart';

class MobileRecruiterInsightsScreen extends StatefulWidget {
  const MobileRecruiterInsightsScreen({super.key});

  @override
  State<MobileRecruiterInsightsScreen> createState() =>
      _MobileRecruiterInsightsScreenState();
}

class _MobileRecruiterInsightsScreenState
    extends State<MobileRecruiterInsightsScreen> {
  var _visualType = AnalyticsVisualType.lines;
  var _showPrevious = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecruiterDashboardController>();
    final data = controller.analytics;
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
                  height: 270,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const RecruiterDashboardHeaderBackground(),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const RecruiterMobileHeaderBar(),
                              const Spacer(),
                              const Text(
                                'Insights Studio',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -.7,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Analyse avancée et coordonnées précises.',
                                style: TextStyle(
                                  color: Color(0xFFE5EEF6),
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              DashboardPeriodSelector(
                                value: controller.period,
                                onChanged: (period) => controller.setPeriod(
                                  period,
                                  loadAnalytics: true,
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
                  offset: const Offset(0, -16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: _body(controller, data),
                  ),
                ),
              ],
            ),
          ),
          MobileBottomNavigation(
            selectedIndex: 0,
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

  Widget _body(
    RecruiterDashboardController controller,
    RecruiterAnalyticsData? data,
  ) {
    if (controller.isLoading && data == null) {
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (data == null) {
      return DashboardCard(
        child: Text(
          controller.errorMessage ?? 'Aucune donnée.',
          style: const TextStyle(color: dashboardNavy),
        ),
      );
    }
    return Column(
      children: [
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardSectionTitle(title: 'Type de graphique'),
              const SizedBox(height: 10),
              SegmentedButton<AnalyticsVisualType>(
                segments: const [
                  ButtonSegment(
                    value: AnalyticsVisualType.lines,
                    label: Text('Courbes'),
                  ),
                  ButtonSegment(
                    value: AnalyticsVisualType.area,
                    label: Text('Aire'),
                  ),
                  ButtonSegment(
                    value: AnalyticsVisualType.bars,
                    label: Text('Barres'),
                  ),
                ],
                selected: {_visualType},
                showSelectedIcon: false,
                onSelectionChanged: (values) =>
                    setState(() => _visualType = values.first),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: _showPrevious,
                onChanged: (value) => setState(() => _showPrevious = value),
                title: const Text(
                  'Comparer à N-1',
                  style: TextStyle(
                    color: dashboardNavy,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DashboardCard(
          padding: const EdgeInsets.fromLTRB(14, 16, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardSectionTitle(
                title: 'Analyse multi-séries',
                subtitle: 'Touchez le plan pour lire toutes les coordonnées.',
              ),
              const SizedBox(height: 8),
              InteractiveMultiSeriesChart(
                points: data.trend,
                height: 270,
                visualType: _visualType,
                showPrevious: _showPrevious,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardSectionTitle(
                title: 'Répartition des candidatures',
              ),
              const SizedBox(height: 12),
              AnalyticsDonutChart(
                items: data.channels,
                size: 135,
                centerLabel: 'Sources',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardSectionTitle(
                title: 'Concentration des candidatures',
              ),
              const SizedBox(height: 14),
              HeatmapChart(data: data.heatmap),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardSectionTitle(title: 'Entonnoir de recrutement'),
              const SizedBox(height: 14),
              FunnelChart(steps: data.funnel),
            ],
          ),
        ),
        const SizedBox(height: 26),
      ],
    );
  }
}
