# `context_sections.dart`

Présente les informations utiles à la recherche et une comparaison avant/après.

[Code source](../../../lib/features/landing/presentation/sections/context_sections.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`
- `../widgets/product_atmosphere.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `SearchDifficultiesSection` | `Bibliothèque` | Présentation de situations de recherche et des informations à comparer. | `class SearchDifficultiesSection extends StatefulWidget` |
| `SearchDifficultiesSection` | `SearchDifficultiesSection` | Initialise les paramètres de SearchDifficultiesSection ; les valeurs par défaut figurent dans la signature. | `const SearchDifficultiesSection({super.key})` |
| `_SearchDifficultiesSectionState` | `Bibliothèque` | État de SearchDifficultiesSection ; définit ses données mutables et son rendu. | `class _SearchDifficultiesSectionState extends State<SearchDifficultiesSection>` |
| `BeforeAfterSection` | `Bibliothèque` | Comparaison entre une recherche sans contexte et une lecture structurée. | `class BeforeAfterSection extends StatefulWidget` |
| `BeforeAfterSection` | `BeforeAfterSection` | Initialise les paramètres de BeforeAfterSection ; les valeurs par défaut figurent dans la signature. | `const BeforeAfterSection({super.key})` |
| `_BeforeAfterSectionState` | `Bibliothèque` | État de BeforeAfterSection ; définit ses données mutables et son rendu. | `class _BeforeAfterSectionState extends State<BeforeAfterSection>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `SearchDifficultiesSection` | Crée l’état local associé au widget. | `State<SearchDifficultiesSection> createState()` |
| `build` | `_SearchDifficultiesSectionState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `createState` | `BeforeAfterSection` | Crée l’état local associé au widget. | `State<BeforeAfterSection> createState()` |
| `build` | `_BeforeAfterSectionState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `active` | `_SearchDifficultiesSectionState` | Indice ou indicateur d’activation utilisé par cette composition. | `int active = 0` |
| `situations` | `_SearchDifficultiesSectionState` | Situations de recherche et informations associées. | `static const situations = [ ('Le bon poste, le mauvais rythme.', 'Camille repère une mission qui lui plaît. Son école impose trois jours en entreprise ; l’annonce parle d’une semaine sur deux.', 'À rendre visible avant de candidater', 'Le calendrier attendu, les jours de présence et la marge de discussion.'), ('Une compétence difficile à raconter.', 'Dart apparaît sur le profil de Camille. Mais un simple mot ne dit pas ce qu’elle a construit avec.', 'À expliquer avec une preuve', 'Le projet réalisé, sa contribution et ce qu’elle souhaite approfondir.'), ('Un trajet qui change tout.', 'Le poste semble intéressant, mais le lieu exact et les jours sur place restent flous.', 'À comparer avec son contexte', 'La localisation, les déplacements demandés et l’organisation du travail.'), ('Une candidature sans prochaine étape.', 'Camille ne sait plus si elle doit attendre, préparer un échange ou relire une offre.', 'À clarifier dans le suivi', 'Le statut de chaque démarche et l’action qu’elle peut préparer.'), ]` |
| `contextual` | `_BeforeAfterSectionState` | Sélectionne la présentation avec informations de contexte. | `bool contextual = true` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `i` | `_SearchDifficultiesSectionState` | Indice de parcours de la liste dans la boucle courante. | `var i = 0;` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `SearchDifficultiesSection` | Identité du widget dans l’arbre Flutter. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `super.key` | `BeforeAfterSection` | Identité du widget dans l’arbre Flutter. |

