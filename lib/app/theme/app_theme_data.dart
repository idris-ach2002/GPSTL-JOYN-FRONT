// Construit les styles typographiques, les couleurs et les états des contrôles.
//
// Référence : doc/landing/fichiers/app_theme_data.md.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../design_system/joyn_tokens.dart';

/// Construit le thème clair et les styles des contrôles à partir des jetons.
ThemeData buildJoynLightTheme() {
  // Base typographique Inter utilisée pour les textes de lecture.
  final body = GoogleFonts.interTextTheme().apply(
    bodyColor: JoynTokens.ink,
    displayColor: JoynTokens.ink,
  );
  TextStyle title(double size) => GoogleFonts.spaceGrotesk(
    fontSize: size,
    fontWeight: FontWeight.w700,
    height: JoynTokens.titleHeight,
    color: JoynTokens.ink,
    letterSpacing: JoynTokens.tracking,
  );
  // Hiérarchie de styles composée à partir du corps et des titres.
  final textTheme = body.copyWith(
    displayLarge: title(JoynTokens.desktopDisplay),
    displayMedium: title(JoynTokens.tabletDisplay),
    displaySmall: title(JoynTokens.mobileDisplay),
    headlineLarge: title(JoynTokens.heading),
    headlineSmall: title(JoynTokens.subheading),
    bodyLarge: body.bodyLarge?.copyWith(
      fontSize: JoynTokens.body,
      height: JoynTokens.textHeight,
    ),
    bodyMedium: body.bodyMedium?.copyWith(
      fontSize: JoynTokens.body,
      height: JoynTokens.textHeight,
    ),
    labelLarge: body.labelLarge?.copyWith(
      fontSize: JoynTokens.label,
      fontWeight: FontWeight.w700,
    ),
  );
  ButtonStyle button({required bool filled}) => ButtonStyle(
    shape: const WidgetStatePropertyAll(JoynTokens.shape),
    minimumSize: const WidgetStatePropertyAll(
      Size(JoynTokens.touch, JoynTokens.touch),
    ),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: JoynTokens.md, vertical: JoynTokens.sm),
    ),
    textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
    mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
    animationDuration: JoynTokens.instant,
    elevation: const WidgetStatePropertyAll(0),
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return JoynTokens.canvas;
      }
      if (states.contains(WidgetState.focused)) {
        return filled ? JoynTokens.paper : JoynTokens.orange;
      }
      if (states.contains(WidgetState.pressed)) {
        return JoynTokens.orange;
      }
      if (states.contains(WidgetState.hovered)) {
        return filled ? JoynTokens.orangeLight : JoynTokens.ink;
      }
      return filled ? JoynTokens.orange : JoynTokens.paper;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return JoynTokens.muted;
      }
      if (states.contains(WidgetState.focused)) {
        return JoynTokens.ink;
      }
      if (states.contains(WidgetState.pressed)) {
        return JoynTokens.ink;
      }
      if (states.contains(WidgetState.hovered)) {
        return filled ? JoynTokens.ink : JoynTokens.paper;
      }
      return JoynTokens.ink;
    }),
    side: WidgetStateProperty.resolveWith(
      (states) => BorderSide(
        color: states.contains(WidgetState.focused) && filled
            ? JoynTokens.orange
            : JoynTokens.ink,
        width: states.contains(WidgetState.focused)
            ? JoynTokens.focusWidth
            : JoynTokens.hairline,
      ),
    ),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: JoynTokens.ink,
      onPrimary: JoynTokens.paper,
      secondary: JoynTokens.orange,
      onSecondary: JoynTokens.ink,
      surface: JoynTokens.paper,
      onSurface: JoynTokens.ink,
      error: JoynTokens.error,
    ),
    scaffoldBackgroundColor: JoynTokens.paper,
    textTheme: textTheme,
    dividerColor: JoynTokens.line,
    dividerTheme: const DividerThemeData(
      thickness: JoynTokens.hairline,
      space: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(style: button(filled: true)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: button(filled: false)),
    // Editorial button children may carry explicit ink TextStyles.
    // Keep all text-button states on light backgrounds to preserve contrast.
    textButtonTheme: TextButtonThemeData(
      style: button(filled: false).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)
              ? JoynTokens.canvas
              : JoynTokens.paper.withValues(alpha: 0),
        ),
        foregroundColor: const WidgetStatePropertyAll(JoynTokens.ink),
        overlayColor: WidgetStatePropertyAll(
          JoynTokens.ink.withValues(alpha: 0),
        ),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.focused)
                ? JoynTokens.ink
                : JoynTokens.paper.withValues(alpha: 0),
            width: JoynTokens.focusWidth,
          ),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: JoynTokens.paper,
      errorStyle: const TextStyle(
        color: JoynTokens.ink,
        fontSize: JoynTokens.label,
      ),
      contentPadding: const EdgeInsets.all(JoynTokens.sm),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(JoynTokens.radius),
        borderSide: const BorderSide(color: JoynTokens.ink),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(JoynTokens.radius),
        borderSide: const BorderSide(color: JoynTokens.ink),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(JoynTokens.radius),
        borderSide: const BorderSide(
          color: JoynTokens.ink,
          width: JoynTokens.focusWidth,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(JoynTokens.radius),
        borderSide: const BorderSide(color: JoynTokens.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(JoynTokens.radius),
        borderSide: const BorderSide(
          color: JoynTokens.error,
          width: JoynTokens.focusWidth,
        ),
      ),
    ),
    cardTheme: const CardThemeData(shape: JoynTokens.shape, elevation: 0),
    buttonTheme: const ButtonThemeData(shape: JoynTokens.shape),
    splashFactory: NoSplash.splashFactory,
  );
}
