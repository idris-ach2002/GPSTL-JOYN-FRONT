import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../controllers/onboarding_controller.dart';
import '../onboarding_scope.dart';
import '../shared/onboarding_steps.dart';
import '../shared/onboarding_text_fields.dart';
import '../shared/steps/domains_step.dart';
import '../shared/steps/formation_step.dart';
import '../shared/steps/location_step.dart';
import '../shared/steps/preferences_step.dart';
import '../shared/steps/skills_step.dart';

/// Onboarding étudiant en 5 étapes (mobile).
class MobileOnboardingScreen extends StatefulWidget {
  const MobileOnboardingScreen({super.key});

  @override
  State<MobileOnboardingScreen> createState() => _MobileOnboardingScreenState();
}

class _MobileOnboardingScreenState extends State<MobileOnboardingScreen> {
  final _fields = OnboardingTextFields();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fields.attach(OnboardingScope.onboardingOf(context));
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  Future<void> _next(OnboardingController form) async {
    if (!form.isLastStep) {
      form.nextStep();
      return;
    }
    final saved = await form.finish();
    if (!mounted || !saved) return;
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final form = OnboardingScope.onboardingOf(context);
    final textTheme = Theme.of(context).textTheme;
    final stepInfo = onboardingSteps[form.step - 1];

    final Widget pane = switch (form.step) {
      1 => FormationStep(
        form: form,
        degreeTitle: _fields.degreeTitle,
        school: _fields.school,
      ),
      2 => LocationStep(
        form: form,
        city: _fields.city,
        availableFrom: _fields.availableFrom,
      ),
      3 => DomainsStep(form: form),
      4 => SkillsStep(form: form, newSkill: _fields.newSkill),
      _ => PreferencesStep(form: form, salary: _fields.salary),
    };

    return JoynMaterialScope(
      child: MobileAppSurface(
        backgroundColor: const Color(0xFFF7F8F2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 18, 10),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Étape précédente',
                    onPressed: form.isFirstStep ? null : form.previousStep,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stepInfo.label, style: textTheme.titleMedium),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: form.progress,
                          borderRadius: BorderRadius.circular(99),
                          semanticsLabel: 'Progression du profil',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${form.step}/${OnboardingController.stepCount}',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: KeyedSubtree(key: ValueKey(form.step), child: pane),
                ),
              ),
            ),
            Material(
              color: AppColors.surface,
              shape: const Border(top: BorderSide(color: AppColors.lineSoft)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    if (form.isFirstStep)
                      TextButton.icon(
                        onPressed: () =>
                            context.go(AppRoutes.candidateCvImport),
                        icon: const Icon(Icons.upload_file_rounded),
                        label: const Text('Mon CV'),
                      )
                    else
                      TextButton(
                        onPressed: form.previousStep,
                        child: const Text('Retour'),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        key: const ValueKey('mobile-onboarding-next'),
                        style: JoynButtonStyles.accent.merge(
                          JoynButtonStyles.trailingIcon,
                        ),
                        onPressed: form.isSaving ? null : () => _next(form),
                        icon: form.isSaving
                            ? const ButtonProgress()
                            : const Icon(Icons.arrow_forward_rounded),
                        label: Text(
                          form.isLastStep ? 'Terminer mon profil' : 'Continuer',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
