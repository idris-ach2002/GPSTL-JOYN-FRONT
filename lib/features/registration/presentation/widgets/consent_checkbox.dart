import 'package:flutter/material.dart';

import '../../../../design_system/components/joyn_field_message.dart';
import '../../../../design_system/tokens/app_colors.dart';

/// Case à cocher avec un libellé cliquable sur toute sa largeur.
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

  /// Libellé, éventuellement enrichi (liens en gras).
  final InlineSpan label;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MergeSemantics(
          child: InkWell(
            onTap: () => onChanged(!value),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox.square(
                    dimension: 24,
                    child: Checkbox(
                      value: value,
                      onChanged: (checked) => onChanged(checked ?? false),
                      activeColor: AppColors.navy,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity,
                      ),
                      side: BorderSide(
                        color: errorText != null
                            ? AppColors.error
                            : AppColors.placeholder,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text.rich(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: AppColors.slateDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 34, top: 6),
            child: JoynFieldMessage.error(errorText!),
          ),
      ],
    );
  }
}
