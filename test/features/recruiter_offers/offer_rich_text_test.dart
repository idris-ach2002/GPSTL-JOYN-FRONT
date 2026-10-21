import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/shared/offer_ui.dart';

void main() {
  testWidgets('rend les titres, listes et styles de description', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OfferRichText(
            value: '## Vos missions\n- Construire **JOYN**\n- Travailler en *équipe*\n[center]Une culture produit',
          ),
        ),
      ),
    );

    expect(find.text('Vos missions', findRichText: true), findsOneWidget);
    expect(find.text('Construire JOYN', findRichText: true), findsOneWidget);
    expect(find.text('Travailler en équipe', findRichText: true), findsOneWidget);
    expect(find.text('Une culture produit', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
