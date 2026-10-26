import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/recruiter_dashboard_models.dart';
import 'dashboard_components.dart';
import 'visualization_settings.dart';

class InteractiveMultiSeriesChart extends StatelessWidget {
  const InteractiveMultiSeriesChart({
    super.key,
    required this.points,
    this.height = 300,
    this.visibleSeries = const {
      DashboardSeriesKind.applications,
      DashboardSeriesKind.matches,
      DashboardSeriesKind.interviews,
    },
    this.showPrevious = false,
    this.visualType = AnalyticsVisualType.lines,
    this.settings,
  });

  final List<DashboardTrendPoint> points;
  final double height;
  final Set<DashboardSeriesKind> visibleSeries;
  final bool showPrevious;
  final AnalyticsVisualType visualType;
  final VisualizationSettings? settings;

  VisualizationSettings get _settings =>
      settings ??
      VisualizationSettings(
        visualType: visualType,
        visibleSeries: visibleSeries,
        showPrevious: showPrevious,
      );

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'Aucune donnée disponible.',
            style: TextStyle(color: dashboardMuted, fontSize: 11),
          ),
        ),
      );
    }

    final config = _settings;
    final series = <DashboardSeriesKind>[
      ...config.visibleSeries,
      if (config.showPrevious) DashboardSeriesKind.previousApplications,
    ];
    final maxY = _maxY(series);

    final chart = switch (config.visualType) {
      AnalyticsVisualType.bars => _buildBarChart(config, series, maxY),
      AnalyticsVisualType.scatter => _buildScatterChart(config, series, maxY),
      AnalyticsVisualType.lines => _buildLineChart(config, series, maxY),
      AnalyticsVisualType.area => _buildLineChart(config, series, maxY),
    };

    return SizedBox(height: height, child: chart);
  }

  double _maxY(List<DashboardSeriesKind> series) {
    var maxValue = 1.0;
    for (final point in points) {
      for (final kind in series) {
        maxValue = math.max(maxValue, point.valueFor(kind));
      }
    }
    return math.max(10, (maxValue / 10).ceil() * 10).toDouble();
  }

  Widget _buildLineChart(
    VisualizationSettings config,
    List<DashboardSeriesKind> series,
    double maxY,
  ) {
    final isArea = config.visualType == AnalyticsVisualType.area;
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: math.max(1, points.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: config.showGrid,
          drawVerticalLine: true,
          horizontalInterval: maxY / 5,
          verticalInterval: _xInterval,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFE7EDF2), strokeWidth: 1),
          getDrawingVerticalLine: (_) =>
              const FlLine(color: Color(0xFFF0F4F7), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: _titles(config, maxY),
        extraLinesData: ExtraLinesData(
          horizontalLines: _thresholdLines(config, maxY, withLabel: true),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchSpotThreshold: 18,
          getTouchedSpotIndicator: (barData, indexes) => [
            for (final _ in indexes)
              TouchedSpotIndicatorData(
                FlLine(
                  color: config.showCrosshair
                      ? const Color(0xFF91A5B8)
                      : Colors.transparent,
                  strokeWidth: config.showCrosshair ? 1 : 0,
                  dashArray: const [3, 3],
                ),
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: bar.color ?? dashboardBlue,
                      ),
                ),
              ),
          ],
          touchTooltipData: LineTouchTooltipData(
            maxContentWidth: 190,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipBorderRadius: BorderRadius.circular(10),
            tooltipBorder: const BorderSide(color: dashboardBorder),
            getTooltipColor: (_) => Colors.white,
            getTooltipItems: (spots) {
              if (spots.isEmpty) return const [];
              final index = spots.first.x.round().clamp(0, points.length - 1);
              final date = points[index].date;
              final dateLabel =
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
              return [
                for (var i = 0; i < spots.length; i++)
                  LineTooltipItem(
                    '${i == 0 ? '$dateLabel\n' : ''}${series[spots[i].barIndex].label} : ${spots[i].y.toStringAsFixed(0)}',
                    TextStyle(
                      color: config.colorFor(series[spots[i].barIndex]),
                      fontFamily: config.fontFamily,
                      fontSize: config.safeFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ];
            },
          ),
        ),
        lineBarsData: [
          for (final kind in series)
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].valueFor(kind)),
              ],
              color: config.colorFor(kind),
              barWidth: kind == DashboardSeriesKind.previousApplications
                  ? math.min(config.safeLineWidth, 2)
                  : config.safeLineWidth,
              isCurved: config.interpolation == ChartInterpolation.smooth,
              curveSmoothness: config.safeSmoothing,
              preventCurveOverShooting: true,
              isStepLineChart: config.interpolation == ChartInterpolation.step,
              isStrokeCapRound: true,
              isStrokeJoinRound: true,
              dashArray: kind == DashboardSeriesKind.previousApplications
                  ? const [7, 5]
                  : null,
              dotData: FlDotData(
                show:
                    config.showDots &&
                    kind != DashboardSeriesKind.previousApplications,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 2.7,
                      color: Colors.white,
                      strokeWidth: 1.7,
                      strokeColor: config.colorFor(kind),
                    ),
              ),
              belowBarData: BarAreaData(
                show:
                    isArea && kind != DashboardSeriesKind.previousApplications,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    config
                        .colorFor(kind)
                        .withValues(alpha: config.safeAreaOpacity),
                    config.colorFor(kind).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
        ],
      ),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildBarChart(
    VisualizationSettings config,
    List<DashboardSeriesKind> series,
    double maxY,
  ) {
    final barKinds = series.take(4).toList();
    final width = math.max(3.0, math.min(8.0, 22 / barKinds.length));
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        groupsSpace: 6,
        gridData: FlGridData(
          show: config.showGrid,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFE7EDF2), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: _titles(config, maxY),
        extraLinesData: ExtraLinesData(
          horizontalLines: _thresholdLines(config, maxY),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 2,
              barRods: [
                for (final kind in barKinds)
                  BarChartRodData(
                    toY: points[i].valueFor(kind),
                    width: width,
                    color: config.colorFor(kind),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
              ],
            ),
        ],
      ),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildScatterChart(
    VisualizationSettings config,
    List<DashboardSeriesKind> series,
    double maxY,
  ) {
    final spots = <ScatterSpot>[];
    for (var seriesIndex = 0; seriesIndex < series.length; seriesIndex++) {
      final kind = series[seriesIndex];
      final offset = (seriesIndex - (series.length - 1) / 2) * .08;
      for (var i = 0; i < points.length; i++) {
        spots.add(
          ScatterSpot(
            i + offset,
            points[i].valueFor(kind),
            dotPainter: FlDotCirclePainter(
              radius: config.showDots ? 4 : 2.5,
              color: config.colorFor(kind),
              strokeWidth: 1.2,
              strokeColor: Colors.white,
            ),
          ),
        );
      }
    }
    return ScatterChart(
      ScatterChartData(
        scatterSpots: spots,
        minX: -.5,
        maxX: math.max(1, points.length - 1).toDouble() + .5,
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: config.showGrid,
          drawVerticalLine: true,
          horizontalInterval: maxY / 5,
          verticalInterval: _xInterval,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFE7EDF2), strokeWidth: 1),
          getDrawingVerticalLine: (_) =>
              const FlLine(color: Color(0xFFF0F4F7), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: _titles(config, maxY),
      ),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
  }

  List<HorizontalLine> _thresholdLines(
    VisualizationSettings config,
    double maxY, {
    bool withLabel = false,
  }) {
    final threshold = config.safeThreshold(maxY);
    if (threshold == null) return const [];
    return [
      HorizontalLine(
        y: threshold,
        color: const Color(0xFFE65100),
        strokeWidth: 1.2,
        dashArray: const [6, 5],
        label: withLabel
            ? HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: TextStyle(
                  color: const Color(0xFFE65100),
                  fontSize: config.safeFontSize - 1,
                  fontFamily: config.fontFamily,
                  fontWeight: FontWeight.w700,
                ),
                labelResolver: (_) => 'Seuil ${threshold.toStringAsFixed(0)}',
              )
            : HorizontalLineLabel(),
      ),
    ];
  }

  double get _xInterval => math.max(1, (points.length / 6).ceil()).toDouble();

  FlTitlesData _titles(VisualizationSettings config, double maxY) {
    final style = TextStyle(
      color: dashboardMuted,
      fontSize: config.safeFontSize,
      fontFamily: config.fontFamily,
      fontWeight: FontWeight.w600,
    );
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: maxY / 5,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            child: Text(value.round().toString(), style: style),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: _xInterval,
          getTitlesWidget: (value, meta) {
            final index = value.round();
            if (index < 0 || index >= points.length) {
              return const SizedBox.shrink();
            }
            final date = points[index].date;
            return SideTitleWidget(
              meta: meta,
              space: 7,
              child: Text('${date.day}/${date.month}', style: style),
            );
          },
        ),
      ),
    );
  }
}

class AnalyticsDonutChart extends StatefulWidget {
  const AnalyticsDonutChart({
    super.key,
    required this.items,
    this.size = 160,
    this.centerLabel = 'Sources',
  });

  final List<AnalyticsChannelValue> items;
  final double size;
  final String centerLabel;

  @override
  State<AnalyticsDonutChart> createState() => _AnalyticsDonutChartState();
}

class _AnalyticsDonutChartState extends State<AnalyticsDonutChart> {
  int _touched = -1;

  static const _colors = [
    Color(0xFF123E72),
    Color(0xFF2676E8),
    Color(0xFF6FA5DC),
    Color(0xFFFF7043),
    Color(0xFF9FB1C2),
    Color(0xFF0A9396),
  ];

  @override
  Widget build(BuildContext context) {
    final total = widget.items.fold<double>(0, (sum, item) => sum + item.value);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;
        final chart = SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  centerSpaceRadius: widget.size * .26,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (!event.isInterestedForInteractions ||
                          response?.touchedSection == null) {
                        if (_touched != -1) setState(() => _touched = -1);
                        return;
                      }
                      setState(
                        () => _touched =
                            response!.touchedSection!.touchedSectionIndex,
                      );
                    },
                  ),
                  sections: [
                    for (var i = 0; i < widget.items.length; i++)
                      PieChartSectionData(
                        value: widget.items[i].value,
                        color: _colors[i % _colors.length],
                        radius: i == _touched ? 25 : 20,
                        showTitle: false,
                      ),
                  ],
                ),
                duration: const Duration(milliseconds: 180),
              ),
              Text(
                widget.centerLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: dashboardNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
        final legend = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _colors[i % _colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        widget.items[i].label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: dashboardMuted,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                    Text(
                      total <= 0
                          ? '0%'
                          : '${(widget.items[i].value / total * 100).round()}%',
                      style: const TextStyle(
                        color: dashboardNavy,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
        if (compact) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [chart, const SizedBox(height: 14), legend],
          );
        }
        return Row(
          children: [
            chart,
            const SizedBox(width: 18),
            Expanded(child: legend),
          ],
        );
      },
    );
  }
}

class HeatmapChart extends StatefulWidget {
  const HeatmapChart({super.key, required this.data});
  final AnalyticsHeatmap data;

  @override
  State<HeatmapChart> createState() => _HeatmapChartState();
}

class _HeatmapChartState extends State<HeatmapChart> {
  int _selectedDay = 0;
  int _selectedHour = 0;

  AnalyticsHeatmap get data => widget.data;

  @override
  void initState() {
    super.initState();
    _selectPeak();
  }

  @override
  void didUpdateWidget(covariant HeatmapChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) _selectPeak();
  }

  void _selectPeak() {
    var best = -double.infinity;
    var bestDay = 0;
    var bestHour = 0;
    for (var day = 0; day < data.rows.length; day++) {
      for (var hour = 0; hour < data.columns.length; hour++) {
        final value = _valueAt(day, hour);
        if (value > best) {
          best = value;
          bestDay = day;
          bestHour = hour;
        }
      }
    }
    _selectedDay = bestDay;
    _selectedHour = bestHour;
  }

  double _valueAt(int day, int hour) {
    if (day < 0 || day >= data.values.length) return 0;
    final row = data.values[day];
    if (hour < 0 || hour >= row.length) return 0;
    return row[hour];
  }

  @override
  Widget build(BuildContext context) {
    if (data.rows.isEmpty || data.columns.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(
          child: Text(
            'Aucune donnée de concentration.',
            style: TextStyle(color: dashboardMuted, fontSize: 10),
          ),
        ),
      );
    }

    final values = <double>[
      for (var day = 0; day < data.rows.length; day++)
        for (var hour = 0; hour < data.columns.length; hour++)
          _valueAt(day, hour),
    ];
    final maxValue = values.isEmpty
        ? 1.0
        : math
              .max(1.0, values.reduce((a, b) => math.max(a, b).toDouble()))
              .toDouble();
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final average = values.isEmpty ? 0.0 : total / values.length;
    final dayTotals = [
      for (var day = 0; day < data.rows.length; day++)
        List.generate(
          data.columns.length,
          (hour) => _valueAt(day, hour),
        ).fold<double>(0, (sum, value) => sum + value),
    ];
    final bestDay = dayTotals.indexOf(
      dayTotals.reduce((a, b) => math.max(a, b).toDouble()),
    );
    final selectedValue = _valueAt(_selectedDay, _selectedHour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _HeatmapStat(
              icon: Icons.bolt_rounded,
              label: 'Pic',
              value: '${maxValue.round()}',
            ),
            _HeatmapStat(
              icon: Icons.analytics_outlined,
              label: 'Moyenne',
              value: average.toStringAsFixed(0),
            ),
            _HeatmapStat(
              icon: Icons.calendar_today_outlined,
              label: 'Jour fort',
              value: data.rows[bestDay],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const SizedBox(width: 34),
            for (final day in data.rows)
              Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: dashboardMuted,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        for (var hour = 0; hour < data.columns.length; hour++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    data.columns[hour],
                    style: const TextStyle(
                      color: dashboardMuted,
                      fontSize: 8.5,
                    ),
                  ),
                ),
                for (var day = 0; day < data.rows.length; day++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Tooltip(
                        message:
                            '${data.rows[day]} ${data.columns[hour]} · ${_valueAt(day, hour).round()} candidatures',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            onTap: () => setState(() {
                              _selectedDay = day;
                              _selectedHour = hour;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              height: 30,
                              decoration: BoxDecoration(
                                color: Color.lerp(
                                  const Color(0xFFF2F6FA),
                                  const Color(0xFF1267C4),
                                  (_valueAt(day, hour) / maxValue)
                                      .clamp(0, 1)
                                      .toDouble(),
                                ),
                                borderRadius: BorderRadius.circular(5),
                                border:
                                    day == _selectedDay && hour == _selectedHour
                                    ? Border.all(
                                        color: const Color(0xFF062E57),
                                        width: 2,
                                      )
                                    : Border.all(color: Colors.white, width: 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F9FC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: dashboardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: dashboardBlue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${data.rows[_selectedDay]} · ${data.columns[_selectedHour]}',
                  style: const TextStyle(
                    color: dashboardNavy,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${selectedValue.round()} candidatures',
                style: const TextStyle(
                  color: dashboardNavy,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text(
              'Faible',
              style: TextStyle(color: dashboardMuted, fontSize: 8),
            ),
            const SizedBox(width: 7),
            for (var i = 1; i <= 6; i++)
              Container(
                width: 16,
                height: 7,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: Color.lerp(
                    const Color(0xFFF2F6FA),
                    const Color(0xFF1267C4),
                    i / 6,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            const SizedBox(width: 5),
            const Text(
              'Élevée',
              style: TextStyle(color: dashboardMuted, fontSize: 8),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeatmapStat extends StatelessWidget {
  const _HeatmapStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF6F9FC),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: dashboardBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: dashboardBlue),
        const SizedBox(width: 5),
        Text(
          '$label · ',
          style: const TextStyle(color: dashboardMuted, fontSize: 8),
        ),
        Text(
          value,
          style: const TextStyle(
            color: dashboardNavy,
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class FunnelChart extends StatelessWidget {
  const FunnelChart({super.key, required this.steps});
  final List<AnalyticsFunnelStep> steps;

  @override
  Widget build(BuildContext context) {
    final maxValue = steps.isEmpty
        ? 1.0
        : steps.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 94,
                  child: Text(
                    steps[i].label,
                    style: const TextStyle(color: dashboardMuted, fontSize: 10),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (steps[i].value / maxValue)
                          .clamp(.08, 1)
                          .toDouble(),
                      child: Container(
                        height: 28,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 9),
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            const Color(0xFFE7F0F9),
                            const Color(0xFF174F85),
                            i / math.max(1, steps.length - 1),
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          steps[i].value.round().toString(),
                          style: TextStyle(
                            color: i >= steps.length ~/ 2
                                ? Colors.white
                                : dashboardNavy,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
