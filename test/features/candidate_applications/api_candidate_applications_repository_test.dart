import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/candidate_applications/data/api_candidate_applications_repository.dart';
import 'package:joyn_front/features/candidate_applications/data/pending_interests_store.dart';
import 'package:joyn_front/features/candidate_applications/domain/candidate_application.dart';

void main() {
  test(
    'récupère le contrat de candidature Spring Boot (page 1-based, limit)',
    () async {
      late Uri requested;
      final client = MockClient((request) async {
        requested = request.url;
        return http.Response(
          jsonEncode({
            'content': [
              {
                'id': 12,
                'jobOfferId': 7,
                'jobTitle': 'Dév Flutter',
                'companyName': 'Atelier Numérique',
                'status': 'INTERVIEW',
                'createdAt': '2026-10-01T09:00:00Z',
                'conversationId': 94,
              },
            ],
            'page': 2,
            'totalPages': 3,
            'totalElements': 41,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = ApiCandidateApplicationsRepository(
        ApiClient(baseUrl: 'https://api.joyn.test', httpClient: client),
      );
      final page = await repo.fetchApplications(page: 2, pageSize: 10);
      expect(requested.path, '/api/v1/candidates/applications');
      expect(requested.queryParameters, {
        'page': '2',
        'limit': '10',
        'sort': 'created_at,desc',
      });
      expect(page.page, 2);
      expect(page.totalItems, 41);
      final item = page.items.single;
      expect(item.companyName, 'Atelier Numérique');
      expect(item.offerId, '7');
      expect(item.status, ApplicationStatus.interview);
      expect(item.conversationId, '94');
    },
  );

  test('Intéressé reste local, puis POST réel de candidature', () async {
    final interests = PendingInterestsStore();
    interests.interested(
      '27',
      title: 'UX designer',
      companyName: 'Maison Solutions',
    );
    final calls = <String>[];
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      if (request.method == 'POST') {
        expect(jsonDecode(request.body), {'jobOfferId': 27});
        return http.Response(
          '{"id":99,"jobOfferId":27,"status":"PENDING"}',
          201,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response(
        '{"content":[],"page":1,"totalPages":1,"totalElements":0}',
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final repo = ApiCandidateApplicationsRepository(
      ApiClient(baseUrl: 'https://api.joyn.test', httpClient: client),
      interests: interests,
    );
    final before = await repo.fetchApplications();
    expect(before.items.single.status, ApplicationStatus.interested);
    await repo.sendApplication(before.items.single.id);
    expect(interests.items, isEmpty);
    expect(calls, [
      'GET /api/v1/candidates/applications',
      'POST /api/v1/applications',
    ]);
  });

  test('aucune route inventée pour créer une conversation', () async {
    final repo = ApiCandidateApplicationsRepository(
      ApiClient(baseUrl: 'https://api.joyn.test'),
    );
    expect(() => repo.createConversation('1'), throwsUnsupportedError);
  });
}
