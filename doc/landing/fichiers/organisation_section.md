# `organisation_section.dart`

Présente les fonctions candidat ou recruteur dans un même espace sélectionnable.

[Code source](../../../lib/features/landing/presentation/sections/organisation_section.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`
- `../widgets/product_atmosphere.dart`
- `../widgets/navigation_symbol.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `OrganisationSection` | `Bibliothèque` | Bloc commun qui distingue les usages candidat et recruteur. | `class OrganisationSection extends StatefulWidget` |
| `OrganisationSection` | `OrganisationSection` | Initialise les paramètres de OrganisationSection ; les valeurs par défaut figurent dans la signature. | `const OrganisationSection({super.key})` |
| `_OrganisationSectionState` | `Bibliothèque` | État de OrganisationSection ; définit ses données mutables et son rendu. | `class _OrganisationSectionState extends State<OrganisationSection>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `OrganisationSection` | Crée l’état local associé au widget. | `State<OrganisationSection> createState()` |
| `select` | `_OrganisationSectionState` | Change la sélection en respectant les limites du contenu. | `void select(bool value)` |
| `build` | `_OrganisationSectionState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `recruiter` | `_OrganisationSectionState` | Sélectionne le rôle recruteur ou son portrait selon le composant. | `bool recruiter=true` |
| `expanded` | `_OrganisationSectionState` | Indice du détail ouvert, ou état ouvert/fermé selon le composant. | `int? expanded` |
| `candidateItems` | `_OrganisationSectionState` | Fonctions et descriptions propres au parcours candidat. | `static const candidateItems=[ ('Créer son profil avec son CV','Joins ton CV à la création du profil. L’analyse recueille les informations utiles pour présenter ton parcours et tes compétences.'), ('Consulter les offres correspondantes','Les recommandations présentent les offres qui correspondent à ton profil. Tu peux consulter leurs missions et leurs conditions avant de candidater.'), ('Retrouver les offres enregistrées','Distingue les postes à relire des candidatures déjà engagées. Enregistrer une offre ne transmet pas de candidature.'), ('Suivre ses candidatures','Retrouve tes démarches et leur statut pour préparer la suite de ta recherche.'), ]` |
| `recruiterItems` | `_OrganisationSectionState` | Fonctions et descriptions propres au parcours recruteur. | `static const recruiterItems=[ ('Présenter une offre','Décris les missions, les compétences attendues, le contrat, le lieu de travail et l’organisation du poste.'), ('Consulter les profils recommandés','Examine les informations du profil en lien avec le besoin de recrutement : parcours, expérience et compétences.'), ('Gérer les candidatures par offre','Retrouve les candidatures associées à chaque poste pour organiser leur consultation et leur suivi.'), ('Clarifier les attentes','Précise les conditions du poste et réponds aux questions du candidat pendant les échanges.'), ]` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `items` | `_OrganisationSectionState` | Liste de contenus correspondant à l’acteur ou à la sélection courante. | `final items=recruiter ? recruiterItems : candidateItems;` |
| `velocity` | `_OrganisationSectionState` | Vitesse horizontale du geste, utilisée pour choisir le rôle affiché. | `final velocity=details.primaryVelocity ?? 0;` |
| `i` | `_OrganisationSectionState` | Indice de parcours de la liste dans la boucle courante. | `var i=0;` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `OrganisationSection` | Identité du widget dans l’arbre Flutter. |
| `bool value` | `void select(bool value)` | Valeur reçue par le paramètre ou affichée dans la ligne, selon la portée. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `details` | `_OrganisationSectionState` | Informations du geste horizontal terminé. |

