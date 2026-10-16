# `person_portrait.dart`

Dessine les portraits illustrés utilisés dans les aperçus.

[Code source](../../../lib/features/landing/presentation/widgets/person_portrait.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `PersonPortrait` | `Bibliothèque` | Portrait vectoriel de candidat ou de recruteur. | `class PersonPortrait extends StatelessWidget` |
| `PersonPortrait` | `PersonPortrait` | Initialise les paramètres de PersonPortrait ; les valeurs par défaut figurent dans la signature. | `const PersonPortrait({super.key, this.recruiter = false, this.size = JoynTokens.portrait})` |
| `_PersonPainter` | `Bibliothèque` | Dessin du portrait selon le rôle représenté. | `class _PersonPainter extends CustomPainter` |
| `_PersonPainter` | `_PersonPainter` | Initialise les paramètres de _PersonPainter ; les valeurs par défaut figurent dans la signature. | `const _PersonPainter(this.recruiter)` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `build` | `PersonPortrait` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `paint` | `_PersonPainter` | Dessine la géométrie dans le repère du canevas fourni. | `void paint(Canvas canvas, Size size)` |
| `shouldRepaint` | `_PersonPainter` | Indique si les données du dessin diffèrent du peintre précédent. | `bool shouldRepaint(covariant _PersonPainter oldDelegate)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `recruiter` | `PersonPortrait` | Sélectionne le rôle recruteur ou son portrait selon le composant. | `final bool recruiter` |
| `size` | `PersonPortrait` | Taille demandée pour le dessin ou dimensions du canevas. | `final double size` |
| `recruiter` | `_PersonPainter` | Sélectionne le rôle recruteur ou son portrait selon le composant. | `final bool recruiter` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `w` | `_PersonPainter` | Largeur du canevas utilisée comme base des proportions du portrait. | `final w = size.width;` |
| `h` | `_PersonPainter` | Hauteur du canevas utilisée comme base des proportions du portrait. | `final h = size.height;` |
| `hair` | `_PersonPainter` | Style de dessin des cheveux du portrait. | `final hair = Path()..moveTo(w * .28, h * .35) ..quadraticBezierTo(w * .24, h * .08, w * .50, h * .11) ..quadraticBezierTo(w * .79, h * .10, w * .72, h * .37) ..lineTo(w * .57, h * .23)..lineTo(w * .30, h * .36)..close();` |
| `face` | `_PersonPainter` | Style de dessin du visage du portrait. | `final face = Paint()..color = JoynTokens.ink..style = PaintingStyle.stroke..strokeWidth = w * .018;` |
| `smile` | `_PersonPainter` | Style du trait de la bouche. | `final smile = Path()..moveTo(w * .44, h * .51)..quadraticBezierTo(w * .50, h * .56, w * .57, h * .51);` |
| `shirt` | `_PersonPainter` | Style de dessin du vêtement du portrait. | `final shirt = Path()..moveTo(w * .36,h * .70)..lineTo(w * .50,h * .86)..lineTo(w * .64,h * .70)..close();` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `PersonPortrait` | Identité du widget dans l’arbre Flutter. |
| `this.recruiter` | `PersonPortrait` | Sélectionne le rôle recruteur ou son portrait selon le composant. |
| `this.size` | `PersonPortrait` | Taille demandée pour le dessin ou dimensions du canevas. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `this.recruiter` | `_PersonPainter` | Sélectionne le rôle recruteur ou son portrait selon le composant. |
| `Canvas canvas` | `void paint(Canvas canvas, Size size)` | Surface de dessin fournie par Flutter. |
| `Size size` | `void paint(Canvas canvas, Size size)` | Taille demandée pour le dessin ou dimensions du canevas. |
| `covariant _PersonPainter oldDelegate` | `bool shouldRepaint(covariant _PersonPainter oldDelegate)` | Peintre précédent utilisé pour décider si un nouveau dessin est nécessaire. |

