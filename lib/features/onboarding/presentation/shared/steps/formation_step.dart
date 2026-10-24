import 'package:flutter/material.dart';

import '../../../../../design_system/material/joyn_chip_group.dart';
import '../../../domain/onboarding_options.dart';
import '../../controllers/onboarding_controller.dart';
import '../field_section.dart';

/// Étape 1 — Ta formation.
class FormationStep extends StatelessWidget {
  const FormationStep({
    required this.form,
    required this.degreeTitle,
    required this.school,
    super.key,
  });

  final OnboardingController form;
  final TextEditingController degreeTitle;
  final TextEditingController school;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepHeading(
          title: 'Ta formation',
          subtitle: "C'est la base de ton matching : on ne te montre que des offres ouvertes à ton diplôme.",
        ),
        const SizedBox(height: 24),
        FieldGroup(
          label: 'Je cherche',
          child: JoynChipGroup<String>.single(
            options: OnboardingOptions.searchKinds,
            selected: form.searchKind,
            onSelected: form.setSearchKind,
            accent: true,
          ),
        ),
        const SizedBox(height: 24),
        ResponsivePair(
          first: TextField(
            key: const ValueKey('onboarding-degree'),
            controller: degreeTitle,
            onChanged: form.setDegreeTitle,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Intitulé de la formation',
              hintText: 'Master Informatique',
            ),
          ),
          second: TextField(
            key: const ValueKey('onboarding-school'),
            controller: school,
            onChanged: form.setSchool,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'École / université',
              hintText: 'Université Paris Cité',
            ),
          ),
        ),
        const SizedBox(height: 24),
        FieldGroup(
          label: 'Niveau visé',
          child: JoynChipGroup<String>.single(
            options: OnboardingOptions.levels,
            selected: form.level,
            onSelected: form.setLevel,
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: DropdownMenu<int>(
              key: const ValueKey('onboarding-year'),
              expandedInsets: EdgeInsets.zero,
              requestFocusOnTap: false,
              label: const Text("Année d'obtention prévue"),
              initialSelection: form.graduationYear,
              onSelected: (year) {
                if (year != null) form.setGraduationYear(year);
              },
              dropdownMenuEntries: [
                for (final year in OnboardingOptions.graduationYears)
                  DropdownMenuEntry(value: year, label: '$year'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
