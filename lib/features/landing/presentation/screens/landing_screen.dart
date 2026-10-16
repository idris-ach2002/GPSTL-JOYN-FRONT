// Assemble les sections, leurs ancres de défilement et les chapitres mobiles.
//
// Référence : doc/landing/fichiers/landing_screen.md.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/platform/page_metadata.dart';
import '../../../../design_system/joyn_tokens.dart';
import '../sections/application_tracking_section.dart';
import '../sections/context_sections.dart';
import '../sections/futurist_hero.dart';
import '../sections/matching_workbench.dart';
import '../sections/opportunities_section.dart';
import '../sections/organisation_section.dart';
import '../sections/plan_comparison_section.dart';
import '../sections/pocket_section.dart';
import '../sections/profile_section.dart';
import '../sections/questions_section.dart';
import '../sections/reciprocity_section.dart';
import '../sections/resources_section.dart';
import '../sections/scroll_journey_section.dart';
import '../widgets/landing_mega_navigation.dart';
import '../widgets/mobile_chapter.dart';
import '../widgets/landing_footer.dart';
import '../widgets/navigation_symbol.dart';
/// Découpage des sections repliables et de leurs cibles sur téléphone.
const mobileChapters = [
  (id:'comprendre',title:'Comprendre le matching',summary:'Les situations, la comparaison et les critères à essayer.',kind:NavigationSymbolKind.link,targets:['difficultes','comparaison','matching']),
  (id:'parcours',title:'Construire mon profil',summary:'Le parcours, le CV et les compétences du profil.',kind:NavigationSymbolKind.profile,targets:['parcours','profil']),
  (id:'opportunites',title:'Explorer les opportunités',summary:'Offres, favoris, intérêt réciproque et suivi.',kind:NavigationSymbolKind.work,targets:['opportunites','reciprocite','suivi']),
  (id:'organisations',title:'Recruteurs',summary:'Les offres et la gestion des candidatures.',kind:NavigationSymbolKind.company,targets:['entreprises']),
  (id:'offres',title:'Mobile et formules',summary:'Le parcours sur téléphone et les services associés.',kind:NavigationSymbolKind.chart,targets:['mobile','offres']),
  (id:'ressources',title:'Guides et questions',summary:'Trois guides pratiques et les questions fréquentes.',kind:NavigationSymbolKind.book,targets:['ressources','questions']),
];
/// Page publique qui possède le défilement et les ancres des sections.
class LandingScreen extends StatefulWidget {
  /// Initialise les paramètres de LandingScreen ; les valeurs par défaut figurent dans la signature.
  const LandingScreen({super.key, this.audience = 'accueil'});
  /// Acteur ou point d’entrée utilisé pour adapter la présentation.
  final String audience;
  /// Crée l’état local associé au widget.
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}
/// État de LandingScreen ; définit ses données mutables et son rendu.
class _LandingScreenState extends State<LandingScreen> {
  /// Contrôleur du défilement principal de la landing, libéré dans dispose.
  final scroll = ScrollController();
  /// Nœud de focus de l’entrée de page, libéré avec son état.
  final contentFocus = FocusNode();
  /// Identifiant du chapitre mobile ouvert ; null signifie qu’aucun chapitre n’est ouvert.
  String? expandedChapter;
  /// Hauteur réellement occupée par la navigation au-dessus du contenu.
  double headerExtent = JoynTokens.navHeight;
  /// Clés des sections qui permettent de retrouver leur position de défilement.
  final anchors = {for (final name in const [
    'hero', 'difficultes', 'comparaison', 'parcours', 'matching', 'profil',
    'opportunites', 'reciprocite', 'suivi', 'entreprises',
    'mobile', 'offres', 'ressources', 'questions',
  ]) name: GlobalKey()};
  /// Initialise les abonnements ou programme le travail qui nécessite le premier rendu.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) { return; }
      updatePageMetadata(widget.audience);
      if (widget.audience == 'entreprises') {
        navigate(widget.audience, instant: true);
      } else if (widget.audience == 'candidats') {
        navigate('parcours', instant: true);
      }
    });
  }
  /// Résout une route, un guide ou une ancre ; ouvre d’abord le chapitre mobile concerné.
  void navigate(String target, {bool instant = false}) {
    if (const ['connexion','assistance','donnees','accessibilite'].contains(target)) {
      context.go(target == 'connexion' ? '/connexion' : target == 'assistance' ? '/assistance' : '/assistance?theme=$target');
      return;
    }
    if (MediaQuery.sizeOf(context).width < JoynTokens.mobile && target != 'hero') {
      for (final chapter in mobileChapters) {
        if (chapter.targets.contains(target) && expandedChapter != chapter.id) {
          setState(() => expandedChapter=chapter.id);
          WidgetsBinding.instance.addPostFrameCallback((_) { if(mounted) { navigate(target,instant: instant); } });
          return;
        }
      }
    }
    if (target.startsWith('guide-') || target == 'presentation') { openResource(target); return; }
    if (target == 'hero' && scroll.hasClients) {
      if (instant || MediaQuery.disableAnimationsOf(context)) { scroll.jumpTo(0); }
      else { scroll.animateTo(0, duration: JoynTokens.duration, curve: Curves.easeInOutCubic); }
      return;
    }
    // Contexte Flutter de la section à rendre visible.
    final targetContext = anchors[target]?.currentContext;
    if (targetContext == null) { return; }
    Scrollable.ensureVisible(targetContext, duration: instant || MediaQuery.disableAnimationsOf(context)
      ? JoynTokens.instant : JoynTokens.duration, curve: Curves.easeInOutCubic);
  }
  /// Associe une clé d’ancre au contenu d’une section.
  Widget section(String target, Widget child) => KeyedSubtree(key: anchors[target], child: child);
  /// Libère les ressources détenues par cet état avant sa destruction.
  @override
  void dispose() { scroll.dispose(); contentFocus.dispose(); super.dispose(); }
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => Title(
    title: switch (widget.audience) {
      'entreprises' => 'JOYN — Des attentes de recrutement explicites',
      _ => 'JOYN — Le match avant la candidature',
    },
    color: JoynTokens.ink,
    child: Scaffold(body: SafeArea(child: Column(children: [
      LandingMegaNavigation(onNavigate: navigate,onExtentChanged: (extent) {
        if(mounted && (extent-headerExtent).abs()>.5) { setState(() => headerExtent=extent); }
      }),
      Expanded(child: Scrollbar(controller: scroll, child: SingleChildScrollView(
        controller: scroll,
        child: FocusTraversalGroup(child: LayoutBuilder(builder: (context,constraints) {
          // Association des identifiants de section aux widgets assemblés par la page.
          final parts = <String,Widget>{
            'hero':section('hero', Focus(focusNode: contentFocus,skipTraversal: true,child: FuturistHero(onExplore: () => navigate('matching')))),
            'difficultes':section('difficultes',const SearchDifficultiesSection()),
            'comparaison':section('comparaison',const BeforeAfterSection()),
            'parcours':section('parcours',ScrollJourneySection(controller: scroll,topInset: headerExtent)),
            'matching':section('matching',const MatchingWorkbench()),
            'profil':section('profil',const ProfileSection()),
            'opportunites':section('opportunites',const OpportunitiesSection()),
            'reciprocite':section('reciprocite',const ReciprocitySection()),
            'suivi':section('suivi',const ApplicationTrackingSection()),
            'entreprises':section('entreprises',const OrganisationSection()),
            'mobile':section('mobile',PocketSection(onExplore: () => navigate('parcours'))),
            'offres':section('offres',const PlanComparisonSection()),
            'ressources':section('ressources',ResourcesSection(onOpen: navigate)),
            'questions':section('questions',const QuestionsSection()),
          };
          return Column(children: [
            if(constraints.maxWidth < JoynTokens.mobile) ...[
              parts['hero']!,
              Padding(padding: const EdgeInsets.all(JoynTokens.md),child: Text('Explore à ton rythme. Les détails s’ouvrent quand tu en as besoin.',style: Theme.of(context).textTheme.bodyLarge)),
              for(final chapter in mobileChapters) MobileChapter(id: chapter.id,title: chapter.title,summary: chapter.summary,kind: chapter.kind,
                expanded: expandedChapter==chapter.id,
                onToggle: () => setState(() => expandedChapter=expandedChapter==chapter.id ? null : chapter.id),
                children: [for(final target in chapter.targets) parts[target]!]),
            ] else ...parts.values,
            LandingFooter(onNavigate: navigate),
          ]);
        })),
      ))),
    ]))),
  );
}
