# `opportunities_section.dart`

Affiche les exemples d’offres, la recherche et les favoris de la visite.

[Code source](../../../lib/features/landing/presentation/sections/opportunities_section.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`
- `../widgets/product_atmosphere.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `OpportunityExample` | `Bibliothèque` | Données d’une offre illustrée : identifiant, intitulé, ville, rythme, compétences et mission. | `class OpportunityExample` |
| `OpportunityExample` | `OpportunityExample` | Initialise les paramètres de OpportunityExample ; les valeurs par défaut figurent dans la signature. | `const OpportunityExample(this.id, this.title, this.city, this.rhythm, this.skills, this.mission)` |
| `OpportunitiesSection` | `Bibliothèque` | Recherche et sélection des offres illustrées, avec favoris de visite. | `class OpportunitiesSection extends StatefulWidget` |
| `OpportunitiesSection` | `OpportunitiesSection` | Initialise les paramètres de OpportunitiesSection ; les valeurs par défaut figurent dans la signature. | `const OpportunitiesSection({super.key})` |
| `_OpportunitiesSectionState` | `Bibliothèque` | État de OpportunitiesSection ; définit ses données mutables et son rendu. | `class _OpportunitiesSectionState extends State<OpportunitiesSection>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `OpportunitiesSection` | Crée l’état local associé au widget. | `State<OpportunitiesSection> createState()` |
| `dispose` | `_OpportunitiesSectionState` | Libère les ressources détenues par cet état avant sa destruction. | `void dispose()` |
| `reset` | `_OpportunitiesSectionState` | Efface la recherche et les filtres sans vider les favoris. | `void reset()` |
| `build` | `_OpportunitiesSectionState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `id` | `OpportunityExample` | Identifiant stable de l’élément. | `final int id` |
| `title` | `OpportunityExample` | Titre affiché dans cette composition. | `final String title` |
| `city` | `OpportunityExample` | Ville de l’offre illustrée. | `final String city` |
| `rhythm` | `OpportunityExample` | Organisation temporelle décrite dans l’offre. | `final String rhythm` |
| `skills` | `OpportunityExample` | Compétences mentionnées par l’offre. | `final String skills` |
| `mission` | `OpportunityExample` | Description concrète de la mission. | `final String mission` |
| `opportunityExamples` | `Bibliothèque` | Jeu d’offres utilisé uniquement par l’aperçu interactif. | `opportunityExamples = [ OpportunityExample(1, 'Développement Flutter', 'Paris', '3 jours en entreprise', 'Dart · Flutter', 'Construire et améliorer une interface de suivi.'), OpportunityExample(2, 'Interface web', 'Lyon', '1 semaine sur 2', 'HTML · CSS · JavaScript', 'Rendre un parcours de recherche plus lisible.'), OpportunityExample(3, 'Qualité logicielle', 'Nantes', '3 jours en entreprise', 'Tests · documentation', 'Vérifier des scénarios et rendre les résultats compréhensibles.'), OpportunityExample(4, 'Conception produit', 'Paris', '1 semaine sur 2', 'Prototypage · entretiens', 'Comprendre un besoin et proposer un parcours testable.'), ]` |
| `search` | `_OpportunitiesSectionState` | Contrôleur du champ de recherche de ce composant ; libéré dans dispose. | `final search = TextEditingController()` |
| `saved` | `_OpportunitiesSectionState` | Ensemble des identifiants d’offres enregistrées pendant la visite. | `final saved = <int>{}` |
| `paris` | `_OpportunitiesSectionState` | Limite les résultats aux offres situées à Paris lorsqu’il est actif. | `bool paris = false` |
| `onlySaved` | `_OpportunitiesSectionState` | Limite les résultats aux offres enregistrées. | `bool onlySaved = false` |
| `query` | `_OpportunitiesSectionState` | Texte utilisé pour filtrer la liste d’offres. | `String query = ''` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `results` | `_OpportunitiesSectionState` | Éléments qui satisfont les filtres et la recherche. | `final results = opportunityExamples.where((offer) => (!paris \|\| offer.city == 'Paris') && (!onlySaved \|\| saved.contains(offer.id)) && '${offer.title} ${offer.skills} ${offer.city}'.toLowerCase().contains(query.toLowerCase().trim())).toList();` |
| `description` | `_OpportunitiesSectionState` | Texte de contexte associé au titre ou au lien. | `final description = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(offer.title, style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: JoynTokens.sm), Text('${offer.city} · ${offer.rhythm}'), const SizedBox(height: JoynTokens.sm), Text(offer.mission), const SizedBox(height: JoynTokens.sm), Text('À mobiliser : ${offer.skills}'), ]);` |
| `action` | `_OpportunitiesSectionState` | Action appelée lors de l’activation. | `final action = Semantics(toggled: saved.contains(offer.id), child: OutlinedButton( key: ValueKey('save-offer-${offer.id}'), onPressed: () => setState(() { if (!saved.add(offer.id)) { saved.remove(offer.id); } }), child: Text(saved.contains(offer.id) ? 'RETIRER DES FAVORIS' : 'ENREGISTRER'), ));` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `this.id` | `OpportunityExample` | Identifiant stable de l’élément. |
| `this.title` | `OpportunityExample` | Titre affiché dans cette composition. |
| `this.city` | `OpportunityExample` | Ville de l’offre illustrée. |
| `this.rhythm` | `OpportunityExample` | Organisation temporelle décrite dans l’offre. |
| `this.skills` | `OpportunityExample` | Compétences mentionnées par l’offre. |
| `this.mission` | `OpportunityExample` | Description concrète de la mission. |
| `super.key` | `OpportunitiesSection` | Identité du widget dans l’arbre Flutter. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `offer` | `_OpportunitiesSectionState` | Offre courante lors du filtrage ou de la construction de la liste. |
| `value` | `_OpportunitiesSectionState` | Valeur reçue par le paramètre ou affichée dans la ligne, selon la portée. |
| `context` | `_OpportunitiesSectionState` | Contexte Flutter de l’élément en cours de construction. |
| `constraints` | `_OpportunitiesSectionState` | Contraintes de largeur et de hauteur reçues du parent. |


## Variables de parcours

Ces variables prennent successivement les éléments de la collection indiquée ; elles ne constituent pas un état conservé entre deux rendus.

| Variable | Boucle et collection |
| --- | --- |
| `offer` | `(final offer in results)` |
