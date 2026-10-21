import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_fonts.dart';

enum JoynButtonVariant {
  /// Bleu nuit, texte blanc : action principale d'un écran.
  primary,

  /// Orange, texte bleu nuit : action qui fait avancer l'inscription.
  accent,

  /// Contour blanc, pour les fonds bleu nuit.
  outlineOnDark,

  /// Contour gris, pour les fonds clairs.
  outline,
}

/// Bouton pilule du design system Joyn.
class JoynButton extends StatelessWidget {
  const JoynButton({
    required this.label,
    required this.onPressed,
    this.variant = JoynButtonVariant.primary,
    this.leadingIcon,
    this.trailingIcon,
    this.height = 52,
    this.fontSize = 16,
    this.expand = false,
    this.isLoading = false,
    this.borderRadius,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final JoynButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double height;
  final double fontSize;

  /// Occupe toute la largeur disponible.
  final bool expand;

  /// Affiche un indicateur à la place du libellé et bloque les appuis.
  final bool isLoading;

  /// Rayon des coins. Par défaut, le bouton est une pilule.
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, side, shadow) = switch (variant) {
      JoynButtonVariant.primary => (
        AppColors.navy,
        AppColors.white,
        BorderSide.none,
        const [
          BoxShadow(
            color: Color(0x40001E3B),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      JoynButtonVariant.accent => (
        AppColors.orange,
        AppColors.textPrimary,
        BorderSide.none,
        const [
          BoxShadow(
            color: Color(0x5CFF6731),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      JoynButtonVariant.outlineOnDark => (
        Colors.transparent,
        AppColors.white,
        const BorderSide(color: Color(0x59FFFFFF)),
        const <BoxShadow>[],
      ),
      JoynButtonVariant.outline => (
        AppColors.surface,
        AppColors.textPrimary,
        const BorderSide(color: AppColors.line, width: 1.5),
        const <BoxShadow>[],
      ),
    };

    final iconSize = fontSize + 2;
    final content = isLoading
        ? SizedBox.square(
            dimension: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: iconSize, color: foreground),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize,
                    color: foreground,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 10),
                Icon(trailingIcon, size: iconSize, color: foreground),
              ],
            ],
          );

    final button = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? height),
        boxShadow: onPressed == null ? null : shadow,
      ),
      child: Material(
        color: background,
        shape: borderRadius == null
            ? StadiumBorder(side: side)
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius!),
                side: side,
              ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.48),
              child: Center(widthFactor: 1, child: content),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: isLoading ? '$label, en cours' : null,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
