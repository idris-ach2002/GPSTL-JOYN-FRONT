# `matching_workbench.dart`

Explique l’analyse initiale du CV, le profil et les offres correspondantes sans calculer de score.

[Code source](../../../lib/features/landing/presentation/sections/matching_workbench.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`
- `../widgets/product_atmosphere.dart`
- `../widgets/navigation_symbol.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `MatchingWorkbench` | `Bibliothèque` | Explication interactive du CV au profil, puis des recommandations. | `class MatchingWorkbench extends StatefulWidget` |
| `MatchingWorkbench` | `MatchingWorkbench` | Initialise les paramètres de MatchingWorkbench ; les valeurs par défaut figurent dans la signature. | `const MatchingWorkbench({super.key})` |
| `_MatchingWorkbenchState` | `Bibliothèque` | État de MatchingWorkbench ; définit ses données mutables et son rendu. | `class _MatchingWorkbenchState extends State<MatchingWorkbench>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `MatchingWorkbench` | Crée l’état local associé au widget. | `State<MatchingWorkbench> createState()` |
| `build` | `_MatchingWorkbenchState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `selected` | `_MatchingWorkbenchState` | Indice de l’étape explicative sélectionnée. | `int selected = 0` |
| `steps` | `_MatchingWorkbenchState` | Contenu des étapes proposées dans cette section. | `static const steps = [ ('Ton CV, au départ', 'À la création de ton profil, joins ton CV. Son analyse permet de retrouver les informations nécessaires à la constitution de ton profil.', NavigationSymbolKind.cv), ('Ton profil prend forme', 'Les informations issues du CV servent à présenter ton parcours et tes compétences dans ton profil candidat.', NavigationSymbolKind.identity), ('Des offres qui correspondent', 'Les recommandations rapprochent ton profil des offres. Seules les offres correspondant à ton profil te sont présentées.', NavigationSymbolKind.matching), ]` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `i` | `_MatchingWorkbenchState` | Indice de parcours de la liste dans la boucle courante. | `var i=0;` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `MatchingWorkbench` | Identité du widget dans l’arbre Flutter. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |

