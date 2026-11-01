import 'package:flutter/foundation.dart';

import '../data/recruiter_dashboard_repository.dart';
import '../domain/recruiter_dashboard_models.dart';

class RecruiterDashboardController extends ChangeNotifier {
  RecruiterDashboardController(this._repository);

  final RecruiterDashboardRepository _repository;

  DashboardPeriod _period = DashboardPeriod.thirtyDays;
  RecruiterDashboardData? _overview;
  RecruiterAnalyticsData? _analytics;
  OfferAnalyticsData? _offerAnalytics;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardPeriod get period => _period;
  RecruiterDashboardData? get overview => _overview;
  RecruiterAnalyticsData? get analytics => _analytics;
  OfferAnalyticsData? get offerAnalytics => _offerAnalytics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard() => _run(() async {
    final results = await Future.wait<Object>([
      _repository.fetchOverview(_period),
      _repository.fetchAnalytics(_period),
    ]);
    _overview = results[0] as RecruiterDashboardData;
    _analytics = results[1] as RecruiterAnalyticsData;
  });

  Future<void> loadOverview() => _run(() async {
    _overview = await _repository.fetchOverview(_period);
  });

  Future<void> loadAnalytics() => _run(() async {
    _analytics = await _repository.fetchAnalytics(_period);
  });

  Future<void> loadOffer(int offerId) => _run(() async {
    _offerAnalytics = await _repository.fetchOfferAnalytics(offerId, _period);
  });

  Future<void> setPeriod(
    DashboardPeriod value, {
    bool loadDashboard = false,
    bool loadOverview = false,
    bool loadAnalytics = false,
    int? offerId,
  }) async {
    if (_period == value && !_isLoading) return;
    _period = value;
    notifyListeners();
    if (loadDashboard) return this.loadDashboard();
    if (loadOverview) return this.loadOverview();
    if (loadAnalytics) return this.loadAnalytics();
    if (offerId != null) return loadOffer(offerId);
  }

  Future<void> _run(Future<void> Function() task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await task();
    } catch (error) {
      debugPrint('Recruiter dashboard error: $error');
      _errorMessage = 'Impossible de charger les données du dashboard.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
