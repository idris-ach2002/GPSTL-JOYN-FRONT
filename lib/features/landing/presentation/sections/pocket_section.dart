// Présente le parcours sur téléphone et un accès aux étapes du candidat.
//
// Référence : doc/landing/fichiers/pocket_section.md.

import 'package:flutter/material.dart';
import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/person_portrait.dart';
import '../widgets/product_atmosphere.dart';
/// Présentation du parcours sur téléphone.
class PocketSection extends StatelessWidget {
  /// Initialise les paramètres de PocketSection ; les valeurs par défaut figurent dans la signature.
  const PocketSection({super.key, required this.onExplore});
  /// Action appelée pour rejoindre l’explication ou le parcours.
  final VoidCallback onExplore;
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => ProductAtmosphere(
    child: EditorialSection(transparent: true, child: EditorialSplit(
      leading: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: JoynTokens.smallPreview),
        child: ProductSurface(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: JoynTokens.lg, height: JoynTokens.hairline, color: JoynTokens.ink)),
          const SizedBox(height: JoynTokens.md),
          const PersonPortrait(),
          const SizedBox(height: JoynTokens.md),
          Text('Une offre à\nta mesure.', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: JoynTokens.sm),
          const Text('Développement Flutter\nParis · Alternance'),
          const SizedBox(height: JoynTokens.md),
          const Divider(),
          const SizedBox(height: JoynTokens.md),
          const Text('Un lieu commun.\nUn rythme compatible.\nDes compétences en commun.'),
          const SizedBox(height: JoynTokens.md),
          FilledButton(onPressed: onExplore, child: const Text('VOIR LES CRITÈRES')),
        ])),
      )),
      trailing: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('JOYN, AUSSI SUR TÉLÉPHONE', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: JoynTokens.blue)),
        const SizedBox(height: JoynTokens.md),
        Text('Ton parcours,\nà portée de main.', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: JoynTokens.paper)),
        const SizedBox(height: JoynTokens.md),
        Text('Comparer une offre entre deux cours. Relire les attentes avant un échange. La présentation s’adapte à l’écran que tu utilises.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: JoynTokens.paper)),
        const SizedBox(height: JoynTokens.lg),
        Text('Aperçu illustratif de l’interface mobile', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: JoynTokens.blue)),
      ]),
    )),
  );
}
