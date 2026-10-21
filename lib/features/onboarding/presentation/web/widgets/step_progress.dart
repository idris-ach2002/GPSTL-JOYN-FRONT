import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_durations.dart';

/// Barre de progression « Étape 2 / 5 ».
class StepProgress extends StatelessWidget {
  const StepProgress({
    required this.step,
    required this.stepCount,
    this.width = 420,
    super.key,
  });

  final int step;
  final int stepCount;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Étape $step sur $stepCount',
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        child: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: Stack(
                  children: [
                    Container(height: 8, color: AppColors.track),
                    AnimatedFractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      duration: AppDurations.slow,
                      curve: Curves.easeOutCubic,
                      widthFactor: step / stepCount,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Étape $step / $stepCount',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.slateDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
