import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/feedback/coming_soon.dart';
import '../../../../design_system/components/joyn_button.dart';
import '../../../../design_system/components/joyn_text_link.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_durations.dart';
import '../controllers/onboarding_controller.dart';
import '../onboarding_scope.dart';
import '../widgets/onboarding_top_bar.dart';
import '../widgets/step_progress.dart';
import '../widgets/step_sidebar.dart';
import '../widgets/steps/domains_step.dart';
import '../widgets/steps/formation_step.dart';
import '../widgets/steps/location_step.dart';
import '../widgets/steps/preferences_step.dart';
import '../widgets/steps/skills_step.dart';

/// Écran 03 — Onboarding étudiant en 5 étapes.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  OnboardingController? _form;
  int _lastStep = 1;

  final _scroll = ScrollController();
  final _degreeTitle = TextEditingController();
  final _school = TextEditingController();
  final _city = TextEditingController();
  final _availableFrom = TextEditingController();
  final _salary = TextEditingController();
  final _newSkill = TextEditingController();

  /// Largeur à partir de laquelle la liste des étapes s'affiche à gauche.
  static const double _sidebarBreakpoint = 900;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final form = OnboardingScope.onboardingOf(context);
    if (!identical(form, _form)) {
      _form?.removeListener(_onFormChanged);
      _form = form..addListener(_onFormChanged);
      _lastStep = form.step;
      _syncTextFields();
    }
  }

  @override
  void dispose() {
    _form?.removeListener(_onFormChanged);
    _scroll.dispose();
    _degreeTitle.dispose();
    _school.dispose();
    _city.dispose();
    _availableFrom.dispose();
    _salary.dispose();
    _newSkill.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    // Les champs texte suivent le contrôleur quand il change de l'extérieur
    // (par exemple après l'import du CV).
    _syncTextFields();

    final form = _form!;
    if (form.step != _lastStep) {
      _lastStep = form.step;
      if (_scroll.hasClients) {
        _scroll.animateTo(
          0,
          duration: AppDurations.normal,
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _syncTextFields() {
    final form = _form;
    if (form == null) return;
    void sync(TextEditingController controller, String value) {
      if (controller.text != value) controller.text = value;
    }

    sync(_degreeTitle, form.degreeTitle);
    sync(_school, form.school);
    sync(_city, form.city);
    sync(_availableFrom, form.availableFrom);
    sync(_salary, form.desiredSalary);
  }

  Future<void> _finish(OnboardingController form) async {
    final saved = await form.finish();
    if (!mounted || !saved) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Profil enregistré. La découverte des offres arrive bientôt.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final form = OnboardingScope.onboardingOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= _sidebarBreakpoint;
    final compact = width < 640;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingTopBar(
              center: StepProgress(
                step: form.step,
                stepCount: OnboardingController.stepCount,
                width: math.min(420.0, width - 48),
              ),
              trailing: JoynTextLink(
                label: 'Terminer plus tard',
                color: AppColors.slate,
                onTap: () => showComingSoon(context, 'Le tableau de bord'),
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
                                  width: 260,
                                  child: StepSidebar(
                                    currentStep: form.step,
                                    onStepSelected: form.goToStep,
                                    prefilledFromCv: form.prefilledFromCv,
                                    onImportCv: () =>
                                        context.go(AppRoutes.candidateCvImport),
                                  ),
                                ),
                                const SizedBox(width: 40),
                                Expanded(child: _buildStepCard(form, compact)),
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
                                _buildStepCard(form, compact),
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
    );
  }

  Widget _buildStepCard(OnboardingController form, bool compact) {
    final Widget pane = switch (form.step) {
      1 => FormationStep(
        form: form,
        degreeTitle: _degreeTitle,
        school: _school,
      ),
      2 => LocationStep(form: form, city: _city, availableFrom: _availableFrom),
      3 => DomainsStep(form: form),
      4 => SkillsStep(form: form, newSkill: _newSkill),
      _ => PreferencesStep(form: form, salary: _salary),
    };

    return Container(
      padding: EdgeInsets.all(compact ? 20 : 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lineSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080E1F2A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
          const Divider(height: 1, thickness: 1, color: AppColors.track),
          const SizedBox(height: 20),
          _StepFooter(
            form: form,
            compact: compact,
            onFinish: () => _finish(form),
          ),
        ],
      ),
    );
  }
}

class _StepFooter extends StatelessWidget {
  const _StepFooter({
    required this.form,
    required this.compact,
    required this.onFinish,
  });

  final OnboardingController form;
  final bool compact;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final back = JoynButton(
      label: 'Retour',
      variant: JoynButtonVariant.outline,
      height: 48,
      fontSize: 15,
      borderRadius: 12,
      expand: compact,
      onPressed: form.previousStep,
    );
    final primary = form.isLastStep
        ? JoynButton(
            key: const ValueKey('onboarding-finish'),
            label: 'Voir mes offres compatibles',
            variant: JoynButtonVariant.accent,
            height: 48,
            fontSize: 15,
            expand: compact,
            isLoading: form.isSaving,
            onPressed: onFinish,
          )
        : JoynButton(
            key: const ValueKey('onboarding-next'),
            label: 'Continuer',
            height: 48,
            fontSize: 15,
            borderRadius: 12,
            expand: compact,
            onPressed: form.nextStep,
          );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          if (!form.isFirstStep) ...[const SizedBox(height: 10), back],
          const SizedBox(height: 12),
          const Text(
            'Enregistré automatiquement',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.slate),
          ),
        ],
      );
    }

    return Row(
      children: [
        if (!form.isFirstStep) back,
        const Spacer(),
        const Text(
          'Enregistré automatiquement',
          style: TextStyle(fontSize: 13, color: AppColors.slate),
        ),
        const SizedBox(width: 12),
        primary,
      ],
    );
  }
}
