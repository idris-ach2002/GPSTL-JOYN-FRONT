// Présente les informations utiles à la recherche et une comparaison avant/après.
//
// Référence : doc/landing/fichiers/context_sections.md.

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
  State<SearchDifficultiesSection> createState() => _SearchDifficultiesSectionState();
}
/// État de SearchDifficultiesSection ; définit ses données mutables et son rendu.
class _SearchDifficultiesSectionState extends State<SearchDifficultiesSection> {
  /// Indice ou indicateur d’activation utilisé par cette composition.
  int active = 0;
  /// Situations de recherche et informations associées.
  static const situations = [
    ('Le bon poste, le mauvais rythme.', 'Camille repère une mission qui lui plaît. Son école impose trois jours en entreprise ; l’annonce parle d’une semaine sur deux.', 'À rendre visible avant de candidater', 'Le calendrier attendu, les jours de présence et la marge de discussion.'),
    ('Une compétence difficile à raconter.', 'Dart apparaît sur le profil de Camille. Mais un simple mot ne dit pas ce qu’elle a construit avec.', 'À expliquer avec une preuve', 'Le projet réalisé, sa contribution et ce qu’elle souhaite approfondir.'),
    ('Un trajet qui change tout.', 'Le poste semble intéressant, mais le lieu exact et les jours sur place restent flous.', 'À comparer avec son contexte', 'La localisation, les déplacements demandés et l’organisation du travail.'),
    ('Une candidature sans prochaine étape.', 'Camille ne sait plus si elle doit attendre, préparer un échange ou relire une offre.', 'À clarifier dans le suivi', 'Le statut de chaque démarche et l’action qu’elle peut préparer.'),
  ];
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => EditorialSection(tinted: true, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionHeading(number: '02 / LE CONTEXTE', title: 'Chercher un poste,\nc’est aussi faire tenir une vie.', description: 'Lieu, rythme, compétences et suivi : les informations à retrouver dans sa recherche.'),
    EditorialSplit(
      leading: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var i = 0; i < situations.length; i++) ...[
          const Divider(),
          SizedBox(width: double.infinity, child: TextButton(
            style: const ButtonStyle(alignment: Alignment.centerLeft),
            onPressed: () => setState(() => active = i),
            child: Text('${i == active ? '—' : '+'} ${situations[i].$1}', style: Theme.of(context).textTheme.headlineSmall),
          )),
        ],
      ]),
      trailing: Semantics(liveRegion: true, child: ProductSurface(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(situations[active].$2), const SizedBox(height: JoynTokens.lg),
        Text(situations[active].$3, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: JoynTokens.md), Text(situations[active].$4),
      ]))),
    ),
  ]));
}
/// Comparaison entre une recherche sans contexte et une lecture structurée.
class BeforeAfterSection extends StatefulWidget {
  /// Initialise les paramètres de BeforeAfterSection ; les valeurs par défaut figurent dans la signature.
  const BeforeAfterSection({super.key});
  /// Crée l’état local associé au widget.
  @override
  State<BeforeAfterSection> createState() => _BeforeAfterSectionState();
}
/// État de BeforeAfterSection ; définit ses données mutables et son rendu.
class _BeforeAfterSectionState extends State<BeforeAfterSection> {
  /// Sélectionne la présentation avec informations de contexte.
  bool contextual = true;
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => EditorialSection(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionHeading(number: '03 / AVANT ET AVEC LE CONTEXTE', title: 'La même offre.\nUne décision mieux éclairée.'),
    Wrap(spacing: JoynTokens.sm, runSpacing: JoynTokens.xs, children: [
      Semantics(selected: !contextual, child: OutlinedButton(onPressed: () => setState(() => contextual = false), child: const Text('ANNONCE SEULE'))),
      Semantics(selected: contextual, child: FilledButton(onPressed: () => setState(() => contextual = true), child: const Text('AVEC MON CONTEXTE'))),
    ]),
    const SizedBox(height: JoynTokens.lg),
    EditorialSplit(
      leading: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Développement Flutter', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: JoynTokens.md), const Text('Contribuer à une interface produit et participer aux échanges avec l’équipe.'),
        const SizedBox(height: JoynTokens.md), const InformationRow(label: 'Contrat', value: 'Alternance'),
        const InformationRow(label: 'Ville', value: 'Paris'),
      ]),
      trailing: Semantics(liveRegion: true, child: ProductSurface(accent: contextual, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(contextual ? 'Ce que Camille peut comparer' : 'Ce qui reste à demander', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: JoynTokens.md),
        InformationRow(label: 'Rythme', value: contextual ? '3 jours : compatible' : 'Non précisé'),
        InformationRow(label: 'Compétence', value: contextual ? 'Dart et Flutter' : 'Niveau à clarifier'),
        InformationRow(label: 'Mobilité', value: contextual ? 'Paris : même ville' : 'À rapprocher du profil'),
        const SizedBox(height: JoynTokens.md),
        Text(contextual ? 'Exemple de lecture contextualisée ; cela ne garantit ni sélection ni entretien.' : 'Une annonce seule ne connaît pas les contraintes de Camille.'),
      ]))),
    ),
  ]));
}
