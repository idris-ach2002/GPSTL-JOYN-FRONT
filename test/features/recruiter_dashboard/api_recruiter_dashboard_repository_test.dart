import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/recruiter_dashboard/data/api_recruiter_dashboard_repository.dart';
import 'package:joyn_front/features/recruiter_dashboard/domain/recruiter_dashboard_models.dart';

void main() {
  test('le repository API mappe le contrat overview R47', () async {
    final httpClient = MockClient((request) async {
      expect(request.url.path, '/api/v1/recruiters/dashboard');
      expect(request.url.queryParameters['period'], '30d');
      return http.Response(
        '''{
          "kpis":[{"id":"applications","label":"Candidatures","value":"12","deltaPercent":10}],
          "trend":[{"date":"2026-10-01","applications":12,"matches":4,"interviews":2,"previousApplications":9}],
          "profileDistribution":[{"label":"Compatibles","value":100}],
          "topOffers":[{"id":1,"title":"Dev","location":"Paris","contract":"CDI","status":"Publiée","applications":12,"matches":4,"interviews":2,"views":80,"conversionRate":33.3}],
          "activities":[],
          "priorityActions":[]
        }''',
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final repository = ApiRecruiterDashboardRepository(
      ApiClient(baseUrl: 'https://api.joyn.test', httpClient: httpClient),
    );

    final data = await repository.fetchOverview(DashboardPeriod.thirtyDays);

    expect(data.kpis.single.value, '12');
    expect(data.trend.single.matches, 4);
    expect(data.topOffers.single.conversionRate, 33.3);
  });
}
