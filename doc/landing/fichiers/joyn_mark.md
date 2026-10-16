# `joyn_mark.dart`

Dessine le signe JOYN et sa rotation au changement d’état actif.

[Code source](../../../lib/features/landing/presentation/widgets/joyn_mark.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `dart:math`
- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `JoynMark` | `Bibliothèque` | Signe vectoriel JOYN dont la taille est paramétrable. | `class JoynMark extends StatelessWidget` |
| `JoynMark` | `JoynMark` | Initialise les paramètres de JoynMark ; les valeurs par défaut figurent dans la signature. | `const JoynMark({this.size = JoynTokens.logo, super.key})` |
| `_JoynMarkPainter` | `Bibliothèque` | Tracé du signe JOYN sur un canevas normalisé. | `class _JoynMarkPainter extends CustomPainter` |
| `_JoynMarkPainter` | `_JoynMarkPainter` | Initialise les paramètres de _JoynMarkPainter ; les valeurs par défaut figurent dans la signature. | `const _JoynMarkPainter()` |
| `AnimatedJoynMark` | `Bibliothèque` | Rotation du signe JOYN selon l’état actif. | `class AnimatedJoynMark extends StatelessWidget` |
| `AnimatedJoynMark` | `AnimatedJoynMark` | Initialise les paramètres de AnimatedJoynMark ; les valeurs par défaut figurent dans la signature. | `const AnimatedJoynMark({super.key, this.active = false})` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `build` | `JoynMark` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `paint` | `_JoynMarkPainter` | Dessine la géométrie dans le repère du canevas fourni. | `void paint(Canvas canvas, Size size)` |
| `shouldRepaint` | `_JoynMarkPainter` | Indique si les données du dessin diffèrent du peintre précédent. | `bool shouldRepaint(covariant _JoynMarkPainter oldDelegate)` |
| `build` | `AnimatedJoynMark` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `size` | `JoynMark` | Taille demandée pour le dessin ou dimensions du canevas. | `final double size` |
| `active` | `AnimatedJoynMark` | Indice ou indicateur d’activation utilisé par cette composition. | `final bool active` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `strokeWidth` | `_JoynMarkPainter` | Épaisseur du trait employé pour le signe JOYN. | `final strokeWidth = size.width * 0.075;` |
| `linkPaint` | `_JoynMarkPainter` | Style du trait des deux boucles du signe JOYN. | `final linkPaint = Paint() ..color = JoynTokens.paper ..style = PaintingStyle.stroke ..strokeWidth = strokeWidth ..strokeCap = StrokeCap.round;` |
| `leftLoop` | `_JoynMarkPainter` | Tracé de la boucle gauche du signe. | `final leftLoop = Rect.fromCenter( center: Offset(-size.width * 0.10, 0), width: size.width * 0.31, height: size.height * 0.53, );` |
| `rightLoop` | `_JoynMarkPainter` | Tracé de la boucle droite du signe. | `final rightLoop = Rect.fromCenter( center: Offset(size.width * 0.10, 0), width: size.width * 0.31, height: size.height * 0.53, );` |
| `dotPaint` | `_JoynMarkPainter` | Style des points de terminaison du signe. | `final dotPaint = Paint() ..color = JoynTokens.paper ..style = PaintingStyle.fill;` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `this.size` | `JoynMark` | Taille demandée pour le dessin ou dimensions du canevas. |
| `super.key` | `JoynMark` | Identité du widget dans l’arbre Flutter. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `Canvas canvas` | `void paint(Canvas canvas, Size size)` | Surface de dessin fournie par Flutter. |
| `Size size` | `void paint(Canvas canvas, Size size)` | Taille demandée pour le dessin ou dimensions du canevas. |
| `covariant _JoynMarkPainter oldDelegate` | `bool shouldRepaint(covariant _JoynMarkPainter oldDelegate)` | Peintre précédent utilisé pour décider si un nouveau dessin est nécessaire. |
| `super.key` | `AnimatedJoynMark` | Identité du widget dans l’arbre Flutter. |
| `this.active` | `AnimatedJoynMark` | Indice ou indicateur d’activation utilisé par cette composition. |
| `context` | `AnimatedJoynMark` | Contexte Flutter de l’élément en cours de construction. |
| `progress` | `AnimatedJoynMark` | Avancement de la scène ou du tracé, généralement entre zéro et un. |
| `child` | `AnimatedJoynMark` | Contenu enveloppé par le composant. |

