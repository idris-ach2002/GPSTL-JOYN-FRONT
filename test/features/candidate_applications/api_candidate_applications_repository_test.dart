import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/candidate_applications/data/api_candidate_applications_repository.dart';
import 'package:joyn_front/features/candidate_applications/domain/candidate_application.dart';

ApiCandidateApplicationsRepository repositoryReplying(
  Object body, {
  void Function(http.Request request)? onRequest,
}) {
  final client = MockClient((request) async {
    onRequest?.call(request);
    return http.Response(
      jsonEncode(body),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
  return ApiCandidateApplicationsRepository(
    ApiClient(baseUrl: 'https://api.joyn.test', httpClient: client),
  );
}

void main() {
  test('appelle la route paginée, triée par date décroissante', () async {
    late Uri called;
    final repository = repositoryReplying({
      'items': <Object>[],
    }, onRequest: (request) => called = request.url);

    await repository.fetchApplications(page: 2, pageSize: 10);

    expect(called.path, '/api/v1/candidates/applications');
    expect(called.queryParameters, {
      'page': '2',
      'size': '10',
      'sort': 'appliedAt,desc',
    });
  });

  test('lit une page au format Spring (content / number)', () async {
    final repository = repositoryReplying({
      'content': [
        {
          'id': 12,
          'status': 'INTERVIEW',
          'company': {'name': 'Entreprise XY'},
          'offer': {'id': 7, 'title': 'Dév Front-End Vue'},
          'compatibilityScore': 83.6,
          'appliedAt': '2026-10-01T09:00:00Z',
          'interviewDate': '2026-10-12T14:00:00Z',
          'conversationId': 'c-1',
        },
      ],
      'number': 0,
      'totalPages': 3,
      'totalElements': 41,
    });

    final page = await repository.fetchApplications();
    final item = page.items.single;

    expect(page.page, 1);
    expect(page.totalPages, 3);
    expect(page.totalItems, 41);
    expect(item.id, '12');
    expect(item.status, ApplicationStatus.interview);
    expect(item.companyName, 'Entreprise XY');
    expect(item.jobTitle, 'Dév Front-End Vue');
    expect(item.offerId, '7');
    expect(item.matchScore, 84);
    expect(item.appliedAt, DateTime.utc(2026, 10, 1, 9).toLocal());
    expect(item.conversationId, 'c-1');
  });

  test('laisse à null les champs absents', () async {
    final repository = repositoryReplying({
      'data': {
        'items': [
          {'id': 'a1'},
        ],
      },
    });

    final item = (await repository.fetchApplications()).items.single;

    expect(item.status, ApplicationStatus.sent);
    expect(item.companyName, isNull);
    expect(item.matchScore, isNull);
    expect(item.appliedAt, isNull);
    expect(item.hasConversation, isFalse);
  });

  test('crée la conversation et renvoie son identifiant', () async {
    late http.Request sent;
    final repository = repositoryReplying({
      'conversationId': 'c-99',
    }, onRequest: (request) => sent = request);

    final id = await repository.createConversation('a1');

    expect(sent.method, 'POST');
    expect(sent.url.path, '/api/v1/candidates/applications/a1/conversation');
    expect(id, 'c-99');
  });
}
