import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/onboarding_options.dart';
import '../controllers/onboarding_controller.dart';
import '../onboarding_scope.dart';

class MobileOnboardingScreen extends StatefulWidget {
  const MobileOnboardingScreen({super.key});

  @override
  State<MobileOnboardingScreen> createState() => _MobileOnboardingScreenState();
}

class _MobileOnboardingScreenState extends State<MobileOnboardingScreen> {
  final _skill = TextEditingController();

  @override
  void dispose() {
    _skill.dispose();
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
    return MobileAppSurface(
      backgroundColor: const Color(0xFFF7F8F2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            child: Row(
              children: [
                IconButton.filledTonal(
                  onPressed: form.isFirstStep ? null : form.previousStep,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ton profil JOYN',
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: form.progress,
                          minHeight: 5,
                          backgroundColor: const Color(0xFFE1E7E1),
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${form.step}/5',
                  style: const TextStyle(
                    color: AppColors.slate,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _StepContent(
                  key: ValueKey(form.step),
                  form: form,
                  skillController: _skill,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE6EAE6))),
            ),
            child: Row(
              children: [
                if (form.isFirstStep)
                  TextButton.icon(
                    onPressed: () => context.go(AppRoutes.candidateCvImport),
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Importer mon CV'),
                  )
                else
                  TextButton(
                    onPressed: form.previousStep,
                    child: const Text('Retour'),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: MobilePrimaryButton(
                    label: form.isLastStep
                        ? 'Terminer mon profil'
                        : 'Continuer',
                    loading: form.isSaving,
                    backgroundColor: AppColors.orange,
                    onPressed: () => _next(form),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({
    super.key,
    required this.form,
    required this.skillController,
  });

  final OnboardingController form;
  final TextEditingController skillController;

  @override
  Widget build(BuildContext context) {
    return switch (form.step) {
      1 => _FormationStep(form: form),
      2 => _LocationStep(form: form),
      3 => _DomainsStep(form: form),
      4 => _SkillsStep(form: form, controller: skillController),
      _ => _PreferencesStep(form: form),
    };
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro(this.title, this.subtitle);
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 29,
          height: 1,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
      ),
      const SizedBox(height: 9),
      Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.slate,
          fontSize: 13,
          height: 1.45,
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}

class _FormationStep extends StatelessWidget {
  const _FormationStep({required this.form});
  final OnboardingController form;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _SectionIntro(
        'Ta formation',
        'On s’en sert pour proposer des offres vraiment compatibles.',
      ),
      _ChipGroup(
        values: OnboardingOptions.searchKinds,
        selected: {form.searchKind},
        onTap: form.setSearchKind,
      ),
      const SizedBox(height: 18),
      MobileField(
        label: 'Diplôme / formation',
        initialValue: form.degreeTitle,
        hintText: 'Master informatique',
        onChanged: form.setDegreeTitle,
      ),
      const SizedBox(height: 14),
      MobileField(
        label: 'École',
        initialValue: form.school,
        hintText: 'Université / école',
        onChanged: form.setSchool,
      ),
      const SizedBox(height: 18),
      const Text('Niveau', style: _labelStyle),
      const SizedBox(height: 8),
      _ChipGroup(
        values: OnboardingOptions.levels,
        selected: {if (form.level != null) form.level!},
        onTap: form.setLevel,
      ),
    ],
  );
}

class _LocationStep extends StatelessWidget {
  const _LocationStep({required this.form});
  final OnboardingController form;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _SectionIntro(
        'Où et quand ?',
        'Précise ta zone et ton rythme pour éviter les offres impossibles.',
      ),
      MobileField(
        label: 'Ville',
        initialValue: form.city,
        hintText: 'Paris',
        onChanged: form.setCity,
      ),
      const SizedBox(height: 14),
      MobileField(
        label: 'Disponible à partir de',
        initialValue: form.availableFrom,
        hintText: 'Septembre 2027',
        onChanged: form.setAvailableFrom,
      ),
      const SizedBox(height: 20),
      Text(
        'Trajet maximum · ${form.maxCommuteMinutes} min',
        style: _labelStyle,
      ),
      Slider(
        value: form.maxCommuteMinutes.toDouble(),
        min: OnboardingOptions.minCommute.toDouble(),
        max: OnboardingOptions.maxCommute.toDouble(),
        divisions: 8,
        activeColor: AppColors.orange,
        onChanged: (value) => form.setMaxCommute(value.round()),
      ),
      const SizedBox(height: 16),
      const Text('Rythme', style: _labelStyle),
      const SizedBox(height: 8),
      _ChipGroup(
        values: OnboardingOptions.rhythms.map((e) => e.label).toList(),
        selected: {if (form.rhythm != null) form.rhythm!},
        onTap: form.setRhythm,
      ),
    ],
  );
}

class _DomainsStep extends StatelessWidget {
  const _DomainsStep({required this.form});
  final OnboardingController form;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _SectionIntro(
        'Tes domaines',
        'Choisis jusqu’à 5 univers qui t’intéressent.',
      ),
      _ChipGroup(
        values: OnboardingOptions.domains,
        selected: form.domains.toSet(),
        onTap: form.toggleDomain,
      ),
    ],
  );
}

class _SkillsStep extends StatelessWidget {
  const _SkillsStep({required this.form, required this.controller});
  final OnboardingController form;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _SectionIntro(
        'Tes compétences',
        'Ajoute les technos et savoir-faire qui comptent dans ton profil.',
      ),
      Row(
        children: [
          Expanded(
            child: MobileField(
              label: 'Ajouter une compétence',
              controller: controller,
              hintText: 'React, Figma, Excel…',
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: IconButton.filled(
              onPressed: () {
                form.addSkill(controller.text);
                controller.clear();
              },
              style: IconButton.styleFrom(backgroundColor: AppColors.orange),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final skill in form.skills.keys)
            InputChip(
              label: Text(skill),
              onDeleted: () => form.removeSkill(skill),
              backgroundColor: Colors.white,
            ),
        ],
      ),
    ],
  );
}

class _PreferencesStep extends StatelessWidget {
  const _PreferencesStep({required this.form});
  final OnboardingController form;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _SectionIntro(
        'Tes préférences',
        'Dernière étape : indique l’environnement dans lequel tu veux évoluer.',
      ),
      const Text('Télétravail', style: _labelStyle),
      const SizedBox(height: 8),
      _ChipGroup(
        values: OnboardingOptions.remoteModes,
        selected: {if (form.remoteMode != null) form.remoteMode!},
        onTap: form.setRemoteMode,
      ),
      const SizedBox(height: 20),
      const Text('Taille d’entreprise', style: _labelStyle),
      const SizedBox(height: 8),
      _ChipGroup(
        values: OnboardingOptions.companySizes,
        selected: form.companySizes.toSet(),
        onTap: form.toggleCompanySize,
      ),
      const SizedBox(height: 20),
      MobileField(
        label: 'Salaire mensuel souhaité',
        initialValue: form.desiredSalary,
        hintText: '1 400 €',
        keyboardType: TextInputType.number,
        onChanged: form.setDesiredSalary,
      ),
    ],
  );
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.values,
    required this.selected,
    required this.onTap,
  });
  final List<String> values;
  final Set<String> selected;
  final ValueChanged<String> onTap;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final value in values)
        FilterChip(
          label: Text(value),
          selected: selected.contains(value),
          onSelected: (_) => onTap(value),
          selectedColor: const Color(0xFFFFE5DB),
          checkmarkColor: AppColors.orange,
          side: BorderSide(
            color: selected.contains(value)
                ? AppColors.orange
                : const Color(0xFFDDE3DD),
          ),
          labelStyle: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
    ],
  );
}

const _labelStyle = TextStyle(
  color: AppColors.navy,
  fontSize: 13,
  fontWeight: FontWeight.w800,
);
