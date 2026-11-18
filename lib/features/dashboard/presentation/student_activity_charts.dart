import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StudentActivityCharts extends StatefulWidget {
  const StudentActivityCharts({
    super.key,
    required this.trend,
    required this.stages,
    required this.period,
  });

  final List<Map> trend;
  final List<(String, int)> stages;
  final String period;

  @override
  State<StudentActivityCharts> createState() => _StudentActivityChartsState();
}

class _StudentActivityChartsState extends State<StudentActivityCharts> {
  static const _applications = Color(0xFF1674CC);
  static const _interviews = Color(0xFFBB4C24);
  static const _stageColors = [
    Color(0xFF548791),
    Color(0xFF1674CC),
    Color(0xFF7363CA),
    Color(0xFFBB4C24),
  ];
  static const _series = [
    ('Candidatures', _applications),
    ('Entretiens', _interviews),
  ];

  final _visible = {0, 1};
  bool _showShares = false;
  int? _selectedStage;
  int? _selectedDay;

  @override
  void didUpdateWidget(StudentActivityCharts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) _selectedDay = null;
  }

  @override
  Widget build(BuildContext context) {
    final (dates, values) = _activity();
    return LayoutBuilder(
      builder: (context, size) {
        final timeline = _timeline(context, dates, values);
        final stages = _stages(context);
        if (size.maxWidth < 820) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [timeline, const SizedBox(height: 16), stages],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: timeline),
            const SizedBox(width: 16),
            Expanded(flex: 5, child: stages),
          ],
        );
      },
    );
  }

  (List<DateTime>, List<List<int>>) _activity() {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final monthly = widget.period == 'all';
    final byDate = <DateTime, List<int>>{};
    var first = today;
    for (final row in widget.trend) {
      final date = DateTime.tryParse('${row['date']}');
      if (date == null) continue;
      final bucket = DateTime.utc(
        date.year,
        date.month,
        monthly ? 1 : date.day,
      );
      final counts = byDate.putIfAbsent(bucket, () => [0, 0]);
      counts[0] += (row['applications'] as num?)?.toInt() ?? 0;
      counts[1] += (row['interviews'] as num?)?.toInt() ?? 0;
      if (bucket.isBefore(first)) first = bucket;
    }
    final start = monthly
        ? DateTime.utc(first.year, first.month)
        : today.subtract(Duration(days: widget.period == '7d' ? 7 : 30));
    final dates = <DateTime>[];
    for (var date = start; !date.isAfter(today);) {
      dates.add(date);
      date = monthly
          ? DateTime.utc(date.year, date.month + 1)
          : date.add(const Duration(days: 1));
    }
    return (
      dates,
      [
        for (final date in dates) byDate[date] ?? const [0, 0],
      ],
    );
  }

  Duration _duration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 430);

  Widget _timeline(
    BuildContext context,
    List<DateTime> dates,
    List<List<int>> values,
  ) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final indices = _visible.toList()..sort();
    final peak = values.fold<int>(
      0,
      (max, value) => indices.fold(max, (best, i) => math.max(best, value[i])),
    );
    final step = math.max(1, (peak / 4).ceil());
    final selected = _selectedDay == null
        ? null
        : math.min(_selectedDay!, dates.length - 1);
    final monthly = widget.period == 'all';

    String dateLabel(int index, {bool full = false}) {
      final date = dates[index];
      if (monthly && full) {
        return MaterialLocalizations.of(context).formatMonthYear(date);
      }
      return monthly
          ? '${date.month}/${date.year % 100}'
          : '${date.day}/${date.month}';
    }

    return _ChartPanel(
      title: 'Historique de recherche',
      icon: Icons.insights_rounded,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (var i = 0; i < _series.length; i++)
              FilterChip(
                label: Text(_series[i].$1),
                avatar: Icon(Icons.circle, color: _series[i].$2, size: 10),
                showCheckmark: false,
                selected: _visible.contains(i),
                onSelected: _visible.length == 1 && _visible.contains(i)
                    ? null
                    : (value) => setState(() {
                        value ? _visible.add(i) : _visible.remove(i);
                      }),
              ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 200,
          child: LineChart(
            duration: _duration(context),
            curve: Curves.easeOutCubic,
            LineChartData(
              minX: 0,
              maxX: math.max(1, dates.length - 1).toDouble(),
              minY: 0,
              maxY: math.max(2, (peak / step).ceil() * step).toDouble(),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: step.toDouble(),
                getDrawingHorizontalLine: (_) => FlLine(
                  color: theme.colorScheme.outlineVariant,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    interval: step.toDouble(),
                    getTitlesWidget: (x, meta) => Text(
                      '${x.toInt()}',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    interval: math.max(1, (dates.length / 5).ceil()).toDouble(),
                    minIncluded: true,
                    maxIncluded: dates.length <= 3,
                    getTitlesWidget: (x, meta) {
                      if (x.toInt() >= dates.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                        child: Text(
                          dateLabel(x.toInt()),
                          style: TextStyle(color: muted, fontSize: 11),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                for (final i in indices)
                  LineChartBarData(
                    color: _series[i].$2,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: dates.length <= 8),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _series[i].$2.withValues(alpha: .27),
                          _series[i].$2.withValues(alpha: .02),
                        ],
                      ),
                    ),
                    spots: [
                      for (var j = 0; j < dates.length; j++)
                        FlSpot(j.toDouble(), values[j][i].toDouble()),
                    ],
                  ),
              ],
              lineTouchData: LineTouchData(
                touchCallback: (event, response) {
                  final spot = response?.lineBarSpots?.firstOrNull;
                  if (spot != null &&
                      event.isInterestedForInteractions &&
                      _selectedDay != spot.spotIndex) {
                    setState(() => _selectedDay = spot.spotIndex);
                  }
                },
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (items) => [
                    for (final item in items)
                      LineTooltipItem(
                        '${dateLabel(item.spotIndex)} · ${item.y.toInt()} ${_series[indices[item.barIndex]].$1.toLowerCase()}',
                        const TextStyle(color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _ChartReadout(
          title: selected == null
              ? 'Total de la période'
              : dateLabel(selected, full: true),
          counts: [
            for (final i in indices)
              (
                _series[i].$1,
                selected == null
                    ? values.fold<int>(0, (sum, value) => sum + value[i])
                    : values[selected][i],
              ),
          ],
          onReset: selected == null
              ? null
              : () => setState(() => _selectedDay = null),
        ),
      ],
    );
  }

  Widget _stages(BuildContext context) {
    final stages = widget.stages;
    final total = stages.fold<int>(0, (sum, step) => sum + step.$2);
    final peak = stages.fold<int>(1, (peak, step) => math.max(peak, step.$2));
    final selected = _selectedStage;
    final colors = Theme.of(context).colorScheme;
    Color stageColor(int i) => _stageColors[i % _stageColors.length];
    void select(int i) {
      if (i >= 0 && i < stages.length) {
        setState(() => _selectedStage = i == selected ? null : i);
      }
    }

    return _ChartPanel(
      title: 'Étapes de mes démarches',
      icon: Icons.stacked_bar_chart_rounded,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ChoiceChip(
              label: const Text('Volumes'),
              selected: !_showShares,
              onSelected: (_) => setState(() => _showShares = false),
            ),
            ChoiceChip(
              label: const Text('Répartition'),
              selected: _showShares,
              onSelected: (_) => setState(() => _showShares = true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 154,
          child: AnimatedSwitcher(
            duration: _duration(context),
            child: _showShares
                ? total == 0
                      ? const Center(child: Text('Aucune démarche à répartir.'))
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              duration: _duration(context),
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 41,
                                pieTouchData: PieTouchData(
                                  touchCallback: (event, response) {
                                    if (event is FlTapUpEvent) {
                                      select(
                                        response
                                                ?.touchedSection
                                                ?.touchedSectionIndex ??
                                            -1,
                                      );
                                    }
                                  },
                                ),
                                sections: [
                                  for (var i = 0; i < stages.length; i++)
                                    PieChartSectionData(
                                      value: stages[i].$2.toDouble(),
                                      color: stageColor(i),
                                      radius: selected == i ? 29 : 22,
                                      showTitle: false,
                                    ),
                                ],
                              ),
                            ),
                            IgnorePointer(
                              child: Text(
                                selected == null
                                    ? '$total'
                                    : '${(100 * stages[selected].$2 / total).round()} %',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ],
                        )
                : BarChart(
                    duration: _duration(context),
                    curve: Curves.easeOutCubic,
                    BarChartData(
                      maxY: peak * 1.2,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: math
                            .max(1, (peak / 4).ceil())
                            .toDouble(),
                      ),
                      titlesData: const FlTitlesData(show: false),
                      barTouchData: BarTouchData(
                        touchCallback: (event, response) {
                          if (event is FlTapUpEvent) {
                            select(response?.spot?.touchedBarGroupIndex ?? -1);
                          }
                        },
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                            '${stages[group.x].$1} · ${rod.toY.toInt()}',
                            const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < stages.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: stages[i].$2.toDouble(),
                                width: selected == i ? 28 : 23,
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    stageColor(i).withValues(alpha: .65),
                                    stageColor(i),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(5),
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: peak * 1.2,
                                  color: colors.surfaceContainerHigh,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (var i = 0; i < stages.length; i++)
              ChoiceChip(
                avatar: Icon(Icons.circle, color: stageColor(i), size: 10),
                showCheckmark: false,
                label: Text('${stages[i].$1} · ${stages[i].$2}'),
                selected: selected == i,
                onSelected: (_) => select(i),
              ),
          ],
        ),
        if (selected != null && total > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${(100 * stages[selected].$2 / total).round()} % des démarches suivies actuellement',
            ),
          ),
      ],
    );
  }
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
            title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ...children,
        ],
      ),
    ),
  );
}

class _ChartReadout extends StatelessWidget {
  const _ChartReadout({
    required this.title,
    required this.counts,
    this.onReset,
  });
  final String title;
  final List<(String, int)> counts;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 14,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          for (final (name, count) in counts) Text('$name · $count'),
          if (onReset != null)
            IconButton(
              tooltip: 'Revenir au total',
              onPressed: onReset,
              icon: const Icon(Icons.close, size: 16),
            ),
        ],
      ),
    ),
  );
}
