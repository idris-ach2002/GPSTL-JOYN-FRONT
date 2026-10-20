import 'package:flutter/material.dart';

import '../../domain/landing_content.dart';

/// Contrôle Material partagé : clavier, focus et sélection unique sont natifs.
class AudienceSelector extends StatelessWidget {
  const AudienceSelector({required this.value, required this.onChanged, super.key});
  final Audience value;
  final ValueChanged<Audience> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<Audience>(
    showSelectedIcon: false,
    segments: const [
      ButtonSegment(value: Audience.candidate, label: Text('Candidat'),
        icon: Icon(Icons.person_outline_rounded)),
      ButtonSegment(value: Audience.company, label: Text('Entreprise'),
        icon: Icon(Icons.apartment_rounded)),
    ],
    selected: {value},
    onSelectionChanged: (selection) => onChanged(selection.single),
  );
}
