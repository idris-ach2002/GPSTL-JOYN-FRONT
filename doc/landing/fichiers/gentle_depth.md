# `gentle_depth.dart`

Déplace légèrement une illustration selon le pointeur sur les grands écrans.

[Code source](../../../lib/features/landing/presentation/widgets/gentle_depth.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `GentleDepth` | `Bibliothèque` | Enveloppe d’illustration avec déplacement borné au passage du pointeur. | `class GentleDepth extends StatefulWidget` |
| `GentleDepth` | `GentleDepth` | Initialise les paramètres de GentleDepth ; les valeurs par défaut figurent dans la signature. | `const GentleDepth({super.key, required this.child})` |
| `_GentleDepthState` | `Bibliothèque` | État de GentleDepth ; définit ses données mutables et son rendu. | `class _GentleDepthState extends State<GentleDepth>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `GentleDepth` | Crée l’état local associé au widget. | `State<GentleDepth> createState()` |
| `build` | `_GentleDepthState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `child` | `GentleDepth` | Contenu enveloppé par le composant. | `final Widget child` |
| `target` | `_GentleDepthState` | Cible d’ancre ou de route transmise à la navigation. | `Offset target = Offset.zero` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `box` | `_GentleDepthState` | Boîte de rendu mesurée pour calculer une position ou une taille. | `final box = context.findRenderObject() as RenderBox?;` |
| `x` | `_GentleDepthState` | Abscisse du dessin ou position horizontale normalisée, selon la portée. | `final x = (event.localPosition.dx / box.size.width * 2 - 1).clamp(-1.0, 1.0).toDouble();` |
| `y` | `_GentleDepthState` | Ordonnée du dessin ou position verticale normalisée, selon la portée. | `final y = (event.localPosition.dy / box.size.height * 2 - 1).clamp(-1.0, 1.0).toDouble();` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `GentleDepth` | Identité du widget dans l’arbre Flutter. |
| `this.child` | `GentleDepth` | Contenu enveloppé par le composant. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `context` | `_GentleDepthState` | Contexte Flutter de l’élément en cours de construction. |
| `constraints` | `_GentleDepthState` | Contraintes de largeur et de hauteur reçues du parent. |
| `event` | `_GentleDepthState` | Position ou événement du pointeur reçu par le composant. |
| `_` | `_GentleDepthState` | Paramètre reçu sans être utilisé dans ce callback. |
| `offset` | `_GentleDepthState` | Décalage utilisé dans le calcul de position ou la transformation. |
| `child` | `_GentleDepthState` | Contenu enveloppé par le composant. |

