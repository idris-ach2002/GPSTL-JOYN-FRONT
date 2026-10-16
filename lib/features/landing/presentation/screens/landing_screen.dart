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

const mobileChapters = [
  (
    id: 'comprendre',
    title: 'Comprendre le matching',
    summary: 'Les situations, la comparaison et les critères à essayer.',
    kind: NavigationSymbolKind.link,
    targets: ['difficultes', 'comparaison', 'matching'],
  ),
  (
    id: 'parcours',
    title: 'Construire mon profil',
    summary: 'Le parcours, le CV et les compétences du profil.',
    kind: NavigationSymbolKind.profile,
    targets: ['parcours', 'profil'],
  ),
  (
    id: 'opportunites',
    title: 'Explorer les opportunités',
    summary: 'Offres, favoris, intérêt réciproque et suivi.',
    kind: NavigationSymbolKind.work,
    targets: ['opportunites', 'reciprocite', 'suivi'],
  ),
  (
    id: 'organisations',
    title: 'Recruteurs',
    summary: 'Les offres et la gestion des candidatures.',
    kind: NavigationSymbolKind.company,
    targets: ['entreprises'],
  ),
  (
    id: 'offres',
    title: 'Mobile et formules',
    summary: 'Le parcours sur téléphone et les services associés.',
    kind: NavigationSymbolKind.chart,
    targets: ['mobile', 'offres'],
  ),
  (
    id: 'ressources',
    title: 'Guides et questions',
    summary: 'Trois guides pratiques et les questions fréquentes.',
    kind: NavigationSymbolKind.book,
    targets: ['ressources', 'questions'],
  ),
];

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key, this.audience = 'accueil'});
  final String audience;
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final scroll = ScrollController();
  final contentFocus = FocusNode();
  String? expandedChapter;
  double headerExtent = JoynTokens.navHeight;
  final anchors = {
    for (final name in const [
      'hero',
      'difficultes',
      'comparaison',
      'parcours',
      'matching',
      'profil',
      'opportunites',
      'reciprocite',
      'suivi',
      'entreprises',
      'mobile',
      'offres',
      'ressources',
      'questions',
    ])
      name: GlobalKey(),
  };
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      updatePageMetadata(widget.audience);
      if (widget.audience == 'entreprises') {
        navigate(widget.audience, instant: true);
      } else if (widget.audience == 'candidats') {
        navigate('parcours', instant: true);
      }
    });
  }

  void navigate(String target, {bool instant = false}) {
    if (const [
      'connexion',
      'assistance',
      'donnees',
      'accessibilite',
    ].contains(target)) {
      context.go(
        target == 'connexion'
            ? '/connexion'
            : target == 'assistance'
            ? '/assistance'
            : '/assistance?theme=$target',
      );
      return;
    }
    if (MediaQuery.sizeOf(context).width < JoynTokens.mobile &&
        target != 'hero') {
      for (final chapter in mobileChapters) {
        if (chapter.targets.contains(target) && expandedChapter != chapter.id) {
          setState(() => expandedChapter = chapter.id);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              navigate(target, instant: instant);
            }
          });
          return;
        }
      }
    }
    if (target.startsWith('guide-') || target == 'presentation') {
      openResource(target);
      return;
    }
    if (target == 'hero' && scroll.hasClients) {
      if (instant || MediaQuery.disableAnimationsOf(context)) {
        scroll.jumpTo(0);
      } else {
        scroll.animateTo(
          0,
          duration: JoynTokens.duration,
          curve: Curves.easeInOutCubic,
        );
      }
      return;
    }
    final targetContext = anchors[target]?.currentContext;
    if (targetContext == null) {
      return;
    }
    Scrollable.ensureVisible(
      targetContext,
      duration: instant || MediaQuery.disableAnimationsOf(context)
          ? JoynTokens.instant
          : JoynTokens.duration,
      curve: Curves.easeInOutCubic,
    );
  }

  Widget section(String target, Widget child) =>
      KeyedSubtree(key: anchors[target], child: child);
  @override
  void dispose() {
    scroll.dispose();
    contentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Title(
    title: switch (widget.audience) {
      'entreprises' => 'JOYN — Des attentes de recrutement explicites',
      _ => 'JOYN — Le match avant la candidature',
    },
    color: JoynTokens.ink,
    child: Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LandingMegaNavigation(
              onNavigate: navigate,
              onExtentChanged: (extent) {
                if (mounted && (extent - headerExtent).abs() > .5) {
                  setState(() => headerExtent = extent);
                }
              },
            ),
            Expanded(
              child: Scrollbar(
                controller: scroll,
                child: SingleChildScrollView(
                  controller: scroll,
                  child: FocusTraversalGroup(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final parts = <String, Widget>{
                          'hero': section(
                            'hero',
                            Focus(
                              focusNode: contentFocus,
                              skipTraversal: true,
                              child: FuturistHero(
                                onExplore: () => navigate('matching'),
                              ),
                            ),
                          ),
                          'difficultes': section(
                            'difficultes',
                            const SearchDifficultiesSection(),
                          ),
                          'comparaison': section(
                            'comparaison',
                            const BeforeAfterSection(),
                          ),
                          'parcours': section(
                            'parcours',
                            ScrollJourneySection(
                              controller: scroll,
                              topInset: headerExtent,
                            ),
                          ),
                          'matching': section(
                            'matching',
                            const MatchingWorkbench(),
                          ),
                          'profil': section('profil', const ProfileSection()),
                          'opportunites': section(
                            'opportunites',
                            const OpportunitiesSection(),
                          ),
                          'reciprocite': section(
                            'reciprocite',
                            const ReciprocitySection(),
                          ),
                          'suivi': section(
                            'suivi',
                            const ApplicationTrackingSection(),
                          ),
                          'entreprises': section(
                            'entreprises',
                            const OrganisationSection(),
                          ),
                          'mobile': section(
                            'mobile',
                            PocketSection(
                              onExplore: () => navigate('parcours'),
                            ),
                          ),
                          'offres': section(
                            'offres',
                            const PlanComparisonSection(),
                          ),
                          'ressources': section(
                            'ressources',
                            ResourcesSection(onOpen: navigate),
                          ),
                          'questions': section(
                            'questions',
                            const QuestionsSection(),
                          ),
                        };
                        return Column(
                          children: [
                            if (constraints.maxWidth < JoynTokens.mobile) ...[
                              parts['hero']!,
                              Padding(
                                padding: const EdgeInsets.all(JoynTokens.md),
                                child: Text(
                                  'Explore à ton rythme. Les détails s’ouvrent quand tu en as besoin.',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              for (final chapter in mobileChapters)
                                MobileChapter(
                                  id: chapter.id,
                                  title: chapter.title,
                                  summary: chapter.summary,
                                  kind: chapter.kind,
                                  expanded: expandedChapter == chapter.id,
                                  onToggle: () => setState(
                                    () => expandedChapter =
                                        expandedChapter == chapter.id
                                        ? null
                                        : chapter.id,
                                  ),
                                  children: [
                                    for (final target in chapter.targets)
                                      parts[target]!,
                                  ],
                                ),
                            ] else
                              ...parts.values,
                            LandingFooter(onNavigate: navigate),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
