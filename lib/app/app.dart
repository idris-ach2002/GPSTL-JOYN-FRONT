import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../features/auth/presentation/auth_screen.dart';
import '../features/landing/presentation/screens/landing_screen.dart';
import '../features/startup/mobile_startup_screen.dart';
import '../features/information/domain/information_content.dart';
import '../features/information/presentation/information_screen.dart';
import 'theme/app_theme.dart';

/// L'entrée dépend de la plateforme, jamais de la largeur de fenêtre.
/// Un navigateur étroit conserve la landing ; Android/iOS ouvrent l'app.
class JoynApp extends StatelessWidget {
  const JoynApp({super.key, this.webOverride});

  /// Point d'injection des tests pour vérifier les deux parcours sans émulateur.
  final bool? webOverride;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'JOYN — Le match avant la candidature',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    initialRoute: '/',
    routes: {
      '/': (_) => (webOverride ?? kIsWeb)
          ? const LandingScreen()
          : const MobileStartupScreen(),
      '/connexion': (_) => const AuthScreen(),
      '/inscription': (_) => const AuthScreen(registration: true),
      for (final entry in informationPages.entries)
        entry.key: (_) => InformationScreen(page: entry.value),
    },
  );
}
