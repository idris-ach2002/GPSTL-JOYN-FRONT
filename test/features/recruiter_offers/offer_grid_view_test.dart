import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/recruiter_offers/data/mock_recruiter_offers_repository.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/controllers/offer_management_controller.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/web/recruiter_offers_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('web : bascule liste grille sans overflow', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = MockRecruiterOffersRepository(latency: Duration.zero);
    final controller = OfferManagementController(repository);
    await controller.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: WebRecruiterOffersScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 260));

    expect(find.byKey(const ValueKey('offers-list-layout')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('offers-view-grid')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('offers-grid-layout')), findsOneWidget);
    expect(find.byKey(const ValueKey('offer-grid-card-1')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('offers-view-list')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('offers-list-layout')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
