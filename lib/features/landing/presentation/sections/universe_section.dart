import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../widgets/matching_story_demo.dart';
import '../widgets/scroll_atmosphere.dart';

/// Rupture visuelle orange consacrée à la visite produit.
///
/// Les écrans présentés dans la démonstration proviennent directement de la
/// maquette JOYN fournie ; la landing anime ces visuels sans reconstruire une
/// interface parallèle qui risquerait de s'éloigner du produit.
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
        padding: const EdgeInsets.only(top: 132, bottom: 148),
        child: Column(
          children: [
            const Text(
              'LE PRODUIT, EN ACTION',
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
              'De la découverte au match.\nVois JOYN en action.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: MediaQuery.sizeOf(context).width < 600 ? 37 : 60,
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
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: const Text(
                'Choisis ton parcours et suis les écrans clés, du premier '
                'signal jusqu’au suivi de la candidature ou du recrutement.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const MatchingStoryDemo(),
          ],
        ),
      ),
    ),
  );
}
