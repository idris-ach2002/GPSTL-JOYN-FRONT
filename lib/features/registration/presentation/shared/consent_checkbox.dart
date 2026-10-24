import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';

/// Case à cocher Material ([CheckboxListTile]) avec un libellé enrichi
/// et, si besoin, un message d'erreur.
class ConsentCheckbox extends StatelessWidget {
  const ConsentCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
    this.errorText,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// Libellé, éventuellement enrichi (mots en gras).
  final InlineSpan label;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final error = errorText;

    return CheckboxListTile(
      value: value,
      onChanged: (checked) => onChanged(checked ?? false),
      isError: error != null,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text.rich(
        label,
        style: textTheme.bodyMedium?.copyWith(color: AppColors.slateDark),
      ),
      subtitle: error == null
          ? null
          : Text(
              error,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.errorDeep,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

/// Texte en gras bleu nuit dans un libellé de consentement.
TextSpan consentEmphasis(String text) => TextSpan(
  text: text,
  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy),
);
