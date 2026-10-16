// Explique l’analyse initiale du CV, le profil et les offres correspondantes sans calculer de score.
//
// Référence : doc/landing/fichiers/matching_workbench.md.

import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/product_atmosphere.dart';
import '../widgets/navigation_symbol.dart';

/// Explication interactive du CV au profil, puis des recommandations.
class MatchingWorkbench extends StatefulWidget {
  /// Initialise les paramètres de MatchingWorkbench ; les valeurs par défaut figurent dans la signature.
  const MatchingWorkbench({super.key});

  /// Crée l’état local associé au widget.
  @override
  State<MatchingWorkbench> createState() => _MatchingWorkbenchState();
}

/// État de MatchingWorkbench ; définit ses données mutables et son rendu.
class _MatchingWorkbenchState extends State<MatchingWorkbench> {
  /// Indice de l’étape explicative sélectionnée.
  int selected = 0;

  /// Contenu des étapes proposées dans cette section.
  static const steps = [
    (
      'Ton CV, au départ',
      'À la création de ton profil, joins ton CV. Son analyse permet de retrouver les informations nécessaires à la constitution de ton profil.',
      NavigationSymbolKind.cv,
    ),
    (
      'Ton profil prend forme',
      'Les informations issues du CV servent à présenter ton parcours et tes compétences dans ton profil candidat.',
      NavigationSymbolKind.identity,
    ),
    (
      'Des offres qui correspondent',
      'Les recommandations rapprochent ton profil des offres. Seules les offres correspondant à ton profil te sont présentées.',
      NavigationSymbolKind.matching,
    ),
  ];

  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => EditorialSection(
    tinted: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          number: '05 / LE FONCTIONNEMENT',
          title: 'Du CV aux offres\nqui te correspondent.',
          description: 'Une analyse à la création du profil, puis des recommandations pour orienter ta recherche.',
        ),
        Wrap(
          spacing: JoynTokens.sm,
          runSpacing: JoynTokens.sm,
          children: [
            for (var i = 0; i < steps.length; i++)
              Semantics(
                selected: selected == i,
                child: OutlinedButton(
                  key: ValueKey('analysis-step-$i'),
                  onPressed: () => setState(() => selected = i),
                  child: Text(steps[i].$1),
                ),
              ),
          ],
        ),
        const SizedBox(height: JoynTokens.lg),
        Semantics(
          liveRegion: true,
          child: ProductSurface(
            accent: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NavigationSymbol(kind: steps[selected].$3, active: true),
                const SizedBox(height: JoynTokens.md),
                Text(
                  steps[selected].$1,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: JoynTokens.md),
                Text(steps[selected].$2),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
