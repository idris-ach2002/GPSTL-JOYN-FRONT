import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/app/app.dart';
import 'package:joyn_front/app/theme/app_theme.dart';
import 'package:joyn_front/features/auth/presentation/auth_screen.dart';
import 'package:joyn_front/features/landing/domain/pricing_plan.dart';
import 'package:joyn_front/features/landing/presentation/screens/landing_screen.dart';
import 'package:joyn_front/features/landing/presentation/sections/constat_section.dart';
import 'package:joyn_front/features/landing/presentation/sections/features_section.dart';
import 'package:joyn_front/features/landing/presentation/sections/pricing_section.dart';
import 'package:joyn_front/features/startup/mobile_startup_screen.dart';
import 'package:joyn_front/features/landing/domain/landing_content.dart';
import 'package:joyn_front/features/landing/presentation/widgets/feature_demo.dart';
import 'package:joyn_front/features/landing/presentation/widgets/matching_story_demo.dart';
import 'package:joyn_front/features/information/domain/footer_links.dart';
import 'package:joyn_front/features/information/domain/information_content.dart';
import 'package:joyn_front/features/information/presentation/information_screen.dart';

/// Hôte isolé des composants. Les animations sont finies ou liées au scroll.
Widget host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

/// Un premier frame installe la transition, les suivants la terminent.
/// Avancer l'horloge sans ce premier pump laisse l'animation à sa valeur initiale.
Future<void> finishTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

void main() {
  test('JOYN+ conserve les accès essentiels et augmente le quota', () {
    final plus = candidatePlans[1];
    expect(plus.features, containsAll(candidateBaseAccess));
    expect(plus.features, contains('« Intéressé » illimités'));
    expect(plus.features, isNot(contains('10 « Intéressé » par jour')));
  });

  test('Premium entreprise conserve les accès de Membre', () {
    expect(companyPlans[1].features, containsAll(companyPlans[0].features));
    expect(
      companyPlans[1].features.length,
      greaterThan(companyPlans[0].features.length),
    );
  });

  testWidgets('Les fonctionnalités changent réellement selon l’audience', (
    tester,
  ) async {
    await tester.pumpWidget(host(const FeaturesSection()));
    expect(find.byKey(const ValueKey('feature-candidate-0')), findsOneWidget);
    await tester.tap(find.text('Entreprise'));
    await finishTransition(tester);
    expect(find.byKey(const ValueKey('feature-company-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('feature-candidate-0')), findsNothing);
    final last = find.byKey(const ValueKey('feature-company-3'));
    await tester.ensureVisible(last);
    await tester.tap(last);
    await finishTransition(tester);
    expect(find.textContaining('Mettez à jour le statut'), findsOneWidget);
  });

  testWidgets('La tarification présente les deux formules entreprise', (
    tester,
  ) async {
    await tester.pumpWidget(host(const PricingSection()));
    await finishTransition(tester);
    expect(find.text('15,99 €'), findsOneWidget);
    await tester.tap(find.text('Entreprise'));
    await finishTransition(tester);
    expect(find.text('Membre premium'), findsOneWidget);
    expect(find.text('Sur devis'), findsOneWidget);
    expect(find.text('15,99 €'), findsNothing);
  });

  test('Chaque lien du footer possède une destination publique', () {
    final destinations = {...informationPages.keys, '/connexion', '/tarifs'};
    expect(
      footerLinks.keys,
      orderedEquals(['Produit', 'Entreprises', 'Ressources', 'Légal']),
    );
    for (final group in footerLinks.values) {
      for (final route in group.values) {
        expect(destinations, contains(route));
      }
    }
  });

  testWidgets('Le carrousel répond aux boutons et aux flèches du clavier', (
    tester,
  ) async {
    await tester.pumpWidget(host(const PricingSection()));
    await finishTransition(tester);
    expect(find.text('Formule 2 sur 3 · joyn+'), findsOneWidget);
    final next = find.byKey(const ValueKey('pricing-next'));
    await tester.ensureVisible(next);
    await tester.tap(next);
    await finishTransition(tester);
    expect(find.text('Formule 3 sur 3 · Boost 48 h'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await finishTransition(tester);
    expect(find.text('Formule 2 sur 3 · joyn+'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await finishTransition(tester);
    expect(find.text('Formule 1 sur 3 · joyn'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await finishTransition(tester);
    expect(find.text('Formule 1 sur 3 · joyn'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Le constat revient avec des indicateurs sourcés', (
    tester,
  ) async {
    await tester.pumpWidget(host(const ConstatSection()));
    await finishTransition(tester);
    expect(find.text('LE CONSTAT'), findsOneWidget);
    expect(find.text('320 000'), findsOneWidget);
    expect(find.text('74 %'), findsOneWidget);
    expect(
      find.text(
        'Source : La bonne alternance — Baromètre de l’alternance, T1 2026.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('La démonstration complète expose les deux parcours', (
    tester,
  ) async {
    await tester.pumpWidget(host(const MatchingStoryDemo()));
    await tester.pump();
    expect(find.text('Ton tableau de bord, dès l’arrivée'), findsOneWidget);
    await tester.tap(find.text('Entreprise'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.text('Pilote tes recrutements depuis le dashboard'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('story-step-3')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Comprends le profil avant de contacter'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Le score de démonstration suit les critères activés', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const FeatureDemo(audience: Audience.candidate, index: 1)),
    );
    await finishTransition(tester);
    expect(find.text('75 %'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('demo-criterion-3')));
    await finishTransition(tester);
    expect(find.text('100 %'), findsOneWidget);
  });

  testWidgets('La démonstration de profil peut être réinitialisée', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const FeatureDemo(audience: Audience.candidate, index: 0)),
    );
    final action = find.byKey(const ValueKey('demo-import'));
    await tester.ensureVisible(action);
    await tester.tap(action);
    await finishTransition(tester);
    expect(find.text('Camille'), findsOneWidget);
    await tester.tap(action);
    await finishTransition(tester);
    expect(find.text('Camille'), findsNothing);
  });

  testWidgets('Un lien du footer ouvre sa page puis revient au même scroll', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const JoynApp(webOverride: true));
    await finishTransition(tester);
    final guide = find.text('Guide de l’alternance');
    await tester.ensureVisible(guide);
    await finishTransition(tester);
    final scroll = tester
        .widget<SingleChildScrollView>(
          find.descendant(
            of: find.byType(LandingScreen),
            matching: find.byType(SingleChildScrollView),
          ),
        )
        .controller!;
    final originalOffset = scroll.offset;
    await tester.tap(guide);
    await finishTransition(tester);
    expect(find.byType(InformationScreen), findsOneWidget);
    expect(find.text('Prépare un profil concret'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('return-landing')));
    await finishTransition(tester);
    expect(find.byType(LandingScreen), findsOneWidget);
    expect(scroll.offset, closeTo(originalOffset, 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Les tarifs restent lisibles avec le texte agrandi', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.6)),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(child: PricingSection()),
        ),
      ),
    );
    await finishTransition(tester);
    expect(tester.takeException(), isNull);
    final enterprise = find.text('Entreprise');
    await tester.ensureVisible(enterprise);
    await tester.tap(enterprise);
    await finishTransition(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Sur devis'), findsOneWidget);
  });

  testWidgets('Le parcours natif remplace l’introduction par la connexion', (
    tester,
  ) async {
    await tester.pumpWidget(const JoynApp(webOverride: false));
    expect(find.byType(MobileStartupScreen), findsOneWidget);
    expect(find.byType(LandingScreen), findsNothing);
    await tester.pump(const Duration(milliseconds: 1700));
    await finishTransition(tester);
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.byType(MobileStartupScreen), findsNothing);
  });

  testWidgets('Démonter l’introduction annule sa navigation différée', (
    tester,
  ) async {
    await tester.pumpWidget(const JoynApp(webOverride: false));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 768.0, 1440.0]) {
    testWidgets('Landing web à $width px : affichage et navigation', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const JoynApp(webOverride: true));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(LandingScreen), findsOneWidget);
      expect(find.byType(MobileStartupScreen), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Connexion').first);
      await finishTransition(tester);
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('La préférence de mouvement réduit court-circuite le splash', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(const JoynApp(webOverride: false));
    await tester.pump();
    await finishTransition(tester);
    expect(find.byType(AuthScreen), findsOneWidget);
  });
}
