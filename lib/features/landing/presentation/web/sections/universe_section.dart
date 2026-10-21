import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/layout/content_container.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/landing/presentation/widgets/matching_story_demo.dart';
import 'package:joyn_front/features/landing/presentation/widgets/scroll_atmosphere.dart';

/// Rupture visuelle orange consacrée à la visite produit.
///
/// Les écrans présentés dans la démonstration proviennent directement de la
/// maquette JOYN fournie ; la landing anime ces visuels sans reconstruire une
/// interface parallèle qui risquerait de s'éloigner du produit.
class UniverseSection extends StatelessWidget {
  const UniverseSection({this.scrollController, super.key});

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final compactLaptop = viewport.width <= 1440 || viewport.height <= 900;
    final demoMaxWidth = compactLaptop ? 920.0 : 1020.0;

    return ScrollAtmosphere(
      universe: true,
      scrollController: scrollController,
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: EdgeInsets.only(
            top: compactLaptop ? 112 : 126,
            bottom: compactLaptop ? 124 : 142,
          ),
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
                  fontSize: viewport.width < 600
                      ? 36
                      : compactLaptop
                      ? 54
                      : 58,
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
              SizedBox(height: compactLaptop ? 30 : 36),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: demoMaxWidth),
                child: const MatchingStoryDemo(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
