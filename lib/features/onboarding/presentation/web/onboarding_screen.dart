import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/theme/joyn_material_theme.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_durations.dart';
import 'package:joyn_front/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:joyn_front/features/onboarding/presentation/onboarding_scope.dart';
import 'package:joyn_front/features/onboarding/presentation/shared/onboarding_text_fields.dart';
import 'package:joyn_front/features/onboarding/presentation/shared/steps/domains_step.dart';
import 'package:joyn_front/features/onboarding/presentation/shared/steps/formation_step.dart';
import 'package:joyn_front/features/onboarding/presentation/shared/steps/location_step.dart';
import 'package:joyn_front/features/onboarding/presentation/shared/steps/preferences_step.dart';
import 'package:joyn_front/features/onboarding/presentation/shared/steps/skills_step.dart';
import 'package:joyn_front/features/onboarding/presentation/web/widgets/onboarding_top_bar.dart';
import 'package:joyn_front/features/onboarding/presentation/web/widgets/step_sidebar.dart';

/// Écran 03 — Onboarding étudiant en 5 étapes (web).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _fields = OnboardingTextFields();
  final _scroll = ScrollController();
  OnboardingController? _form;
  int _lastStep = 1;

  /// Largeur à partir de laquelle la liste des étapes s'affiche à gauche.
  static const double _sidebarBreakpoint = 900;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final form = OnboardingScope.onboardingOf(context);
    _fields.attach(form);
    if (!identical(form, _form)) {
      _form?.removeListener(_scrollToTopOnStepChange);
      _form = form..addListener(_scrollToTopOnStepChange);
      _lastStep = form.step;
    }
  }

  @override
  void dispose() {
    _form?.removeListener(_scrollToTopOnStepChange);
    _fields.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToTopOnStepChange() {
    final form = _form;
    if (form == null || form.step == _lastStep) return;
    _lastStep = form.step;
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: AppDurations.normal,
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _finish(OnboardingController form) async {
    final saved = await form.finish();
    if (!mounted || !saved) return;
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final form = OnboardingScope.onboardingOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= _sidebarBreakpoint;
    final compact = width < 640;

    return JoynMaterialScope(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              OnboardingTopBar(
                center: StepProgress(
                  step: form.step,
                  stepCount: OnboardingController.stepCount,
                  maxWidth: math.min(420.0, width - 48),
                ),
                trailing: TextButton(
                  onPressed: () => context.go(AppRoutes.dashboard),
                  child: const Text('Terminer plus tard'),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Padding(
                        padding: compact
                            ? const EdgeInsets.fromLTRB(16, 20, 16, 32)
                            : const EdgeInsets.fromLTRB(24, 40, 24, 56),
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 270,
                                    child: StepSidebar(
                                      currentStep: form.step,
                                      onStepSelected: form.goToStep,
                                      prefilledFromCv: form.prefilledFromCv,
                                      onImportCv: () => context.go(
                                        AppRoutes.candidateCvImport,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    child: _StepCard(
                                      form: form,
                                      fields: _fields,
                                      compact: compact,
                                      onFinish: () => _finish(form),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  CvShortcutCard(
                                    prefilled: form.prefilledFromCv,
                                    onImport: () =>
                                        context.go(AppRoutes.candidateCvImport),
                                  ),
                                  const SizedBox(height: 16),
                                  _StepCard(
                                    form: form,
                                    fields: _fields,
                                    compact: compact,
                                    onFinish: () => _finish(form),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte de l'étape en cours, avec ses boutons de navigation.
class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.form,
    required this.fields,
    required this.compact,
    required this.onFinish,
  });

  final OnboardingController form;
  final OnboardingTextFields fields;
  final bool compact;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final Widget pane = switch (form.step) {
      1 => FormationStep(
        form: form,
        degreeTitle: fields.degreeTitle,
        school: fields.school,
      ),
      2 => LocationStep(
        form: form,
        city: fields.city,
        availableFrom: fields.availableFrom,
      ),
      3 => DomainsStep(form: form),
      4 => SkillsStep(form: form, newSkill: fields.newSkill),
      _ => PreferencesStep(form: form, salary: fields.salary),
    };

    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 20 : 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : AppDurations.normal,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topLeft,
                children: [...previous, ?current],
              ),
              child: KeyedSubtree(key: ValueKey(form.step), child: pane),
            ),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 20),
            _StepActions(form: form, compact: compact, onFinish: onFinish),
          ],
        ),
      ),
    );
  }
}

class _StepActions extends StatelessWidget {
  const _StepActions({
    required this.form,
    required this.compact,
    required this.onFinish,
  });

  final OnboardingController form;
  final bool compact;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final back = OutlinedButton.icon(
      style: JoynButtonStyles.rounded,
      onPressed: form.previousStep,
      icon: const Icon(Icons.arrow_back_rounded),
      label: const Text('Retour'),
    );
    final primary = form.isLastStep
        ? FilledButton.icon(
            key: const ValueKey('onboarding-finish'),
            style: JoynButtonStyles.accent.merge(JoynButtonStyles.trailingIcon),
            onPressed: form.isSaving ? null : onFinish,
            icon: form.isSaving
                ? const ButtonProgress()
                : const Icon(Icons.arrow_forward_rounded),
            label: const Text('Voir mes offres compatibles'),
          )
        : FilledButton.icon(
            key: const ValueKey('onboarding-next'),
            style: JoynButtonStyles.rounded.merge(
              JoynButtonStyles.trailingIcon,
            ),
            onPressed: form.nextStep,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Continuer'),
          );
    final saved = Text(
      'Enregistré automatiquement',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: AppColors.slate),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          if (!form.isFirstStep) ...[const SizedBox(height: 10), back],
          const SizedBox(height: 12),
          saved,
        ],
      );
    }

    return Row(
      children: [
        if (!form.isFirstStep) back,
        const Spacer(),
        saved,
        const SizedBox(width: 12),
        primary,
      ],
    );
  }
}
