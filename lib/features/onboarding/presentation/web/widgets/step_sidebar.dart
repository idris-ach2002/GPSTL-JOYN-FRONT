import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/onboarding/presentation/shared/onboarding_steps.dart';

/// Liste des 5 étapes ([ListTile] cliquables) + encart « CV ».
class StepSidebar extends StatelessWidget {
  const StepSidebar({
    required this.currentStep,
    required this.onStepSelected,
    required this.onImportCv,
    required this.prefilledFromCv,
    super.key,
  });

  final int currentStep;
  final ValueChanged<int> onStepSelected;
  final VoidCallback onImportCv;
  final bool prefilledFromCv;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < onboardingSteps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _StepTile(
              number: i + 1,
              info: onboardingSteps[i],
              currentStep: currentStep,
              onTap: () => onStepSelected(i + 1),
            ),
          ),
        const SizedBox(height: 16),
        CvShortcutCard(prefilled: prefilledFromCv, onImport: onImportCv),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.info,
    required this.currentStep,
    required this.onTap,
  });

  final int number;
  final OnboardingStepInfo info;
  final int currentStep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = number < currentStep;
    final current = number == currentStep;

    return ListTile(
      selected: current,
      onTap: onTap,
      leading: CircleAvatar(
        radius: 15,
        backgroundColor: done
            ? AppColors.successDeep
            : current
            ? AppColors.navy
            : AppColors.track,
        child: done
            ? const Icon(Icons.check_rounded, size: 16, color: AppColors.white)
            : Text(
                '$number',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: current ? AppColors.white : AppColors.slate,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
      title: Text(info.label),
      subtitle: Text(info.hint),
    );
  }
}

/// Encart qui propose d'importer le CV pour pré-remplir l'onboarding.
class CvShortcutCard extends StatelessWidget {
  const CvShortcutCard({
    required this.prefilled,
    required this.onImport,
    super.key,
  });

  final bool prefilled;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: prefilled ? AppColors.successTint : AppColors.skyTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prefilled
                  ? 'Profil pré-rempli avec ton CV'
                  : 'Plus rapide avec ton CV',
              style: textTheme.titleSmall?.copyWith(
                color: prefilled ? AppColors.successDeep : AppColors.navy,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                prefilled
                    ? 'Formation, ville et compétences sont remplies. Vérifie-les à chaque étape.'
                    : 'On pré-remplit formation, compétences et expériences pour toi.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.slateDark,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.upload_file_outlined, size: 18),
              label: Text(prefilled ? 'Revoir mon CV' : 'Importer mon CV'),
            ),
          ],
        ),
      ),
    );
  }
}
