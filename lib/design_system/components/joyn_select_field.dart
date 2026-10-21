import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_fonts.dart';

/// Liste déroulante au style des champs Joyn.
class JoynSelectField<T> extends StatelessWidget {
  const JoynSelectField({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.optionLabel,
    this.placeholder = 'Choisir',
    super.key,
  });

  final String label;
  final List<T> options;
  final T? value;
  final ValueChanged<T> onChanged;

  /// Texte affiché pour une option. Par défaut, `toString()`.
  final String Function(T option)? optionLabel;
  final String placeholder;

  String _labelOf(T option) => optionLabel?.call(option) ?? option.toString();

  @override
  Widget build(BuildContext context) {
    final current = value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 7),
        PopupMenuButton<T>(
          tooltip: label,
          initialValue: current,
          onSelected: onChanged,
          position: PopupMenuPosition.under,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          itemBuilder: (context) => [
            for (final option in options)
              PopupMenuItem<T>(value: option, child: Text(_labelOf(option))),
          ],
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    current == null ? placeholder : _labelOf(current),
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 15,
                      color: current == null
                          ? AppColors.placeholder
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.expand_more_rounded,
                  color: AppColors.slate,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
