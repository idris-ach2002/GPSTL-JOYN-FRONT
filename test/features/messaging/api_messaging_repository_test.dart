import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/messaging/data/api_messaging_repository.dart';
import 'package:joyn_front/features/messaging/domain/conversation.dart';
import 'package:joyn_front/features/recruiter_workspace/data/recruiter_workspace_repository.dart';

ApiClient _client(Future<http.Response> Function(http.Request) handler) =>
    ApiClient(
      baseUrl: 'https://api.joyn.test',
      httpClient: MockClient(handler),
    );

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test('lit la liste des conversations et le total des non-lus', () async {
    final repo = ApiMessagingRepository(
      _client((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/conversations');
        return _json({
          'data': [
            {
              'id': 12,
              'applicationId': 52,
              'offerTitle': 'Dev Java',
              'companyName': 'Banque Horizon',
              'candidateName': 'Alex Dupont',
              'lastMessage': 'À jeudi !',
              'lastMessageAt': '2026-11-14T10:00:00Z',
              'unread': 2,
            },
          ],
          'totalUnread': 2,
        });
      }),
    );

    final list = await repo.fetchConversations();

    expect(list.totalUnread, 2);
    final c = list.items.single;
    expect(c.id, '12');
    expect(c.applicationId, '52');
    expect(c.companyName, 'Banque Horizon');
    expect(c.unread, 2);
    expect(c.lastMessageAt, isNotNull);
  });

  test('ouvre une conversation à partir d’une candidature', () async {
    final repo = ApiMessagingRepository(
      _client((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/conversations');
        expect(jsonDecode(request.body), {'application_id': 52});
        return _json({'id': 12, 'applicationId': 52}, 201);
      }),
    );

    final c = await repo.openForApplication('52');

    expect(c.id, '12');
  });

  test(
    'avant l’entretien, le refus du back devient un message clair',
    () async {
      final repo = ApiMessagingRepository(
        _client((_) async => _json({'message': 'forbidden'}, 403)),
      );

      expect(
        () => repo.openForApplication('52'),
        throwsA(
          isA<MessagingException>().having(
            (e) => e.message,
            'message',
            contains('entretien'),
          ),
        ),
      );
    },
  );

  test('pagine les messages et les remet dans l’ordre chronologique', () async {
    final repo = ApiMessagingRepository(
      _client((request) async {
        expect(request.url.path, '/api/v1/conversations/12/messages');
        expect(request.url.queryParameters['before'], '40');
        expect(request.url.queryParameters['limit'], '30');
        return _json({
          'data': [
            {
              'id': 39,
              'text': 'Deuxième',
              'fromMe': true,
              'createdAt': '2026-11-14T10:05:00Z',
              'readAt': '2026-11-14T10:06:00Z',
            },
            {
              'id': 38,
              'text': 'Premier',
              'fromMe': false,
              'senderName': 'Camille',
              'createdAt': '2026-11-14T10:00:00Z',
            },
          ],
          'nextCursor': 38,
          'hasMore': true,
        });
      }),
    );

    final page = await repo.fetchMessages('12', before: '40');

    expect(page.messages.map((m) => m.text), ['Premier', 'Deuxième']);
    expect(page.messages.last.readAt, isNotNull);
    expect(page.nextCursor, '38');
    expect(page.hasMore, isTrue);
  });

  test('envoie un message avec son clientId et marque comme lu', () async {
    final calls = <String>[];
    final repo = ApiMessagingRepository(
      _client((request) async {
        calls.add('${request.method} ${request.url.path}');
        if (request.method == 'POST') {
          expect(jsonDecode(request.body), {
            'text': 'Bonjour',
            'clientId': 'tmp-1',
          });
          return _json({
            'id': 41,
            'text': 'Bonjour',
            'fromMe': true,
            'clientId': 'tmp-1',
            'createdAt': '2026-11-14T10:10:00Z',
          }, 201);
        }
        return _json({'conversationId': 12, 'markedAsRead': 1, 'unread': 0});
      }),
    );

    final sent = await repo.send('12', 'Bonjour', clientId: 'tmp-1');
    await repo.markRead('12');

    expect(sent.id, '41');
    expect(sent.clientId, 'tmp-1');
    expect(calls, [
      'POST /api/v1/conversations/12/messages',
      'PATCH /api/v1/conversations/12/read',
    ]);
  });

  test(
    'le recruteur lit les conversations du back (plus de liste vide)',
    () async {
      final repo = ApiRecruiterWorkspaceRepository(
        _client((request) async {
          expect(request.url.path, '/api/v1/conversations');
          return _json({
            'data': [
              {
                'id': 7,
                'candidateId': 3,
                'candidateName': 'Alex Dupont',
                'offerTitle': 'Dev Java',
                'lastMessage': 'Merci !',
                'unread': 1,
              },
            ],
            'totalUnread': 1,
          });
        }),
      );

      final items = await repo.conversations();

      expect(items.single['id'], '7');
      expect(items.single['name'], 'Alex Dupont');
      expect(items.single['unread'], 1);
    },
  );
}
