import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/candidate_discover/data/api_recommended_offers_repository.dart';
import 'package:joyn_front/features/candidate_discover/domain/recommended_offer.dart';

void main() {
  test(
    'GET recommendations réel, contenu imbriqué et enrichissement entreprise',
    () async {
      final calls = <String>[];
      final client = MockClient((request) async {
        calls.add(request.url.path);
        if (request.url.path.endsWith('/companies/12')) {
          return http.Response(
            '{"id":12,"name":"Maison Solutions","sector":"Design"}',
            200,
          );
        }
        expect(request.url.path, '/api/v1/candidates/recommendations');
        expect(request.url.queryParameters['location'], 'Paris');
        return http.Response('''{
        "content":[{"offer":{"id":27,"company_id":12,"title":"Designer UX",
           "contract_type":"INTERNSHIP","location":"Paris","salary_period":"MONTH",
           "salary_min":1450,"skills":["Figma","Prototypage"]},
           "match_score":92,"score_breakdown":{"skills":90,"location":75}}],
        "page":1,"totalElements":1,"totalPages":1}''', 200);
      });
      final repo = ApiRecommendedOffersRepository(
        ApiClient(baseUrl: 'https://api.joyn.test', httpClient: client),
      );
      final feed = await repo.fetchFeed(
        filters: const DiscoverFilters(location: 'Paris'),
      );
      expect(feed.offers.single.company.name, 'Maison Solutions');
      expect(feed.offers.single.compatibility, 92);
      expect(feed.offers.single.monthlySalary, 1450);
      expect(calls, [
        '/api/v1/candidates/recommendations',
        '/api/v1/companies/12',
      ]);
      await repo.submitDecision('27', SwipeDecision.interested);
      expect(repo.interests.items.single.offerId, '27');
      await repo.cancelDecision('27');
      expect(repo.interests.items, isEmpty);
      expect(calls.length, 2); // Swipe local = no invented backend route.
    },
  );

  test('score borné à 100 et compétences en liste simple', () {
    final offer = ApiRecommendedOffersRepository.mapOffer({
      'id': 12,
      'title': 'Stage data',
      'companyName': 'Mobilis',
      'score': 140,
      'skills': ['SQL'],
      'matching': {'skills': 80, 'location': 50},
    });
    expect(offer.compatibility, 100);
    expect(offer.skills.single.name, 'SQL');
    expect(offer.criteria.map((c) => c.label), ['Technos', 'Trajet']);
  });
}
