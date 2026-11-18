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

  testWidgets('masquer une série et consulter la part par étape', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StudentActivityCharts(
              trend: [],
              stages: [
                ('Offres repérées', 0),
                ('Envoyées', 3),
                ('Entretiens', 1),
              ],
              period: '30d',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Candidatures'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<LineChart>(find.byType(LineChart)).data.lineBarsData,
      hasLength(1),
    );

    final breakdown = find.widgetWithText(ChoiceChip, 'Répartition');
    await tester.ensureVisible(breakdown);
    await tester.tap(breakdown);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PieChart>(find.byType(PieChart))
          .data
          .sections
          .map((item) => item.value),
      [0, 3, 1],
    );

    final interviews = find.widgetWithText(ChoiceChip, 'Entretiens · 1');
    await tester.ensureVisible(interviews);
    await tester.tap(interviews);
    await tester.pumpAndSettle();
    expect(
      find.text('25 % des démarches suivies actuellement'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
