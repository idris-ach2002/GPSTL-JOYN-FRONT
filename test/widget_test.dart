import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/app/app.dart';
import 'package:joyn_front/app/theme/app_theme.dart';
import 'package:joyn_front/features/auth/presentation/auth_screen.dart';
import 'package:joyn_front/features/landing/domain/pricing_plan.dart';
import 'package:joyn_front/features/landing/presentation/screens/landing_screen.dart';
import 'package:joyn_front/features/landing/presentation/sections/features_section.dart';
import 'package:joyn_front/features/landing/presentation/sections/pricing_section.dart';
import 'package:joyn_front/features/startup/mobile_startup_screen.dart';

/// Les pompages sont bornés : la courbe de footer reste animée en continu.
/// pumpAndSettle sur la landing entière ne conviendrait donc pas ici.
Widget host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  test('JOYN+ conserve les accès essentiels et augmente le quota', () {
    final plus = candidatePlans[1];
    expect(plus.features, containsAll(candidateBaseAccess));
    expect(plus.features, contains('« Intéressé » illimités'));
    expect(plus.features, isNot(contains('10 « Intéressé » par jour')));
  });

  test('Premium entreprise conserve les accès de Membre', () {
    expect(companyPlans[1].features, containsAll(companyPlans[0].features));
    expect(companyPlans[1].features.length,
      greaterThan(companyPlans[0].features.length));
  });

  testWidgets('Les fonctionnalités changent réellement selon l’audience', (tester) async {
    await tester.pumpWidget(host(const FeaturesSection()));
    expect(find.byKey(const ValueKey('feature-candidate-0')), findsOneWidget);
    await tester.tap(find.text('Entreprise'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('feature-company-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('feature-candidate-0')), findsNothing);
    final last = find.byKey(const ValueKey('feature-company-3'));
    await tester.ensureVisible(last);
    await tester.tap(last);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Mettez à jour le statut'), findsOneWidget);
  });

  testWidgets('La tarification présente les deux formules entreprise', (tester) async {
    await tester.pumpWidget(host(const PricingSection()));
    expect(find.text('15,99 €'), findsOneWidget);
    await tester.tap(find.text('Entreprise'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Membre premium'), findsOneWidget);
    expect(find.text('Sur devis'), findsOneWidget);
    expect(find.text('15,99 €'), findsNothing);
  });

  testWidgets('Le parcours natif remplace l’introduction par la connexion', (tester) async {
    await tester.pumpWidget(const JoynApp(webOverride: false));
    expect(find.byType(MobileStartupScreen), findsOneWidget);
    expect(find.byType(LandingScreen), findsNothing);
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.byType(MobileStartupScreen), findsNothing);
  });

  testWidgets('Démonter l’introduction annule sa navigation différée', (tester) async {
    await tester.pumpWidget(const JoynApp(webOverride: false));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 768.0, 1440.0]) {
    testWidgets('Landing web à $width px : affichage et navigation', (tester) async {
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
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('La préférence de mouvement réduit court-circuite le splash', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(const JoynApp(webOverride: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AuthScreen), findsOneWidget);
  });
}
