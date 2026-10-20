import 'package:flutter/material.dart';

import '../../design_system/tokens/app_colors.dart';

/// Thème Material 3 commun aux écrans web et natifs.
///
/// Les rôles sont fixés explicitement : une palette calculée depuis une seed
/// introduirait des teintes absentes de la charte JOYN.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
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
        foregroundColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
            ? AppColors.white : AppColors.navy),
        backgroundColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
            ? AppColors.navy : AppColors.white),
      ),
    ),
  );
}
