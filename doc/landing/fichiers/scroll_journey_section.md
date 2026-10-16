# `scroll_journey_section.dart`

Synchronise une scène de parcours avec le défilement sans remplacer le scroll du navigateur.

[Code source](../../../lib/features/landing/presentation/sections/scroll_journey_section.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`
- `../widgets/journey_preview.dart`
- `journey_carousel.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `ScrollJourneySection` | `Bibliothèque` | Scène inscrite dans le document et synchronisée au scroll de la page. | `class ScrollJourneySection extends StatefulWidget` |
| `ScrollJourneySection` | `ScrollJourneySection` | Initialise les paramètres de ScrollJourneySection ; les valeurs par défaut figurent dans la signature. | `const ScrollJourneySection({super.key, required this.controller,this.topInset = JoynTokens.navHeight})` |
| `_ScrollJourneySectionState` | `Bibliothèque` | État de ScrollJourneySection ; définit ses données mutables et son rendu. | `class _ScrollJourneySectionState extends State<ScrollJourneySection>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `ScrollJourneySection` | Crée l’état local associé au widget. | `State<ScrollJourneySection> createState()` |
| `initState` | `_ScrollJourneySectionState` | Initialise les abonnements ou programme le travail qui nécessite le premier rendu. | `void initState()` |
| `didChangeDependencies` | `_ScrollJourneySectionState` | Recalcule la scène après un changement des informations héritées. | `void didChangeDependencies()` |
| `didUpdateWidget` | `_ScrollJourneySectionState` | Actualise les abonnements et les mesures lorsque la configuration du parent change. | `void didUpdateWidget(covariant ScrollJourneySection oldWidget)` |
| `update` | `_ScrollJourneySectionState` | Mesure la scène et synchronise sa progression avec le scroll principal. | `void update()` |
| `select` | `_ScrollJourneySectionState` | Change la sélection en respectant les limites du contenu. | `void select(int index, double travel)` |
| `dispose` | `_ScrollJourneySectionState` | Libère les ressources détenues par cet état avant sa destruction. | `void dispose()` |
| `build` | `_ScrollJourneySectionState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `controller` | `ScrollJourneySection` | Contrôleur fourni ou détenu par le composant pour piloter son défilement. | `final ScrollController controller` |
| `topInset` | `ScrollJourneySection` | Hauteur de navigation à réserver avant la scène. | `final double topInset` |
| `progress` | `_ScrollJourneySectionState` | Avancement de la scène ou du tracé, généralement entre zéro et un. | `double progress = 0` |
| `pin` | `_ScrollJourneySectionState` | Décalage vertical de la scène à l’intérieur de son espace de document. | `double pin = 0` |
| `storyKey` | `_ScrollJourneySectionState` | Clé permettant de mesurer la position de la scène dans le document. | `final storyKey = GlobalKey()` |
| `steps` | `_ScrollJourneySectionState` | Contenu des étapes proposées dans cette section. | `static const steps = [ ('Ton profil', 'Tes compétences prennent du sens avec une réalisation et ton contexte.'), ('Les critères', 'Lieu, rythme et compétence : les points communs et les écarts restent visibles.'), ('Les deux intérêts', 'Ton intérêt et celui de l’entreprise sont présentés séparément.'), ('Le premier échange', 'Un projet à raconter. Des attentes et des questions à partager.'), ]` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `box` | `_ScrollJourneySectionState` | Boîte de rendu mesurée pour calculer une position ou une taille. | `final box = storyKey.currentContext?.findRenderObject() as RenderBox?;` |
| `viewport` | `_ScrollJourneySectionState` | Hauteur de contenu disponible après retrait de la navigation. | `final viewport = MediaQuery.sizeOf(context).height - widget.topInset;` |
| `travel` | `_ScrollJourneySectionState` | Distance de défilement disponible pour la scène. | `final travel = viewport * 2;` |
| `offset` | `_ScrollJourneySectionState` | Décalage utilisé dans le calcul de position ou la transformation. | `final offset = (widget.topInset - box.localToGlobal(Offset.zero).dy).clamp(0.0, travel).toDouble();` |
| `next` | `_ScrollJourneySectionState` | Nouvelle progression calculée avant comparaison avec l’état courant. | `final next = offset / travel;` |
| `box` | `_ScrollJourneySectionState` | Boîte de rendu mesurée pour calculer une position ou une taille. | `final box = storyKey.currentContext?.findRenderObject() as RenderBox?;` |
| `start` | `_ScrollJourneySectionState` | Position de départ de la scène dans le défilement principal. | `final start = widget.controller.offset + box.localToGlobal(Offset.zero).dy - widget.topInset;` |
| `destination` | `_ScrollJourneySectionState` | Position de défilement demandée, bornée à la zone disponible. | `final destination = (start + travel * index / (steps.length - 1)).clamp(0.0, widget.controller.position.maxScrollExtent).toDouble();` |
| `screen` | `_ScrollJourneySectionState` | Dimensions de la vue lues dans MediaQuery. | `final screen = MediaQuery.sizeOf(context);` |
| `viewport` | `_ScrollJourneySectionState` | Hauteur de contenu disponible après retrait de la navigation. | `final viewport = screen.height - widget.topInset;` |
| `stage` | `_ScrollJourneySectionState` | Indice de l’étape actuellement affichée. | `final stage = (progress * steps.length).floor().clamp(0, steps.length - 1).toInt();` |
| `i` | `_ScrollJourneySectionState` | Indice de parcours de la liste dans la boucle courante. | `var i = 0;` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `ScrollJourneySection` | Identité du widget dans l’arbre Flutter. |
| `this.controller` | `ScrollJourneySection` | Contrôleur fourni ou détenu par le composant pour piloter son défilement. |
| `this.topInset` | `ScrollJourneySection` | Hauteur de navigation à réserver avant la scène. |
| `_` | `_ScrollJourneySectionState` | Paramètre reçu sans être utilisé dans ce callback. |
| `covariant ScrollJourneySection oldWidget` | `void didUpdateWidget(covariant ScrollJourneySection oldWidget)` | Configuration précédente utilisée pour déplacer les abonnements. |
| `int index` | `void select(int index, double travel)` | Indice de l’élément demandé. |
| `double travel` | `void select(int index, double travel)` | Distance de défilement disponible pour la scène. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `context` | `_ScrollJourneySectionState` | Contexte Flutter de l’élément en cours de construction. |
| `constraints` | `_ScrollJourneySectionState` | Contraintes de largeur et de hauteur reçues du parent. |

