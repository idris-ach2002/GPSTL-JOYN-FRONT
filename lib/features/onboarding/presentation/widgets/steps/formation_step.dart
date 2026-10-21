import 'package:flutter/material.dart';

import '../../../../../design_system/components/joyn_choice_chip.dart';
import '../../../../../design_system/components/joyn_select_field.dart';
import '../../../../../design_system/components/joyn_text_field.dart';
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
          subtitle:
              "C'est la base de ton matching : on ne te montre que des offres ouvertes à ton diplôme.",
        ),
        const SizedBox(height: 24),
        FieldGroup(
          label: 'Je cherche',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final kind in OnboardingOptions.searchKinds)
                JoynChoiceChip(
                  label: kind,
                  tone: JoynChipTone.orange,
                  selected: form.searchKind == kind,
                  onTap: () => form.setSearchKind(kind),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ResponsivePair(
          first: JoynTextField(
            key: const ValueKey('onboarding-degree'),
            label: 'Intitulé de la formation',
            controller: degreeTitle,
            onChanged: form.setDegreeTitle,
            hintText: 'Master Informatique',
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
          ),
          second: JoynTextField(
            key: const ValueKey('onboarding-school'),
            label: 'École / université',
            controller: school,
            onChanged: form.setSchool,
            hintText: 'Université Paris Cité',
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(height: 24),
        FieldGroup(
          label: 'Niveau visé',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final level in OnboardingOptions.levels)
                JoynChoiceChip(
                  label: level,
                  selected: form.level == level,
                  onTap: () => form.setLevel(level),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: JoynSelectField<int>(
              label: "Année d'obtention prévue",
              options: OnboardingOptions.graduationYears,
              value: form.graduationYear,
              onChanged: form.setGraduationYear,
              placeholder: 'Choisir une année',
            ),
          ),
        ),
      ],
    );
  }
}
