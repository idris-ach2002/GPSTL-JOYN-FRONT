import '../domain/recruiter_dashboard_models.dart';
import 'recruiter_dashboard_repository.dart';

class CachedRecruiterDashboardRepository
    implements RecruiterDashboardRepository {
  CachedRecruiterDashboardRepository(
    this._delegate, {
    this.ttl = const Duration(minutes: 2),
  });

  final RecruiterDashboardRepository _delegate;
  final Duration ttl;
  final Map<String, _CacheEntry<Object>> _cache = {};

  @override
  Future<RecruiterDashboardData> fetchOverview(DashboardPeriod period) => _read(
    'overview:${period.queryValue}',
    () => _delegate.fetchOverview(period),
  );

  @override
  Future<RecruiterAnalyticsData> fetchAnalytics(DashboardPeriod period) =>
      _read(
        'analytics:${period.queryValue}',
        () => _delegate.fetchAnalytics(period),
      );

  @override
  Future<OfferAnalyticsData> fetchOfferAnalytics(
    int offerId,
    DashboardPeriod period,
  ) => _read(
    'offer:$offerId:${period.queryValue}',
    () => _delegate.fetchOfferAnalytics(offerId, period),
  );

  Future<T> _read<T extends Object>(
    String key,
    Future<T> Function() loader,
  ) async {
    final cached = _cache[key];
    final now = DateTime.now();
    if (cached != null && now.difference(cached.createdAt) < ttl) {
      return cached.value as T;
    }
    final value = await loader();
    _cache[key] = _CacheEntry<Object>(createdAt: now, value: value);
    return value;
  }
}

class _CacheEntry<T> {
  const _CacheEntry({required this.createdAt, required this.value});
  final DateTime createdAt;
  final T value;
}
