import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:joyn_front/design_system/components/joyn_choice_chip.dart';
import 'package:joyn_front/design_system/components/joyn_text_field.dart';
import 'package:joyn_front/features/onboarding/domain/onboarding_options.dart';
import 'package:joyn_front/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:joyn_front/features/onboarding/presentation/widgets/field_section.dart';

/// Étape 5 — Tes préférences.
class PreferencesStep extends StatelessWidget {
  const PreferencesStep({required this.form, required this.salary, super.key});

  final OnboardingController form;
  final TextEditingController salary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepHeading(
          title: 'Tes préférences',
          subtitle: 'Dernière étape. On affine tes recommandations avec ça.',
        ),
        const SizedBox(height: 24),
        FieldGroup(
          label: 'Télétravail',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final mode in OnboardingOptions.remoteModes)
                JoynChoiceChip(
                  label: mode,
                  selected: form.remoteMode == mode,
                  onTap: () => form.setRemoteMode(mode),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FieldGroup(
          label: "Taille d'entreprise",
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final size in OnboardingOptions.companySizes)
                JoynChoiceChip(
                  label: size,
                  showCheck: true,
                  selected: form.isCompanySizeSelected(size),
                  onTap: () => form.toggleCompanySize(size),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: JoynTextField(
              key: const ValueKey('onboarding-salary'),
              label: 'Rémunération souhaitée (brut / mois)',
              labelSuffix: '(facultatif)',
              controller: salary,
              onChanged: form.setDesiredSalary,
              hintText: 'Ex. 1 400',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9 ]')),
                LengthLimitingTextInputFormatter(7),
              ],
              suffix: const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Center(
                  widthFactor: 1,
                  child: Text('€', style: TextStyle(fontSize: 15)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
