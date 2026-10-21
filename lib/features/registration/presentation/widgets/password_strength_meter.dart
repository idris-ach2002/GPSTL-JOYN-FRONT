import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_durations.dart';
import '../../domain/password_strength.dart';

/// Jauge à 4 segments + règles du mot de passe.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({required this.strength, super.key});

  final PasswordStrength strength;

  static const _barColors = [
    AppColors.error,
    AppColors.orangeLight,
    AppColors.cyanBlue,
    AppColors.success,
  ];

  static const _labelColors = [
    AppColors.slate,
    AppColors.errorDeep,
    AppColors.warningDeep,
    AppColors.navyLight,
    AppColors.successDeep,
  ];

  @override
  Widget build(BuildContext context) {
    final score = strength.score;
    final activeColor = score == 0 ? AppColors.track : _barColors[score - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    for (var i = 0; i < 4; i++) ...[
                      if (i > 0) const SizedBox(width: 5),
                      Expanded(
                        child: AnimatedContainer(
                          duration: AppDurations.normal,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i < score ? activeColor : AppColors.track,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 84,
              child: Semantics(
                liveRegion: true,
                label: score == 0 ? null : 'Robustesse : ${strength.label}',
                child: Text(
                  strength.label,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _labelColors[score],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final rule in strength.rules) _RuleChip(rule: rule),
          ],
        ),
      ],
    );
  }
}

class _RuleChip extends StatelessWidget {
  const _RuleChip({required this.rule});

  final PasswordRule rule;

  @override
  Widget build(BuildContext context) {
    final ok = rule.satisfied;
    return Semantics(
      label: '${rule.label} : ${ok ? 'respecté' : 'manquant'}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: ok ? AppColors.successTint : AppColors.background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ok)
              const Icon(
                Icons.check_rounded,
                size: 12,
                color: AppColors.successDeep,
              )
            else
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.placeholder,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 5),
            Text(
              rule.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ok ? AppColors.successDeep : AppColors.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
