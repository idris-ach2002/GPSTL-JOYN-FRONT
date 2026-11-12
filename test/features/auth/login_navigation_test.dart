import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/app/app.dart';
import 'package:joyn_front/features/auth/data/fake_auth_repository.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';
import 'package:joyn_front/features/auth/presentation/web/login_page.dart';
import 'package:joyn_front/features/dashboard/data/fake_dashboard_repository.dart';
import 'package:joyn_front/features/dashboard/presentation/web/dashboard_page.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

void main() {
  // Régression : la connexion ouverte depuis la landing (via `push`) restait
  // bloquée sur la page malgré des identifiants valides.
  testWidgets('Connexion depuis la landing ouvre le dashboard', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthController(FakeAuthRepository(latency: Duration.zero));
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      JoynApp(
        webOverride: true,
        authController: auth,
        dashboardRepository: FakeDashboardRepository(latency: Duration.zero),
      ),
    );
    await settle(tester);

    await tester.tap(find.text('Connexion').first);
    await settle(tester);
    expect(find.byType(LoginPage), findsOneWidget);

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'etudiant@joyn.fr');
    await tester.enterText(fields.at(1), FakeAuthRepository.demoPassword);
    await tester.tap(find.text('Se connecter'));
    await settle(tester);
    // Laisse le dashboard terminer son chargement.
    await settle(tester);

    expect(auth.isAuthenticated, isTrue);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(DashboardPage), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
