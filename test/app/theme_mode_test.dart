import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/app/app.dart';
import 'package:joyn_front/features/auth/domain/user_role.dart';
import 'package:joyn_front/features/auth/presentation/web/login_page.dart';

void main() {
  test('hors espace recruteur, le thème reste clair même si le système est '
      'en sombre', () {
    expect(themeModeFor(null, ThemeMode.system), ThemeMode.light);
    expect(themeModeFor(UserRole.student, ThemeMode.dark), ThemeMode.light);
  });

  test('le recruteur garde le thème choisi dans le studio', () {
    expect(themeModeFor(UserRole.company, ThemeMode.dark), ThemeMode.dark);
    expect(themeModeFor(UserRole.company, ThemeMode.system), ThemeMode.system);
  });

  // Régression : sur un système en mode sombre, la page de connexion
  // affichait du texte quasi blanc sur fond blanc.
  testWidgets('la connexion reste en thème clair sur un système sombre', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const JoynApp(webOverride: true));
    await tester.pump();
    await tester.tap(find.text('Connexion').first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final context = tester.element(find.byType(LoginPage));
    expect(Theme.of(context).brightness, Brightness.light);
    await tester.pumpWidget(const SizedBox());
  });
}
