// Compose l’entrée de page et l’accès à l’explication des recommandations.
//
// Référence : doc/landing.md#futurist_herodart.

import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/match_signature.dart';
import '../widgets/product_atmosphere.dart';
import '../widgets/gentle_depth.dart';
import '../widgets/mobile_chapter.dart';

/// Composition du titre principal, de son action et de la scène de mise en relation.
class FuturistHero extends StatelessWidget {
  /// Initialise les paramètres de FuturistHero ; les valeurs par défaut figurent dans la signature.
  const FuturistHero({super.key, required this.onExplore});

  /// Action appelée pour rejoindre l’explication ou le parcours.
  final VoidCallback onExplore;

  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => ProductAtmosphere(
    child: EditorialSection(
      transparent: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditorialSplit(
            leading: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LE MATCH AVANT LA CANDIDATURE',
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: JoynTokens.blue),
                ),
                const SizedBox(height: JoynTokens.lg),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Styles typographiques ou contenu du message, selon la portée.
                    final text = Theme.of(context).textTheme;
                    // Sélectionne une présentation compacte ou indique le mode de navigation mobile.
                    final compact = constraints.maxWidth < JoynTokens.mobile;
                    // Titre affiché dans cette composition.
                    final title =
                        (compact ? text.displayMedium : text.displayLarge)
                            ?.copyWith(color: JoynTokens.paper);
                    return Semantics(
                      header: true,
                      label: 'Joyn a job, with joy.',
                      child: ExcludeSemantics(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Joyn a job,', style: title),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text('With ', style: title),
                                Text(
                                  'joy.',
                                  style: TextStyle(
                                    fontFamily: 'GreatVibes',
                                    fontSize: JoynTokens.joySize,
                                    height: JoynTokens.titleHeight,
                                    color: JoynTokens.orangeLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: JoynTokens.md),
                Text(
                  'Ton prochain poste commence par ce qui te correspond.',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(color: JoynTokens.paper),
                ),
                const SizedBox(height: JoynTokens.md),
                Text(
                  'Tes compétences, ton rythme, ton trajet. JOYN met les points communs en lumière pour te permettre de choisir avant de candidater.',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: JoynTokens.paper),
                ),
                const SizedBox(height: JoynTokens.lg),
                FilledButton(
                  onPressed: onExplore,
                  child: const Text('COMPRENDRE LES RECOMMANDATIONS →'),
                ),
                const SizedBox(height: JoynTokens.md),
                Text(
                  'Candidats · Recruteurs',
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: JoynTokens.blue),
                ),
              ],
            ),
            trailing: MediaQuery.sizeOf(context).width < JoynTokens.mobile
                ? const MobileReveal(
                    label: 'VOIR LA RENCONTRE',
                    child: MatchSignature(),
                  )
                : const GentleDepth(child: MatchSignature()),
          ),
          const SizedBox(height: JoynTokens.xl),
          Divider(color: JoynTokens.cyan.withValues(alpha: .4)),
          const SizedBox(height: JoynTokens.md),
          Wrap(
            spacing: JoynTokens.lg,
            runSpacing: JoynTokens.sm,
            children: [
              for (final item in [
                '01 / UN PROFIL QUI TE RESSEMBLE',
                '02 / DES CRITÈRES EXPLIQUÉS',
                '03 / UN INTÉRÊT PARTAGÉ',
              ])
                Text(
                  item,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: JoynTokens.paper),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
