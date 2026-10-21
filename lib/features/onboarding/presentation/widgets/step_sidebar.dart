import 'package:flutter/material.dart';

import '../../../../design_system/components/joyn_text_link.dart';
import '../../../../design_system/tokens/app_colors.dart';

/// Une étape de la liste latérale.
class OnboardingStepInfo {
  const OnboardingStepInfo(this.label, this.hint);

  final String label;
  final String hint;
}

const onboardingSteps = [
  OnboardingStepInfo('Formation', 'École, diplôme, niveau'),
  OnboardingStepInfo('Localisation & rythme', 'Zone, rythme, disponibilité'),
  OnboardingStepInfo('Domaines', 'Métiers recherchés'),
  OnboardingStepInfo('Compétences', 'Technos et soft skills'),
  OnboardingStepInfo('Préférences', 'Télétravail, entreprise, salaire'),
];

/// Liste des 5 étapes (cliquables) + encart « Plus rapide avec ton CV ».
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
        for (var i = 0; i < onboardingSteps.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          _StepTile(
            number: i + 1,
            info: onboardingSteps[i],
            currentStep: currentStep,
            onTap: () => onStepSelected(i + 1),
          ),
        ],
        const SizedBox(height: 20),
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

    final Widget marker;
    if (done) {
      marker = Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: AppColors.successDeep,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, size: 16, color: AppColors.white),
      );
    } else {
      marker = Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: current ? AppColors.navy : Colors.transparent,
          shape: BoxShape.circle,
          border: current
              ? null
              : Border.all(color: AppColors.lineDashed, width: 1.5),
        ),
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: current ? FontWeight.w700 : FontWeight.w600,
            color: current ? AppColors.white : AppColors.slate,
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      selected: current,
      label:
          'Étape $number, ${info.label}${done ? ', terminée' : ''}${current ? ', en cours' : ''}',
      excludeSemantics: true,
      child: Material(
        color: current ? AppColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  marker,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          info.label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          info.hint,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: prefilled ? AppColors.successTint : AppColors.skyTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prefilled ? 'Profil pré-rempli avec ton CV' : 'Plus rapide avec ton CV',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: prefilled ? AppColors.successDeep : AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            prefilled
                ? 'Formation, ville et compétences sont remplies. Vérifie-les à chaque étape.'
                : 'On pré-remplit formation, compétences et expériences pour toi.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.slateDark,
            ),
          ),
          const SizedBox(height: 8),
          JoynTextLink(
            label: prefilled ? 'Revoir mon CV' : 'Importer mon CV',
            leadingIcon: Icons.upload_file_outlined,
            onTap: onImport,
          ),
        ],
      ),
    );
  }
}
