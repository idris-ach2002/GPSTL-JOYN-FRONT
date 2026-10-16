# `resources_section.dart`

Présente les accès aux trois guides de préparation.

[Code source](../../../lib/features/landing/presentation/sections/resources_section.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `ResourcesSection` | `Bibliothèque` | Liens vers les guides du profil, des recommandations et de l’entretien. | `class ResourcesSection extends StatelessWidget` |
| `ResourcesSection` | `ResourcesSection` | Initialise les paramètres de ResourcesSection ; les valeurs par défaut figurent dans la signature. | `const ResourcesSection({super.key, required this.onOpen})` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `build` | `ResourcesSection` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `onOpen` | `ResourcesSection` | Action de navigation vers le guide sélectionné. | `final ValueChanged<String> onOpen` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `ResourcesSection` | Identité du widget dans l’arbre Flutter. |
| `this.onOpen` | `ResourcesSection` | Action de navigation vers le guide sélectionné. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |


## Variables de parcours

Ces variables prennent successivement les éléments de la collection indiquée ; elles ne constituent pas un état conservé entre deux rendus.

| Variable | Boucle et collection |
| --- | --- |
| `item` | `(final item in const [ ('01', 'Présenter son profil', 'Relier une compétence à une réalisation, expliquer sa contribution et rendre ses contraintes lisibles.', 'guide-profil'), ('02', 'Lire un matching', 'Comprendre l’analyse du CV et les offres correspondant au profil.', 'guide-matching'), ('03', 'Préparer un entretien', 'Raconter un projet, choisir une difficulté à expliquer et préparer ses questions.', 'guide-entretien'), ])` |
