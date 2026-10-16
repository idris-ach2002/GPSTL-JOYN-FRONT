# `questions_section.dart`

Filtre les questions et réponses, les pagine et transmet la recherche à l’assistance.

[Code source](../../../lib/features/landing/presentation/sections/questions_section.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `package:go_router/go_router.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `QuestionsSection` | `Bibliothèque` | Centre de questions et réponses avec catégories, recherche et pagination. | `class QuestionsSection extends StatefulWidget` |
| `QuestionsSection` | `QuestionsSection` | Initialise les paramètres de QuestionsSection ; les valeurs par défaut figurent dans la signature. | `const QuestionsSection({super.key})` |
| `_QuestionsSectionState` | `Bibliothèque` | État de QuestionsSection ; définit ses données mutables et son rendu. | `class _QuestionsSectionState extends State<QuestionsSection>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `QuestionsSection` | Crée l’état local associé au widget. | `State<QuestionsSection> createState()` |
| `normalize` | `_QuestionsSectionState` | Met le texte en minuscules et remplace les accents pour la recherche FAQ. | `String normalize(String value)` |
| `dispose` | `_QuestionsSectionState` | Libère les ressources détenues par cet état avant sa destruction. | `void dispose()` |
| `build` | `_QuestionsSectionState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `search` | `_QuestionsSectionState` | Contrôleur du champ de recherche de ce composant ; libéré dans dispose. | `final search=TextEditingController()` |
| `open` | `_QuestionsSectionState` | Indice de la réponse dépliée ; null ferme toutes les réponses. | `int? open` |
| `page` | `_QuestionsSectionState` | Indice de la page de résultats FAQ, à partir de zéro. | `int page=0` |
| `pageSize` | `_QuestionsSectionState` | Nombre maximal de réponses affichées par page : cinq. | `static const pageSize=5` |
| `category` | `_QuestionsSectionState` | Catégorie active ; TOUT désactive la restriction par catégorie. | `String category='TOUT'` |
| `questions` | `_QuestionsSectionState` | Questions, catégories et réponses disponibles dans la FAQ. | `static const questions=[ ('PROFIL ET CV','Quand mon CV est-il analysé ?','Le CV joint est analysé à la création de ton profil. Les informations recueillies servent à constituer ton profil candidat et à présenter ton parcours.'), ('PROFIL ET CV','Que présente mon profil ?','Ton profil rassemble les informations sur ton parcours et tes compétences. Il donne au recruteur les éléments nécessaires pour comprendre ton expérience en lien avec une offre.'), ('RECOMMANDATIONS','Pourquoi cette offre apparaît-elle dans ma sélection ?','Les offres présentées correspondent à ton profil candidat. Les recommandations servent à rapprocher ton parcours des besoins décrits dans les offres.'), ('RECOMMANDATIONS','Une recommandation garantit-elle un recrutement ?','Non. Une correspondance permet d’identifier une offre pertinente. La candidature, les échanges et la décision de recrutement restent des étapes distinctes.'), ('RECOMMANDATIONS','Pourquoi ne pas afficher toutes les offres ?','La sélection est centrée sur les offres correspondant à ton profil. Elle permet de consulter des postes en rapport avec ton parcours plutôt qu’une liste indifférenciée.'), ('CANDIDATURES','À quoi sert le suivi des candidatures ?','Il permet de retrouver les démarches engagées et leur statut. Le candidat suit ses candidatures ; le recruteur retrouve celles qui concernent ses offres.'), ('CANDIDATURES','Une offre enregistrée est-elle une candidature ?','Non. Enregistrer une offre permet de la retrouver. Cette action est différente de l’envoi d’une candidature.'), ('CANDIDATURES','Quand un échange peut-il commencer ?','L’intérêt réciproque distingue l’intérêt du candidat de celui du recruteur. Lorsque les deux sont exprimés, un échange permet de préciser les attentes de chacun.'), ('RECRUTEURS','Quelles informations préciser dans une offre ?','Décris les missions, les compétences attendues, la localisation, le contrat et l’organisation du travail. Ces informations aident le candidat à comprendre le poste et permettent de rapprocher l’offre des profils.'), ('RECRUTEURS','Comment organiser les candidatures ?','Le suivi par offre permet de replacer chaque candidature dans son contexte : le poste concerné, le profil et l’état de la démarche.'), ('FORMULES','Où trouver les informations sur les formules ?','La rubrique des services distingue l’usage candidat de l’usage entreprise. Pour une question sur les conditions d’une formule, consulte l’assistance.'), ('ASSISTANCE','Comment trouver une réponse à ma question ?','Saisis quelques mots dans la recherche ou sélectionne une catégorie. La recherche porte sur les questions et les réponses. Si aucun résultat ne correspond, ouvre l’assistance avec ta question.'), ]` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `result` | `_QuestionsSectionState` | Texte normalisé ou valeur calculée dans la portée courante. | `var result=value.toLowerCase();` |
| `accents` | `_QuestionsSectionState` | Table de remplacement des caractères accentués pour la recherche. | `const accents={'à':'a','â':'a','ä':'a','é':'e','è':'e','ê':'e','ë':'e','î':'i','ï':'i','ô':'o','ö':'o','ù':'u','û':'u','ü':'u','ç':'c','œ':'oe'};` |
| `terms` | `_QuestionsSectionState` | Mots de recherche normalisés ; chaque mot doit apparaître dans la question ou sa réponse. | `final terms=normalize(search.text).trim().split(RegExp(r'\s+')).where((term) => term.isNotEmpty);` |
| `results` | `_QuestionsSectionState` | Éléments qui satisfont les filtres et la recherche. | `final results=[for(var i=0;i<questions.length;i++) if((category=='TOUT' \|\| questions[i].$1==category) && terms.every((term) => normalize('${questions[i].$2} ${questions[i].$3}').contains(term))) i];` |
| `i` | `_QuestionsSectionState` | Indice de parcours de la liste dans la boucle courante. | `var i=0;` |
| `pages` | `_QuestionsSectionState` | Nombre de pages de résultats, calculé par arrondi supérieur. | `final pages=(results.length/pageSize).ceil();` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `QuestionsSection` | Identité du widget dans l’arbre Flutter. |
| `String value` | `String normalize(String value)` | Valeur reçue par le paramètre ou affichée dans la ligne, selon la portée. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `term` | `_QuestionsSectionState` | Mot normalisé à rechercher dans le texte de la question et de sa réponse. |
| `_` | `_QuestionsSectionState` | Paramètre reçu sans être utilisé dans ce callback. |


## Variables de parcours

Ces variables prennent successivement les éléments de la collection indiquée ; elles ne constituent pas un état conservé entre deux rendus.

| Variable | Boucle et collection |
| --- | --- |
| `entry` | `(final entry in accents.entries)` |
| `item` | `(final item in const ['TOUT','PROFIL ET CV','RECOMMANDATIONS','CANDIDATURES','RECRUTEURS','FORMULES','ASSISTANCE'])` |
| `i` | `(final i in results.skip(page*pageSize).take(pageSize))` |
