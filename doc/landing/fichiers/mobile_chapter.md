# `mobile_chapter.dart`

Gère les détails repliables sur mobile tout en conservant l’état des contenus masqués.

[Code source](../../../lib/features/landing/presentation/widgets/mobile_chapter.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `navigation_symbol.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `MobileChapter` | `Bibliothèque` | Chapitre contrôlé de l’extérieur, repliable sans perdre son contenu. | `class MobileChapter extends StatelessWidget` |
| `MobileChapter` | `MobileChapter` | Initialise les paramètres de MobileChapter ; les valeurs par défaut figurent dans la signature. | `const MobileChapter({super.key,required this.id,required this.title,required this.summary, required this.expanded,required this.onToggle,required this.children,required this.kind})` |
| `MobileReveal` | `Bibliothèque` | Commande autonome qui affiche ou masque une scène sur mobile. | `class MobileReveal extends StatefulWidget` |
| `MobileReveal` | `MobileReveal` | Initialise les paramètres de MobileReveal ; les valeurs par défaut figurent dans la signature. | `const MobileReveal({super.key,required this.label,required this.child})` |
| `_MobileRevealState` | `Bibliothèque` | État de MobileReveal ; définit ses données mutables et son rendu. | `class _MobileRevealState extends State<MobileReveal>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `build` | `MobileChapter` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `createState` | `MobileReveal` | Crée l’état local associé au widget. | `State<MobileReveal> createState()` |
| `build` | `_MobileRevealState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `id` | `MobileChapter` | Identifiant stable de l’élément. | `final String id` |
| `title` | `MobileChapter` | Titre affiché dans cette composition. | `final String title` |
| `summary` | `MobileChapter` | Résumé visible lorsque le chapitre est replié. | `final String summary` |
| `expanded` | `MobileChapter` | Indice du détail ouvert, ou état ouvert/fermé selon le composant. | `final bool expanded` |
| `onToggle` | `MobileChapter` | Action de dépliage ou de repli du chapitre. | `final VoidCallback onToggle` |
| `children` | `MobileChapter` | Contenus du chapitre, conservés lorsque celui-ci est replié. | `final List<Widget> children` |
| `kind` | `MobileChapter` | Dessin vectoriel à utiliser. | `final NavigationSymbolKind kind` |
| `label` | `MobileReveal` | Libellé présenté à l’utilisateur. | `final String label` |
| `child` | `MobileReveal` | Contenu enveloppé par le composant. | `final Widget child` |
| `expanded` | `_MobileRevealState` | Indice du détail ouvert, ou état ouvert/fermé selon le composant. | `bool expanded = false` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `MobileChapter` | Identité du widget dans l’arbre Flutter. |
| `this.id` | `MobileChapter` | Identifiant stable de l’élément. |
| `this.title` | `MobileChapter` | Titre affiché dans cette composition. |
| `this.summary` | `MobileChapter` | Résumé visible lorsque le chapitre est replié. |
| `this.expanded` | `MobileChapter` | Indice du détail ouvert, ou état ouvert/fermé selon le composant. |
| `this.onToggle` | `MobileChapter` | Action de dépliage ou de repli du chapitre. |
| `this.children` | `MobileChapter` | Contenus du chapitre, conservés lorsque celui-ci est replié. |
| `this.kind` | `MobileChapter` | Dessin vectoriel à utiliser. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `super.key` | `MobileReveal` | Identité du widget dans l’arbre Flutter. |
| `this.label` | `MobileReveal` | Libellé présenté à l’utilisateur. |
| `this.child` | `MobileReveal` | Contenu enveloppé par le composant. |

