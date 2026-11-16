import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/recruiter_dashboard/data/api_recruiter_dashboard_repository.dart';
import 'package:joyn_front/features/recruiter_dashboard/data/recruiter_dashboard_repository.dart';
import 'package:joyn_front/features/recruiter_offers/data/api_recruiter_offers_repository.dart';
import 'package:joyn_front/features/recruiter_offers/data/recruiter_offers_repository.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/shared/offer_ui.dart';
import 'package:joyn_front/features/recruiter_workspace/data/recruiter_workspace_repository.dart';
import 'package:joyn_front/features/recruiter_workspace/presentation/connected_offer_summary.dart';
import 'package:joyn_front/features/recruiter_workspace/presentation/workspace_controller.dart';

void main() {
  test('une date absente ne devient pas le 1 janvier 1970', () {
    expect(dateLabel(DateTime.fromMillisecondsSinceEpoch(0)), '—');
    expect(dateLabel(null), '—');
  });
  for (final width in [390.0, 1440.0]) {
    testWidgets('détail offre, candidats et chiffres à $width pixels', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = ApiClient(
        baseUrl: 'https://api.joyn.test',
        httpClient: MockClient((q) async {
          expect(q.method, 'GET');
          final Object body;
          switch (q.url.path) {
            case '/api/v1/recruiters/dashboard/offers/139':
              body = {
                'offer': {
                  'id': 139,
                  'title': 'Data Analyst junior',
                  'location': 'Rouen',
                  'contract': 'CDI',
                  'status': 'Publiée',
                  'applications': 4,
                },
                'kpis': [
                  {
                    'id': 'applications',
                    'label': 'Candidatures reçues',
                    'value': '4',
                  },
                ],
                'skills': [
                  {'label': 'SQL', 'value': 75},
                ],
                'pipeline': [
                  {'label': 'En revue', 'value': 2},
                ],
                'sources': [
                  {'label': 'Candidature directe', 'value': 4},
                ],
                'trend': [],
                'actions': [],
              };
            case '/api/v1/recruiters/dashboard':
              body = {'companyId': 30};
            case '/api/v1/companies/30':
              body = {
                'name': 'Cap Numérique',
                'jobs': [
                  {
                    'id': 139,
                    'remotePolicy': 'HYBRID',
                    'publishedAt': '2026-11-12T12:00:00Z',
                  },
                ],
              };
            case '/api/v1/recruiters/jobs/139/recommendations':
              body = {
                'content': [
                  {
                    'application_id': 310,
                    'application_status': 'IN_REVIEW',
                    'match_score': 85,
                    'candidate': {
                      'id': 235,
                      'first_name': 'Raphaël',
                      'last_name': 'Michel',
                      'headline': 'Analyste',
                      'skills': ['SQL'],
                    },
                  },
                ],
                'hasNext': false,
              };
            default:
              throw StateError('Route inattendue : ${q.url}');
          }
          return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
        }),
      );
      final workspace = WorkspaceController(
        ApiRecruiterWorkspaceRepository(api),
      );
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<RecruiterDashboardRepository>.value(
              value: ApiRecruiterDashboardRepository(api),
            ),
            Provider<RecruiterOffersRepository>.value(
              value: ApiRecruiterOffersRepository(api),
            ),
            ChangeNotifierProvider.value(value: workspace),
          ],
          child: const MaterialApp(home: ConnectedOfferSummary(offerId: 139)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Candidatures reçues'), findsOneWidget);
      expect(find.text('Cap Numérique'), findsOneWidget);
      expect(find.text('Hybride'), findsOneWidget);
      expect(find.textContaining('1 janv. 1970'), findsNothing);
      await tester.ensureVisible(find.text('Les candidats à cette offre'));
      await tester.pumpAndSettle();
      expect(find.text('Raphaël Michel'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      workspace.dispose();
    });
  }
}
