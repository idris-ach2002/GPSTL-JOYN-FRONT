import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';

/// Rupture orange statique : ni cercle, ni ticker, ni carrousel, ni analyse CV.
/// Le changement d'univers repose sur la couleur et la typographie uniquement.
class UniverseSection extends StatelessWidget {
  const UniverseSection({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.orange,
    child: ContentContainer(maxWidth: 1240,
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 88),
        child: Column(children: [
          const Text('DEUX PARCOURS. UNE RENCONTRE.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.navy, fontSize: 12,
              fontWeight: FontWeight.w800, letterSpacing: 2)),
          const SizedBox(height: 20),
          Text('Moins de distance.\nPlus de possibilités.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.white,
              fontSize: MediaQuery.sizeOf(context).width < 600 ? 38 : 64,
              fontWeight: FontWeight.w900, height: 1.05, letterSpacing: -1.5)),
          const SizedBox(height: 24),
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600),
            child: const Text('Un profil, une offre, une conversation. '
              'JOYN réunit les étapes pour avancer vers la bonne rencontre.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.navy, fontSize: 18, height: 1.6))),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/inscription'),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Commencer avec JOYN')),
        ])),
    ),
  );
}
