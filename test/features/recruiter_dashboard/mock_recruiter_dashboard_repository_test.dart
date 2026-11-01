import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/recruiter_dashboard/data/cached_recruiter_dashboard_repository.dart';
import 'package:joyn_front/features/recruiter_dashboard/data/mock_recruiter_dashboard_repository.dart';
import 'package:joyn_front/features/recruiter_dashboard/domain/recruiter_dashboard_models.dart';

void main() {
  test('le mock R47 expose des métriques cohérentes', () async {
    final repository = MockRecruiterDashboardRepository(latency: Duration.zero);
    final data = await repository.fetchOverview(DashboardPeriod.thirtyDays);

    expect(data.kpis, hasLength(4));
    expect(data.trend, hasLength(30));
    expect(data.topOffers, isNotEmpty);
    expect(
      data.profileDistribution.fold<double>(0, (sum, item) => sum + item.value),
      100,
    );
  });

  test('Insights Studio fournit surface, heatmap et funnel', () async {
    final repository = MockRecruiterDashboardRepository(latency: Duration.zero);
    final data = await repository.fetchAnalytics(DashboardPeriod.thirtyDays);

    expect(data.surface.values, isNotEmpty);
    expect(data.heatmap.values, hasLength(data.heatmap.rows.length));
    expect(data.funnel.length, greaterThanOrEqualTo(4));
  });

  test('le cache retourne la même instance pendant le TTL', () async {
    final repository = CachedRecruiterDashboardRepository(
      MockRecruiterDashboardRepository(latency: Duration.zero),
      ttl: const Duration(minutes: 2),
    );

    final first = await repository.fetchOverview(DashboardPeriod.sevenDays);
    final second = await repository.fetchOverview(DashboardPeriod.sevenDays);

    expect(identical(first, second), isTrue);
  });
}
