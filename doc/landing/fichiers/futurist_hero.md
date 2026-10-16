# `futurist_hero.dart`

Compose l’entrée de page et l’accès à l’explication des recommandations.

[Code source](../../../lib/features/landing/presentation/sections/futurist_hero.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`
- `../widgets/match_signature.dart`
- `../widgets/product_atmosphere.dart`
- `../widgets/gentle_depth.dart`
- `../widgets/mobile_chapter.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `FuturistHero` | `Bibliothèque` | Composition du titre principal, de son action et de la scène de mise en relation. | `class FuturistHero extends StatelessWidget` |
| `FuturistHero` | `FuturistHero` | Initialise les paramètres de FuturistHero ; les valeurs par défaut figurent dans la signature. | `const FuturistHero({super.key, required this.onExplore})` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `build` | `FuturistHero` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `onExplore` | `FuturistHero` | Action appelée pour rejoindre l’explication ou le parcours. | `final VoidCallback onExplore` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `text` | `FuturistHero` | Styles typographiques ou contenu du message, selon la portée. | `final text = Theme.of(context).textTheme;` |
| `compact` | `FuturistHero` | Sélectionne une présentation compacte ou indique le mode de navigation mobile. | `final compact = constraints.maxWidth < JoynTokens.mobile;` |
| `title` | `FuturistHero` | Titre affiché dans cette composition. | `final title = (compact ? text.displayMedium : text.displayLarge)?.copyWith(color: JoynTokens.paper);` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `FuturistHero` | Identité du widget dans l’arbre Flutter. |
| `this.onExplore` | `FuturistHero` | Action appelée pour rejoindre l’explication ou le parcours. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `context` | `FuturistHero` | Contexte Flutter de l’élément en cours de construction. |
| `constraints` | `FuturistHero` | Contraintes de largeur et de hauteur reçues du parent. |


## Variables de parcours

Ces variables prennent successivement les éléments de la collection indiquée ; elles ne constituent pas un état conservé entre deux rendus.

| Variable | Boucle et collection |
| --- | --- |
| `item` | `(final item in ['01 / UN PROFIL QUI TE RESSEMBLE', '02 / DES CRITÈRES EXPLIQUÉS', '03 / UN INTÉRÊT PARTAGÉ'])` |
