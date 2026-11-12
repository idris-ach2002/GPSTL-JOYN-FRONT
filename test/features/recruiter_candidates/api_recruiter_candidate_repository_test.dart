import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/recruiter_candidates/data/api_recruiter_candidate_repository.dart';
import 'package:joyn_front/features/recruiter_candidates/domain/recruiter_candidate_models.dart';

void main() {
  test('les candidats sont des postulants à une offre, score réel', () async {
    final calls=<String>[];
    final client=MockClient((request) async {
      calls.add(request.url.path);
      if(request.url.path=='/api/v1/recruiters/dashboard') {
        return http.Response('{"topOffers":[{"id":7,"title":"Full Stack","location":"Paris","contract":"CDI"}]}',200);
      }
      if(request.method=='PATCH') {
        expect(request.url.path,'/api/v1/applications/41/status');
        expect(jsonDecode(request.body),{'status':'IN_REVIEW'});
        return http.Response('{"id":41,"status":"IN_REVIEW"}',200);
      }
      expect(request.url.path,'/api/v1/recruiters/jobs/7/recommendations');
      expect(request.url.queryParameters,{'page':'1','limit':'20'});
      return http.Response.bytes(utf8.encode('''{
        "content":[{
          "application_id":41,"application_status":"PENDING","match_score":93,
          "score_breakdown":{"skills":95,"experience":90,"education":100,"location":85,"availability":100},
          "candidate":{"id":17,"first_name":"Amina","last_name":"Diallo",
            "headline":"Développeuse","location":"Paris","skills":["React"]}
        }],"page":1,"totalPages":1,"totalElements":1}'''),200, headers: {'content-type': 'application/json; charset=utf-8'});
    });
    final repo=ApiRecruiterCandidateRepository(
      ApiClient(baseUrl:'https://api.joyn.test',httpClient:client));
    final data=await repo.fetchRecommendations(const CandidateRecommendationQuery(offerId:7));
    expect(data.items.single.profileId, '17');
    expect(data.items.single.jobTitle, 'Développeuse');
    expect(data.items.single.fullName,'Amina Diallo');
    expect(data.items.single.compatibilityScore,93);
    expect(data.items.single.match.skills,95);
    expect(data.items.single.id,'41'); // Application ID, not candidate profile ID.
    final updated=await repo.updateStatus('41',CandidateRecommendationStatus.interested);
    expect(updated.status,CandidateRecommendationStatus.interested);
    expect(calls.last,'/api/v1/applications/41/status');
  });
}
