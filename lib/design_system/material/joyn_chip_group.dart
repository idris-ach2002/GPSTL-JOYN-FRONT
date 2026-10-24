import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// Groupe de puces Material : [ChoiceChip] pour un choix unique,
/// [FilterChip] pour un choix multiple.
class JoynChipGroup<T> extends StatelessWidget {
  /// Un seul choix possible.
  const JoynChipGroup.single({
    required this.options,
    required this.selected,
    required ValueChanged<T> this.onSelected,
    this.labelOf,
    this.accent = false,
    super.key,
  }) : selectedValues = null,
       onToggled = null,
       isEnabled = null;

  /// Plusieurs choix possibles. [isEnabled] permet de griser des options
  /// (par exemple quand une limite de sélection est atteinte).
  const JoynChipGroup.multi({
    required this.options,
    required Set<T> selected,
    required ValueChanged<T> this.onToggled,
    this.isEnabled,
    this.labelOf,
    super.key,
  }) : selectedValues = selected,
       selected = null,
       onSelected = null,
       accent = false;

  final List<T> options;
  final String Function(T option)? labelOf;

  /// Sélection en orange plutôt qu'en bleu nuit (choix principal d'un écran).
  final bool accent;

  /// Choix unique : option sélectionnée.
  final T? selected;
  final ValueChanged<T>? onSelected;

  /// Choix multiple : options sélectionnées.
  final Set<T>? selectedValues;
  final ValueChanged<T>? onToggled;
  final bool Function(T option)? isEnabled;

  String _label(T option) => labelOf?.call(option) ?? option.toString();

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium;
    final selectedColor = accent ? AppColors.orangeLight : AppColors.navy;
    final selectedText = accent ? AppColors.textPrimary : AppColors.white;

    TextStyle? styleFor(bool isSelected) => labelStyle?.copyWith(
      color: isSelected ? selectedText : AppColors.slateDark,
      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
    );

    final values = selectedValues;
    final toggle = onToggled;
    final select = onSelected;
    final enabled = isEnabled;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          if (values != null && toggle != null)
            FilterChip(
              label: Text(_label(option)),
              labelStyle: styleFor(values.contains(option)),
              selected: values.contains(option),
              selectedColor: selectedColor,
              checkmarkColor: selectedText,
              onSelected: (enabled?.call(option) ?? true)
                  ? (_) => toggle(option)
                  : null,
            )
          else
            ChoiceChip(
              label: Text(_label(option)),
              labelStyle: styleFor(selected == option),
              selected: selected == option,
              selectedColor: selectedColor,
              showCheckmark: false,
              side: BorderSide(
                color: selected == option ? selectedColor : AppColors.line,
                width: 1.5,
              ),
              onSelected: select == null ? null : (_) => select(option),
            ),
      ],
    );
  }
}

/// Puce d'information non cliquable (statut, badge).
class JoynInfoChip extends StatelessWidget {
  const JoynInfoChip({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.borderColor,
    this.small = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return Chip(
      avatar: icon == null
          ? null
          : Icon(icon, size: small ? 14 : 16, color: foreground),
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: foreground,
        letterSpacing: 0,
        fontSize: small ? 12 : 13,
      ),
      // `color` est prioritaire sur le thème des puces : sans lui, Material
      // remplace un fond translucide par du blanc.
      color: WidgetStatePropertyAll(background),
      backgroundColor: background,
      side: BorderSide(color: borderColor ?? background),
      shape: const StadiumBorder(),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.symmetric(horizontal: small ? 4 : 6),
    );
  }
}
