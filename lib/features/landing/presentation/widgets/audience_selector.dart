import 'package:flutter/material.dart';

import '../../domain/landing_content.dart';

/// Contrôle Material partagé : clavier, focus et sélection unique sont natifs.
class AudienceSelector extends StatelessWidget {
  const AudienceSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final Audience value;
  final ValueChanged<Audience> onChanged;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 400;

    final selector = SegmentedButton<Audience>(
      showSelectedIcon: false,
      style: compact
          ? const ButtonStyle(
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          : null,
      segments: [
        ButtonSegment(
          value: Audience.candidate,
          label: const Text('Candidat'),
          icon: compact ? null : const Icon(Icons.person_outline_rounded),
        ),
        ButtonSegment(
          value: Audience.company,
          label: const Text('Entreprise'),
          icon: compact ? null : const Icon(Icons.apartment_rounded),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.single),
    );

    if (!compact) return selector;

    return FittedBox(fit: BoxFit.scaleDown, child: selector);
  }
}
