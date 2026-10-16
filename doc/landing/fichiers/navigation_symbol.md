# `navigation_symbol.dart`

Associe les libellés de menu à des pictogrammes vectoriels et anime leur tracé.

[Code source](../../../lib/features/landing/presentation/widgets/navigation_symbol.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `dart:math`
- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `NavigationSymbolKind` | `Bibliothèque` | Identifiants des dessins disponibles pour les pictogrammes. | `enum NavigationSymbolKind` |
| `NavigationSymbol` | `Bibliothèque` | Pictogramme avec accent tracé et agrandissement selon l’état actif. | `class NavigationSymbol extends StatelessWidget` |
| `NavigationSymbol` | `NavigationSymbol` | Initialise les paramètres de NavigationSymbol ; les valeurs par défaut figurent dans la signature. | `const NavigationSymbol({super.key, required this.kind, this.active = false, this.size = JoynTokens.navSymbol})` |
| `_SymbolPainter` | `Bibliothèque` | Dessin du pictogramme sélectionné et de la portion de tracé accentuée. | `class _SymbolPainter extends CustomPainter` |
| `_SymbolPainter` | `_SymbolPainter` | Initialise les paramètres de _SymbolPainter ; les valeurs par défaut figurent dans la signature. | `const _SymbolPainter(this.kind, this.progress)` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `symbolFor` | `Bibliothèque` | Résout le dessin correspondant au libellé ; refuse les libellés sans association. | `NavigationSymbolKind symbolFor(String label)` |
| `build` | `NavigationSymbol` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `paint` | `_SymbolPainter` | Dessine la géométrie dans le repère du canevas fourni. | `void paint(Canvas canvas, Size size)` |
| `shouldRepaint` | `_SymbolPainter` | Indique si les données du dessin diffèrent du peintre précédent. | `bool shouldRepaint(covariant _SymbolPainter oldDelegate)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `kind` | `NavigationSymbol` | Dessin vectoriel à utiliser. | `final NavigationSymbolKind kind` |
| `active` | `NavigationSymbol` | Indice ou indicateur d’activation utilisé par cette composition. | `final bool active` |
| `size` | `NavigationSymbol` | Taille demandée pour le dessin ou dimensions du canevas. | `final double size` |
| `kind` | `_SymbolPainter` | Dessin vectoriel à utiliser. | `final NavigationSymbolKind kind` |
| `progress` | `_SymbolPainter` | Avancement de la scène ou du tracé, généralement entre zéro et un. | `final double progress` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `line` | `_SymbolPainter` | Style du trait utilisé pour le dessin. | `final line = Paint()..color = JoynTokens.ink..style = PaintingStyle.stroke ..strokeWidth = 2..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;` |
| `path` | `_SymbolPainter` | Tracé courant du dessin vectoriel. | `final path = Path();` |
| `angle` | `_SymbolPainter` | Angle interpolé pour transformer les traits du menu en croix. | `final angle = progress * math.pi / 4;` |
| `dx` | `_SymbolPainter` | Composante horizontale du segment animé du pictogramme. | `final dx = math.cos(angle)*18;` |
| `dy` | `_SymbolPainter` | Composante verticale du segment animé du pictogramme. | `final dy = math.sin(angle)*18;` |
| `metrics` | `_SymbolPainter` | Segments mesurables du tracé. | `final metrics = path.computeMetrics().toList();` |
| `total` | `_SymbolPainter` | Longueur cumulée des segments du tracé. | `final total = metrics.fold<double>(0,(sum,m)=>sum+m.length);` |
| `remaining` | `_SymbolPainter` | Longueur de tracé accentué restant à dessiner. | `var remaining = total*progress;` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `String label` | `NavigationSymbolKind symbolFor(String label)` | Libellé présenté à l’utilisateur. |
| `super.key` | `NavigationSymbol` | Identité du widget dans l’arbre Flutter. |
| `this.kind` | `NavigationSymbol` | Dessin vectoriel à utiliser. |
| `this.active` | `NavigationSymbol` | Indice ou indicateur d’activation utilisé par cette composition. |
| `this.size` | `NavigationSymbol` | Taille demandée pour le dessin ou dimensions du canevas. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `context` | `NavigationSymbol` | Contexte Flutter de l’élément en cours de construction. |
| `progress` | `NavigationSymbol` | Avancement de la scène ou du tracé, généralement entre zéro et un. |
| `child` | `NavigationSymbol` | Contenu enveloppé par le composant. |
| `this.kind` | `_SymbolPainter` | Dessin vectoriel à utiliser. |
| `this.progress` | `_SymbolPainter` | Avancement de la scène ou du tracé, généralement entre zéro et un. |
| `Canvas canvas` | `void paint(Canvas canvas, Size size)` | Surface de dessin fournie par Flutter. |
| `Size size` | `void paint(Canvas canvas, Size size)` | Taille demandée pour le dessin ou dimensions du canevas. |
| `sum` | `_SymbolPainter` | Longueur cumulée des segments déjà traités. |
| `m` | `_SymbolPainter` | Segment de tracé dont la longueur est additionnée. |
| `covariant _SymbolPainter oldDelegate` | `bool shouldRepaint(covariant _SymbolPainter oldDelegate)` | Peintre précédent utilisé pour décider si un nouveau dessin est nécessaire. |


## Variables de parcours

Ces variables prennent successivement les éléments de la collection indiquée ; elles ne constituent pas un état conservé entre deux rendus.

| Variable | Boucle et collection |
| --- | --- |
| `metric` | `(final metric in metrics)` |
