import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../widgets/matching_story_demo.dart';
import '../widgets/scroll_atmosphere.dart';

/// Rupture visuelle orange : une démonstration animée remplace l'ancien score
/// isolé et raconte maintenant le parcours complet côté candidat et entreprise.
class UniverseSection extends StatelessWidget {
  const UniverseSection({this.scrollController, super.key});
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => ScrollAtmosphere(
    universe: true,
    scrollController: scrollController,
    child: ContentContainer(
      maxWidth: 1240,
      child: Padding(
        padding: const EdgeInsets.only(top: 150, bottom: 170),
        child: Column(
          children: [
            const Text(
              'JOYN, EN MOUVEMENT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.1,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Le parcours complet,\nen quelques secondes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: MediaQuery.sizeOf(context).width < 600 ? 39 : 64,
                fontWeight: FontWeight.w900,
                height: 1.02,
                letterSpacing: -2,
                shadows: [
                  Shadow(
                    color: AppColors.orangeLight.withValues(alpha: .5),
                    blurRadius: 35,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 700),
              child: Text(
                'Passe du profil à l’entretien côté candidat, puis de la publication '
                'd’une offre au suivi du recrutement côté entreprise.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 52),
            const MatchingStoryDemo(),
          ],
        ),
      ),
    ),
  );
}
