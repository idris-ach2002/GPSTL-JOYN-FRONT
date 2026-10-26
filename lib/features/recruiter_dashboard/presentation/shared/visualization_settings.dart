import 'package:flutter/material.dart';

import '../../domain/recruiter_dashboard_models.dart';

enum AnalyticsVisualType { lines, area, bars, scatter }

enum ChartInterpolation { linear, smooth, step }

enum VisualizationPalette { joyn, scientific, monochrome, contrast }

enum VisualizationFont { instrumentSans, roboto, bricolage, monospace }

@immutable
class VisualizationSettings {
  const VisualizationSettings({
    this.visualType = AnalyticsVisualType.lines,
    this.interpolation = ChartInterpolation.smooth,
    this.visibleSeries = const {
      DashboardSeriesKind.applications,
      DashboardSeriesKind.matches,
      DashboardSeriesKind.interviews,
    },
    this.showPrevious = true,
    this.showDots = true,
    this.showGrid = true,
    this.showCrosshair = true,
    this.lineWidth = 2.5,
    this.areaOpacity = .22,
    this.smoothing = .35,
    this.font = VisualizationFont.instrumentSans,
    this.fontSize = 11,
    this.palette = VisualizationPalette.joyn,
    this.customSeriesColors = const {},
    this.threshold,
  });

  final AnalyticsVisualType visualType;
  final ChartInterpolation interpolation;
  final Set<DashboardSeriesKind> visibleSeries;
  final bool showPrevious;
  final bool showDots;
  final bool showGrid;
  final bool showCrosshair;
  final double lineWidth;
  final double areaOpacity;
  final double smoothing;
  final VisualizationFont font;
  final double fontSize;
  final VisualizationPalette palette;
  final Map<DashboardSeriesKind, int> customSeriesColors;
  final double? threshold;

  double get safeLineWidth => lineWidth.clamp(1, 6).toDouble();
  double get safeAreaOpacity => areaOpacity.clamp(0, .6).toDouble();
  double get safeSmoothing => smoothing.clamp(0, 1).toDouble();
  double get safeFontSize => fontSize.clamp(10, 18).toDouble();

  String get fontFamily => switch (font) {
    VisualizationFont.instrumentSans => 'InstrumentSans',
    VisualizationFont.roboto => 'Roboto',
    VisualizationFont.bricolage => 'BricolageGrotesque',
    VisualizationFont.monospace => 'monospace',
  };

  Color colorFor(DashboardSeriesKind kind) {
    final custom = customSeriesColors[kind];
    if (custom != null) return Color(custom);
    return switch (palette) {
      VisualizationPalette.joyn => switch (kind) {
        DashboardSeriesKind.applications => const Color(0xFF123E72),
        DashboardSeriesKind.matches => const Color(0xFF4A91E8),
        DashboardSeriesKind.interviews => const Color(0xFFFF7043),
        DashboardSeriesKind.previousApplications => const Color(0xFFA8B8C7),
      },
      VisualizationPalette.scientific => switch (kind) {
        DashboardSeriesKind.applications => const Color(0xFF005F73),
        DashboardSeriesKind.matches => const Color(0xFF0A9396),
        DashboardSeriesKind.interviews => const Color(0xFFEE9B00),
        DashboardSeriesKind.previousApplications => const Color(0xFF94A3B8),
      },
      VisualizationPalette.monochrome => switch (kind) {
        DashboardSeriesKind.applications => const Color(0xFF111827),
        DashboardSeriesKind.matches => const Color(0xFF4B5563),
        DashboardSeriesKind.interviews => const Color(0xFF9CA3AF),
        DashboardSeriesKind.previousApplications => const Color(0xFFD1D5DB),
      },
      VisualizationPalette.contrast => switch (kind) {
        DashboardSeriesKind.applications => const Color(0xFF0B3D91),
        DashboardSeriesKind.matches => const Color(0xFF00897B),
        DashboardSeriesKind.interviews => const Color(0xFFE65100),
        DashboardSeriesKind.previousApplications => const Color(0xFF6B7280),
      },
    };
  }

  double? safeThreshold(double maxY) {
    if (threshold == null || maxY <= 0) return null;
    return threshold!.clamp(0, maxY).toDouble();
  }

  VisualizationSettings copyWith({
    AnalyticsVisualType? visualType,
    ChartInterpolation? interpolation,
    Set<DashboardSeriesKind>? visibleSeries,
    bool? showPrevious,
    bool? showDots,
    bool? showGrid,
    bool? showCrosshair,
    double? lineWidth,
    double? areaOpacity,
    double? smoothing,
    VisualizationFont? font,
    double? fontSize,
    VisualizationPalette? palette,
    Map<DashboardSeriesKind, int>? customSeriesColors,
    double? threshold,
    bool clearThreshold = false,
  }) {
    return VisualizationSettings(
      visualType: visualType ?? this.visualType,
      interpolation: interpolation ?? this.interpolation,
      visibleSeries: visibleSeries ?? this.visibleSeries,
      showPrevious: showPrevious ?? this.showPrevious,
      showDots: showDots ?? this.showDots,
      showGrid: showGrid ?? this.showGrid,
      showCrosshair: showCrosshair ?? this.showCrosshair,
      lineWidth: (lineWidth ?? this.lineWidth).clamp(1, 6).toDouble(),
      areaOpacity: (areaOpacity ?? this.areaOpacity).clamp(0, .6).toDouble(),
      smoothing: (smoothing ?? this.smoothing).clamp(0, 1).toDouble(),
      font: font ?? this.font,
      fontSize: (fontSize ?? this.fontSize).clamp(10, 18).toDouble(),
      palette: palette ?? this.palette,
      customSeriesColors: customSeriesColors ?? this.customSeriesColors,
      threshold: clearThreshold ? null : threshold ?? this.threshold,
    );
  }

  VisualizationSettings withSeriesColor(DashboardSeriesKind kind, Color color) {
    return copyWith(
      customSeriesColors: {...customSeriesColors, kind: color.toARGB32()},
    );
  }

  static const standard = VisualizationSettings();

  static const supervision = VisualizationSettings(
    visualType: AnalyticsVisualType.area,
    interpolation: ChartInterpolation.smooth,
    showPrevious: true,
    showDots: true,
    showGrid: true,
    showCrosshair: true,
    lineWidth: 2.8,
    areaOpacity: .28,
    palette: VisualizationPalette.scientific,
  );
}
