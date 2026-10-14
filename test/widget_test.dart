import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/app/app.dart';
import 'package:joyn_front/features/landing/presentation/widgets/hero_match_preview.dart';

void main() {
  testWidgets('JOYN starts on the landing page', (tester) async {
    await tester.pumpWidget(const JoynApp());

    await tester.pumpAndSettle();

    expect(find.text('Joyn a job,'), findsOneWidget);

    expect(find.text('Trouver des offres'), findsOneWidget);

    expect(find.byType(HeroMatchPreview), findsOneWidget);
  });

  testWidgets('mobile navigation opens feature and company submenus', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const JoynApp());

    await tester.pumpAndSettle();

    // Menu fermé au départ.
    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);

    // Ouverture du menu principal.
    await tester.tap(find.byIcon(Icons.menu_rounded));

    await tester.pumpAndSettle();

    expect(find.text('Fonctionnalités'), findsOneWidget);

    expect(find.text('Entreprises'), findsOneWidget);

    // Les sous-items sont fermés au départ.
    expect(find.text('Matching intelligent'), findsNothing);

    // Ouvre Fonctionnalités.
    await tester.tap(find.text('Fonctionnalités'));

    await tester.pumpAndSettle();

    expect(find.text('Matching intelligent'), findsOneWidget);

    expect(find.text('Découverte fluide'), findsOneWidget);

    expect(find.text('Échange direct'), findsOneWidget);

    // Ouvre Entreprises.
    await tester.tap(find.text('Entreprises'));

    await tester.pumpAndSettle();

    expect(find.text('Publier une offre'), findsOneWidget);

    expect(find.text('Trouver les bons profils'), findsOneWidget);

    expect(find.text('Piloter le recrutement'), findsOneWidget);

    // Le précédent accordéon se referme.
    expect(find.text('Matching intelligent'), findsNothing);

    // Fermeture complète.
    await tester.tap(find.byIcon(Icons.close_rounded));

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
  });
}
