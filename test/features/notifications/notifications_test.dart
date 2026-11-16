import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/notifications/data/api_notifications_repository.dart';
import 'package:joyn_front/features/notifications/data/mock_notifications_repository.dart';
import 'package:joyn_front/features/notifications/domain/app_notification.dart';
import 'package:joyn_front/features/notifications/presentation/notifications_controller.dart';
import 'package:joyn_front/features/notifications/presentation/shared/notifications_panel.dart';
import 'package:joyn_front/app/routing/app_routes.dart';

void main() {
  test('le dépôt API lit la page et appelle les bonnes routes', () async {
    final calls = <String>[];
    final repo = ApiNotificationsRepository(
      ApiClient(
        baseUrl: 'https://api.joyn.test',
        httpClient: MockClient((request) async {
          calls.add('${request.method} ${request.url.path}');
          final body = request.method == 'GET'
              ? {
                  'notifications': [
                    {
                      'id': 5,
                      'type': 'NEW_MESSAGE',
                      'title': 'Nouveau message',
                      'message': 'Banque Horizon vous a écrit.',
                      'isRead': false,
                      'createdAt': '2026-11-14T10:00:00Z',
                    },
                  ],
                  'unreadCount': 1,
                  'totalCount': 1,
                }
              : {'message': 'ok', 'affectedCount': 3};
          return http.Response(
            jsonEncode(body),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      ),
    );

    final page = await repo.fetch();
    await repo.markRead('5');
    await repo.markAllRead();
    await repo.delete('5');
    final deleted = await repo.deleteRead();

    expect(page.unreadCount, 1);
    expect(page.items.single.kind, NotificationKind.newMessage);
    expect(deleted, 3);
    expect(calls, [
      'GET /api/v1/notifications',
      'PATCH /api/v1/notifications/5/read',
      'PATCH /api/v1/notifications/read-all',
      'DELETE /api/v1/notifications/5',
      'DELETE /api/v1/notifications/read',
    ]);
  });

  test('chaque type mène à la bonne page candidat', () {
    expect(
      candidateRouteFor(NotificationKind.newMessage),
      AppRoutes.candidateMessages,
    );
    expect(
      candidateRouteFor(NotificationKind.interview),
      AppRoutes.candidateApplications,
    );
    expect(
      candidateRouteFor(NotificationKind.newMatch),
      AppRoutes.candidateDiscover,
    );
    expect(candidateRouteFor(NotificationKind.system), isNull);
  });

  test('le contrôleur tient le compteur de non-lues à jour', () async {
    final controller = NotificationsController(
      MockNotificationsRepository(latency: Duration.zero),
      pollInterval: null,
    );
    addTearDown(controller.dispose);

    await controller.start();
    expect(controller.unreadCount, 3);

    await controller.markRead(controller.items.first);
    expect(controller.unreadCount, 2);

    await controller.markAllRead();
    expect(controller.unreadCount, 0);

    final removed = await controller.deleteRead();
    expect(removed, 4);
    expect(controller.items, isEmpty);

    controller.stop();
    expect(controller.unreadCount, 0);
  });
}
