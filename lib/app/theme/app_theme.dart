import 'package:flutter/material.dart';

import '../../design_system/tokens/app_colors.dart';

/// Thème Material 3 commun aux écrans web et natifs.
///
/// Les rôles sont fixés explicitement : une palette calculée depuis une seed
/// introduirait des teintes absentes de la charte JOYN.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.light(
      primary: AppColors.navy,
      onPrimary: AppColors.white,
      secondary: AppColors.orange,
      onSecondary: AppColors.white,
      tertiary: AppColors.blue,
      onTertiary: AppColors.navy,
      surface: AppColors.white,
      onSurface: AppColors.navy,
      surfaceDim: AppColors.background,
      surfaceBright: AppColors.white,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.background,
      surfaceContainer: AppColors.background,
      surfaceContainerHigh: AppColors.background,
      surfaceContainerHighest: AppColors.background,
      onSurfaceVariant: AppColors.blueGreyDark,
      outline: AppColors.grey,
      outlineVariant: AppColors.greyLight,
      error: AppColors.error,
      onError: AppColors.white,
      inverseSurface: AppColors.navy,
      onInverseSurface: AppColors.white,
      inversePrimary: AppColors.blue,
      shadow: AppColors.navy,
      scrim: AppColors.navy,
      surfaceTint: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: AppColors.white,
      surfaceTintColor: AppColors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      filled: true,
      fillColor: AppColors.white,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.white
              : AppColors.navy,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.navy
              : AppColors.white,
        ),
      ),
    ),
  );
}

/// Couleurs sémantiques du studio : surfaces, texte et bordures se répondent.
abstract final class RecruiterTheme {
  static ThemeData build({
    required bool dark,
    required Color accent,
    bool compact = false,
    bool contrast = false,
  }) {
    final scheme = dark
        ? ColorScheme.dark(
            primary: accent,
            onPrimary: const Color(0xFF071321),
            secondary: const Color(0xFF7FCFC1),
            surface: const Color(0xFF142237),
            onSurface: const Color(0xFFEBF2FC),
            onSurfaceVariant: const Color(0xFFB2C1D7),
            outline: contrast ? Colors.white70 : const Color(0xFF63758E),
            outlineVariant: const Color(0xFF2B405B),
            surfaceContainerLow: const Color(0xFF101D2F),
            surfaceContainerHighest: const Color(0xFF213650),
            error: const Color(0xFFFF9D96),
          )
        : AppTheme.light.colorScheme.copyWith(
            primary: accent,
            onPrimary: Colors.white,
            outlineVariant: const Color(0xFFDDE5EF),
          );
    return AppTheme.light.copyWith(
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF0B1525)
          : const Color(0xFFF2F5F9),
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      textTheme: AppTheme.light.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      dividerColor: scheme.outlineVariant,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: accent.withValues(alpha: .2),
      ),
      chipTheme: AppTheme.light.chipTheme.copyWith(
        backgroundColor: scheme.surface,
        selectedColor: accent.withValues(alpha: .18),
        labelStyle: TextStyle(color: scheme.onSurface),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? scheme.onPrimary
                : scheme.onSurface,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? accent : scheme.surface,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent
              : scheme.surfaceContainerHighest,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
