# `service_screen.dart`

Affiche les pages de connexion et d’assistance avec leur état de disponibilité.

[Code source](../../../lib/features/landing/presentation/screens/service_screen.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `package:go_router/go_router.dart`
- `../../../../core/platform/page_metadata.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`
- `../widgets/joyn_mark.dart`
- `../widgets/navigation_symbol.dart`
- `../widgets/product_atmosphere.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `ServiceScreen` | `Bibliothèque` | Écran de connexion ou d’assistance, choisi par le paramètre connection. | `class ServiceScreen extends StatefulWidget` |
| `ServiceScreen` | `ServiceScreen` | Initialise les paramètres de ServiceScreen ; les valeurs par défaut figurent dans la signature. | `const ServiceScreen({super.key,required this.connection,this.topic = '',this.question = ''})` |
| `_ServiceScreenState` | `Bibliothèque` | État de ServiceScreen ; définit ses données mutables et son rendu. | `class _ServiceScreenState extends State<ServiceScreen>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `ServiceScreen` | Crée l’état local associé au widget. | `State<ServiceScreen> createState()` |
| `initState` | `_ServiceScreenState` | Initialise les abonnements ou programme le travail qui nécessite le premier rendu. | `void initState()` |
| `dispose` | `_ServiceScreenState` | Libère les ressources détenues par cet état avant sa destruction. | `void dispose()` |
| `build` | `_ServiceScreenState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `connection` | `_ServiceScreenState` | Construit l’espace de connexion avec son état indisponible et ses champs désactivés. | `Widget connection(BuildContext context)` |
| `assistance` | `_ServiceScreenState` | Construit les guides, la question reçue et les informations de navigation. | `Widget assistance(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `connection` | `ServiceScreen` | Sélectionne l’écran de connexion plutôt que l’assistance. | `final bool connection` |
| `topic` | `ServiceScreen` | Sujet reçu dans le paramètre de route theme. | `final String topic` |
| `question` | `ServiceScreen` | Question reçue par la route ou contrôleur de sa saisie, selon la portée. | `final String question` |
| `form` | `_ServiceScreenState` | Clé du formulaire utilisée pour déclencher la validation de ses champs. | `final form=GlobalKey<FormState>()` |
| `topicKey` | `_ServiceScreenState` | Clé du bloc d’assistance à rendre visible après le premier rendu. | `final topicKey=GlobalKey()` |
| `email` | `_ServiceScreenState` | Contrôleur du champ d’adresse e-mail. | `final email=TextEditingController()` |
| `password` | `_ServiceScreenState` | Contrôleur du champ de mot de passe. | `final password=TextEditingController()` |
| `question` | `_ServiceScreenState` | Question reçue par la route ou contrôleur de sa saisie, selon la portée. | `late final question=TextEditingController(text: widget.question)` |
| `revealed` | `_ServiceScreenState` | Indique si le texte du mot de passe est visible. | `bool revealed=false` |
| `message` | `_ServiceScreenState` | Message facultatif présenté sous le formulaire. | `String? message` |
| `audience` | `_ServiceScreenState` | Acteur ou point d’entrée utilisé pour adapter la présentation. | `String audience='Candidat'` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `target` | `_ServiceScreenState` | Cible d’ancre ou de route transmise à la navigation. | `final target=topicKey.currentContext;` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `ServiceScreen` | Identité du widget dans l’arbre Flutter. |
| `this.connection` | `ServiceScreen` | Sélectionne l’écran de connexion plutôt que l’assistance. |
| `this.topic` | `ServiceScreen` | Sujet reçu dans le paramètre de route theme. |
| `this.question` | `ServiceScreen` | Question reçue par la route ou contrôleur de sa saisie, selon la portée. |
| `_` | `_ServiceScreenState` | Paramètre reçu sans être utilisé dans ce callback. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `BuildContext context` | `Widget connection(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `value` | `_ServiceScreenState` | Valeur reçue par le paramètre ou affichée dans la ligne, selon la portée. |
| `BuildContext context` | `Widget assistance(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |


## Variables de parcours

Ces variables prennent successivement les éléments de la collection indiquée ; elles ne constituent pas un état conservé entre deux rendus.

| Variable | Boucle et collection |
| --- | --- |
| `role` | `(final role in const ['Candidat','Recruteur'])` |
| `item` | `(final item in const [ ('Profil et compétences','Présenter son expérience et ses réalisations.','guide-profil'), ('Comprendre le matching','Comprendre les offres correspondant au profil.','guide-matching'), ('Préparer un échange','Raconter un projet et préparer ses questions.','guide-entretien'), ])` |
