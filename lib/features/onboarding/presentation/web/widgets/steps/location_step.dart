import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/components/joyn_text_field.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_durations.dart';
import 'package:joyn_front/features/onboarding/domain/onboarding_options.dart';
import 'package:joyn_front/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:joyn_front/features/onboarding/presentation/widgets/field_section.dart';

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
          first: JoynTextField(
            key: const ValueKey('onboarding-city'),
            label: 'Ville ou adresse',
            controller: city,
            onChanged: form.setCity,
            hintText: 'Paris 13e',
            prefixIcon: Icons.place_outlined,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.addressCity],
          ),
          second: JoynTextField(
            key: const ValueKey('onboarding-available'),
            label: 'Disponible à partir de',
            controller: availableFrom,
            onChanged: form.setAvailableFrom,
            hintText: 'Septembre 2027',
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(height: 24),
        FieldGroup(
          label: 'Trajet maximum',
          trailing: Text(
            '$commute min',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.navy,
              inactiveTrackColor: AppColors.track,
              thumbColor: AppColors.navy,
              overlayColor: AppColors.navy.withValues(alpha: 0.12),
              trackHeight: 6,
            ),
            child: Slider(
              value: commute.toDouble(),
              min: OnboardingOptions.minCommute.toDouble(),
              max: OnboardingOptions.maxCommute.toDouble(),
              divisions:
                  (OnboardingOptions.maxCommute -
                      OnboardingOptions.minCommute) ~/
                  5,
              semanticFormatterCallback: (value) =>
                  '${value.round()} minutes de trajet maximum',
              onChanged: (value) => form.setMaxCommute(value.round()),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FieldGroup(
          label: "Rythme d'alternance",
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 680
                  ? 4
                  : constraints.maxWidth >= 340
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
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.skyTint : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.navy : AppColors.line,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  option.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  option.detail,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? AppColors.slateDark : AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
