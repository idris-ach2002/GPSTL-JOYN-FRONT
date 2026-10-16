// Présente les étapes du suivi d’une candidature à partir d’un exemple interactif.
//
// Référence : doc/landing/fichiers/application_tracking_section.md.

import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/product_atmosphere.dart';

/// Sélecteur des étapes d’une démarche de candidature.
class ApplicationTrackingSection extends StatefulWidget {
  /// Initialise les paramètres de ApplicationTrackingSection ; les valeurs par défaut figurent dans la signature.
  const ApplicationTrackingSection({super.key});

  /// Crée l’état local associé au widget.
  @override
  State<ApplicationTrackingSection> createState() =>
      _ApplicationTrackingSectionState();
}

/// État de ApplicationTrackingSection ; définit ses données mutables et son rendu.
class _ApplicationTrackingSectionState
    extends State<ApplicationTrackingSection> {
  /// Indice de l’étape actuellement affichée.
  int stage = 0;

  /// Contenu des étapes proposées dans cette section.
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

  /// Construit la présentation à partir de la configuration et de l’état courant.
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
