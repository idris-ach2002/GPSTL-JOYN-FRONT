import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/recruiter_dashboard/domain/recruiter_dashboard_models.dart';
import 'package:joyn_front/features/recruiter_dashboard/presentation/shared/visualization_settings.dart';

void main() {
  group('VisualizationSettings', () {
    test('borne les paramètres graphiques sensibles', () {
      const settings = VisualizationSettings(
        lineWidth: 500,
        areaOpacity: 2,
        smoothing: -1,
        fontSize: 100,
        threshold: 300,
      );

      expect(settings.safeLineWidth, 6);
      expect(settings.safeAreaOpacity, .6);
      expect(settings.safeSmoothing, 0);
      expect(settings.safeFontSize, 18);
      expect(settings.safeThreshold(80), 80);
    });

    test('copyWith applique aussi les bornes', () {
      final settings = VisualizationSettings.standard.copyWith(
        lineWidth: -20,
        areaOpacity: -4,
        fontSize: 2,
      );

      expect(settings.lineWidth, 1);
      expect(settings.areaOpacity, 0);
      expect(settings.fontSize, 10);
    });

    test('une couleur personnalisée remplace la palette pour une série', () {
      final settings = VisualizationSettings.standard.withSeriesColor(
        DashboardSeriesKind.matches,
        const Color(0xFFABCDEF),
      );

      expect(
        settings.colorFor(DashboardSeriesKind.matches),
        const Color(0xFFABCDEF),
      );
      expect(
        settings.colorFor(DashboardSeriesKind.applications),
        const Color(0xFF123E72),
      );
    });

    test('le seuil peut être supprimé explicitement', () {
      final withThreshold = VisualizationSettings.standard.copyWith(
        threshold: 42,
      );
      final withoutThreshold = withThreshold.copyWith(clearThreshold: true);

      expect(withThreshold.threshold, 42);
      expect(withoutThreshold.threshold, isNull);
    });
  });
}
