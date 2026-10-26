enum DashboardPeriod {
  sevenDays('7 jours', '7d'),
  thirtyDays('30 jours', '30d'),
  all('Tout', 'all');

  const DashboardPeriod(this.label, this.queryValue);
  final String label;
  final String queryValue;
}

enum DashboardSeriesKind {
  applications('Candidatures'),
  matches('Matches qualifiés'),
  interviews('Entretiens'),
  previousApplications('Candidatures N-1');

  const DashboardSeriesKind(this.label);
  final String label;
}

enum ActivityKind { application, match, interview, offer, system }

class DashboardKpi {
  const DashboardKpi({
    required this.id,
    required this.label,
    required this.value,
    this.deltaPercent,
    this.deltaLabel,
  });

  final String id;
  final String label;
  final String value;
  final double? deltaPercent;
  final String? deltaLabel;
}

class DashboardTrendPoint {
  const DashboardTrendPoint({
    required this.date,
    required this.applications,
    required this.matches,
    required this.interviews,
    required this.previousApplications,
  });

  final DateTime date;
  final double applications;
  final double matches;
  final double interviews;
  final double previousApplications;

  double valueFor(DashboardSeriesKind kind) => switch (kind) {
    DashboardSeriesKind.applications => applications,
    DashboardSeriesKind.matches => matches,
    DashboardSeriesKind.interviews => interviews,
    DashboardSeriesKind.previousApplications => previousApplications,
  };
}

class DashboardDistributionItem {
  const DashboardDistributionItem({required this.label, required this.value});
  final String label;
  final double value;
}

class DashboardOfferPerformance {
  const DashboardOfferPerformance({
    required this.id,
    required this.title,
    required this.location,
    required this.contract,
    required this.status,
    required this.applications,
    required this.matches,
    required this.interviews,
    required this.views,
    required this.conversionRate,
    this.lastActivity,
    this.tagline,
  });

  final int id;
  final String title;
  final String location;
  final String contract;
  final String status;
  final int applications;
  final int matches;
  final int interviews;
  final int views;
  final double conversionRate;
  final String? lastActivity;
  final String? tagline;
}

class DashboardActivity {
  const DashboardActivity({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.whenLabel,
  });

  final ActivityKind kind;
  final String title;
  final String subtitle;
  final String whenLabel;
}

class DashboardPriorityAction {
  const DashboardPriorityAction({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
}

class RecruiterDashboardData {
  const RecruiterDashboardData({
    required this.period,
    required this.kpis,
    required this.trend,
    required this.profileDistribution,
    required this.topOffers,
    required this.activities,
    required this.priorityActions,
  });

  final DashboardPeriod period;
  final List<DashboardKpi> kpis;
  final List<DashboardTrendPoint> trend;
  final List<DashboardDistributionItem> profileDistribution;
  final List<DashboardOfferPerformance> topOffers;
  final List<DashboardActivity> activities;
  final List<DashboardPriorityAction> priorityActions;
}

class AnalyticsFunnelStep {
  const AnalyticsFunnelStep({required this.label, required this.value});
  final String label;
  final double value;
}

class AnalyticsChannelValue {
  const AnalyticsChannelValue({required this.label, required this.value});
  final String label;
  final double value;
}

class AnalyticsHeatmap {
  const AnalyticsHeatmap({
    required this.rows,
    required this.columns,
    required this.values,
  });

  final List<String> rows;
  final List<String> columns;
  final List<List<double>> values;
}

class AnalyticsSurface {
  const AnalyticsSurface({
    required this.xLabels,
    required this.yLabels,
    required this.values,
  });

  final List<String> xLabels;
  final List<String> yLabels;
  final List<List<double>> values;

  double get maxValue {
    var max = 0.0;
    for (final row in values) {
      for (final value in row) {
        max = max > value ? max : value;
      }
    }
    return max;
  }
}

class RecruiterAnalyticsData {
  const RecruiterAnalyticsData({
    required this.period,
    required this.trend,
    required this.funnel,
    required this.channels,
    required this.heatmap,
    required this.surface,
  });

  final DashboardPeriod period;
  final List<DashboardTrendPoint> trend;
  final List<AnalyticsFunnelStep> funnel;
  final List<AnalyticsChannelValue> channels;
  final AnalyticsHeatmap heatmap;
  final AnalyticsSurface surface;
}

class OfferAnalyticsData {
  const OfferAnalyticsData({
    required this.offer,
    required this.kpis,
    required this.trend,
    required this.sources,
    required this.pipeline,
    required this.skills,
    required this.actions,
  });

  final DashboardOfferPerformance offer;
  final List<DashboardKpi> kpis;
  final List<DashboardTrendPoint> trend;
  final List<DashboardDistributionItem> sources;
  final List<AnalyticsFunnelStep> pipeline;
  final List<DashboardDistributionItem> skills;
  final List<DashboardPriorityAction> actions;
}
