# `product_atmosphere.dart`

Dessine le fond sombre quadrillé et les surfaces de présentation.

[Code source](../../../lib/features/landing/presentation/widgets/product_atmosphere.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `ProductAtmosphere` | `Bibliothèque` | Fond bleu nuit avec éclairage et quadrillage vectoriel. | `class ProductAtmosphere extends StatelessWidget` |
| `ProductAtmosphere` | `ProductAtmosphere` | Initialise les paramètres de ProductAtmosphere ; les valeurs par défaut figurent dans la signature. | `const ProductAtmosphere({super.key, required this.child})` |
| `_ConnectionGrid` | `Bibliothèque` | Tracé du quadrillage du fond sans état d’animation. | `class _ConnectionGrid extends CustomPainter` |
| `_ConnectionGrid` | `_ConnectionGrid` | Initialise les paramètres de _ConnectionGrid ; les valeurs par défaut figurent dans la signature. | `const _ConnectionGrid()` |
| `ProductSurface` | `Bibliothèque` | Surface de contenu avec variantes sombre et accentuée. | `class ProductSurface extends StatelessWidget` |
| `ProductSurface` | `ProductSurface` | Initialise les paramètres de ProductSurface ; les valeurs par défaut figurent dans la signature. | `const ProductSurface({super.key, required this.child, this.dark = false, this.accent = false})` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `build` | `ProductAtmosphere` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `paint` | `_ConnectionGrid` | Dessine la géométrie dans le repère du canevas fourni. | `void paint(Canvas canvas, Size size)` |
| `shouldRepaint` | `_ConnectionGrid` | Indique si les données du dessin diffèrent du peintre précédent. | `bool shouldRepaint(covariant _ConnectionGrid oldDelegate)` |
| `build` | `ProductSurface` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `child` | `ProductAtmosphere` | Contenu enveloppé par le composant. | `final Widget child` |
| `child` | `ProductSurface` | Contenu enveloppé par le composant. | `final Widget child` |
| `dark` | `ProductSurface` | Applique la variante sombre de la surface. | `final bool dark` |
| `accent` | `ProductSurface` | Applique la variante accentuée de la surface. | `final bool accent` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `line` | `_ConnectionGrid` | Style du trait utilisé pour le dessin. | `final line = Paint()..color = JoynTokens.cyan.withValues(alpha: JoynTokens.gridAlpha)..strokeWidth = JoynTokens.hairline;` |
| `x` | `_ConnectionGrid` | Abscisse du dessin ou position horizontale normalisée, selon la portée. | `double x = 0;` |
| `y` | `_ConnectionGrid` | Ordonnée du dessin ou position verticale normalisée, selon la portée. | `double y = 0;` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `ProductAtmosphere` | Identité du widget dans l’arbre Flutter. |
| `this.child` | `ProductAtmosphere` | Contenu enveloppé par le composant. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `Canvas canvas` | `void paint(Canvas canvas, Size size)` | Surface de dessin fournie par Flutter. |
| `Size size` | `void paint(Canvas canvas, Size size)` | Taille demandée pour le dessin ou dimensions du canevas. |
| `covariant _ConnectionGrid oldDelegate` | `bool shouldRepaint(covariant _ConnectionGrid oldDelegate)` | Peintre précédent utilisé pour décider si un nouveau dessin est nécessaire. |
| `super.key` | `ProductSurface` | Identité du widget dans l’arbre Flutter. |
| `this.child` | `ProductSurface` | Contenu enveloppé par le composant. |
| `this.dark` | `ProductSurface` | Applique la variante sombre de la surface. |
| `this.accent` | `ProductSurface` | Applique la variante accentuée de la surface. |

