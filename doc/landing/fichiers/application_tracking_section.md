# `application_tracking_section.dart`

Présente les étapes du suivi d’une candidature à partir d’un exemple interactif.

[Code source](../../../lib/features/landing/presentation/sections/application_tracking_section.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`
- `../widgets/product_atmosphere.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `ApplicationTrackingSection` | `Bibliothèque` | Sélecteur des étapes d’une démarche de candidature. | `class ApplicationTrackingSection extends StatefulWidget` |
| `ApplicationTrackingSection` | `ApplicationTrackingSection` | Initialise les paramètres de ApplicationTrackingSection ; les valeurs par défaut figurent dans la signature. | `const ApplicationTrackingSection({super.key})` |
| `_ApplicationTrackingSectionState` | `Bibliothèque` | État de ApplicationTrackingSection ; définit ses données mutables et son rendu. | `class _ApplicationTrackingSectionState extends State<ApplicationTrackingSection>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `ApplicationTrackingSection` | Crée l’état local associé au widget. | `State<ApplicationTrackingSection> createState()` |
| `build` | `_ApplicationTrackingSectionState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `stage` | `_ApplicationTrackingSectionState` | Indice de l’étape actuellement affichée. | `int stage = 0` |
| `steps` | `_ApplicationTrackingSectionState` | Contenu des étapes proposées dans cette section. | `static const steps = [ ('Enregistrée', 'Relire les missions et noter ses questions.', 'Camille garde une offre pour y revenir avec son calendrier de formation.'), ('Intérêt exprimé', 'Conserver une trace de ce qui motive la démarche.', 'Camille a exprimé son intérêt pour cette offre.'), ('Échange', 'Préparer une explication de son projet.', 'Un intérêt réciproque permet maintenant d’illustrer un premier échange.'), ('Entretien', 'Clarifier le format et les points à préparer.', 'Camille prépare ses exemples et les questions sur les missions, le rythme et l’accompagnement.'), ]` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `i` | `_ApplicationTrackingSectionState` | Indice de parcours de la liste dans la boucle courante. | `var i = 0;` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `ApplicationTrackingSection` | Identité du widget dans l’arbre Flutter. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |

