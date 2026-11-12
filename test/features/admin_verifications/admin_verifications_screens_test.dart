import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:joyn_front/app/app.dart';
import 'package:joyn_front/features/admin/presentation/shared/admin_forbidden_screen.dart';
import 'package:joyn_front/features/admin_verifications/data/fake_verification_repository.dart';
import 'package:joyn_front/features/admin_verifications/presentation/controllers/admin_verifications_controller.dart';
import 'package:joyn_front/features/admin_verifications/presentation/mobile/mobile_admin_verifications_screen.dart';
import 'package:joyn_front/features/admin_verifications/presentation/web/admin_verifications_screen.dart';
import 'package:joyn_front/features/auth/data/fake_auth_repository.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';
import 'package:provider/provider.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _open(WidgetTester tester, String email) async {
  tester.view
    ..physicalSize = const Size(1440, 1000)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final auth = AuthController(FakeAuthRepository(latency: Duration.zero));
  await tester.runAsync(
    () => auth.signIn(email: email, password: FakeAuthRepository.demoPassword),
  );
  addTearDown(auth.dispose);

  await tester.pumpWidget(JoynApp(authController: auth, webOverride: true));
  await tester.pump();
  GoRouter.of(tester.element(find.byType(Navigator).first))
      .go('/admin/verifications');
  await _settle(tester);
}

void main() {
  testWidgets('web : un admin voit la file et le détail', (tester) async {
    await _open(tester, 'admin@joyn.fr');
    expect(find.byType(AdminVerificationsScreen), findsOneWidget);
    // Barre latérale : uniquement les rubriques existantes.
    expect(find.text('Vérifications'), findsWidgets);
    expect(find.text('Modération'), findsNothing);
    expect(find.text('Revenus'), findsNothing);
    // Détail de la première demande et ses actions.
    expect(find.text('Valider manuellement'), findsOneWidget);
    expect(find.text('Relancer la vérification'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('web : un recruteur voit la page 403', (tester) async {
    await _open(tester, 'recruteur@joyn.fr');
    expect(find.byType(AdminForbiddenScreen), findsOneWidget);
  });

  testWidgets('mobile : file et détail sans débordement', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final controller = AdminVerificationsController(
      FakeVerificationRepository(latency: Duration.zero),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller..load(),
        child: const MaterialApp(home: MobileAdminVerificationsScreen()),
      ),
    );
    await _settle(tester);
    expect(find.text('Vérifications'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('verification-ver-1')));
    await _settle(tester);
    expect(find.text('Valider manuellement'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
