# `editorial_layout.dart`

Fournit les compositions de section, de titre, de colonnes et de lignes d’information.

[Code source](../../../lib/features/landing/presentation/widgets/editorial_layout.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `EditorialSection` | `Bibliothèque` | Cadre de section qui applique largeur maximale, marges et fond. | `class EditorialSection extends StatelessWidget` |
| `EditorialSection` | `EditorialSection` | Initialise les paramètres de EditorialSection ; les valeurs par défaut figurent dans la signature. | `const EditorialSection({super.key, required this.child, this.tinted = false, this.transparent = false})` |
| `SectionHeading` | `Bibliothèque` | En-tête de section avec repère, titre sémantique et description facultative. | `class SectionHeading extends StatelessWidget` |
| `SectionHeading` | `SectionHeading` | Initialise les paramètres de SectionHeading ; les valeurs par défaut figurent dans la signature. | `const SectionHeading({super.key, required this.number, required this.title, this.description})` |
| `EditorialSplit` | `Bibliothèque` | Deux colonnes qui deviennent une pile lorsque la largeur manque. | `class EditorialSplit extends StatelessWidget` |
| `EditorialSplit` | `EditorialSplit` | Initialise les paramètres de EditorialSplit ; les valeurs par défaut figurent dans la signature. | `const EditorialSplit({super.key, required this.leading, required this.trailing})` |
| `InformationRow` | `Bibliothèque` | Couple libellé/valeur séparé par un filet horizontal. | `class InformationRow extends StatelessWidget` |
| `InformationRow` | `InformationRow` | Initialise les paramètres de InformationRow ; les valeurs par défaut figurent dans la signature. | `const InformationRow({super.key, required this.label, required this.value})` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `build` | `EditorialSection` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `build` | `SectionHeading` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `build` | `EditorialSplit` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `build` | `InformationRow` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `child` | `EditorialSection` | Contenu enveloppé par le composant. | `final Widget child` |
| `tinted` | `EditorialSection` | Applique le fond canvas à la section. | `final bool tinted` |
| `transparent` | `EditorialSection` | Laisse apparaître le fond du parent. | `final bool transparent` |
| `number` | `SectionHeading` | Repère éditorial placé avant le titre. | `final String number` |
| `title` | `SectionHeading` | Titre affiché dans cette composition. | `final String title` |
| `description` | `SectionHeading` | Texte de contexte associé au titre ou au lien. | `final String? description` |
| `leading` | `EditorialSplit` | Contenu de la première colonne. | `final Widget leading` |
| `trailing` | `EditorialSplit` | Contenu de la seconde colonne. | `final Widget trailing` |
| `label` | `InformationRow` | Libellé présenté à l’utilisateur. | `final String label` |
| `value` | `InformationRow` | Valeur reçue par le paramètre ou affichée dans la ligne, selon la portée. | `final String value` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `compact` | `EditorialSection` | Sélectionne une présentation compacte ou indique le mode de navigation mobile. | `final compact = constraints.maxWidth < JoynTokens.mobile;` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `EditorialSection` | Identité du widget dans l’arbre Flutter. |
| `this.child` | `EditorialSection` | Contenu enveloppé par le composant. |
| `this.tinted` | `EditorialSection` | Applique le fond canvas à la section. |
| `this.transparent` | `EditorialSection` | Laisse apparaître le fond du parent. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `context` | `EditorialSection` | Contexte Flutter de l’élément en cours de construction. |
| `constraints` | `EditorialSection` | Contraintes de largeur et de hauteur reçues du parent. |
| `super.key` | `SectionHeading` | Identité du widget dans l’arbre Flutter. |
| `this.number` | `SectionHeading` | Repère éditorial placé avant le titre. |
| `this.title` | `SectionHeading` | Titre affiché dans cette composition. |
| `this.description` | `SectionHeading` | Texte de contexte associé au titre ou au lien. |
| `super.key` | `EditorialSplit` | Identité du widget dans l’arbre Flutter. |
| `this.leading` | `EditorialSplit` | Contenu de la première colonne. |
| `this.trailing` | `EditorialSplit` | Contenu de la seconde colonne. |
| `context` | `EditorialSplit` | Contexte Flutter de l’élément en cours de construction. |
| `constraints` | `EditorialSplit` | Contraintes de largeur et de hauteur reçues du parent. |
| `super.key` | `InformationRow` | Identité du widget dans l’arbre Flutter. |
| `this.label` | `InformationRow` | Libellé présenté à l’utilisateur. |
| `this.value` | `InformationRow` | Valeur reçue par le paramètre ou affichée dans la ligne, selon la portée. |

