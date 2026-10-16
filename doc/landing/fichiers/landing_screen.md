# `landing_screen.dart`

Assemble les sections, leurs ancres de défilement et les chapitres mobiles.

[Code source](../../../lib/features/landing/presentation/screens/landing_screen.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `package:go_router/go_router.dart`
- `../../../../core/platform/page_metadata.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../sections/application_tracking_section.dart`
- `../sections/context_sections.dart`
- `../sections/futurist_hero.dart`
- `../sections/matching_workbench.dart`
- `../sections/opportunities_section.dart`
- `../sections/organisation_section.dart`
- `../sections/plan_comparison_section.dart`
- `../sections/pocket_section.dart`
- `../sections/profile_section.dart`
- `../sections/questions_section.dart`
- `../sections/reciprocity_section.dart`
- `../sections/resources_section.dart`
- `../sections/scroll_journey_section.dart`
- `../widgets/landing_mega_navigation.dart`
- `../widgets/mobile_chapter.dart`
- `../widgets/landing_footer.dart`
- `../widgets/navigation_symbol.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `LandingScreen` | `Bibliothèque` | Page publique qui possède le défilement et les ancres des sections. | `class LandingScreen extends StatefulWidget` |
| `LandingScreen` | `LandingScreen` | Initialise les paramètres de LandingScreen ; les valeurs par défaut figurent dans la signature. | `const LandingScreen({super.key, this.audience = 'accueil'})` |
| `_LandingScreenState` | `Bibliothèque` | État de LandingScreen ; définit ses données mutables et son rendu. | `class _LandingScreenState extends State<LandingScreen>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `LandingScreen` | Crée l’état local associé au widget. | `State<LandingScreen> createState()` |
| `initState` | `_LandingScreenState` | Initialise les abonnements ou programme le travail qui nécessite le premier rendu. | `void initState()` |
| `navigate` | `_LandingScreenState` | Résout une route, un guide ou une ancre ; ouvre d’abord le chapitre mobile concerné. | `void navigate(String target, {bool instant = false})` |
| `section` | `_LandingScreenState` | Associe une clé d’ancre au contenu d’une section. | `Widget section(String target, Widget child)` |
| `dispose` | `_LandingScreenState` | Libère les ressources détenues par cet état avant sa destruction. | `void dispose()` |
| `build` | `_LandingScreenState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `mobileChapters` | `Bibliothèque` | Découpage des sections repliables et de leurs cibles sur téléphone. | `mobileChapters = [ (id:'comprendre',title:'Comprendre le matching',summary:'Les situations, la comparaison et les critères à essayer.',kind:NavigationSymbolKind.link,targets:['difficultes','comparaison','matching']), (id:'parcours',title:'Construire mon profil',summary:'Le parcours, le CV et les compétences du profil.',kind:NavigationSymbolKind.profile,targets:['parcours','profil']), (id:'opportunites',title:'Explorer les opportunités',summary:'Offres, favoris, intérêt réciproque et suivi.',kind:NavigationSymbolKind.work,targets:['opportunites','reciprocite','suivi']), (id:'organisations',title:'Recruteurs',summary:'Les offres et la gestion des candidatures.',kind:NavigationSymbolKind.company,targets:['entreprises']), (id:'offres',title:'Mobile et formules',summary:'Le parcours sur téléphone et les services associés.',kind:NavigationSymbolKind.chart,targets:['mobile','offres']), (id:'ressources',title:'Guides et questions',summary:'Trois guides pratiques et les questions fréquentes.',kind:NavigationSymbolKind.book,targets:['ressources','questions']), ]` |
| `audience` | `LandingScreen` | Acteur ou point d’entrée utilisé pour adapter la présentation. | `final String audience` |
| `scroll` | `_LandingScreenState` | Contrôleur du défilement principal de la landing, libéré dans dispose. | `final scroll = ScrollController()` |
| `contentFocus` | `_LandingScreenState` | Nœud de focus de l’entrée de page, libéré avec son état. | `final contentFocus = FocusNode()` |
| `expandedChapter` | `_LandingScreenState` | Identifiant du chapitre mobile ouvert ; null signifie qu’aucun chapitre n’est ouvert. | `String? expandedChapter` |
| `headerExtent` | `_LandingScreenState` | Hauteur réellement occupée par la navigation au-dessus du contenu. | `double headerExtent = JoynTokens.navHeight` |
| `anchors` | `_LandingScreenState` | Clés des sections qui permettent de retrouver leur position de défilement. | `final anchors = {for (final name in const [ 'hero', 'difficultes', 'comparaison', 'parcours', 'matching', 'profil', 'opportunites', 'reciprocite', 'suivi', 'entreprises', 'mobile', 'offres', 'ressources', 'questions', ]) name: GlobalKey()}` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `targetContext` | `_LandingScreenState` | Contexte Flutter de la section à rendre visible. | `final targetContext = anchors[target]?.currentContext;` |
| `parts` | `_LandingScreenState` | Association des identifiants de section aux widgets assemblés par la page. | `final parts = <String,Widget>{ 'hero':section('hero', Focus(focusNode: contentFocus,skipTraversal: true,child: FuturistHero(onExplore: () => navigate('matching')))), 'difficultes':section('difficultes',const SearchDifficultiesSection()), 'comparaison':section('comparaison',const BeforeAfterSection()), 'parcours':section('parcours',ScrollJourneySection(controller: scroll,topInset: headerExtent)), 'matching':section('matching',const MatchingWorkbench()), 'profil':section('profil',const ProfileSection()), 'opportunites':section('opportunites',const OpportunitiesSection()), 'reciprocite':section('reciprocite',const ReciprocitySection()), 'suivi':section('suivi',const ApplicationTrackingSection()), 'entreprises':section('entreprises',const OrganisationSection()), 'mobile':section('mobile',PocketSection(onExplore: () => navigate('parcours'))), 'offres':section('offres',const PlanComparisonSection()), 'ressources':section('ressources',ResourcesSection(onOpen: navigate)), 'questions':section('questions',const QuestionsSection()), };` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `LandingScreen` | Identité du widget dans l’arbre Flutter. |
| `this.audience` | `LandingScreen` | Acteur ou point d’entrée utilisé pour adapter la présentation. |
| `_` | `_LandingScreenState` | Paramètre reçu sans être utilisé dans ce callback. |
| `String target` | `void navigate(String target, {bool instant = false})` | Cible d’ancre ou de route transmise à la navigation. |
| `bool instant` | `void navigate(String target, {bool instant = false})` | Désactive la transition de défilement lorsqu’il vaut true. |
| `String target` | `Widget section(String target, Widget child)` | Cible d’ancre ou de route transmise à la navigation. |
| `Widget child` | `Widget section(String target, Widget child)` | Contenu enveloppé par le composant. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `extent` | `_LandingScreenState` | Position du bas de la barre, mesurée dans la vue. |
| `context` | `_LandingScreenState` | Contexte Flutter de l’élément en cours de construction. |
| `constraints` | `_LandingScreenState` | Contraintes de largeur et de hauteur reçues du parent. |


## Variables de parcours

Ces variables prennent successivement les éléments de la collection indiquée ; elles ne constituent pas un état conservé entre deux rendus.

| Variable | Boucle et collection |
| --- | --- |
| `name` | `(final name in const [ 'hero', 'difficultes', 'comparaison', 'parcours', 'matching', 'profil', 'opportunites', 'reciprocite', 'suivi', 'entreprises', 'mobile', 'offres', 'ressources', 'questions', ])` |
| `chapter` | `(final chapter in mobileChapters)` |
| `chapter` | `(final chapter in mobileChapters)` |
| `target` | `(final target in chapter.targets)` |
