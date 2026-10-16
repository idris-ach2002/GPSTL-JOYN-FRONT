// Choisit un contenu mobile, tablette ou ordinateur selon la largeur disponible.
//
// Référence : doc/landing/fichiers/responsive_layout.md.

import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

/// Composition de trois variantes de contenu selon les contraintes de largeur.
class ResponsiveLayout extends StatelessWidget {
  /// Initialise les paramètres de ResponsiveLayout ; les valeurs par défaut figurent dans la signature.
  const ResponsiveLayout({
    required this.mobile,
    required this.tablet,
    required this.desktop,
    super.key,
  });

  /// Seuil ou contenu de la variante mobile, selon la déclaration.
  final Widget mobile;

  /// Seuil ou contenu de la variante tablette, selon la déclaration.
  final Widget tablet;

  /// Seuil ou contenu de la variante ordinateur, selon la déclaration.
  final Widget desktop;

  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return mobile;
        }

        if (constraints.maxWidth < AppBreakpoints.tablet) {
          return tablet;
        }

        return desktop;
      },
    );
  }
}
