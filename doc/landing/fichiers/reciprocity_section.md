# `reciprocity_section.dart`

Distingue les intérêts candidat et entreprise avant l’ouverture d’un échange illustré.

[Code source](../../../lib/features/landing/presentation/sections/reciprocity_section.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`
- `../widgets/person_portrait.dart`
- `../widgets/product_atmosphere.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `ReciprocitySection` | `Bibliothèque` | Présentation des quatre combinaisons d’intérêt candidat et entreprise. | `class ReciprocitySection extends StatefulWidget` |
| `ReciprocitySection` | `ReciprocitySection` | Initialise les paramètres de ReciprocitySection ; les valeurs par défaut figurent dans la signature. | `const ReciprocitySection({super.key})` |
| `_ReciprocitySectionState` | `Bibliothèque` | État de ReciprocitySection ; définit ses données mutables et son rendu. | `class _ReciprocitySectionState extends State<ReciprocitySection>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `ReciprocitySection` | Crée l’état local associé au widget. | `State<ReciprocitySection> createState()` |
| `build` | `_ReciprocitySectionState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `candidate` | `_ReciprocitySectionState` | Intérêt exprimé du côté candidat dans la scène interactive. | `bool candidate = false` |
| `company` | `_ReciprocitySectionState` | Intérêt exprimé du côté entreprise dans la scène interactive. | `bool company = false` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `ReciprocitySection` | Identité du widget dans l’arbre Flutter. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |

