import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/candidate_discover/data/api_recommended_offers_repository.dart';
import 'package:joyn_front/features/candidate_discover/domain/recommended_offer.dart';

void main() {
  test('mappe le flux de recommandations', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/v1/candidates/me/recommendations');
      expect(request.url.queryParameters['location'], 'Paris');
      return http.Response(
        '''{
          "data": {
            "items": [{
              "id": "off-7",
              "title": "Développeur Full-Stack",
              "company": {"name": "Entreprise Beta", "sector": "Fintech",
                          "headcount": 120, "city": "Paris 9e"},
              "compatibility": 92,
              "location": "Paris 9e",
              "commuteMinutes": 35,
              "rhythm": "3 sem / 1 sem",
              "remoteDays": 2,
              "monthlySalary": 1450,
              "contractType": "Alternance",
              "description": "Équipe Paiements.",
              "skills": [{"name": "React", "matched": true},
                         {"name": "Docker", "matched": false}],
              "criteria": [{"label": "Technos", "score": 90},
                           {"label": "Trajet", "score": 75}],
              "alumniCount": 2
            }],
            "filters": {"rhythm": "3 sem / 1 sem", "location": "Paris"},
            "totalCompatible": 10
          }
        }''',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final repository = ApiRecommendedOffersRepository(
      ApiClient(baseUrl: 'https://api.joyn.test', httpClient: client),
    );

    final feed = await repository.fetchFeed(
      filters: const DiscoverFilters(location: 'Paris'),
    );

    expect(feed.totalCompatible, 10);
    expect(feed.filters.rhythm, '3 sem / 1 sem');
    final offer = feed.offers.single;
    expect(offer.id, 'off-7');
    expect(offer.company.name, 'Entreprise Beta');
    expect(offer.company.summary, 'Fintech · 120 pers. · Paris 9e');
    expect(offer.compatibility, 92);
    expect(offer.monthlySalary, 1450);
    expect(offer.skills.map((s) => s.matched), [true, false]);
    expect(offer.criteria.first.label, 'Technos');
    expect(offer.alumniCount, 2);
  });

  test('accepte des critères sous forme d’objet et un score hors bornes', () {
    final offer = ApiRecommendedOffersRepository.mapOffer({
      'id': 12,
      'title': 'Stage data',
      'companyName': 'Mobilis',
      'score': 140,
      'skills': ['SQL'],
      'matching': {'skills': 80, 'commute': 50},
    });

    expect(offer.id, '12');
    expect(offer.company.name, 'Mobilis');
    expect(offer.compatibility, 100);
    expect(offer.skills.single.name, 'SQL');
    expect(offer.criteria.map((c) => c.label), ['Technos', 'Trajet']);
  });

  test('envoie et annule un geste', () async {
    final calls = <String>[];
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path} ${request.body}');
      return http.Response('', 204);
    });
    final repository = ApiRecommendedOffersRepository(
      ApiClient(baseUrl: 'https://api.joyn.test', httpClient: client),
    );

    await repository.submitDecision('off-7', SwipeDecision.interested);
    await repository.cancelDecision('off-7');

    expect(
      calls.first,
      startsWith('POST /api/v1/candidates/me/recommendations/off-7/decision'),
    );
    expect(jsonDecode(calls.first.split(' ').skip(2).join(' ')), {
      'decision': 'interested',
    });
    expect(
      calls.last,
      startsWith('DELETE /api/v1/candidates/me/recommendations/off-7/decision'),
    );
  });
}
