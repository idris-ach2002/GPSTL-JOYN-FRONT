import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StudentActivityCharts extends StatelessWidget {
  const StudentActivityCharts({
    super.key,
    required this.trend,
    required this.stages,
    required this.period,
  });

  final List<Map> trend;
  final List<(String, int)> stages;
  final String period;
  static const applications = Color(0xFF215D91);
  static const interviews = Color(0xFFC84D29);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final firstEvent = trend.isEmpty
        ? today
        : DateTime.tryParse('${trend.first['date']}') ?? today;
    final monthly = period == 'all';
    final start = monthly
        ? DateTime.utc(firstEvent.year, firstEvent.month)
        : today.subtract(Duration(days: period == '7d' ? 7 : 30));
    final points = {
      for (final row in trend)
        '${row['date']}': (
          row['applications'] as int,
          row['interviews'] as int,
        ),
    };
    final dates = <DateTime>[];
    for (var date = start; !date.isAfter(today);) {
      dates.add(date);
      date = monthly
          ? DateTime.utc(date.year, date.month + 1)
          : date.add(const Duration(days: 1));
    }
    final values = [
      for (final date in dates)
        points[date.toIso8601String().split('T').first] ?? (0, 0),
    ];
    final maximum = values.fold(
      1,
      (value, pair) => math.max(value, math.max(pair.$1, pair.$2)),
    );
    final peak = stages.fold(1, (value, pair) => math.max(value, pair.$2));
    final axis = Theme.of(context).colorScheme.onSurfaceVariant;

    Widget panel(String title, Widget child) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );

    String label(int index) {
      final d = dates[index];
      return monthly ? '${d.month}/${d.year % 100}' : '${d.day}/${d.month}';
    }

    final curve = panel(
      'Évolution des candidatures et des entretiens',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Wrap(
            spacing: 18,
            runSpacing: 6,
            children: [
              _Legend(applications, 'Candidatures envoyées'),
              _Legend(interviews, 'Entretiens proposés'),
            ],
          ),
          const SizedBox(height: 18),
          if (trend.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Aucune activité sur cette période.'),
            ),
          if (dates.isNotEmpty)
            SizedBox(
              height: 176,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: math.max(1, dates.length - 1).toDouble(),
                  minY: 0,
                  maxY: maximum.toDouble(),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: math
                        .max(1, (maximum / 4).ceil())
                        .toDouble(),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: math.max(1, (maximum / 4).ceil()).toDouble(),
                        getTitlesWidget: (x, meta) => Text(
                          x.toInt().toString(),
                          style: TextStyle(color: axis, fontSize: 11),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 25,
                        interval: math
                            .max(1, (dates.length / 4).ceil())
                            .toDouble(),
                        getTitlesWidget: (x, meta) {
                          final i = x.toInt();
                          if (i >= dates.length) return const SizedBox.shrink();
                          if (i != 0 &&
                              i == dates.length - 1 &&
                              i % math.max(1, (dates.length / 4).ceil()) != 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            label(i),
                            style: TextStyle(color: axis, fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    for (final (color, second) in [
                      (applications, false),
                      (interviews, true),
                    ])
                      LineChartBarData(
                        color: color,
                        barWidth: 3,
                        dotData: FlDotData(show: values.length <= 8),
                        spots: [
                          for (var i = 0; i < values.length; i++)
                            FlSpot(
                              i.toDouble(),
                              (second ? values[i].$2 : values[i].$1).toDouble(),
                            ),
                        ],
                      ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (items) => [
                        for (final item in items)
                          LineTooltipItem(
                            '${label(item.x.toInt())} · ${item.y.toInt()} ${item.barIndex == 0 ? 'candidature(s)' : 'entretien(s)'}',
                            const TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    final histogram = panel(
      'Candidatures par étape',
      Column(
        children: [
          SizedBox(
            height: 176,
            child: BarChart(
              BarChartData(
                maxY: peak.toDouble(),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: math.max(1, (peak / 4).ceil()).toDouble(),
                ),
                titlesData: const FlTitlesData(show: false),
                barGroups: [
                  for (var i = 0; i < stages.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: stages[i].$2.toDouble(),
                          width: 22,
                          color: i == stages.length - 1
                              ? interviews
                              : applications,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (name, count) in stages)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$count',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, size) => size.maxWidth < 720
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [curve, histogram],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: curve),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: histogram),
              ],
            ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.circle, color: color, size: 9),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}
