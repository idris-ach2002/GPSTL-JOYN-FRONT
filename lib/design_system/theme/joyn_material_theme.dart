import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_fonts.dart';

/// Thème Material 3 aux couleurs et polices JOYN, pour les parcours
/// d'inscription et d'onboarding.
///
/// Il complète le thème global ([AppTheme.light]) sans le modifier :
/// [JoynMaterialScope] l'applique localement. Pour l'étendre à toute l'app,
/// il suffira d'appeler [JoynMaterialTheme.apply] dans `AppTheme.light`.
abstract final class JoynMaterialTheme {
  static ThemeData apply(ThemeData base) {
    final colorScheme = base.colorScheme.copyWith(
      primary: AppColors.navy,
      onPrimary: AppColors.white,
      secondary: AppColors.orange,
      onSecondary: AppColors.textPrimary,
      tertiary: AppColors.cyanBlue,
      error: AppColors.errorDeep,
      onError: AppColors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.slate,
      outline: AppColors.line,
      outlineVariant: AppColors.lineSoft,
      secondaryContainer: AppColors.skyTint,
      onSecondaryContainer: AppColors.navy,
    );
    final textTheme = _textTheme(base.textTheme);

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    /// Texte saisi dans les champs (TextField l'hérite de bodyLarge).
    final fieldText = textTheme.bodyLarge?.copyWith(fontSize: 15, height: 1.3);

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.track,
          disabledForegroundColor: AppColors.placeholder,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 26),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.line, width: 1.5),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.navy,
          minimumSize: const Size(48, 40),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: border(AppColors.line),
        enabledBorder: border(AppColors.line),
        focusedBorder: border(AppColors.navy, 1.6),
        errorBorder: border(AppColors.errorDeep),
        focusedErrorBorder: border(AppColors.errorDeep, 1.6),
        disabledBorder: border(AppColors.lineSoft),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.navy,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.placeholder),
        helperStyle: textTheme.bodySmall?.copyWith(fontSize: 12.5),
        helperMaxLines: 3,
        errorStyle: textTheme.bodySmall?.copyWith(
          fontSize: 12.5,
          color: AppColors.errorDeep,
          fontWeight: FontWeight.w600,
        ),
        errorMaxLines: 3,
        prefixIconColor: AppColors.slate,
        suffixIconColor: AppColors.slate,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 42,
          minHeight: 40,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 42,
          minHeight: 40,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: fieldText,
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.navy,
        disabledColor: AppColors.background,
        checkmarkColor: AppColors.white,
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: const StadiumBorder(),
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected)
                ? AppColors.navy
                : AppColors.line,
            width: 1.5,
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.navy
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.white),
        side: const BorderSide(color: AppColors.placeholder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.navy,
        inactiveTrackColor: AppColors.track,
        thumbColor: AppColors.navy,
        overlayColor: AppColors.navy.withValues(alpha: 0.12),
        valueIndicatorColor: AppColors.navy,
        valueIndicatorTextStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.white,
        ),
        trackHeight: 6,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(textTheme.labelMedium),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.white
                : AppColors.slateDark,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.navy
                : AppColors.surface,
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.line, width: 1.5),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.navy,
        linearTrackColor: AppColors.track,
        circularTrackColor: AppColors.skyMist,
        linearMinHeight: 6,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          side: BorderSide(color: AppColors.lineSoft),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.navy,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        selectedColor: AppColors.navy,
        selectedTileColor: AppColors.surface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: textTheme.titleLarge,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.track,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Bricolage Grotesque pour les titres, Instrument Sans pour le reste.
  static TextTheme _textTheme(TextTheme base) {
    final body = base.apply(
      fontFamily: AppFonts.body,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    TextStyle display(
      TextStyle? style,
      double size,
      FontWeight weight,
      double letterSpacing,
    ) {
      return (style ?? const TextStyle()).copyWith(
        fontFamily: AppFonts.display,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: 1.06,
        color: AppColors.textPrimary,
      );
    }

    TextStyle text(
      TextStyle? style,
      double size,
      FontWeight weight, {
      double height = 1.45,
      Color color = AppColors.textPrimary,
      double letterSpacing = 0,
    }) {
      return (style ?? const TextStyle()).copyWith(
        fontFamily: AppFonts.body,
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
        letterSpacing: letterSpacing,
      );
    }

    return body.copyWith(
      displayLarge: display(body.displayLarge, 64, FontWeight.w800, -3),
      displayMedium: display(body.displayMedium, 52, FontWeight.w800, -2.4),
      displaySmall: display(body.displaySmall, 42, FontWeight.w700, -1.3),
      headlineLarge: display(body.headlineLarge, 36, FontWeight.w700, -1.1),
      headlineMedium: display(body.headlineMedium, 30, FontWeight.w700, -0.9),
      headlineSmall: display(body.headlineSmall, 24, FontWeight.w700, -0.5),
      titleLarge: display(body.titleLarge, 22, FontWeight.w700, -0.4),
      titleMedium: text(body.titleMedium, 16, FontWeight.w700),
      titleSmall: text(body.titleSmall, 14, FontWeight.w700),
      bodyLarge: text(body.bodyLarge, 15, FontWeight.w400, height: 1.45),
      bodyMedium: text(body.bodyMedium, 14, FontWeight.w400),
      bodySmall: text(
        body.bodySmall,
        13,
        FontWeight.w400,
        height: 1.4,
        color: AppColors.slate,
      ),
      labelLarge: text(body.labelLarge, 15, FontWeight.w700, height: 1.2),
      labelMedium: text(body.labelMedium, 13, FontWeight.w600, height: 1.2),
      labelSmall: text(
        body.labelSmall,
        12,
        FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.4,
      ),
    );
  }
}

/// Applique [JoynMaterialTheme] au sous-arbre.
class JoynMaterialScope extends StatelessWidget {
  const JoynMaterialScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: JoynMaterialTheme.apply(Theme.of(context)),
      child: child,
    );
  }
}

/// Variantes de boutons Material au style JOYN, à combiner avec `merge`.
abstract final class JoynButtonStyles {
  /// Orange, texte bleu nuit : action qui fait avancer l'inscription.
  static final ButtonStyle accent = FilledButton.styleFrom(
    backgroundColor: AppColors.orange,
    foregroundColor: AppColors.textPrimary,
  );

  /// Grand bouton d'action principale (56 px).
  static final ButtonStyle large = FilledButton.styleFrom(
    minimumSize: const Size(64, 56),
    textStyle: const TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );

  /// Coins arrondis plutôt que pilule (barres d'actions, dialogues).
  static final ButtonStyle rounded = ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  /// Icône après le libellé (« Continuer → »).
  static const ButtonStyle trailingIcon = ButtonStyle(
    iconAlignment: IconAlignment.end,
  );

  /// Contour blanc, pour les fonds bleu nuit.
  static final ButtonStyle outlinedOnDark = OutlinedButton.styleFrom(
    foregroundColor: AppColors.white,
    backgroundColor: Colors.transparent,
    minimumSize: const Size(64, 42),
    side: const BorderSide(color: Color(0x59FFFFFF)),
  );
}

/// Indicateur de chargement à placer dans un bouton pendant un envoi.
class ButtonProgress extends StatelessWidget {
  const ButtonProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        color: DefaultTextStyle.of(context).style.color,
      ),
    );
  }
}
