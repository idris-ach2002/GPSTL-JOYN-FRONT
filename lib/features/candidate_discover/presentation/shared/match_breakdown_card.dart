import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../domain/recommended_offer.dart';

/// Panneau « Pourquoi 92 % ? » : une barre par critère du score.
class MatchBreakdownCard extends StatelessWidget {
  const MatchBreakdownCard({
    super.key,
    required this.offer,
    this.onSkillGap,
    this.framed = true,
  });

  final RecommendedOffer offer;
  final VoidCallback? onSkillGap;

  /// `false` pour l'afficher sans fond (ex. dans une bottom sheet).
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pourquoi ${offer.compatibility} % ?',
          style: const TextStyle(
            fontFamily: AppFonts.display,
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        if (offer.criteria.isEmpty)
          const Text(
            'Le détail du score sera bientôt disponible.',
            style: TextStyle(fontFamily: AppFonts.body, color: AppColors.slate),
          ),
        for (final criterion in offer.criteria)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _CriterionBar(criterion: criterion),
          ),
        TextButton(
          onPressed: onSkillGap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: AppColors.navy,
            textStyle: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Voir mon Skill Gap →'),
        ),
      ],
    );

    if (!framed) return content;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.skyTint,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
      ),
      child: Padding(padding: const EdgeInsets.all(22), child: content),
    );
  }
}

class _CriterionBar extends StatelessWidget {
  const _CriterionBar({required this.criterion});

  final MatchCriterion criterion;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${criterion.label} : ${criterion.score} %',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  criterion.label,
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    color: AppColors.slate,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${criterion.score}%',
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: criterion.score / 100,
              minHeight: 7,
              color: AppColors.navy,
              backgroundColor: AppColors.skyMist,
            ),
          ),
        ],
      ),
    );
  }
}
