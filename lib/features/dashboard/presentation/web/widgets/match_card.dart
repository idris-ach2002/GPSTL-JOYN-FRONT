import 'package:flutter/material.dart';

import 'package:joyn_front/core/theme/app_colors.dart';
import 'package:joyn_front/core/theme/app_dimens.dart';
import 'package:joyn_front/core/theme/app_text_styles.dart';
import 'package:joyn_front/core/utils/placeholders.dart';
import 'package:joyn_front/features/dashboard/presentation/widgets/dashboard_card.dart';

/// Score d'adéquation (anneau), classement et points forts du match.
class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.score,
    required this.label,
    required this.ranking,
    required this.highlights,
  });

  final int? score;
  final String? label;
  final String? ranking;
  final List<String>? highlights;

  @override
  Widget build(BuildContext context) {
    final lines = (highlights == null || highlights!.isEmpty)
        ? const [Placeholders.missing]
        : highlights!;

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ScoreRing(score: score),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Placeholders.text(label),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Placeholders.text(ranking),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(line, style: AppTextStyles.caption),
            ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score});

  final int? score;

  @override
  Widget build(BuildContext context) {
    const size = 64.0;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: (score ?? 0).clamp(0, 100) / 100,
            strokeWidth: 6,
            strokeCap: StrokeCap.round,
            color: AppColors.navy,
            backgroundColor: AppColors.surfaceMuted,
          ),
          Center(
            child: Text(
              Placeholders.percent(score),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
