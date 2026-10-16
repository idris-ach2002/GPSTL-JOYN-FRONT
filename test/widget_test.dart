// Tests des interactions et compositions de la landing.
// Référence : doc/landing/fichiers/widget_test.md.

import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyn_front/app/theme/app_theme.dart';
import 'package:joyn_front/design_system/joyn_tokens.dart';
import 'package:joyn_front/features/landing/presentation/screens/service_screen.dart';
import 'package:joyn_front/features/landing/presentation/sections/matching_workbench.dart';
import 'package:joyn_front/features/landing/presentation/sections/journey_carousel.dart';
import 'package:joyn_front/features/landing/presentation/screens/landing_screen.dart';
import 'package:joyn_front/features/landing/presentation/widgets/match_signature.dart';
import 'package:joyn_front/features/landing/presentation/widgets/landing_mega_navigation.dart';
import 'package:joyn_front/features/landing/domain/landing_navigation.dart';
import 'package:joyn_front/features/landing/presentation/widgets/navigation_symbol.dart';
import 'package:joyn_front/features/landing/presentation/sections/questions_section.dart';
import 'package:joyn_front/features/landing/presentation/sections/opportunities_section.dart';
import 'package:joyn_front/features/landing/presentation/sections/profile_section.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  // Configure the FlutterView used by MediaQuery as well as layout constraints.
  // One physical pixel per logical pixel makes every breakpoint deterministic.
  // Synchronise la vue et sa largeur logique ; restaure les réglages en fin de test.
  void setViewport(WidgetTester tester, Size size) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // Installe le thème et un défilement avant de vérifier le composant.
  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(1280, 1000),
  }) async {
    setViewport(tester, size);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Rend la commande visible puis attend la stabilisation après son activation.
  Future<void> activate(WidgetTester tester, String text) async {
    final target = find.text(text);
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'editorial ink titles retain contrast in every text-button state',
    (tester) async {
      final theme = AppTheme.light;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: Text('Contraste')),
        ),
      );
      await tester.pumpAndSettle();
      final style = theme.textButtonTheme.style!;
      for (final states in <Set<WidgetState>>[
        {},
        {WidgetState.hovered},
        {WidgetState.focused},
        {WidgetState.pressed},
        {WidgetState.disabled},
      ]) {
        final background = Color.alphaBlend(
          style.backgroundColor!.resolve(states)!,
          JoynTokens.paper,
        );
        final ratio =
            (background.computeLuminance() + .05) /
            (JoynTokens.ink.computeLuminance() + .05);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Explicit ink headings must remain readable: $states',
        );
      }
    },
  );
  testWidgets('mobile chapters open on demand and preserve the local profile', (
    tester,
  ) async {
    setViewport(tester, const Size(390, 900));

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const LandingScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSection), findsNothing);
    final chapter = find.byKey(const ValueKey('chapter-parcours'));
    await tester.ensureVisible(chapter);
    await tester.tap(chapter);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSection), findsOneWidget);
    final name = find.byType(TextFormField).first;
    await tester.ensureVisible(name);
    await tester.enterText(name, 'Profil conservé');
    await tester.pump();
    await tester.ensureVisible(chapter);
    await tester.tap(chapter);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSection), findsNothing);
    await tester.tap(chapter);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      'Profil conservé',
    );
  });
  testWidgets('mobile menu has a category level and a back path', (
    tester,
  ) async {
    setViewport(tester, const Size(390, 900));

    String? destination;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: LandingMegaNavigation(
            onNavigate: (value) => destination = value,
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('nav-menu-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Le matching expliqué'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('mobile-category-0')));
    await tester.pumpAndSettle();
    expect(find.text('Le matching expliqué'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('menu-back')));
    await tester.pumpAndSettle();
    expect(find.text('Le matching expliqué'), findsNothing);
    await tester.enterText(find.byType(TextField), 'connexion');
    await tester.pumpAndSettle();
    expect(find.text('Se connecter'), findsOneWidget);
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(destination, 'connexion');
  });
  testWidgets('connection interface never simulates an authenticated account', (
    tester,
  ) async {
    setViewport(tester, const Size(1280, 1000));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ServiceScreen(connection: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'CONNEXION INDISPONIBLE'),
          )
          .onPressed,
      isNull,
    );
    for (final field in tester.widgetList<TextFormField>(
      find.byType(TextFormField),
    )) {
      expect(field.enabled, isFalse);
    }
  });
  testWidgets('desktop hover menu switches groups and follows a real target', (
    tester,
  ) async {
    setViewport(tester, const Size(1440, 1000));

    String? destination;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              LandingMegaNavigation(
                onNavigate: (target) => destination = target,
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final desktopTrigger = find.byKey(const ValueKey('nav-group-1'));
    expect(desktopTrigger, findsOneWidget);
    expect(find.byKey(const ValueKey('nav-menu-toggle')), findsNothing);
    expect(
      MediaQuery.sizeOf(tester.element(desktopTrigger)),
      const Size(1440, 1000),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('nav-group-1'))),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('mega-profil-Profil et CV')),
      findsOneWidget,
    );
    // The overlay must leave the navigation bar reachable for hover switching.
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('nav-group-6'))),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('mega-guide-profil-Guide du profil')),
      findsOneWidget,
    );
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('nav-group-1'))),
    );
    await tester.pumpAndSettle();
    final skillLink = find.byKey(const ValueKey('mega-profil-Profil et CV'));
    await tester.ensureVisible(skillLink);
    await tester.tap(skillLink);
    await tester.pumpAndSettle();
    expect(destination, 'profil');
    expect(skillLink, findsNothing);
    await mouse.removePointer();
    await tester.pumpAndSettle();
  });
  testWidgets('menu Escape closes the panel and restores its trigger focus', (
    tester,
  ) async {
    setViewport(tester, const Size(1440, 1000));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: LandingMegaNavigation(onNavigate: (_) {})),
      ),
    );
    await tester.pumpAndSettle();
    final trigger = find.byKey(const ValueKey('nav-group-0'));
    expect(trigger, findsOneWidget);
    final triggerFocus = tester.widget<TextButton>(trigger).focusNode!;
    triggerFocus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('mega-matching-Le matching expliqué')),
      findsOneWidget,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('mega-matching-Le matching expliqué')),
      findsNothing,
    );
    expect(triggerFocus.hasFocus, isTrue);
  });
  testWidgets(
    'favorites, empty results and resetting filters preserve local choices',
    (tester) async {
      await mount(tester, const OpportunitiesSection());
      expect(find.text('4 exemple(s) d’offre affiché(s)'), findsOneWidget);
      final save = find.byKey(const ValueKey('save-offer-1'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      await activate(tester, 'FAVORIS (1)');
      expect(find.text('1 exemple(s) d’offre affiché(s)'), findsOneWidget);
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(
        find.byType(TextField),
        'aucun poste de cet exemple',
      );
      await tester.pumpAndSettle();
      expect(find.text('Aucune offre dans cette sélection.'), findsOneWidget);
      await activate(tester, 'REVOIR LES EXEMPLES');
      expect(find.text('4 exemple(s) d’offre affiché(s)'), findsOneWidget);
      expect(find.text('FAVORIS (1)'), findsOneWidget);
    },
  );
  testWidgets('profile clear and validation cannot publish an empty preview', (
    tester,
  ) async {
    await mount(tester, const ProfileSection());
    await activate(tester, 'EFFACER');
    expect(find.text('Le profil est encore vide.'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      isEmpty,
    );
    await activate(tester, 'METTRE À JOUR L’APERÇU');
    expect(
      find.text('Ajoute une information pour construire cet exemple.'),
      findsNWidgets(3),
    );
    await activate(tester, 'UTILISER L’EXEMPLE');
    expect(find.text('Le profil est encore vide.'), findsNothing);
    // The name exists both in the editable field and the rendered preview.
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      'Camille',
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'Camille',
      ),
      findsOneWidget,
    );
  });
  testWidgets('meeting simulation reveals and resets the conversation', (
    tester,
  ) async {
    await mount(tester, const MatchSignature(), size: const Size(390, 1000));
    expect(find.text('C’est un match.'), findsNothing);
    await activate(tester, 'VOIR L’INTÉRÊT PARTAGÉ');
    expect(find.text('C’est un match.'), findsOneWidget);
    expect(
      find.text('Alex : « Ton projet Flutter m’intéresse. On en parle ? »'),
      findsOneWidget,
    );
    await activate(tester, 'REJOUER LA RENCONTRE');
    expect(find.text('C’est un match.'), findsNothing);
    expect(find.text('Et si l’intérêt était partagé ?'), findsOneWidget);
  });
  test(
    'menu siblings use distinct pictograms including shared destinations',
    () {
      for (final group in [...landingGroups, assistanceGroup, accountGroup]) {
        final kinds = group.links.map((item) => symbolFor(item.label)).toList();
        expect(kinds.toSet().length, kinds.length, reason: group.label);
      }
      expect(
        symbolFor('Profil et CV'),
        isNot(symbolFor('Construire mon profil')),
      );
    },
  );
  testWidgets(
    'CV explanation presents the product without a fabricated score',
    (tester) async {
      await mount(tester, const MatchingWorkbench());
      expect(
        find.textContaining('À la création de ton profil'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('analysis-step-2')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Seules les offres correspondant'),
        findsOneWidget,
      );
      expect(find.textContaining('/ 3 critères'), findsNothing);
    },
  );
  testWidgets('FAQ searches accents and resets pagination after filtering', (
    tester,
  ) async {
    await mount(tester, const QuestionsSection());
    expect(find.text('1 / 3'), findsOneWidget);
    await activate(tester, 'SUIVANT');
    expect(find.text('2 / 3'), findsOneWidget);
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'analyse');
    await tester.pumpAndSettle();
    expect(find.text('Quand mon CV est-il analysé ?'), findsNothing);
    expect(
      find.textContaining('Quand mon CV est-il analysé ?'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('faq-page')), findsNothing);
    await tester.enterText(find.byType(TextField), 'zzzintrouvable');
    await tester.pumpAndSettle();
    expect(find.text('0 réponse(s)'), findsOneWidget);
    expect(find.text('POSER MA QUESTION À L’ASSISTANCE →'), findsOneWidget);
  });
  testWidgets('carousel buttons reach each endpoint without looping', (
    tester,
  ) async {
    await mount(tester, const JourneyCarousel());
    expect(find.text('1 / 3'), findsOneWidget);
    await activate(tester, 'SUIVANT');
    expect(find.text('2 / 3'), findsOneWidget);
    await activate(tester, 'SUIVANT');
    expect(find.text('3 / 3'), findsOneWidget);
    final next = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'SUIVANT'),
    );
    expect(next.onPressed, isNull);
    await activate(tester, 'PRÉCÉDENT');
    expect(find.text('2 / 3'), findsOneWidget);
    // Keyboard shortcuts apply when a carousel control has focus.
    // A simulated pointer tap does not guarantee keyboard focus.
    final previousContext = tester.element(find.text('PRÉCÉDENT'));
    final previousFocus = Focus.of(previousContext);
    previousFocus.requestFocus();
    await tester.pump();
    expect(previousFocus.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);
    // The left endpoint must also resist further keyboard navigation.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);
  });
  for (final width in [320.0, 390.0, 768.0, 1024.0, 1440.0]) {
    testWidgets('landing has no layout exceptions at width $width', (
      tester,
    ) async {
      setViewport(tester, Size(width, 1000));

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const LandingScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Joyn a job,'), findsOneWidget);
      if (width < 1280) {
        await tester.tap(find.byKey(const ValueKey('nav-menu-toggle')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('mobile-category-0')));
        await tester.pumpAndSettle();
        expect(find.text('Le matching expliqué'), findsOneWidget);
        await tester.ensureVisible(find.text('Le matching expliqué'));
        await tester.tap(find.text('Le matching expliqué'));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('nav-menu-toggle')), findsOneWidget);
        expect(find.text('Le matching expliqué'), findsNothing);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
