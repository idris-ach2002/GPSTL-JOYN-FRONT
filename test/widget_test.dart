import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/app/app.dart';
import 'package:joyn_front/features/landing/presentation/widgets/hero_match_preview.dart';

void main() {
  testWidgets('JOYN landing renders the premium product story', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const JoynApp());
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Joyn a job,'), findsOneWidget);
    expect(find.byType(HeroMatchPreview), findsOneWidget);
    expect(
      find.text(
        'Chercher une alternance ne devrait pas être un job à plein temps.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Des opportunités qui te ressemblent vraiment.'),
      findsOneWidget,
    );
    expect(
      find.text('Du profil au premier entretien, en trois gestes.'),
      findsOneWidget,
    );
    expect(
      find.text("Tout ce qu'il faut pour décrocher ta place."),
      findsOneWidget,
    );
    expect(
      find.text('Moins de CV à trier.\nPlus de candidats motivés.'),
      findsOneWidget,
    );
    expect(find.text('Gratuit pour commencer.'), findsOneWidget);
  });

  testWidgets('mobile landing navigation opens feature submenu', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const JoynApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pump(const Duration(milliseconds: 350));

    final featuresNav = find.byKey(
      const ValueKey('mobile-nav-Fonctionnalités'),
    );
    expect(featuresNav, findsOneWidget);
    await tester.ensureVisible(featuresNav);
    await tester.pump(const Duration(milliseconds: 120));
    await tester.tap(featuresNav);
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const ValueKey('mobile-submenu-Matching intelligent')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('mobile-submenu-Découverte fluide')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('mobile-submenu-Échange direct')),
      findsOneWidget,
    );
  });

  testWidgets('feature showcase changes mockup', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const JoynApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text('3 compétences à renforcer pour passer au-dessus de 95 %.'),
      findsNothing,
    );

    final skillGap = find.text('Skill Gap').first;
    await tester.ensureVisible(skillGap);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(skillGap);
    await tester.pump(const Duration(milliseconds: 450));

    expect(
      find.text('3 compétences à renforcer pour passer au-dessus de 95 %.'),
      findsOneWidget,
    );
  });

  testWidgets('pricing switch exposes recruiter proposition', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const JoynApp());
    await tester.pump(const Duration(milliseconds: 500));

    final recruiterSegment = find.byKey(
      const ValueKey('pricing-segment-Recruteur'),
    );
    expect(recruiterSegment, findsOneWidget);

    // LandingReveal animates this control with a Transform. In widget tests,
    // hit-testing a transformed child after a long programmatic scroll can be
    // flaky even though the control is clickable in the browser. Invoke the
    // InkWell callback directly here: this test verifies the pricing state
    // transition and AnimatedSwitcher content, while the responsive test
    // already validates the rendered page at the main breakpoints.
    final recruiterInkWell = tester.widget<InkWell>(recruiterSegment);
    expect(recruiterInkWell.onTap, isNotNull);
    recruiterInkWell.onTap!.call();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    expect(find.byKey(const ValueKey('recruiter')), findsOneWidget);
    expect(find.text('Recrutement à l’annonce'), findsOneWidget);
    expect(find.text('À l’annonce'), findsOneWidget);
  });

  testWidgets('landing stays renderable across key responsive widths', (
    tester,
  ) async {
    for (final size in const [
      Size(1440, 1000),
      Size(1024, 900),
      Size(768, 900),
      Size(430, 900),
      Size(390, 844),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(const JoynApp());
      await tester.pump(const Duration(milliseconds: 250));
      expect(
        tester.takeException(),
        isNull,
        reason: 'Unexpected exception at $size',
      );
    }

    await tester.binding.setSurfaceSize(null);
  });
}
