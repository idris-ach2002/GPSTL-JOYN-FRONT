// Présente les situations de recherche et la lecture concrète d’une offre.
//
// Référence : doc/landing.md#context_sectionsdart.

import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/product_atmosphere.dart';

/// Présentation de situations de recherche et des informations à comparer.
class SearchDifficultiesSection extends StatefulWidget {
  /// Initialise les paramètres de SearchDifficultiesSection ; les valeurs par défaut figurent dans la signature.
  const SearchDifficultiesSection({super.key});

  /// Crée l’état local associé au widget.
  @override
  State<SearchDifficultiesSection> createState() =>
      _SearchDifficultiesSectionState();
}

/// État de SearchDifficultiesSection ; définit ses données mutables et son rendu.
class _SearchDifficultiesSectionState extends State<SearchDifficultiesSection> {
  /// Indice ou indicateur d’activation utilisé par cette composition.
  int active = 0;

  /// Situations de recherche et informations associées.
  static const situations = [
    (
      'Le bon poste, le mauvais rythme.',
      'Camille repère une mission qui lui plaît. Son école impose trois jours en entreprise ; l’annonce parle d’une semaine sur deux.',
      'À rendre visible avant de candidater',
      'Le calendrier attendu, les jours de présence et la marge de discussion.',
    ),
    (
      'Une compétence difficile à raconter.',
      'Dart apparaît sur le profil de Camille. Mais un simple mot ne dit pas ce qu’elle a construit avec.',
      'À expliquer avec une preuve',
      'Le projet réalisé, sa contribution et ce qu’elle souhaite approfondir.',
    ),
    (
      'Un trajet qui change tout.',
      'Le poste semble intéressant, mais le lieu exact et les jours sur place restent flous.',
      'À comparer avec son contexte',
      'La localisation, les déplacements demandés et l’organisation du travail.',
    ),
    (
      'Une candidature sans prochaine étape.',
      'Camille ne sait plus si elle doit attendre, préparer un échange ou relire une offre.',
      'À clarifier dans le suivi',
      'Le statut de chaque démarche et l’action qu’elle peut préparer.',
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
          number: '02 / LE CONTEXTE',
          title: 'Chercher un poste,\nc’est aussi faire tenir une vie.',
          description: 'Lieu, rythme, compétences et suivi : les informations à retrouver dans sa recherche.',
        ),
        EditorialSplit(
          leading: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < situations.length; i++) ...[
                const Divider(),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: const ButtonStyle(alignment: Alignment.centerLeft),
                    onPressed: () => setState(() => active = i),
                    child: Text(
                      '${i == active ? '—' : '+'} ${situations[i].$1}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
              ],
            ],
          ),
          trailing: Semantics(
            liveRegion: true,
            child: ProductSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(situations[active].$2),
                  const SizedBox(height: JoynTokens.lg),
                  Text(
                    situations[active].$3,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: JoynTokens.md),
                  Text(situations[active].$4),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Décompose une offre concrète en missions, conditions et démarche de candidature.
class OfferDecisionSection extends StatefulWidget {
  const OfferDecisionSection({super.key});
  @override
  State<OfferDecisionSection> createState() => _OfferDecisionSectionState();
}

class _OfferDecisionSectionState extends State<OfferDecisionSection> {
  int selected = 0;
  static const details = [
    (
      'MISSIONS',
      'Qu’est-ce que je vais faire ?',
      'Développer des écrans Flutter',
      'Construire la liste des candidatures, relier les écrans de détail et vérifier les parcours au clavier.',
      'Compétences mobilisées',
      'Dart · Flutter · tests de widgets',
    ),
    (
      'CONDITIONS',
      'Dans quelles conditions ?',
      'Un poste à Paris, en alternance',
      'Trois jours en entreprise chaque semaine. Les jours de présence et les modalités de travail sont précisés dans l’offre.',
      'À lire avant de candidater',
      'Lieu · contrat · rythme de présence',
    ),
    (
      'CANDIDATURE',
      'Que se passe-t-il ensuite ?',
      'Retrouver chaque étape',
      'Consulter l’offre, présenter son profil et retrouver la candidature dans son suivi. Le recruteur la consulte avec les autres démarches liées au poste.',
      'Deux vues du même recrutement',
      'Suivi personnel · candidatures par offre',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final detail = details[selected];
    return EditorialSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            number: '03 / LIRE UNE OFFRE',
            title: 'Une offre lisible.\nUne décision concrète.',
            description: 'Les missions, les conditions et la candidature, à partir d’un exemple de poste en développement Flutter.',
          ),
          EditorialSplit(
            leading: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DÉVELOPPEMENT FLUTTER / EXEMPLE',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: JoynTokens.md),
                Text(
                  'Trois questions avant de candidater.',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: JoynTokens.md),
                for (var i = 0; i < details.length; i++) ...[
                  const Divider(),
                  Semantics(
                    selected: selected == i,
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        key: ValueKey('offer-detail-$i'),
                        style: const ButtonStyle(
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () => setState(() => selected = i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: JoynTokens.sm,
                          ),
                          child: Text(
                            '${selected == i ? '—' : '+'} ${details[i].$2}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: Semantics(
              liveRegion: true,
              child: ProductSurface(
                accent: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.$1,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: JoynTokens.md),
                    Text(
                      detail.$3,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: JoynTokens.md),
                    Text(detail.$4),
                    const SizedBox(height: JoynTokens.lg),
                    InformationRow(label: detail.$5, value: detail.$6),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
