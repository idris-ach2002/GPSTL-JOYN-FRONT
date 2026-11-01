import 'package:flutter/material.dart';

import '../../../../../design_system/tokens/app_colors.dart';
import '../../../domain/onboarding_options.dart';
import '../../controllers/onboarding_controller.dart';
import '../field_section.dart';

/// Étape 2 — Où, quand, à quel rythme ?
class LocationStep extends StatelessWidget {
  const LocationStep({
    required this.form,
    required this.city,
    required this.availableFrom,
    super.key,
  });

  final OnboardingController form;
  final TextEditingController city;
  final TextEditingController availableFrom;

  @override
  Widget build(BuildContext context) {
    final commute = form.maxCommuteMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepHeading(
          title: 'Où, quand, à quel rythme ?',
          subtitle:
              'On respecte le calendrier de ton école et ton temps de trajet.',
        ),
        const SizedBox(height: 24),
        ResponsivePair(
          first: TextField(
            key: const ValueKey('onboarding-city'),
            controller: city,
            onChanged: form.setCity,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.addressCity],
            decoration: const InputDecoration(
              labelText: 'Ville ou adresse',
              hintText: 'Paris 13e',
              prefixIcon: Icon(Icons.place_outlined, size: 20),
            ),
          ),
          second: TextField(
            key: const ValueKey('onboarding-available'),
            controller: availableFrom,
            onChanged: form.setAvailableFrom,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Disponible à partir de',
              hintText: 'Septembre 2027',
              prefixIcon: Icon(Icons.event_outlined, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FieldGroup(
          label: 'Trajet maximum',
          trailing: Text(
            '$commute min',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: AppColors.navy),
          ),
          child: Slider(
            value: commute.toDouble(),
            min: OnboardingOptions.minCommute.toDouble(),
            max: OnboardingOptions.maxCommute.toDouble(),
            divisions:
                (OnboardingOptions.maxCommute - OnboardingOptions.minCommute) ~/
                5,
            label: '$commute min',
            semanticFormatterCallback: (value) =>
                '${value.round()} minutes de trajet maximum',
            onChanged: (value) => form.setMaxCommute(value.round()),
          ),
        ),
        const SizedBox(height: 16),
        FieldGroup(
          label: "Rythme d'alternance",
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 680
                  ? 4
                  : constraints.maxWidth >= 300
                  ? 2
                  : 1;
              const spacing = 10.0;
              final cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final option in OnboardingOptions.rhythms)
                    SizedBox(
                      width: cardWidth,
                      child: _RhythmCard(
                        option: option,
                        selected: form.rhythm == option.label,
                        onTap: () => form.setRhythm(option.label),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Carte de rythme sélectionnable ([Card] + [InkWell]).
class _RhythmCard extends StatelessWidget {
  const _RhythmCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final RhythmOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Card(
        color: selected ? AppColors.skyTint : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? AppColors.navy : AppColors.line,
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(option.label, style: textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(option.detail, style: textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
