# `pocket_section.dart`

Présente le parcours sur téléphone et un accès aux étapes du candidat.

[Code source](../../../lib/features/landing/presentation/sections/pocket_section.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`
- `../widgets/person_portrait.dart`
- `../widgets/product_atmosphere.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `PocketSection` | `Bibliothèque` | Présentation du parcours sur téléphone. | `class PocketSection extends StatelessWidget` |
| `PocketSection` | `PocketSection` | Initialise les paramètres de PocketSection ; les valeurs par défaut figurent dans la signature. | `const PocketSection({super.key, required this.onExplore})` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `build` | `PocketSection` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `onExplore` | `PocketSection` | Action appelée pour rejoindre l’explication ou le parcours. | `final VoidCallback onExplore` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `PocketSection` | Identité du widget dans l’arbre Flutter. |
| `this.onExplore` | `PocketSection` | Action appelée pour rejoindre l’explication ou le parcours. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |

