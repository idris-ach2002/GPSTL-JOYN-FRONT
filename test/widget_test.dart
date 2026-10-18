import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:joyn_front/app.dart';
import 'package:joyn_front/features/auth/data/fake_auth_repository.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';
import 'package:joyn_front/features/dashboard/data/fake_dashboard_repository.dart';

/// Lance l'application avec les services simulés, sans délai réseau.
Future<void> pumpJoynApp(WidgetTester tester, {bool skipLogin = false}) async {
  final controller = AuthController(FakeAuthRepository(latency: Duration.zero));
  await tester.pumpWidget(
    JoynApp(
      authController: controller,
      dashboardRepository: FakeDashboardRepository(latency: Duration.zero),
      skipLogin: skipLogin,
    ),
  );
  await tester.pumpAndSettle();
}

/// Simule un écran d'ordinateur (mise en page à deux colonnes).
void useDesktopScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1440, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('affiche l’écran de connexion au démarrage', (tester) async {
    await pumpJoynApp(tester);

    expect(find.text('Content de te revoir.'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('affiche les erreurs de validation en français', (tester) async {
    await pumpJoynApp(tester);

    await tapText(tester, 'Se connecter');

    expect(find.text('Saisis ton adresse e-mail.'), findsOneWidget);
    expect(find.text('Saisis ton mot de passe.'), findsOneWidget);
  });

  testWidgets('affiche une erreur si les identifiants sont faux', (
    tester,
  ) async {
    await pumpJoynApp(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'etudiant@joyn.fr',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'mauvais1');
    await tapText(tester, 'Se connecter');

    expect(find.text('E-mail ou mot de passe incorrect.'), findsOneWidget);
  });

  testWidgets('connecte le compte de démo puis redirige vers le dashboard', (
    tester,
  ) async {
    await pumpJoynApp(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'etudiant@joyn.fr',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      FakeAuthRepository.demoPassword,
    );
    await tapText(tester, 'Se connecter');

    expect(find.text('Compétences vs. votre offre'), findsOneWidget);
  });

  testWidgets('mode démo : démarre directement sur le dashboard', (
    tester,
  ) async {
    useDesktopScreen(tester);
    await pumpJoynApp(tester, skipLogin: true);

    expect(find.text('Content de te revoir.'), findsNothing);
    expect(find.text('Compétences vs. votre offre'), findsOneWidget);
    expect(find.text('Parcours'), findsOneWidget);
    expect(find.text('Proposer un entretien'), findsOneWidget);
  });

  testWidgets('se déconnecter depuis le dashboard ramène à la connexion', (
    tester,
  ) async {
    await pumpJoynApp(tester, skipLogin: true);

    await tester.tap(find.byTooltip('Mon compte'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Se déconnecter');

    expect(find.text('Content de te revoir.'), findsOneWidget);
  });

  testWidgets('« Créer un compte » ne mène nulle part pour l’instant', (
    tester,
  ) async {
    await pumpJoynApp(tester);

    await tapText(tester, 'Créer un compte');

    expect(find.text('Content de te revoir.'), findsOneWidget);
  });
}
