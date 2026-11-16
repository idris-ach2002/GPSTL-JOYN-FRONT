import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/app/theme/app_theme.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/auth/data/fake_auth_repository.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';
import 'package:joyn_front/features/recruiter_studio/presentation/studio_controller.dart';
import 'package:joyn_front/features/recruiter_workspace/data/recruiter_workspace_repository.dart';
import 'package:joyn_front/features/recruiter_workspace/presentation/workspace_controller.dart';
import 'package:joyn_front/features/recruiter_workspace/presentation/workspace_screen.dart';
import 'package:provider/provider.dart';

/// Régression : en mode API, la messagerie recruteur affichait un brouillon
/// d'e-mail (« Choisir un postulant à contacter ») au lieu des conversations
/// renvoyées par `GET /api/v1/conversations`.
void main() {
  testWidgets('en mode API, le recruteur voit les conversations du back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = ApiClient(
      baseUrl: 'https://api.joyn.test',
      httpClient: MockClient((request) async {
        if (request.url.path == '/api/v1/conversations') {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 1,
                  'applicationId': 310,
                  'jobOfferId': 139,
                  'offerTitle': 'Data Analyst junior',
                  'companyName': 'Cap Numérique',
                  'candidateId': 235,
                  'candidateName': 'Raphaël Michel',
                  'lastMessage': 'Quelles sont les disponibilités ?',
                  'lastMessageAt': '2026-11-16T09:02:39Z',
                  'unread': 1,
                },
              ],
              'totalUnread': 1,
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response(
          '{}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final auth = AuthController(FakeAuthRepository(latency: Duration.zero));
    await tester.runAsync(
      () => auth.signIn(email: 'recruteur@joyn.fr', password: 'Joyn2026'),
    );
    final studio = StudioController();
    await studio.bind('demo-company');
    final c = WorkspaceController(ApiRecruiterWorkspaceRepository(api));
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const RecruiterWorkspaceScreen(section: 'messages'),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: studio),
          ChangeNotifierProvider.value(value: c),
          ChangeNotifierProvider.value(value: auth),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choisir un postulant à contacter'), findsNothing);
    expect(find.text('Raphaël Michel'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    router.dispose();
    c.dispose();
    auth.dispose();
    studio.dispose();
  });
}
