import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:joyn_front/app/app.dart';
import 'package:joyn_front/features/admin/presentation/shared/admin_forbidden_screen.dart';
import 'package:joyn_front/features/admin_users/domain/user_query.dart';
import 'package:joyn_front/features/admin_users/presentation/controllers/admin_users_controller.dart';
import 'package:joyn_front/features/admin_users/presentation/web/admin_users_screen.dart';
import 'package:joyn_front/features/auth/data/fake_auth_repository.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';
import 'package:provider/provider.dart';

Future<void> _open(WidgetTester tester, String? email, String location) async {
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
  GoRouter.of(tester.element(find.byType(Navigator).first)).go(location);
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('un admin ouvre la page Utilisateurs', (tester) async {
    // Le compte admin est le plus ancien : on le cherche par son e-mail.
    await _open(tester, 'admin@joyn.fr', '/admin/users?q=admin@joyn.fr');
    expect(find.byType(AdminUsersScreen), findsOneWidget);
    expect(find.text('Équipe Joyn (vous)'), findsOneWidget);
  });

  testWidgets('les filtres de l’URL sont repris au chargement', (tester) async {
    await _open(
      tester,
      'admin@joyn.fr',
      '/admin/users?role=recruiter&status=suspended',
    );
    final controller = Provider.of<AdminUsersController>(
      tester.element(find.byType(AdminUsersScreen)),
      listen: false,
    );
    expect(controller.query.role, UserRoleFilter.recruiter);
    expect(controller.query.status, UserStatusFilter.suspended);
  });

  testWidgets('un recruteur voit la page 403', (tester) async {
    await _open(tester, 'recruteur@joyn.fr', '/admin/users');
    expect(find.byType(AdminUsersScreen), findsNothing);
    expect(find.byType(AdminForbiddenScreen), findsOneWidget);
  });

  testWidgets('un visiteur est renvoyé vers la connexion', (tester) async {
    await _open(tester, null, '/admin/users');
    expect(find.byType(AdminUsersScreen), findsNothing);
  });
}
