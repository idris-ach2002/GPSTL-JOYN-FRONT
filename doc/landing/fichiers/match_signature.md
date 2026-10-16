# `match_signature.dart`

Illustre l’intérêt partagé par une liaison animée entre deux portraits.

[Code source](../../../lib/features/landing/presentation/widgets/match_signature.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `person_portrait.dart`
- `product_atmosphere.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `MatchSignature` | `Bibliothèque` | Scène illustrée qui alterne entre attente et intérêt partagé. | `class MatchSignature extends StatefulWidget` |
| `MatchSignature` | `MatchSignature` | Initialise les paramètres de MatchSignature ; les valeurs par défaut figurent dans la signature. | `const MatchSignature({super.key})` |
| `_MatchSignatureState` | `Bibliothèque` | État de MatchSignature ; définit ses données mutables et son rendu. | `class _MatchSignatureState extends State<MatchSignature>` |
| `_ProfileStory` | `Bibliothèque` | Portrait, nom, rôle et courte présentation d’un acteur de la scène. | `class _ProfileStory extends StatelessWidget` |
| `_ProfileStory` | `_ProfileStory` | Initialise les paramètres de _ProfileStory ; les valeurs par défaut figurent dans la signature. | `const _ProfileStory({required this.name, required this.role, required this.detail, this.recruiter = false})` |
| `_MatchConnection` | `Bibliothèque` | Tracé progressif de la liaison entre les deux portraits. | `class _MatchConnection extends CustomPainter` |
| `_MatchConnection` | `_MatchConnection` | Initialise les paramètres de _MatchConnection ; les valeurs par défaut figurent dans la signature. | `const _MatchConnection(this.progress)` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `MatchSignature` | Crée l’état local associé au widget. | `State<MatchSignature> createState()` |
| `build` | `_MatchSignatureState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `build` | `_ProfileStory` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `paint` | `_MatchConnection` | Dessine la géométrie dans le repère du canevas fourni. | `void paint(Canvas canvas, Size size)` |
| `shouldRepaint` | `_MatchConnection` | Indique si les données du dessin diffèrent du peintre précédent. | `bool shouldRepaint(covariant _MatchConnection oldDelegate)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `connected` | `_MatchSignatureState` | Affiche la variante avec intérêt partagé dans la scène illustrée. | `bool connected = false` |
| `name` | `_ProfileStory` | Contrôleur du prénom ou nom de la personne représentée, selon la portée. | `final String name` |
| `role` | `_ProfileStory` | Rôle affiché sous le nom du portrait. | `final String role` |
| `detail` | `_ProfileStory` | Présentation courte associée au portrait. | `final String detail` |
| `recruiter` | `_ProfileStory` | Sélectionne le rôle recruteur ou son portrait selon le composant. | `final bool recruiter` |
| `progress` | `_MatchConnection` | Avancement de la scène ou du tracé, généralement entre zéro et un. | `final double progress` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `y` | `_MatchConnection` | Ordonnée du dessin ou position verticale normalisée, selon la portée. | `final y = size.height / 2;` |
| `paint` | `_MatchConnection` | Dessine la géométrie dans le repère du canevas fourni. | `final paint = Paint()..color = JoynTokens.cyan.withValues(alpha: .5)..strokeWidth = JoynTokens.hairline;` |
| `path` | `_MatchConnection` | Tracé courant du dessin vectoriel. | `final path = Path()..moveTo(0, y) ..cubicTo(size.width * .3, 0, size.width * .7, size.height, size.width, y);` |
| `metric` | `_MatchConnection` | Segment mesurable du tracé actuellement parcouru. | `final metric = path.computeMetrics().first;` |
| `position` | `_MatchConnection` | Position de l’extrémité animée sur le tracé. | `final position = metric.getTangentForOffset(metric.length * progress)?.position ?? Offset(0,y);` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `MatchSignature` | Identité du widget dans l’arbre Flutter. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `context` | `_MatchSignatureState` | Contexte Flutter de l’élément en cours de construction. |
| `progress` | `_MatchSignatureState` | Avancement de la scène ou du tracé, généralement entre zéro et un. |
| `child` | `_MatchSignatureState` | Contenu enveloppé par le composant. |
| `this.name` | `_ProfileStory` | Contrôleur du prénom ou nom de la personne représentée, selon la portée. |
| `this.role` | `_ProfileStory` | Rôle affiché sous le nom du portrait. |
| `this.detail` | `_ProfileStory` | Présentation courte associée au portrait. |
| `this.recruiter` | `_ProfileStory` | Sélectionne le rôle recruteur ou son portrait selon le composant. |
| `this.progress` | `_MatchConnection` | Avancement de la scène ou du tracé, généralement entre zéro et un. |
| `Canvas canvas` | `void paint(Canvas canvas, Size size)` | Surface de dessin fournie par Flutter. |
| `Size size` | `void paint(Canvas canvas, Size size)` | Taille demandée pour le dessin ou dimensions du canevas. |
| `covariant _MatchConnection oldDelegate` | `bool shouldRepaint(covariant _MatchConnection oldDelegate)` | Peintre précédent utilisé pour décider si un nouveau dessin est nécessaire. |

