import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../recruiter_offers/presentation/web/recruiter_offers_top_bar.dart';
import '../../domain/recruiter_dashboard_models.dart';
import '../recruiter_dashboard_controller.dart';
import '../shared/analytics_charts.dart';
import '../shared/dashboard_components.dart';
import '../shared/visualization_settings.dart';

class WebRecruiterInsightsScreen extends StatefulWidget {
  const WebRecruiterInsightsScreen({super.key});

  @override
  State<WebRecruiterInsightsScreen> createState() =>
      _WebRecruiterInsightsScreenState();
}

class _WebRecruiterInsightsScreenState
    extends State<WebRecruiterInsightsScreen> {
  AnalyticsVisualType _visualType = AnalyticsVisualType.lines;
  var _showPrevious = true;
  final Set<DashboardSeriesKind> _series = {
    DashboardSeriesKind.applications,
    DashboardSeriesKind.matches,
    DashboardSeriesKind.interviews,
  };

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecruiterDashboardController>();
    final data = controller.analytics;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 245,
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
                                active: RecruiterTopTab.dashboard,
                              ),
                              const Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Insights Studio',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 34,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -.8,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Construisez vos analyses comme dans un outil mathématique : séries, axes, coordonnées et vues multidimensionnelles.',
                                          style: TextStyle(
                                            color: Color(0xFFE4EDF5),
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                    child: _body(controller, data),
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
    RecruiterDashboardController controller,
    RecruiterAnalyticsData? data,
  ) {
    if (controller.isLoading && data == null) {
      return const SizedBox(
        height: 500,
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 285,
              child: _ConfigurationPanel(
                visualType: _visualType,
                showPrevious: _showPrevious,
                series: _series,
                onVisualTypeChanged: (value) =>
                    setState(() => _visualType = value),
                onPreviousChanged: (value) =>
                    setState(() => _showPrevious = value),
                onSeriesChanged: (kind, enabled) => setState(() {
                  if (enabled) {
                    _series.add(kind);
                  } else if (_series.length > 1) {
                    _series.remove(kind);
                  }
                }),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  DashboardCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DashboardSectionTitle(
                          title: 'Analyse multi-séries',
                          subtitle: 'Lecture précise des coordonnées : survolez ou touchez le plan pour inspecter chaque date.',
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            for (final kind in _series)
                              _SeriesLegend(kind: kind),
                            if (_showPrevious)
                              const _SeriesLegend(
                                kind: DashboardSeriesKind.previousApplications,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        InteractiveMultiSeriesChart(
                          points: data.trend,
                          height: 365,
                          visibleSeries: _series,
                          visualType: _visualType,
                          showPrevious: _showPrevious,
                        ),
                      ],
                    ),
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
                                title: 'Tunnel de conversion',
                                subtitle: 'Progression des candidatures dans les principales étapes du recrutement.',
                              ),
                              const SizedBox(height: 8),
                              FunnelChart(steps: data.funnel),
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
                                title: 'Concentration des candidatures',
                                subtitle: 'Concentration des candidatures par jour et plage horaire.',
                              ),
                              const SizedBox(height: 18),
                              HeatmapChart(data: data.heatmap),
                              const SizedBox(height: 16),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'faible',
                                    style: TextStyle(
                                      color: dashboardMuted,
                                      fontSize: 9,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  _HeatLegend(),
                                  SizedBox(width: 8),
                                  Text(
                                    'fort',
                                    style: TextStyle(
                                      color: dashboardMuted,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
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
                                title: 'Entonnoir de recrutement',
                              ),
                              const SizedBox(height: 16),
                              FunnelChart(steps: data.funnel),
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
                                title: 'Performance par canal',
                              ),
                              const SizedBox(height: 14),
                              for (final channel in data.channels)
                                _ChannelBar(
                                  channel: channel,
                                  max: data.channels
                                      .map((e) => e.value)
                                      .reduce((a, b) => a > b ? a : b),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ConfigurationPanel extends StatelessWidget {
  const _ConfigurationPanel({
    required this.visualType,
    required this.showPrevious,
    required this.series,
    required this.onVisualTypeChanged,
    required this.onPreviousChanged,
    required this.onSeriesChanged,
  });

  final AnalyticsVisualType visualType;
  final bool showPrevious;
  final Set<DashboardSeriesKind> series;
  final ValueChanged<AnalyticsVisualType> onVisualTypeChanged;
  final ValueChanged<bool> onPreviousChanged;
  final void Function(DashboardSeriesKind, bool) onSeriesChanged;

  @override
  Widget build(BuildContext context) => DashboardCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSectionTitle(
          title: 'Configuration du graphique',
          subtitle: 'Choisissez le plan, les séries et le type de rendu.',
        ),
        const SizedBox(height: 18),
        const _FieldLabel('Type de graphique'),
        const SizedBox(height: 6),
        SegmentedButton<AnalyticsVisualType>(
          segments: const [
            ButtonSegment(
              value: AnalyticsVisualType.lines,
              icon: Icon(Icons.show_chart_rounded),
              tooltip: 'Courbes',
            ),
            ButtonSegment(
              value: AnalyticsVisualType.area,
              icon: Icon(Icons.area_chart_outlined),
              tooltip: 'Aire',
            ),
            ButtonSegment(
              value: AnalyticsVisualType.bars,
              icon: Icon(Icons.bar_chart_rounded),
              tooltip: 'Barres',
            ),
          ],
          selected: {visualType},
          showSelectedIcon: false,
          onSelectionChanged: (values) => onVisualTypeChanged(values.first),
        ),
        const SizedBox(height: 18),
        const _FieldLabel('Axe X'),
        const SizedBox(height: 6),
        const _SelectBox(label: 'Temps (date)'),
        const SizedBox(height: 12),
        const _FieldLabel('Axe Y'),
        const SizedBox(height: 6),
        const _SelectBox(label: 'Volume / nombre'),
        const SizedBox(height: 18),
        const _FieldLabel('Séries'),
        const SizedBox(height: 5),
        for (final kind in const [
          DashboardSeriesKind.applications,
          DashboardSeriesKind.matches,
          DashboardSeriesKind.interviews,
        ])
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: series.contains(kind),
            onChanged: (value) => onSeriesChanged(kind, value ?? false),
            title: Text(
              kind.label,
              style: const TextStyle(color: dashboardNavy, fontSize: 11),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        const Divider(color: dashboardBorder),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: showPrevious,
          onChanged: onPreviousChanged,
          title: const Text(
            'Comparer à N-1',
            style: TextStyle(
              color: dashboardNavy,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dashboardBorder),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: dashboardBlue),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Les coordonnées affichées correspondent aux valeurs brutes reçues du repository, sans interpolation cachée.',
                  style: TextStyle(
                    color: dashboardMuted,
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: dashboardMuted,
      fontSize: 10,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _SelectBox extends StatelessWidget {
  const _SelectBox({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: dashboardBorder),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: dashboardNavy, fontSize: 10.5),
          ),
        ),
        const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: dashboardMuted,
        ),
      ],
    ),
  );
}

class _SeriesLegend extends StatelessWidget {
  const _SeriesLegend({required this.kind});
  final DashboardSeriesKind kind;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: dashboardSeriesColor(kind),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 5),
      Text(
        kind.label,
        style: const TextStyle(color: dashboardMuted, fontSize: 10),
      ),
    ],
  );
}

class _HeatLegend extends StatelessWidget {
  const _HeatLegend();
  @override
  Widget build(BuildContext context) => Container(
    width: 88,
    height: 8,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(999),
      gradient: const LinearGradient(
        colors: [Color(0xFFF1F5F8), Color(0xFF164D83)],
      ),
    ),
  );
}

class _ChannelBar extends StatelessWidget {
  const _ChannelBar({required this.channel, required this.max});
  final AnalyticsChannelValue channel;
  final double max;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(
            channel.label,
            style: const TextStyle(color: dashboardMuted, fontSize: 10),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: max <= 0 ? 0 : channel.value / max,
              minHeight: 8,
              backgroundColor: const Color(0xFFE9EFF4),
              color: dashboardBlue,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            channel.value.round().toString(),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: dashboardNavy,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}
