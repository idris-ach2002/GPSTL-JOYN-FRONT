import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/recruiter_candidates/data/api_recruiter_candidate_repository.dart';
import 'package:joyn_front/features/recruiter_candidates/domain/recruiter_candidate_models.dart';

void main() {
  test('le repository API mappe une page de recommandations', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/recruiters/recommendations');
      expect(request.url.queryParameters['offerId'], '7');
      expect(request.url.queryParameters['status'], 'recommended');
      return http.Response(
        '''{
          "items":[{
            "id":"cand-42",
            "firstName":"Amina",
            "lastName":"Diallo",
            "jobTitle":"Software Engineer",
            "location":"Paris",
            "education":"Bac+5",
            "experienceYears":3.5,
            "availability":"Immédiate",
            "contractPreference":"CDI",
            "remotePreference":"Hybride",
            "skills":["React","Node.js"],
            "compatibilityScore":93,
            "matching":{"skills":95,"experience":90,"education":100,"location":85,"availability":100},
            "strengths":["React solide"],
            "warnings":[],
            "summary":"Profil produit.",
            "status":"recommended",
            "reciprocalMatch":false,
            "connections":2
          }],
          "offers":[{"id":7,"title":"Full-Stack","location":"Paris","contract":"CDI"}],
          "stats":{"recommended":12,"saved":3,"interested":4,"matches":2},
          "page":1,
          "totalPages":1,
          "totalItems":1,
          "selectedOfferId":7
        }''',
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final repository = ApiRecruiterCandidateRepository(
      ApiClient(baseUrl: 'https://api.joyn.test', httpClient: client),
    );

    final data = await repository.fetchRecommendations(
      const CandidateRecommendationQuery(offerId: 7),
    );

    expect(data.items.single.fullName, 'Amina Diallo');
    expect(data.items.single.compatibilityScore, 93);
    expect(data.items.single.match.skills, 95);
    expect(data.stats.matches, 2);
  });

  test('interest utilise le endpoint dédié', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(
        request.url.path,
        '/api/v1/recruiters/recommendations/cand-42/interest',
      );
      return http.Response(
        '''{
          "id":"cand-42",
          "firstName":"Amina",
          "lastName":"Diallo",
          "jobTitle":"Software Engineer",
          "location":"Paris",
          "education":"Bac+5",
          "experienceYears":3.5,
          "availability":"Immédiate",
          "contractPreference":"CDI",
          "remotePreference":"Hybride",
          "skills":["React"],
          "compatibilityScore":93,
          "matching":{"skills":95,"experience":90,"education":100,"location":85,"availability":100},
          "strengths":[],
          "warnings":[],
          "summary":"Profil produit.",
          "status":"interested",
          "reciprocalMatch":true,
          "connections":2
        }''',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final repository = ApiRecruiterCandidateRepository(
      ApiClient(baseUrl: 'https://api.joyn.test', httpClient: client),
    );

    final candidate = await repository.updateStatus(
      'cand-42',
      CandidateRecommendationStatus.interested,
    );

    expect(candidate.status, CandidateRecommendationStatus.interested);
    expect(candidate.reciprocalMatch, isTrue);
  });
}
