import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/recruiter_dashboard_models.dart';
import 'recruiter_dashboard_repository.dart';

class ApiRecruiterDashboardRepository implements RecruiterDashboardRepository {
  ApiRecruiterDashboardRepository(this._api);

  final ApiClient _api;

  static const String _basePath = '/api/v1/recruiters/dashboard';

  @override
  Future<RecruiterDashboardData> fetchOverview(DashboardPeriod period) async {
    final json = await _api.getJson(
      _basePath,
      query: {'period': period.queryValue},
    );
    return _DashboardApiMapper.overview(_map(json), period);
  }

  @override
  Future<RecruiterAnalyticsData> fetchAnalytics(DashboardPeriod period) async {
    final json = await _api.getJson(
      '$_basePath/insights',
      query: {'period': period.queryValue},
    );
    return _DashboardApiMapper.analytics(_map(json), period);
  }

  @override
  Future<OfferAnalyticsData> fetchOfferAnalytics(
    int offerId,
    DashboardPeriod period,
  ) async {
    final json = await _api.getJson(
      '$_basePath/offers/$offerId',
      query: {'period': period.queryValue},
    );
    return _DashboardApiMapper.offerAnalytics(_map(json), offerId, period);
  }

  Map<String, Object?> _map(Object? value) {
    if (value case final Map<String, dynamic> map) return map;
    if (value case final Map<Object?, Object?> map) {
      return map.map((key, value) => MapEntry('$key', value));
    }
    throw const ApiException(message: 'Le dashboard attend un objet JSON.');
  }
}

abstract final class _DashboardApiMapper {
  static RecruiterDashboardData overview(
    Map<String, Object?> json,
    DashboardPeriod period,
  ) {
    return RecruiterDashboardData(
      period: period,
      kpis: _list(json['kpis']).map(_kpi).toList(),
      trend: _list(json['trend']).map(_trend).toList(),
      profileDistribution: _list(json['profileDistribution'])
          .map(_distribution)
          .toList(),
      topOffers: _list(json['topOffers']).map(_offer).toList(),
      activities: _list(json['activities']).map(_activity).toList(),
      priorityActions: _list(json['priorityActions']).map(_action).toList(),
    );
  }

  static RecruiterAnalyticsData analytics(
    Map<String, Object?> json,
    DashboardPeriod period,
  ) {
    return RecruiterAnalyticsData(
      period: period,
      trend: _list(json['trend']).map(_trend).toList(),
      funnel: _list(json['funnel']).map(_funnel).toList(),
      channels: _list(json['channels']).map(_channel).toList(),
      heatmap: _heatmap(_object(json['heatmap'])),
      surface: _surface(_object(json['surface'])),
    );
  }

  static OfferAnalyticsData offerAnalytics(
    Map<String, Object?> json,
    int offerId,
    DashboardPeriod period,
  ) {
    return OfferAnalyticsData(
      offer: _offer(_object(json['offer']), fallbackId: offerId),
      kpis: _list(json['kpis']).map(_kpi).toList(),
      trend: _list(json['trend']).map(_trend).toList(),
      sources: _list(json['sources']).map(_distribution).toList(),
      pipeline: _list(json['pipeline']).map(_funnel).toList(),
      skills: _list(json['skills']).map(_distribution).toList(),
      actions: _list(json['actions']).map(_action).toList(),
    );
  }

  static DashboardKpi _kpi(Object? raw) {
    final map = _object(raw);
    return DashboardKpi(
      id: _string(map['id'], fallback: 'metric'),
      label: _string(map['label']),
      value: _string(map['value'], fallback: '—'),
      deltaPercent: _doubleOrNull(map['deltaPercent']),
      deltaLabel: _stringOrNull(map['deltaLabel']),
    );
  }

  static DashboardTrendPoint _trend(Object? raw) {
    final map = _object(raw);
    return DashboardTrendPoint(
      date: DateTime.tryParse(_string(map['date'])) ?? DateTime(1970),
      applications: _double(map['applications']),
      matches: _double(map['matches']),
      interviews: _double(map['interviews']),
      previousApplications: _double(map['previousApplications']),
    );
  }

  static DashboardDistributionItem _distribution(Object? raw) {
    final map = _object(raw);
    return DashboardDistributionItem(
      label: _string(map['label']),
      value: _double(map['value']),
    );
  }

  static DashboardOfferPerformance _offer(Object? raw, {int fallbackId = 0}) {
    final map = _object(raw);
    return DashboardOfferPerformance(
      id: _int(map['id'], fallback: fallbackId),
      title: _string(map['title'], fallback: 'Offre'),
      location: _string(map['location'], fallback: '—'),
      contract: _string(map['contract'], fallback: '—'),
      status: _string(map['status'], fallback: '—'),
      applications: _int(map['applications']),
      matches: _int(map['matches']),
      interviews: _int(map['interviews']),
      views: _int(map['views']),
      conversionRate: _double(map['conversionRate']),
      lastActivity: _stringOrNull(map['lastActivity']),
      tagline: _stringOrNull(map['tagline']),
    );
  }

  static DashboardActivity _activity(Object? raw) {
    final map = _object(raw);
    final kind = switch (_string(map['kind']).toLowerCase()) {
      'match' => ActivityKind.match,
      'interview' => ActivityKind.interview,
      'offer' => ActivityKind.offer,
      'system' => ActivityKind.system,
      _ => ActivityKind.application,
    };
    return DashboardActivity(
      kind: kind,
      title: _string(map['title']),
      subtitle: _string(map['subtitle']),
      whenLabel: _string(map['whenLabel']),
    );
  }

  static DashboardPriorityAction _action(Object? raw) {
    final map = _object(raw);
    return DashboardPriorityAction(
      title: _string(map['title']),
      subtitle: _string(map['subtitle']),
      actionLabel: _string(map['actionLabel'], fallback: 'Ouvrir'),
    );
  }

  static AnalyticsFunnelStep _funnel(Object? raw) {
    final map = _object(raw);
    return AnalyticsFunnelStep(
      label: _string(map['label']),
      value: _double(map['value']),
    );
  }

  static AnalyticsChannelValue _channel(Object? raw) {
    final map = _object(raw);
    return AnalyticsChannelValue(
      label: _string(map['label']),
      value: _double(map['value']),
    );
  }

  static AnalyticsHeatmap _heatmap(Map<String, Object?> map) {
    return AnalyticsHeatmap(
      rows: _list(map['rows']).map((item) => '$item').toList(),
      columns: _list(map['columns']).map((item) => '$item').toList(),
      values: _list(map['values'])
          .map((row) => _list(row).map(_double).toList())
          .toList(),
    );
  }

  static AnalyticsSurface _surface(Map<String, Object?> map) {
    return AnalyticsSurface(
      xLabels: _list(map['xLabels']).map((item) => '$item').toList(),
      yLabels: _list(map['yLabels']).map((item) => '$item').toList(),
      values: _list(map['values'])
          .map((row) => _list(row).map(_double).toList())
          .toList(),
    );
  }

  static List<Object?> _list(Object? value) => value is List ? value : const [];

  static Map<String, Object?> _object(Object? value) {
    if (value case final Map<String, dynamic> map) return map;
    if (value case final Map<Object?, Object?> map) {
      return map.map((key, value) => MapEntry('$key', value));
    }
    return const {};
  }

  static String _string(Object? value, {String fallback = ''}) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  static String? _stringOrNull(Object? value) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? null : result;
  }

  static double _double(Object? value) => _doubleOrNull(value) ?? 0;

  static double? _doubleOrNull(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}'.replaceAll(',', '.'));
  }

  static int _int(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? fallback;
  }
}
