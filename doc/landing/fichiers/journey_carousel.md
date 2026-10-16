# `journey_carousel.dart`

Affiche trois étapes du parcours avec boutons, balayage et commandes clavier.

[Code source](../../../lib/features/landing/presentation/sections/journey_carousel.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `package:flutter/services.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`
- `../widgets/journey_preview.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `JourneyCarousel` | `Bibliothèque` | Parcours de trois pages avec sélection bornée et commandes clavier. | `class JourneyCarousel extends StatefulWidget` |
| `JourneyCarousel` | `JourneyCarousel` | Initialise les paramètres de JourneyCarousel ; les valeurs par défaut figurent dans la signature. | `const JourneyCarousel({super.key})` |
| `_JourneyCarouselState` | `Bibliothèque` | État de JourneyCarousel ; définit ses données mutables et son rendu. | `class _JourneyCarouselState extends State<JourneyCarousel>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `JourneyCarousel` | Crée l’état local associé au widget. | `State<JourneyCarousel> createState()` |
| `select` | `_JourneyCarouselState` | Change la sélection en respectant les limites du contenu. | `void select(int index)` |
| `dispose` | `_JourneyCarouselState` | Libère les ressources détenues par cet état avant sa destruction. | `void dispose()` |
| `build` | `_JourneyCarouselState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `controller` | `_JourneyCarouselState` | Contrôleur fourni ou détenu par le composant pour piloter son défilement. | `final PageController controller = PageController()` |
| `active` | `_JourneyCarouselState` | Indice ou indicateur d’activation utilisé par cette composition. | `int active = 0` |
| `slides` | `_JourneyCarouselState` | Contenu des trois pages du carrousel. | `static const slides = [ (title: 'Précise ce qui compte.', text: 'Compétences, mobilité, rythme : rends tes contraintes lisibles avant de regarder les offres.', rows: [('Compétences', 'Dart, Flutter'), ('Mobilité', 'Paris'), ('Rythme', '3 jours en entreprise')]), (title: 'Lis les points communs.', text: 'Consulte les missions, les conditions du poste et les correspondances avec ton profil.', rows: [('Même localisation', 'Paris'), ('Même rythme', '3 jours en entreprise'), ('Compétences communes', 'Dart et Flutter')]), (title: 'Exprime ton intérêt.', text: 'Le parcours présenté prévoit une mise en relation quand le candidat et l’entreprise expriment tous deux leur intérêt.', rows: [('Candidat', 'Intéressé'), ('Entreprise', 'Intéressée'), ('Étape suivante', 'Premier échange')]), ]` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `i` | `_JourneyCarouselState` | Indice de parcours de la liste dans la boucle courante. | `var i = 0;` |
| `slide` | `_JourneyCarouselState` | Contenu de la page actuellement construite dans le carrousel. | `final slide = slides[index];` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `JourneyCarousel` | Identité du widget dans l’arbre Flutter. |
| `int index` | `void select(int index)` | Indice de l’élément demandé. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `context` | `_JourneyCarouselState` | Contexte Flutter de l’élément en cours de construction. |
| `constraints` | `_JourneyCarouselState` | Contraintes de largeur et de hauteur reçues du parent. |
| `index` | `_JourneyCarouselState` | Indice de l’élément demandé. |

