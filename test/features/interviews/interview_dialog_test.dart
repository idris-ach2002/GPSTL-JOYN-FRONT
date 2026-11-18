import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/interviews/presentation/interview_dialog.dart';

void main() {
  testWidgets(
    'change les candidats avec l’offre et envoie par la route entretien',
    (tester) async {
      final posts = <Map>[];
      final api = ApiClient(
        baseUrl: 'https://api.joyn.test',
        httpClient: MockClient((request) async {
          if (request.method == 'GET') {
            expect(request.url.path, '/api/v1/interviews/options');
            return http.Response(
              '[{"id":1,"title":"Offre IA","applicants":[{"applicationId":10,"name":"Alice"}]},'
              '{"id":2,"title":"Offre Web","applicants":[{"applicationId":20,"name":"Bob"}]}]',
              200,
            );
          }
          expect(request.url.path, '/api/v1/interviews');
          posts.add(jsonDecode(request.body) as Map);
          return http.Response('{"id":5}', 200);
        }),
      );
      addTearDown(api.close);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => showInterviewProposal(context, api),
                  child: const Text('Ouvrir'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      final offer = find.byWidgetPredicate(
        (widget) => widget is DropdownButton && widget.items?.length == 2,
      );
      await tester.tap(offer);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Offre IA').last);
      await tester.pumpAndSettle();

      Finder applicants() => find.byWidgetPredicate(
        (widget) => widget is DropdownButton && widget.items?.length == 1,
      );
      await tester.tap(applicants());
      await tester.pumpAndSettle();
      expect(find.text('Bob'), findsNothing);
      await tester.tap(find.text('Alice').last);
      await tester.pumpAndSettle();

      await tester.tap(offer);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Offre Web').last);
      await tester.pumpAndSettle();
      final submit = find.widgetWithText(
        FilledButton,
        'Enregistrer et envoyer',
      );
      expect(tester.widget<FilledButton>(submit).onPressed, isNull);
      await tester.tap(applicants());
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsNothing);
      await tester.tap(find.text('Bob').last);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(posts.single['applicationId'], 20);
      expect(find.text('Proposer un entretien'), findsNothing);
    },
  );
}
