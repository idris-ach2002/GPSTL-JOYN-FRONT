import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/admin_users/data/fake_admin_user_repository.dart';
import 'package:joyn_front/features/admin_users/domain/user_query.dart';
import 'package:joyn_front/features/admin_users/presentation/controllers/admin_users_controller.dart';
import 'package:joyn_front/features/admin_users/presentation/mobile/mobile_admin_users_screen.dart';
import 'package:provider/provider.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('mobile : liste et détail sans débordement', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final controller = AdminUsersController(
      FakeAdminUserRepository(latency: Duration.zero),
      currentUserId: 'demo-admin',
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(
          home: MobileAdminUsersScreen(urlQuery: UserQuery()),
        ),
      ),
    );
    await _settle(tester);

    final rows = find.byWidgetPredicate(
      (widget) =>
          widget is InkWell &&
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith('user-card-'),
    );
    expect(find.text('Utilisateurs'), findsOneWidget);
    expect(rows, findsWidgets);
    expect(find.byTooltip('Ajouter un admin'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Ouvrir le détail du premier compte.
    await tester.tap(rows.first);
    await _settle(tester);
    expect(find.text('Détail du compte'), findsOneWidget);
    expect(find.text('Journal de modération'.toUpperCase()), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
