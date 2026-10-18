import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/placeholders.dart';
import '../../domain/skill_comparison.dart';
import 'dashboard_card.dart';

/// Tableau « Compétences vs. votre offre ».
class SkillsCard extends StatelessWidget {
  const SkillsCard({super.key, required this.skills, required this.offerTitle});

  final List<SkillComparison>? skills;
  final String? offerTitle;

  // Largeur relative des colonnes : compétence, requis, candidat, statut.
  static const List<int> _flex = [3, 3, 3, 2];

  @override
  Widget build(BuildContext context) {
    final rows = skills ?? const <SkillComparison>[];

    return DashboardCard(
      title: 'Compétences vs. votre offre',
      trailing: Text(
        Placeholders.text(offerTitle),
        style: AppTextStyles.caption,
      ),
      child: Column(
        children: [
          _row(const [
            _HeaderCell('COMPÉTENCES'),
            _HeaderCell('REQUIS'),
            _HeaderCell('CANDIDAT'),
            _HeaderCell('STATUT'),
          ]),
          const SizedBox(height: AppSpacing.sm),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Aucune compétence renseignée.',
                style: AppTextStyles.caption,
              ),
            ),
          for (final skill in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: _row([
                Text(
                  Placeholders.text(skill.name),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  Placeholders.text(skill.requiredLevel),
                  style: AppTextStyles.caption.copyWith(fontSize: 14),
                ),
                Text(
                  Placeholders.text(skill.candidateLevel),
                  style: AppTextStyles.caption.copyWith(fontSize: 14),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusBadge(status: skill.status),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _row(List<Widget> cells) {
    return Row(
      children: [
        for (var i = 0; i < cells.length; i++)
          Expanded(flex: _flex[i], child: cells[i]),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.caption.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SkillStatus? status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      SkillStatus.exceeds => (AppColors.successSoft, AppColors.success),
      SkillStatus.meets => (AppColors.skySoft, AppColors.info),
      SkillStatus.toTrain => (AppColors.coralSoft, AppColors.error),
      null => (AppColors.surfaceMuted, AppColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status?.label ?? Placeholders.missing,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
