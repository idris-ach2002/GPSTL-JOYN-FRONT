import 'package:flutter/material.dart';

import '../../../../../design_system/material/joyn_chip_group.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../domain/onboarding_options.dart';
import '../../controllers/onboarding_controller.dart';
import '../add_item_dialog.dart';
import '../field_section.dart';

/// Étape 4 — Technologies & compétences.
class SkillsStep extends StatelessWidget {
  const SkillsStep({required this.form, required this.newSkill, super.key});

  final OnboardingController form;

  /// Champ « Ajouter une technologie ».
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepHeading(
          title: 'Technologies & compétences',
          subtitle: 'Indique ton niveau : il pèse directement dans ton score de compatibilité.',
        ),
        const SizedBox(height: 24),
        TextField(
          key: const ValueKey('onboarding-new-skill'),
          controller: newSkill,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addSkill(),
          decoration: InputDecoration(
            labelText: 'Ajouter une technologie',
            hintText: 'Python, Figma, SQL…',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: IconButton(
              tooltip: 'Ajouter',
              onPressed: _addSkill,
              icon: const Icon(Icons.add_rounded, color: AppColors.navy),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (skills.isEmpty)
          Card(
            color: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aucune technologie pour l’instant. Ajoute-les une par une, ou importe ton CV pour les détecter.',
                style: textTheme.bodySmall,
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
                InputChip(
                  label: Text(soft),
                  labelStyle: textTheme.labelMedium?.copyWith(
                    color: AppColors.successDeep,
                  ),
                  backgroundColor: AppColors.successTint,
                  side: BorderSide.none,
                  deleteIconColor: AppColors.successDeep,
                  deleteButtonTooltipMessage: 'Retirer $soft',
                  onDeleted: () => form.removeSoftSkill(soft),
                ),
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Ajouter'),
                onPressed: () => _addSoftSkill(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Une technologie, son niveau ([SegmentedButton]) et le bouton « retirer ».
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
    final levels = SegmentedButton<SkillLevel>(
      segments: [
        for (final option in SkillLevel.values)
          ButtonSegment(value: option, label: Text(option.label)),
      ],
      selected: {level},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onLevelChanged(selection.first),
    );
    final title = Text(name, style: Theme.of(context).textTheme.titleSmall);
    final remove = IconButton(
      tooltip: 'Retirer $name',
      onPressed: onRemove,
      icon: const Icon(Icons.close_rounded, size: 18),
    );

    return Card(
      color: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 560) {
              return Row(
                children: [
                  Expanded(child: title),
                  levels,
                  const SizedBox(width: 4),
                  remove,
                ],
              );
            }
            // Sur petit écran, des puces qui passent à la ligne plutôt
            // qu'un SegmentedButton trop large.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: title),
                    remove,
                  ],
                ),
                JoynChipGroup<SkillLevel>.single(
                  options: SkillLevel.values,
                  selected: level,
                  onSelected: onLevelChanged,
                  labelOf: (option) => option.label,
                ),
                const SizedBox(height: 6),
              ],
            );
          },
        ),
      ),
    );
  }
}
