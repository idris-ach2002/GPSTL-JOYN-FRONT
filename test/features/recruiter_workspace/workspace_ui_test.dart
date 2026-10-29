import 'package:joyn_front/features/recruiter_studio/presentation/studio_controller.dart';
import 'package:joyn_front/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:joyn_front/features/auth/data/fake_auth_repository.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';
import 'package:joyn_front/features/recruiter_workspace/data/recruiter_workspace_repository.dart';
import 'package:joyn_front/features/recruiter_workspace/presentation/workspace_controller.dart';
import 'package:joyn_front/features/recruiter_workspace/presentation/workspace_screen.dart';

void main() {
  for (final width in [320.0, 390.0, 1440.0]) {
    for (final section in [
      'profile',
      'settings',
      'notifications',
      'messages',
    ]) {
      testWidgets('$section : écran sans overflow à $width px', (tester) async {
        tester.view.physicalSize = Size(width, 850);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final auth = AuthController(FakeAuthRepository(latency: Duration.zero));
        await tester.runAsync(
          () => auth.signIn(email: 'recruteur@joyn.fr', password: 'Joyn2026'),
        );
        final studio = StudioController();
        await studio.bind('demo-company');
        final c = WorkspaceController(MockRecruiterWorkspaceRepository());
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, state) => RecruiterWorkspaceScreen(section: section),
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
            child: MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (section == 'messages') {
          await tester.tap(find.text('Alex Dupont'));
          await tester.pumpAndSettle();
          expect(
            find.text('Bonjour, je suis disponible pour un échange jeudi.'),
            findsWidgets,
          );
          await tester.enterText(find.byType(TextField).last, 'Bonjour Alex !');
          await tester.pump();
          await tester.tap(find.byTooltip('Envoyer le message'));
          await tester.pumpAndSettle();
          expect(find.text('Bonjour Alex !'), findsWidgets);
          expect(
            tester
                .widget<TextField>(find.byType(TextField).last)
                .controller!
                .text,
            isEmpty,
          );
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
        router.dispose();
        c.dispose();
        auth.dispose();
        studio.dispose();
      });
    }
  }
}
