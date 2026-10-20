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
  Widget build(BuildContext context) => SegmentedButton<Audience>(
    showSelectedIcon: false,
    style: MediaQuery.sizeOf(context).width < 400
        ? const ButtonStyle(
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          )
        : null,
    segments: [
      ButtonSegment(
        value: Audience.candidate,
        label: const Text('Candidat'),
        icon: MediaQuery.sizeOf(context).width < 400
            ? null
            : const Icon(Icons.person_outline_rounded),
      ),
      ButtonSegment(
        value: Audience.company,
        label: const Text('Entreprise'),
        icon: MediaQuery.sizeOf(context).width < 400
            ? null
            : const Icon(Icons.apartment_rounded),
      ),
    ],
    selected: {value},
    onSelectionChanged: (selection) => onChanged(selection.single),
  );
}
