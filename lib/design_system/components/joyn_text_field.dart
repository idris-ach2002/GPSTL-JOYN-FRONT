import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_fonts.dart';
import 'joyn_field_message.dart';

/// Champ de saisie Joyn : libellé au-dessus, message d'aide ou d'erreur dessous.
class JoynTextField extends StatelessWidget {
  const JoynTextField({
    required this.label,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.hintText,
    this.labelSuffix,
    this.labelTrailing,
    this.errorText,
    this.helper,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.letterSpacing,
    this.trailingAction,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final String? hintText;

  /// Précision discrète après le libellé, par exemple « (facultatif) ».
  final String? labelSuffix;

  /// Action alignée à droite du libellé, par exemple « Retirer ».
  final Widget? labelTrailing;

  /// Quand il est renseigné, le champ passe en état d'erreur.
  final String? errorText;

  /// Contenu affiché sous le champ (astuce, jauge…).
  final Widget? helper;

  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final double? letterSpacing;

  /// Bouton placé à droite du champ (par exemple « Rechercher »).
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    OutlineInputBorder border(Color color, [double width = 1.5]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label,
                  children: [
                    if (labelSuffix != null)
                      TextSpan(
                        text: ' $labelSuffix',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate,
                        ),
                      ),
                  ],
                ),
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ?labelTrailing,
          ],
        ),
        const SizedBox(height: 7),
        _withTrailingAction(
          TextField(
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            autofocus: autofocus,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            cursorColor: AppColors.navy,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 15,
              color: AppColors.textPrimary,
              letterSpacing: letterSpacing,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 15,
                color: AppColors.placeholder,
                letterSpacing: 0,
              ),
              filled: true,
              fillColor: hasError ? AppColors.errorTint : AppColors.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              prefixIcon: prefixIcon == null
                  ? null
                  : Icon(prefixIcon, size: 20, color: AppColors.slate),
              suffixIcon: suffix,
              border: border(AppColors.line),
              enabledBorder: border(hasError ? AppColors.error : AppColors.line),
              focusedBorder: border(
                hasError ? AppColors.error : AppColors.navy,
                2,
              ),
            ),
          ),
        ),
        if (helper != null) ...[const SizedBox(height: 8), helper!],
        if (hasError) ...[
          const SizedBox(height: 7),
          JoynFieldMessage.error(errorText!),
        ],
      ],
    );
  }

  Widget _withTrailingAction(Widget field) {
    final action = trailingAction;
    if (action == null) return field;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: field),
        const SizedBox(width: 8),
        action,
      ],
    );
  }
}
