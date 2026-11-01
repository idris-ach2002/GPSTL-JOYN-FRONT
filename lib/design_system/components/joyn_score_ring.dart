import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// Score de compatibilité (0 à 100) : un [CircularProgressIndicator]
/// déterminé, avec le pourcentage au centre.
class JoynScoreRing extends StatelessWidget {
  const JoynScoreRing({required this.score, this.size = 40, super.key})
    : assert(score >= 0 && score <= 100);

  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Compatibilité $score %',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: score / 100,
              strokeWidth: size * 0.11,
              color: AppColors.navy,
              backgroundColor: AppColors.skyMist,
            ),
            Center(
              child: Text(
                '$score%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: size * 0.25,
                  letterSpacing: 0,
                  color: AppColors.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
