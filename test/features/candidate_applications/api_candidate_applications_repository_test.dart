import 'dart:convert';
import 'dart:typed_data';

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

  test('transmet une lettre éditée ou un PDF avec la candidature', () async {
    final interests = PendingInterestsStore();
    for (final id in ['11', '12']) {
      interests.interested(id, title: 'Offre $id', companyName: 'JOYN');
    }
    final repository = ApiCandidateApplicationsRepository(
      ApiClient(
        baseUrl: 'https://api.joyn.test',
        httpClient: MockClient((request) async {
          expect(request.url.path, '/api/v1/applications');
          if (request.headers['content-type']!.startsWith('application/json')) {
            expect(jsonDecode(request.body), {
              'jobOfferId': 11,
              'coverMessage': 'Lettre adaptée',
            });
          } else {
            expect(
              request.headers['content-type'],
              startsWith('multipart/form-data;'),
            );
            expect(request.body, contains('name="jobOfferId"'));
            expect(
              request.body,
              contains('name="coverPdf"; filename="lettre.pdf"'),
            );
            expect(request.body, contains('%PDF'));
          }
          return http.Response('{"id":99,"status":"PENDING"}', 201);
        }),
      ),
      interests: interests,
    );
    await repository.sendApplication(
      'local-interest-11',
      coverMessage: 'Lettre adaptée',
    );
    await repository.sendApplication(
      'local-interest-12',
      coverPdf: Uint8List.fromList('%PDF'.codeUnits),
      coverPdfName: 'lettre.pdf',
    );
    expect(interests.items, isEmpty);
  });

  // La route existe désormais dans le Swagger du back (tag « Messaging »).
  test('crée la conversation via POST /api/v1/conversations', () async {
    final repo = ApiCandidateApplicationsRepository(
      ApiClient(
        baseUrl: 'https://api.joyn.test',
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/v1/conversations');
          expect(jsonDecode(request.body), {'application_id': 1});
          return http.Response(
            jsonEncode({'id': 12, 'applicationId': 1}),
            201,
            headers: {'content-type': 'application/json'},
          );
        }),
      ),
    );
    expect(await repo.createConversation('1'), '12');
  });
}
