import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:joyn_front/app/app.dart';
import 'package:joyn_front/features/auth/data/fake_auth_repository.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';
import 'package:joyn_front/features/recruiter_studio/data/studio_store.dart';
import 'package:joyn_front/features/recruiter_studio/presentation/studio_controller.dart';
import 'package:joyn_front/features/recruiter_studio/presentation/studio_settings.dart';

void main() {
  for (final width in [320.0, 390.0, 768.0, 1440.0]) {
    for (final dark in [false, true]) {
      testWidgets('studio entier · $width px · sombre=$dark', (tester) async {
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
        final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        final router = app.routerConfig! as GoRouter;
        final studio = tester
            .element(find.byType(MaterialApp))
            .read<StudioController>();
        await studio.setPreference('theme', dark ? 'dark' : 'light');
        for (final route in [
          '/recruiter/profile',
          '/recruiter/notifications',
          '/recruiter/messages',
          '/recruiter/settings',
          '/recruiter/planner',
          '/recruiter/compare',
          '/recruiter/dashboard',
          '/recruiter/jobs',
          '/recruiter/candidates',
        ]) {
          router.go(route);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 800));
          expect(tester.takeException(), isNull, reason: route);
        }
        router.go('/recruiter/settings');
        await tester.pumpAndSettle();
        expect(find.byType(StudioSettings), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        auth.dispose();
      });
    }
  }
}
