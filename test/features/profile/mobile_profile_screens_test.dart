import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/profile/data/fake_profile_repository.dart';
import 'package:joyn_front/features/profile/data/profile_repository.dart';
import 'package:joyn_front/features/profile/presentation/mobile/mobile_profile_edit_screen.dart';
import 'package:joyn_front/features/profile/presentation/mobile/mobile_profile_screen.dart';
import 'package:provider/provider.dart';

Future<void> _pumpMobile(WidgetTester tester, Widget screen) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    Provider<ProfileRepository>.value(
      value: FakeProfileRepository(latency: Duration.zero),
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mobile : le profil s’affiche sans débordement', (tester) async {
    await _pumpMobile(tester, const MobileProfileScreen());

    expect(find.text('Mon profil'), findsOneWidget);
    expect(find.text('Benatsi Ariel'), findsOneWidget);
    expect(find.text('Présentation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile : la modification du profil s’affiche', (tester) async {
    await _pumpMobile(tester, const MobileProfileEditScreen());

    expect(find.text('Modifier mon profil'), findsOneWidget);
    expect(find.text('Photo et identité'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile : modifier le titre affiche « Annuler »', (tester) async {
    await _pumpMobile(tester, const MobileProfileEditScreen());
    expect(find.text('Annuler'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('profile-headline')),
      'Développeuse mobile',
    );
    await tester.pump();

    expect(find.text('Annuler'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
