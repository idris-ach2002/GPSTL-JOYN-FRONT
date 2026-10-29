import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:joyn_front/app/app.dart';
import 'package:joyn_front/features/auth/data/fake_auth_repository.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';
import 'package:joyn_front/features/recruiter_studio/data/studio_store.dart';
import 'package:joyn_front/features/recruiter_studio/presentation/studio_controller.dart';
import 'package:joyn_front/features/recruiter_workspace/presentation/workspace_controller.dart';

Future<({GoRouter router, StudioController studio, AuthController auth})> setup(
  WidgetTester tester,
  String route, {
  double width = 1440,
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final auth = AuthController(FakeAuthRepository(latency: Duration.zero));
  await tester.runAsync(
    () => auth.signIn(email: 'recruteur@joyn.fr', password: 'Joyn2026'),
  );
  await tester.pumpWidget(
    JoynApp(
      authController: auth,
      webOverride: width >= 768,
      studioStore: MemoryStudioStore(),
    ),
  );
  await tester.pump();
  final router =
      tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig!
          as GoRouter;
  final studio = tester
      .element(find.byType(MaterialApp))
      .read<StudioController>();
  router.go(route);
  await tester.pumpAndSettle();
  return (router: router, studio: studio, auth: auth);
}

void main() {
  testWidgets(
    'paramètres : éditer la signature puis créer une réponse enregistrée',
    (tester) async {
      final app = await setup(tester, '/recruiter/settings');
      await tester.tap(find.text('Messagerie'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Signature de message'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField),
        'Camille · équipe Joyn',
      );
      await tester.tap(find.text('Enregistrer').last);
      await tester.pumpAndSettle();
      expect(app.studio.data['signature'], 'Camille · équipe Joyn');
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Créer une réponse'));
      await tester.tap(find.text('Créer une réponse'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'Après entretien',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'Bonjour {prenom}, merci pour cet échange.',
      );
      await tester.tap(find.text('Créer').last);
      await tester.pumpAndSettle();
      expect(app.studio.list('templates').single['title'], 'Après entretien');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      app.auth.dispose();
    },
  );
  testWidgets(
    'agenda : préparer un entretien et naviguer entre les sous-vues',
    (tester) async {
      final app = await setup(tester, '/recruiter/planner?tab=1');
      await tester.tap(find.text('Préparer un entretien'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Alex Dupont');
      await tester.tap(find.text('Enregistrer le créneau'));
      await tester.pumpAndSettle();
      expect(app.studio.list('interviews').single['name'], 'Alex Dupont');
      expect(find.text('Alex Dupont'), findsOneWidget);
      app.router.go('/recruiter/planner?tab=2');
      await tester.pumpAndSettle();
      expect(
        find.text('Votre pipeline se construit avec vos rencontres.'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      app.auth.dispose();
    },
  );

  testWidgets('réglages mobile : sous-menu apparence, mode nuit et retour', (
    tester,
  ) async {
    final app = await setup(tester, '/recruiter/settings', width: 390);
    await tester.tap(find.text('Apparence et confort'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('theme-dark')));
    await tester.tap(find.byKey(const ValueKey('theme-dark')));
    await tester.pumpAndSettle();
    expect(app.studio.themeMode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.text('Votre lumière, votre rythme')))
          .brightness,
      Brightness.dark,
    );
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    expect(find.text('Compte et sécurité'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    app.auth.dispose();
  });
  testWidgets('notifications : archiver puis restaurer sans supprimer', (
    tester,
  ) async {
    final app = await setup(tester, '/recruiter/notifications');
    await tester.tap(find.byTooltip('Actions de notification').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archiver').last);
    await tester.pumpAndSettle();
    expect(app.studio.contains('archivedNotifications', 'n1'), true);
    await tester.tap(find.text('Archives').first);
    await tester.pumpAndSettle();
    expect(find.text('Un message vous attend'), findsOneWidget);
    await tester.tap(find.byTooltip('Actions de notification').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restaurer').last);
    await tester.pumpAndSettle();
    expect(app.studio.contains('archivedNotifications', 'n1'), false);
    await tester.pumpWidget(const SizedBox());
    app.auth.dispose();
  });
  testWidgets('agenda : créer une action puis la terminer', (tester) async {
    final app = await setup(tester, '/recruiter/planner');
    await tester.tap(find.text('Nouvelle action'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField),
      'Relancer Alex vendredi',
    );
    await tester.tap(find.text('Enregistrer').last);
    await tester.pumpAndSettle();
    expect(app.studio.list('tasks').single['title'], 'Relancer Alex vendredi');
    expect(find.text('Relancer Alex vendredi'), findsOneWidget);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(app.studio.list('tasks').single['done'], true);
    await tester.tap(find.text('Terminées'));
    await tester.pumpAndSettle();
    expect(find.text('Relancer Alex vendredi'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    app.auth.dispose();
  });
  testWidgets('chat : modèle personnalisé, signature et envoi confirmé', (
    tester,
  ) async {
    final app = await setup(tester, '/recruiter/messages');
    await app.studio.save('signature', 'Camille · Joyn');
    await app.studio.setPreference('useSignature', true);
    await app.studio.upsert('templates', {
      'id': 'template-1',
      'title': 'Mon introduction',
      'text': 'Bonjour {prenom}, parlons de votre projet.',
    });
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alex Dupont'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Réponses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mon introduction'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller!.text,
      'Bonjour Alex, parlons de votre projet.',
    );
    await tester.tap(find.byTooltip('Envoyer le message'));
    await tester.pumpAndSettle();
    final workspace = tester
        .element(find.byType(MaterialApp))
        .read<WorkspaceController>();
    expect(
      (await workspace.repository.messages('c1')).last['text'],
      'Bonjour Alex, parlons de votre projet.\n\nCamille · Joyn',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller!.text,
      isEmpty,
    );
    await tester.pumpWidget(const SizedBox());
    app.auth.dispose();
  });
  testWidgets(
    'profil : une navigation demande de traiter les changements non enregistrés',
    (tester) async {
      final app = await setup(tester, '/recruiter/profile');
      await tester.enterText(find.byType(TextFormField).first, 'Idris');
      await tester.pump();
      app.router.go('/recruiter/settings');
      await tester.pumpAndSettle();
      expect(find.text('Quitter sans enregistrer ?'), findsOneWidget);
      await tester.tap(find.text('Annuler').last);
      await tester.pumpAndSettle();
      expect(
        app.router.routeInformationProvider.value.uri.path,
        '/recruiter/profile',
      );
      await tester.ensureVisible(find.text('Enregistrer le profil'));
      await tester.tap(find.text('Enregistrer le profil'));
      await tester.pumpAndSettle();
      final workspace = tester
          .element(find.byType(MaterialApp))
          .read<WorkspaceController>();
      expect(workspace.profile!['firstName'], 'Idris');
      expect(workspace.profileDirty, false);
      await tester.pumpWidget(const SizedBox());
      app.auth.dispose();
    },
  );
  testWidgets('recherche globale : ouvrir le centre de travail', (
    tester,
  ) async {
    final app = await setup(tester, '/recruiter/profile');
    await tester.tap(find.byTooltip('Rechercher dans le studio'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'centre de travail');
    await tester.pump();
    await tester.tap(find.text('Centre de travail'));
    await tester.pumpAndSettle();
    expect(
      app.router.routeInformationProvider.value.uri.path,
      '/recruiter/planner',
    );
    await tester.pumpWidget(const SizedBox());
    app.auth.dispose();
  });
}
