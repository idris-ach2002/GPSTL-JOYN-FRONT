import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';

/// Champ de saisie Joyn : libellé au-dessus, champ arrondi, erreur en dessous.
///
/// À placer dans un `Form` pour profiter de la validation ([validator]).
/// Avec [isPassword], le texte est masqué et un bouton « œil » permet de
/// l'afficher.
class JoynTextField extends StatefulWidget {
  const JoynTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.helperText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    this.isPassword = false,
    this.trailingLabel,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;

  /// Texte d'aide affiché sous le champ tant qu'il n'y a pas d'erreur.
  final String? helperText;

  /// Retourne un message d'erreur (en français) ou `null` si la valeur est valide.
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final bool isPassword;

  /// Widget affiché à droite du libellé (ex. lien « Mot de passe oublié ? »).
  final Widget? trailingLabel;

  @override
  State<JoynTextField> createState() => _JoynTextFieldState();
}

class _JoynTextFieldState extends State<JoynTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final trailing = widget.trailingLabel;
            if (trailing == null) {
              return Text(widget.label, style: AppTextStyles.label);
            }

            if (constraints.maxWidth < 300) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.label, style: AppTextStyles.label),
                  Align(alignment: Alignment.centerRight, child: trailing),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: Text(widget.label, style: AppTextStyles.label)),
                Flexible(child: trailing),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          label: widget.label,
          child: TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            onFieldSubmitted: widget.onFieldSubmitted,
            obscureText: widget.isPassword && _obscured,
            autocorrect: !widget.isPassword,
            enableSuggestions: !widget.isPassword,
            style: const TextStyle(fontSize: 15),
            decoration: AppTheme.inputDecoration(
              hintText: widget.hintText,
              helperText: widget.helperText,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      tooltip: _obscured
                          ? 'Afficher le mot de passe'
                          : 'Masquer le mot de passe',
                      icon: Icon(
                        _obscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscured = !_obscured),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
