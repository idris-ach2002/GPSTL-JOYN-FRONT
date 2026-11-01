/// Une étape de l'onboarding, telle qu'affichée dans les listes d'étapes.
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
