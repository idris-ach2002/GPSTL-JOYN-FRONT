import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/core/network/api_exception.dart';
import 'package:joyn_front/features/auth/data/api_auth_repository.dart';
import 'package:joyn_front/features/auth/domain/user_role.dart';
import 'package:joyn_front/features/recruiter_workspace/data/recruiter_workspace_repository.dart';
import 'package:joyn_front/features/recruiter_workspace/presentation/workspace_controller.dart';

void main() {
  test(
    'mock : état conservé, lecture, suppression, envoi idempotent',
    () async {
      final r = MockRecruiterWorkspaceRepository();
      expect(
        (await r.startConversation('cand-001', 'Alex Dupont'))['id'],
        'c1',
      );
      await r.saveProfile({'firstName': 'Idris'});
      expect((await r.profile())['firstName'], 'Idris');
      await r.saveSettings({'emailNotifications': false});
      expect((await r.settings())['emailNotifications'], false);
      await r.readNotification('n1');
      expect((await r.notifications()).first['read'], true);
      await r.deleteNotification('n1');
      expect((await r.notifications()).length, 2);
      final c = await r.startConversation('new-candidate', 'Nouveau candidat');
      final again = await r.startConversation(
        'new-candidate',
        'Nouveau candidat',
      );
      expect(c['id'], again['id']);
      await r.send(c['id'] as String, 'Bonjour !', 'request-1');
      await r.send(c['id'] as String, 'Bonjour !', 'request-1');
      final messages = await r.messages(c['id'] as String);
      expect(messages.length, 1);
      expect(messages.single['fromMe'], true); // aucune réponse inventée
    },
  );
  test(
    'API : profil 204, GET de confirmation et bearer sur toutes les routes',
    () async {
      final requests = <http.Request>[];
      final api = ApiClient(
        baseUrl: 'https://api.joyn.test',
        tokenProvider: () async => 'token',
        httpClient: MockClient((q) async {
          requests.add(q);
          return q.method == 'PATCH'
              ? http.Response('', 204)
              : http.Response('{"data":{"firstName":"Idris"}}', 200);
        }),
      );
      final r = ApiRecruiterWorkspaceRepository(api);
      expect(
        (await r.saveProfile({'firstName': 'Idris'}))['firstName'],
        'Idris',
      );
      expect(requests.map((q) => q.method), ['PATCH', 'GET']);
      expect(
        requests.every((q) => q.headers['Authorization'] == 'Bearer token'),
        true,
      );
      expect(jsonDecode(requests.first.body), {'firstName': 'Idris'});
    },
  );
  test(
    'API : un 401 invalide la session et ne renvoie aucune donnée mock',
    () async {
      var invalidated = false;
      final api = ApiClient(
        baseUrl: 'https://api.joyn.test',
        onUnauthorized: () => invalidated = true,
        httpClient: MockClient((q) async => http.Response('{}', 401)),
      );
      await expectLater(
        ApiRecruiterWorkspaceRepository(api).notifications(),
        throwsA(isA<ApiException>()),
      );
      expect(invalidated, true);
    },
  );
  test(
    'API : notifications paginées, lecture et suppression serveur',
    () async {
      final requests = <http.Request>[];
      final read = <String>{};
      final deleted = <String>{};
      final repo = ApiRecruiterWorkspaceRepository(
        ApiClient(
          baseUrl: 'https://api.joyn.test',
          httpClient: MockClient((q) async {
            requests.add(q);
            if (q.method == 'PATCH') {
              read.add(q.url.path.split('/')[4]);
              return http.Response('{}', 200);
            }
            if (q.method == 'DELETE') {
              deleted.add(q.url.path.split('/').last);
              return http.Response('{}', 200);
            }
            expect(q.url.path, '/api/v1/notifications');
            final id = q.url.queryParameters['page']!;
            return http.Response.bytes(
              utf8.encode(
                jsonEncode({
                  'notifications': [
                    if (!deleted.contains(id))
                      {
                        'id': id,
                        'type': 'NEW_MESSAGE',
                        'title': 'Nouveau message',
                        'message': 'Raphaël : disponible jeudi',
                        'isRead': read.contains(id),
                        'createdAt': '2026-11-16T10:00:00Z',
                        'link': '/conversations/7',
                      },
                  ],
                  'totalPages': 2,
                }),
              ),
              200,
            );
          }),
        ),
      );
      final first = await repo.notifications();
      expect(first, hasLength(2));
      expect(first.first['body'], 'Raphaël : disponible jeudi');
      expect(first.first['target'], '/recruiter/messages?conversationId=7');
      await repo.readNotification('1');
      expect((await repo.notifications()).first['read'], true);
      await expectLater(
        repo.updateNotification('1', {'read': false}),
        throwsUnsupportedError,
      );
      await repo.deleteNotification('2');
      expect(await repo.notifications(), hasLength(1));
      expect(requests.any((q) => q.method == 'DELETE'), true);
    },
  );

  test('historique réel si aucune notification, sans faux non-lu', () async {
    final repo = ApiRecruiterWorkspaceRepository(
      ApiClient(
        baseUrl: 'https://api.joyn.test',
        httpClient: MockClient((q) async {
          if (q.url.path == '/api/v1/notifications') {
            return http.Response('{"notifications":[],"totalPages":0}', 200);
          }
          expect(q.url.path, '/api/v1/recruiters/dashboard');
          return http.Response(
            '{"activities":[{"kind":"application","title":"Candidature","subtitle":"Alice - Java","occurredAt":"2026-11-16T10:00:00Z"}]}',
            200,
          );
        }),
      ),
    );
    final event = (await repo.notifications()).single;
    expect(event['body'], 'Alice - Java');
    expect(event['read'], true);
    expect(event['source'], isNotNull);
    await repo.readNotification(event['id'] as String);
  });

  test('API : les liens externes des notifications ne sont pas suivis', () {
    expect(
      ApiRecruiterWorkspaceRepository.notificationTarget(
        'https://evil.test',
        'NEW_MESSAGE',
      ),
      '/recruiter/messages',
    );
    expect(
      ApiRecruiterWorkspaceRepository.notificationTarget(
        '/recruiters/jobs/139/recommendations',
        'NEW_APPLICATION',
      ),
      '/recruiter/jobs/139',
    );
  });

  test(
    'API : ouvre la candidature exacte et utilise le curseur des messages',
    () async {
      final repo = ApiRecruiterWorkspaceRepository(
        ApiClient(
          baseUrl: 'https://api.joyn.test',
          httpClient: MockClient((q) async {
            if (q.method == 'POST') {
              expect(jsonDecode(q.body), {'application_id': 310});
              return http.Response(
                '{"id":7,"applicationId":310,"candidateId":235}',
                200,
              );
            }
            expect(q.url.path, '/api/v1/conversations/7/messages');
            expect(q.url.queryParameters['before'], '42');
            return http.Response(
              '{"data":[{"id":41,"text":"Bonjour","fromMe":false,"createdAt":"2026-11-16T10:00:00Z"}],"hasMore":true,"nextCursor":41}',
              200,
            );
          }),
        ),
      );
      expect((await repo.openApplication('310'))['applicationId'], '310');
      final page = await repo.messagePage('7', before: '42');
      expect(page.nextCursor, '41');
      expect(page.hasMore, true);
    },
  );

  test('API : authentification vérifie le rôle et transmet le jeton', () async {
    late ApiAuthRepository auth;
    final api = ApiClient(
      baseUrl: 'https://api.joyn.test',
      tokenProvider: () async => auth.accessToken,
      httpClient: MockClient((q) async {
        if (q.url.path.endsWith('/login')) {
          return http.Response(
            jsonEncode({
              'access_token':
                  'x.${base64Url.encode(utf8.encode('{"sub":"42"}'))}.y',
              'role': 'RECRUITER',
              'expires_in': 3600,
              'token_type': 'Bearer',
            }),
            200,
          );
        }
        expect(q.headers['Authorization'], 'Bearer ${auth.accessToken}');
        return http.Response('', 204);
      }),
    );
    auth = ApiAuthRepository(api);
    expect(
      (await auth.signIn(email: 'test@joyn.fr', password: 'secret')).role,
      UserRole.company,
    );
    await api.deleteJson('/api/v1/jobs/1');
    await auth.signOut();
    expect(auth.accessToken, isNull);
    expect(await auth.currentUser(), isNull);
  });
  test('contrôleur : une erreur conserve les champs pour réessayer', () async {
    final c = WorkspaceController(MockRecruiterWorkspaceRepository());
    await c.load('profile');
    final before = c.profile;
    expect(await c.run(() async => throw Exception('offline')), false);
    expect(c.error, isNotNull);
    expect(c.profile, same(before));
    expect(c.busy, false);
    c.dispose();
  });
}
