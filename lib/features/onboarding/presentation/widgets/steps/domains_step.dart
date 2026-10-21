import 'package:flutter/material.dart';

import '../../../../../design_system/components/joyn_choice_chip.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../domain/onboarding_options.dart';
import '../../controllers/onboarding_controller.dart';
import '../field_section.dart';

/// Étape 3 — Quels métiers t'intéressent ?
class DomainsStep extends StatelessWidget {
  const DomainsStep({required this.form, super.key});

  final OnboardingController form;

  @override
  Widget build(BuildContext context) {
    final count = form.domains.length;
    const max = OnboardingOptions.maxDomains;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepHeading(
          title: "Quels métiers t'intéressent ?",
          subtitle:
              "Choisis jusqu'à 5 domaines. Tu pourras les modifier à tout moment.",
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final domain in OnboardingOptions.domains)
              JoynChoiceChip(
                label: domain,
                showCheck: true,
                selected: form.isDomainSelected(domain),
                // Une fois la limite atteinte, seuls les domaines déjà
                // choisis restent cliquables (pour pouvoir les retirer).
                onTap: form.isDomainSelected(domain) || !form.domainLimitReached
                    ? () => form.toggleDomain(domain)
                    : null,
              ),
          ],
        ),
        const SizedBox(height: 16),
        Semantics(
          liveRegion: true,
          child: Text(
            form.domainLimitReached
                ? '$max domaines choisis : retire-en un pour en sélectionner un autre.'
                : '$count / $max domaines choisis',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: form.domainLimitReached
                  ? AppColors.warningDeep
                  : AppColors.slate,
            ),
          ),
        ),
      ],
    );
  }
}
