import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/landing_content.dart';
import '../widgets/feature_demo.dart';
import '../widgets/scroll_atmosphere.dart';

/// Changement d'univers : fondu navy/orange/lumière, grille et halos diffus.
/// Le panneau central illustre le score sans réintroduire une analyse de CV.
class UniverseSection extends StatelessWidget {
  const UniverseSection({this.scrollController, super.key});
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => ScrollAtmosphere(
    universe: true, scrollController: scrollController,
    child: ContentContainer(maxWidth: 1240,
      child: Padding(padding: const EdgeInsets.only(top: 160, bottom: 180),
        child: Column(children: [
          const Text('LE MATCHING, EN LUMIÈRE', textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.navy, fontSize: 12,
              fontWeight: FontWeight.w800, letterSpacing: 2.1)),
          const SizedBox(height: 24),
          Text('Un score utile\ndoit être explicable.', textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.white,
              fontSize: MediaQuery.sizeOf(context).width < 600 ? 38 : 64,
              fontWeight: FontWeight.w900, height: 1.02, letterSpacing: -2,
              shadows: [Shadow(color: AppColors.orangeLight.withValues(alpha: .5),
                blurRadius: 35)])),
          const SizedBox(height: 24),
          const _UniverseDescription(),
          const SizedBox(height: 48),
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 700),
            child: Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: AppColors.white.withValues(alpha: .45)),
                boxShadow: [BoxShadow(color: AppColors.navy.withValues(alpha: .2),
                  blurRadius: 70, offset: const Offset(0, 28))]),
              child: const FeatureDemo(audience: Audience.candidate, index: 1))),
        ])),
    ),
  );
}

/// Texte borné pour préserver les proportions du titre sans largeur fixe.
class _UniverseDescription extends StatelessWidget {
  const _UniverseDescription({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 640),
    child: const Text('Derrière un pourcentage, des points concrets. '
      'Explore les critères, comprends ce qui rapproche un profil et une offre.',
      textAlign: TextAlign.center,
      style: TextStyle(color: AppColors.navy, fontSize: 18, height: 1.6)),
  );
}
