import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:joyn_front/app/app.dart';
import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/features/admin_companies/presentation/shared/admin_forbidden_screen.dart';
import 'package:joyn_front/features/admin_companies/presentation/web/admin_companies_screen.dart';
import 'package:joyn_front/features/auth/data/fake_auth_repository.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';

Future<void> _openAdminAs(WidgetTester tester, String? email) async {
  tester.view
    ..physicalSize = const Size(1440, 1000)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final auth = AuthController(FakeAuthRepository(latency: Duration.zero));
  if (email != null) {
    await tester.runAsync(
      () =>
          auth.signIn(email: email, password: FakeAuthRepository.demoPassword),
    );
  }
  addTearDown(auth.dispose);

  await tester.pumpWidget(JoynApp(authController: auth, webOverride: true));
  await tester.pump();

  GoRouter.of(tester.element(find.byType(Navigator).first))
      .go(AppRoutes.adminCompanies);
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('un admin accède à la gestion des entreprises', (tester) async {
    await _openAdminAs(tester, 'admin@joyn.fr');
    expect(find.byType(AdminCompaniesScreen), findsOneWidget);
    expect(find.text('Entreprises'), findsWidgets);
  });

  testWidgets('un recruteur voit la page 403', (tester) async {
    await _openAdminAs(tester, 'recruteur@joyn.fr');
    expect(find.byType(AdminCompaniesScreen), findsNothing);
    expect(find.byType(AdminForbiddenScreen), findsOneWidget);
  });

  testWidgets('un·e étudiant·e voit la page 403', (tester) async {
    await _openAdminAs(tester, 'etudiant@joyn.fr');
    expect(find.byType(AdminForbiddenScreen), findsOneWidget);
  });

  testWidgets('un visiteur est renvoyé vers la connexion', (tester) async {
    await _openAdminAs(tester, null);
    expect(find.byType(AdminCompaniesScreen), findsNothing);
    expect(find.byType(AdminForbiddenScreen), findsNothing);
  });
}
