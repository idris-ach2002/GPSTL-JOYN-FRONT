import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/product_atmosphere.dart';

class ApplicationTrackingSection extends StatefulWidget {
  const ApplicationTrackingSection({super.key});
  @override
  State<ApplicationTrackingSection> createState() =>
      _ApplicationTrackingSectionState();
}

class _ApplicationTrackingSectionState
    extends State<ApplicationTrackingSection> {
  int stage = 0;
  static const steps = [
    (
      'Enregistrée',
      'Relire les missions et noter ses questions.',
      'Camille garde une offre pour y revenir avec son calendrier de formation.',
    ),
    (
      'Intérêt exprimé',
      'Conserver une trace de ce qui motive la démarche.',
      'Camille a exprimé son intérêt pour cette offre.',
    ),
    (
      'Échange',
      'Préparer une explication de son projet.',
      'Un intérêt réciproque permet maintenant d’illustrer un premier échange.',
    ),
    (
      'Entretien',
      'Clarifier le format et les points à préparer.',
      'Camille prépare ses exemples et les questions sur les missions, le rythme et l’accompagnement.',
    ),
  ];
  @override
  Widget build(BuildContext context) => EditorialSection(
    tinted: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          number: '10 / SUIVI DES DÉMARCHES',
          title: 'Savoir où tu en es.\nChoisir ce que tu prépares.',
          description: 'Un aperçu des étapes pour retrouver chaque candidature et préparer la suite.',
        ),
        Wrap(
          spacing: JoynTokens.sm,
          runSpacing: JoynTokens.sm,
          children: [
            for (var i = 0; i < steps.length; i++)
              Semantics(
                selected: stage == i,
                child: OutlinedButton(
                  onPressed: () => setState(() => stage = i),
                  child: Text(
                    '${i + 1} / ${steps[i].$1}${stage == i ? ' —' : ''}',
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: JoynTokens.lg),
        Semantics(
          liveRegion: true,
          child: ProductSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Développement Flutter · ${steps[stage].$1}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: JoynTokens.md),
                Text(steps[stage].$3),
                const SizedBox(height: JoynTokens.md),
                const Divider(),
                const SizedBox(height: JoynTokens.md),
                InformationRow(label: 'À préparer', value: steps[stage].$2),
                const InformationRow(
                  label: 'À garder sous la main',
                  value: 'Offre, calendrier et exemple de projet',
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
