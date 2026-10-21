import 'package:flutter/material.dart';

import '../../../../../design_system/components/joyn_choice_chip.dart';
import '../../../../../design_system/components/joyn_dashed_button.dart';
import '../../../../../design_system/components/joyn_removable_chip.dart';
import '../../../../../design_system/components/joyn_text_field.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../domain/onboarding_options.dart';
import '../../controllers/onboarding_controller.dart';
import '../add_item_dialog.dart';
import '../field_section.dart';

/// Étape 4 — Technologies & compétences.
class SkillsStep extends StatelessWidget {
  const SkillsStep({required this.form, required this.newSkill, super.key});

  final OnboardingController form;

  /// Champ « Ajouter une techno ».
  final TextEditingController newSkill;

  void _addSkill() {
    form.addSkill(newSkill.text);
    newSkill.clear();
  }

  Future<void> _addSoftSkill(BuildContext context) async {
    final value = await showAddItemDialog(
      context,
      title: 'Ajouter une soft skill',
      label: 'Soft skill',
      hintText: 'Ex. Rigueur, Communication…',
    );
    if (value != null) form.addSoftSkill(value);
  }

  @override
  Widget build(BuildContext context) {
    final skills = form.skills;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepHeading(
          title: 'Technologies & compétences',
          subtitle: 'Indique ton niveau : il pèse directement dans ton score de compatibilité.',
        ),
        const SizedBox(height: 24),
        JoynTextField(
          key: const ValueKey('onboarding-new-skill'),
          label: 'Ajouter une technologie',
          controller: newSkill,
          hintText: 'Python, Figma, SQL…',
          prefixIcon: Icons.search_rounded,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addSkill(),
          suffix: IconButton(
            tooltip: 'Ajouter',
            onPressed: _addSkill,
            icon: const Icon(Icons.add_rounded, color: AppColors.navy),
          ),
        ),
        const SizedBox(height: 16),
        if (skills.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Aucune technologie pour l’instant. Ajoute-les une par une, ou importe ton CV pour les détecter.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.slate,
              ),
            ),
          )
        else
          for (final entry in skills.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SkillRow(
                name: entry.key,
                level: entry.value,
                onLevelChanged: (level) => form.setSkillLevel(entry.key, level),
                onRemove: () => form.removeSkill(entry.key),
              ),
            ),
        const SizedBox(height: 14),
        FieldGroup(
          label: 'Soft skills',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final soft in form.softSkills)
                JoynRemovableChip(
                  label: soft,
                  background: AppColors.successTint,
                  foreground: AppColors.successDeep,
                  onRemove: () => form.removeSoftSkill(soft),
                ),
              JoynDashedButton(
                label: 'Ajouter',
                height: 40,
                color: AppColors.slate,
                onTap: () => _addSoftSkill(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.name,
    required this.level,
    required this.onLevelChanged,
    required this.onRemove,
  });

  final String name;
  final SkillLevel level;
  final ValueChanged<SkillLevel> onLevelChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final levels = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final option in SkillLevel.values)
          JoynChoiceChip(
            label: option.label,
            selected: option == level,
            borderRadius: 10,
            onTap: () => onLevelChanged(option),
          ),
      ],
    );
    final title = Text(
      name,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
    final remove = IconButton(
      tooltip: 'Retirer $name',
      onPressed: onRemove,
      icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.slate),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 540) {
            return Row(
              children: [
                Expanded(child: title),
                levels,
                const SizedBox(width: 4),
                remove,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: title),
                  remove,
                ],
              ),
              levels,
            ],
          );
        },
      ),
    );
  }
}
