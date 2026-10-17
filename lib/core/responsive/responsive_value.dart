// Sélectionne une valeur typée à partir de la largeur fournie par MediaQuery.
//
// Référence : doc/landing.md#responsive_valuedart.

import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

/// Retourne la variante mobile, tablette ou ordinateur du type demandé.
T responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  required T tablet,
  required T desktop,
}) {
  // Largeur disponible ou calculée pour cette composition.
  final width = MediaQuery.sizeOf(context).width;

  if (width < AppBreakpoints.mobile) {
    return mobile;
  }

  if (width < AppBreakpoints.tablet) {
    return tablet;
  }

  return desktop;
}
