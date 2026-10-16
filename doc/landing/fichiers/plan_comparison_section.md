# `plan_comparison_section.dart`

Présente les services par acteur sans inventer de tarifs ni de conditions commerciales.

[Code source](../../../lib/features/landing/presentation/sections/plan_comparison_section.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `package:go_router/go_router.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`
- `../widgets/product_atmosphere.dart`
- `../widgets/navigation_symbol.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `PlanComparisonSection` | `Bibliothèque` | Sélection des services candidat ou entreprise. | `class PlanComparisonSection extends StatefulWidget` |
| `PlanComparisonSection` | `PlanComparisonSection` | Initialise les paramètres de PlanComparisonSection ; les valeurs par défaut figurent dans la signature. | `const PlanComparisonSection({super.key})` |
| `_PlanComparisonSectionState` | `Bibliothèque` | État de PlanComparisonSection ; définit ses données mutables et son rendu. | `class _PlanComparisonSectionState extends State<PlanComparisonSection>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `PlanComparisonSection` | Crée l’état local associé au widget. | `State<PlanComparisonSection> createState()` |
| `build` | `_PlanComparisonSectionState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `recruiters` | `_PlanComparisonSectionState` | Sélectionne les services entreprise plutôt que les services candidat. | `bool recruiters = false` |
| `candidateDetails` | `_PlanComparisonSectionState` | Services présentés pour la recherche de poste. | `static const candidateDetails = [ ('Profil', 'Présenter son parcours à partir de son CV'), ('Recommandations', 'Consulter les offres correspondant à son profil'), ('Candidatures', 'Retrouver ses démarches et leur statut'), ]` |
| `companyDetails` | `_PlanComparisonSectionState` | Services présentés pour le recrutement en entreprise. | `static const companyDetails = [ ('Offres', 'Présenter les missions et les attentes du poste'), ('Profils', 'Consulter les profils recommandés'), ('Candidatures', 'Organiser le suivi des candidatures par offre'), ]` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `PlanComparisonSection` | Identité du widget dans l’arbre Flutter. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |


## Variables de parcours

Ces variables prennent successivement les éléments de la collection indiquée ; elles ne constituent pas un état conservé entre deux rendus.

| Variable | Boucle et collection |
| --- | --- |
| `item` | `(final item in recruiters ? companyDetails : candidateDetails)` |
