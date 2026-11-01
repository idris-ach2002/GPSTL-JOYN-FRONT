import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/password_strength.dart';

/// Robustesse du mot de passe : [LinearProgressIndicator] + puces des règles.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({required this.strength, super.key});

  final PasswordStrength strength;

  static const _barColors = [
    AppColors.track,
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
    final textTheme = Theme.of(context).textTheme;
    final score = strength.score;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: score / 4),
                duration: const Duration(milliseconds: 250),
                // Barre décorative : la robustesse est annoncée par le
                // libellé texte à droite.
                builder: (context, value, _) => ExcludeSemantics(
                  child: LinearProgressIndicator(
                    value: value,
                    color: _barColors[score],
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 84,
              child: Text(
                strength.label,
                semanticsLabel: score == 0
                    ? null
                    : 'Robustesse du mot de passe : ${strength.label}',
                textAlign: TextAlign.right,
                style: textTheme.labelSmall?.copyWith(
                  color: _labelColors[score],
                  letterSpacing: 0,
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
            for (final rule in strength.rules)
              Chip(
                avatar: Icon(
                  rule.satisfied
                      ? Icons.check_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 14,
                  color: rule.satisfied
                      ? AppColors.successDeep
                      : AppColors.placeholder,
                ),
                label: Text(rule.label),
                labelStyle: textTheme.labelSmall?.copyWith(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  color: rule.satisfied
                      ? AppColors.successDeep
                      : AppColors.slate,
                ),
                backgroundColor: rule.satisfied
                    ? AppColors.successTint
                    : AppColors.background,
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
      ],
    );
  }
}
