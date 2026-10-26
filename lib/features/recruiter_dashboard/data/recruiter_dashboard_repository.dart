import '../domain/recruiter_dashboard_models.dart';

abstract interface class RecruiterDashboardRepository {
  Future<RecruiterDashboardData> fetchOverview(DashboardPeriod period);
  Future<RecruiterAnalyticsData> fetchAnalytics(DashboardPeriod period);
  Future<OfferAnalyticsData> fetchOfferAnalytics(
    int offerId,
    DashboardPeriod period,
  );
}
