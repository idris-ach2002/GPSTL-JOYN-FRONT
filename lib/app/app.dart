// Configure l’application Material, son thème et son routeur.
//
// Référence : doc/landing/fichiers/app.md.

import 'package:flutter/material.dart';

import 'routing/app_router.dart';
import 'theme/app_theme.dart';
/// Point d’entrée visuel de JOYN ; relie MaterialApp au thème et au routeur.
class JoynApp extends StatelessWidget {
  /// Initialise les paramètres de JoynApp ; les valeurs par défaut figurent dans la signature.
  const JoynApp({super.key});
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JOYN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
