import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/placeholders.dart';
import '../../domain/experience.dart';
import 'dashboard_card.dart';

/// Carte « Parcours » : expériences du candidat, de la plus récente à la
/// plus ancienne.
class ExperienceCard extends StatelessWidget {
  const ExperienceCard({super.key, required this.experiences});

  final List<Experience>? experiences;

  @override
  Widget build(BuildContext context) {
    final items = experiences ?? const <Experience>[];

    return DashboardCard(
      title: 'Parcours',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            const Text(
              'Aucune expérience renseignée.',
              style: AppTextStyles.caption,
            ),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : AppSpacing.lg),
              child: _ExperienceTile(
                experience: items[i],
                colors: AppColors.tilePalette[i % AppColors.tilePalette.length],
              ),
            ),
        ],
      ),
    );
  }
}

class _ExperienceTile extends StatelessWidget {
  const _ExperienceTile({required this.experience, required this.colors});

  final Experience experience;

  /// (fond, lettre) de la pastille.
  final (Color, Color) colors;

  @override
  Widget build(BuildContext context) {
    final title = experience.title?.trim();
    final letter = (title == null || title.isEmpty)
        ? Placeholders.missing
        : title[0].toUpperCase();
    final details = [
      experience.organization,
      experience.period,
    ].map(Placeholders.text).join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.$1,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            letter,
            style: TextStyle(
              color: colors.$2,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Placeholders.text(experience.title),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(details, style: AppTextStyles.muted),
              if (experience.description != null)
                Text(experience.description!, style: AppTextStyles.muted),
            ],
          ),
        ),
      ],
    );
  }
}
