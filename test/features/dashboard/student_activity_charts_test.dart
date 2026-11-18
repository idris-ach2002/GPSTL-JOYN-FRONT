import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/dashboard/presentation/student_activity_charts.dart';

void main() {
  for (final width in [320.0, 1100.0]) {
    testWidgets('graphiques du tableau de bord à ${width.toInt()} px', (
      tester,
    ) async {
      tester.view
        ..physicalSize = Size(width, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final day = DateTime.now().toIso8601String().split('T').first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StudentActivityCharts(
                trend: [
                  {'date': day, 'applications': 3, 'interviews': 1},
                ],
                stages: const [('Envoyée', 3), ('Entretien', 1)],
                period: '7d',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final curve = tester.widget<LineChart>(find.byType(LineChart)).data;
      expect(curve.lineBarsData.map((line) => line.spots.last.y), [3, 1]);
      final histogram = tester.widget<BarChart>(find.byType(BarChart)).data;
      expect(histogram.barGroups.map((bar) => bar.barRods.single.toY), [3, 1]);
      expect(tester.takeException(), isNull);
    });
  }
}
