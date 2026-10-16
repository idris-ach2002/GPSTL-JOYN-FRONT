# `landing_footer.dart`

Présente les liens de pied de page en colonnes ou en groupes dépliables.

[Code source](../../../lib/features/landing/presentation/widgets/landing_footer.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `editorial_layout.dart`
- `joyn_mark.dart`
- `navigation_symbol.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `LandingFooter` | `Bibliothèque` | Navigation de pied de page adaptée à la largeur de l’écran. | `class LandingFooter extends StatefulWidget` |
| `LandingFooter` | `LandingFooter` | Initialise les paramètres de LandingFooter ; les valeurs par défaut figurent dans la signature. | `const LandingFooter({super.key,required this.onNavigate})` |
| `_LandingFooterState` | `Bibliothèque` | État de LandingFooter ; définit ses données mutables et son rendu. | `class _LandingFooterState extends State<LandingFooter>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `LandingFooter` | Crée l’état local associé au widget. | `State<LandingFooter> createState()` |
| `linkStyle` | `_LandingFooterState` | Style des liens du pied de page avec focus visible. | `ButtonStyle get linkStyle` |
| `links` | `_LandingFooterState` | Construit les liens du groupe de pied de page demandé. | `Widget links(int index)` |
| `build` | `_LandingFooterState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `footerGroups` | `Bibliothèque` | Groupes de liens du pied de page. | `footerGroups = [ ('Candidats',NavigationSymbolKind.profile,[('Le parcours','parcours'),('Mon profil','profil'),('Offres et favoris','opportunites'),('Mes candidatures','suivi')]), ('Recruteurs',NavigationSymbolKind.work,[('Présenter un poste','entreprises'),('Gérer les candidatures','suivi'),('Comprendre les recommandations','matching'),('Les services JOYN','offres')]), ('Assistance',NavigationSymbolKind.support,[('Centre d’aide','assistance'),('Questions fréquentes','questions'),('Guide du profil','guide-profil'),('Préparer un entretien','guide-entretien')]), ('JOYN & compte',NavigationSymbolKind.account,[('Présentation de JOYN','presentation'),('Connexion','connexion'),('Lire un matching','guide-matching'),('Données de navigation','donnees')]), ]` |
| `onNavigate` | `LandingFooter` | Action remontant une cible de navigation au propriétaire de la page. | `final ValueChanged<String> onNavigate` |
| `expanded` | `_LandingFooterState` | Indice du détail ouvert, ou état ouvert/fermé selon le composant. | `int? expanded` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `i` | `_LandingFooterState` | Indice de parcours de la liste dans la boucle courante. | `var i=0;` |
| `i` | `_LandingFooterState` | Indice de parcours de la liste dans la boucle courante. | `var i=0;` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `LandingFooter` | Identité du widget dans l’arbre Flutter. |
| `this.onNavigate` | `LandingFooter` | Action remontant une cible de navigation au propriétaire de la page. |
| `states` | `_LandingFooterState` | Ensemble des états visuels du bouton. |
| `int index` | `Widget links(int index)` | Indice de l’élément demandé. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `context` | `_LandingFooterState` | Contexte Flutter de l’élément en cours de construction. |
| `constraints` | `_LandingFooterState` | Contraintes de largeur et de hauteur reçues du parent. |


## Variables de parcours

Ces variables prennent successivement les éléments de la collection indiquée ; elles ne constituent pas un état conservé entre deux rendus.

| Variable | Boucle et collection |
| --- | --- |
| `link` | `(final link in footerGroups[index].$3)` |
