import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/recruiter_dashboard/domain/recruiter_dashboard_models.dart';
import 'package:joyn_front/features/recruiter_dashboard/presentation/shared/analytics_charts.dart';
import 'package:joyn_front/features/recruiter_dashboard/presentation/shared/dashboard_components.dart';

void main() {
  testWidgets('Top offres reste sans overflow dans une colonne étroite', (
    tester,
  ) async {
    const offer = DashboardOfferPerformance(
      id: 1,
      title: 'Développeur·se Full-Stack en alternance',
      location: 'Paris, France',
      contract: 'Alternance',
      status: 'Publiée',
      applications: 128,
      matches: 32,
      interviews: 12,
      views: 1240,
      conversionRate: 25,
      lastActivity: 'il y a 2 h',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 285,
              child: DashboardCard(
                child: OfferPerformanceList(
                  offers: const [offer],
                  onOpen: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('la grille de concentration occupe toute la largeur disponible', (
    tester,
  ) async {
    const heatmap = AnalyticsHeatmap(
      rows: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
      columns: ['8h', '10h', '12h', '14h', '16h', '18h'],
      values: [
        [12, 28, 46, 58, 52, 31],
        [18, 34, 62, 70, 66, 42],
        [16, 40, 68, 78, 71, 38],
        [21, 43, 74, 82, 69, 35],
        [14, 37, 63, 72, 61, 29],
        [7, 18, 29, 34, 27, 13],
        [5, 12, 22, 25, 18, 9],
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 520, child: HeatmapChart(data: heatmap)),
        ),
      ),
    );

    final chart = find.byType(HeatmapChart);
    expect(chart, findsOneWidget);
    expect(tester.getSize(chart).width, greaterThan(500));
    expect(tester.takeException(), isNull);
  });
}
