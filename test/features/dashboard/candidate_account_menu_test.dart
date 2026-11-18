import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/app/navigation/candidate_account_menu.dart';

void main() {
  testWidgets('le menu contient le profil et la déconnexion', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CandidateAccountMenu(icon: Icon(Icons.person_outline)),
        ),
      ),
    );

    expect(find.text('Se déconnecter'), findsNothing);
    await tester.tap(find.byTooltip('Mon profil'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate((widget) => widget is PopupMenuItem),
      findsNWidgets(2),
    );
    expect(find.text('Voir mon profil'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);
    expect(find.text('Modifier mon profil'), findsNothing);
  });
}
