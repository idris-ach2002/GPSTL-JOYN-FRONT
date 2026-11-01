import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../design_system/material/joyn_chip_group.dart';
import '../../../domain/onboarding_options.dart';
import '../../controllers/onboarding_controller.dart';
import '../field_section.dart';

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
          child: JoynChipGroup<String>.single(
            options: OnboardingOptions.remoteModes,
            selected: form.remoteMode,
            onSelected: form.setRemoteMode,
          ),
        ),
        const SizedBox(height: 24),
        FieldGroup(
          label: "Taille d'entreprise",
          child: JoynChipGroup<String>.multi(
            options: OnboardingOptions.companySizes,
            selected: form.companySizes.toSet(),
            onToggled: form.toggleCompanySize,
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: TextField(
              key: const ValueKey('onboarding-salary'),
              controller: salary,
              onChanged: form.setDesiredSalary,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9 ]')),
                LengthLimitingTextInputFormatter(7),
              ],
              decoration: const InputDecoration(
                labelText: 'Salaire souhaité (brut / mois)',
                hintText: 'Ex. 1 400',
                helperText: 'Facultatif',
                suffixText: '€',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
