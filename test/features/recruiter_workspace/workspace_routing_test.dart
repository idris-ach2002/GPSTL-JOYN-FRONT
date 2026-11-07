import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:joyn_front/app/app.dart';
import 'package:joyn_front/features/auth/data/fake_auth_repository.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';
import 'package:joyn_front/features/recruiter_workspace/presentation/workspace_screen.dart';

void main() {
  for (final web in [true, false]) {
    testWidgets('routes recruteur et déconnexion : web=$web', (tester) async {
      tester.view.physicalSize = Size(web ? 1440 : 390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final auth = AuthController(FakeAuthRepository(latency: Duration.zero));
      await tester.runAsync(
        () => auth.signIn(email: 'recruteur@joyn.fr', password: 'Joyn2026'),
      );
      await tester.pumpWidget(JoynApp(webOverride: web, authController: auth));
      await tester.pump();
      final router =
          tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig!
              as GoRouter;
      for (final section in [
        'profile',
        'notifications',
        'messages',
        'settings',
      ]) {
        router.go('/recruiter/$section');
        await tester.pumpAndSettle();
        expect(find.byType(RecruiterWorkspaceScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      await auth.signOut();
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/login');
      await tester.pumpWidget(const SizedBox());
      auth.dispose();
    });
  }
}
