import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/admin_companies/data/fake_admin_company_repository.dart';
import 'package:joyn_front/features/admin_companies/presentation/controllers/admin_companies_controller.dart';
import 'package:joyn_front/features/admin_companies/presentation/mobile/mobile_admin_companies_screen.dart';
import 'package:provider/provider.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('mobile : liste des entreprises sans débordement', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final controller = AdminCompaniesController(
      FakeAdminCompanyRepository(latency: Duration.zero),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller..load(),
        child: const MaterialApp(home: MobileAdminCompaniesScreen()),
      ),
    );
    await _settle(tester);

    expect(find.text('Entreprises'), findsOneWidget);
    expect(find.text('Ajouter'), findsOneWidget);
    expect(tester.takeException(), isNull);

    expect(find.text('Exporter en CSV'), findsOneWidget);
    final pendingMenu = find.byKey(const ValueKey('menu-cmp-3'));
    await tester.ensureVisible(pendingMenu);
    await tester.pump();
    await tester.tap(pendingMenu);
    await _settle(tester);
    expect(find.text('Valider'), findsNothing);
    expect(find.text('Rejeter'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
