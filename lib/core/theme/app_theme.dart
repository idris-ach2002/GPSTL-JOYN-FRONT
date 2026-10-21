import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_text_styles.dart';

/// Thème Material global de Joyn.
abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      primary: AppColors.navy,
      onPrimary: Colors.white,
      secondary: AppColors.coral,
      onSecondary: Colors.white,
      error: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
    );
    final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTextStyles.textTheme(base.textTheme),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      // Boutons secondaires (ex. connexion Google / LinkedIn).
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      // Liens textuels (« Mot de passe oublié ? », « Créer un compte »).
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? AppColors.navy : null,
        ),
        side: const BorderSide(color: AppColors.textMuted, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
      ),
    );
  }

  /// Décoration standard des champs de saisie Joyn.
  ///
  /// Utilisée par `JoynTextField` ; peut aussi servir pour tout autre champ.
  static InputDecoration inputDecoration({
    String? hintText,
    String? helperText,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hintText,
      helperText: helperText,
      helperMaxLines: 2,
      errorMaxLines: 2,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 15),
      helperStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 16,
      ),
      suffixIcon: suffixIcon,
      suffixIconColor: AppColors.ink,
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.navy, 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 1.5),
    );
  }
}
