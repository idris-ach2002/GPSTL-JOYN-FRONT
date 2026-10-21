import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/app/app.dart';
import 'package:joyn_front/features/auth/presentation/mobile/mobile_login_screen.dart';
import 'package:joyn_front/features/landing/presentation/screens/landing_screen.dart';
import 'package:joyn_front/features/registration/presentation/mobile/mobile_register_choice_screen.dart';
import 'package:joyn_front/features/registration/presentation/mobile/mobile_student_register_screen.dart';
import 'package:joyn_front/features/startup/mobile_startup_screen.dart';

void main() {
  testWidgets('mobile : startup puis connexion native puis inscription native', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const JoynApp(webOverride: false));

    expect(find.byType(MobileStartupScreen), findsOneWidget);
    expect(find.byType(LandingScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

        expect(find.byType(MobileLoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    final createAccount = find.byKey(
      const ValueKey('mobile-create-account'),
    );
    await tester.ensureVisible(createAccount);
    await tester.tap(createAccount);
    await tester.pumpAndSettle();

        expect(find.byType(MobileRegisterChoiceScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile : la connexion reste lisible sur 320 px', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const JoynApp(webOverride: false));
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    expect(find.byType(MobileLoginScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('mobile-login-email')), findsOneWidget);
    expect(find.byKey(const ValueKey('mobile-login-password')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('mobile : le choix candidat ouvre l'inscription native', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const JoynApp(webOverride: false));
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    final createAccount = find.byKey(const ValueKey('mobile-create-account'));
    await tester.ensureVisible(createAccount);
    await tester.tap(createAccount);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('mobile-register-student')));
    await tester.pumpAndSettle();

    expect(find.byType(MobileStudentRegisterScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}
