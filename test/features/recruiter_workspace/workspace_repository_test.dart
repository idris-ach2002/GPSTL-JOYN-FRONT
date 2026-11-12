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
  test('API : une activité garde son candidat, sa date et son état après actualisation', () async {
    final activity = {
      'kind': 'application', 'title': 'Nouvelle candidature',
      'subtitle': 'Raphaël · Data Analyst junior',
      'occurredAt': '2026-11-12T14:30:00Z', 'whenLabel': 'il y a 5 min',
    };
    final events = [activity];
    final repo = ApiRecruiterWorkspaceRepository(ApiClient(
      baseUrl: 'https://api.joyn.test',
      httpClient: MockClient((_) async => http.Response.bytes(
        utf8.encode(jsonEncode({'activities': events})), 200)),
    ));
    final first = (await repo.notifications()).single;
    expect(first['body'], activity['subtitle']);
    expect(first['createdAt'], activity['occurredAt']);
    final id = first['id'] as String;
    await repo.readNotification(id);
    events.insert(0, {...activity, 'occurredAt': '2026-11-12T15:00:00Z'});
    expect((await repo.notifications()).last['read'], true);
    await repo.updateNotification(id, {'read': false});
    expect((await repo.notifications()).last['read'], false);
    await repo.deleteNotification(id);
    expect((await repo.notifications()).single['read'], false);
  });

  test('API : authentification vérifie le rôle et transmet le jeton', () async {
    late ApiAuthRepository auth;
    final api = ApiClient(
      baseUrl: 'https://api.joyn.test',
      tokenProvider: () async => auth.accessToken,
      httpClient: MockClient((q) async {
        if (q.url.path.endsWith('/login')) {
          return http.Response(
            jsonEncode({'access_token': 'x.${base64Url.encode(utf8.encode('{"sub":"42"}'))}.y', 'role': 'RECRUITER', 'expires_in': 3600, 'token_type': 'Bearer'}),
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
