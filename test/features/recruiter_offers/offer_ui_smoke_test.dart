import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/recruiter_offers/data/mock_recruiter_offers_repository.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/controllers/offer_detail_controller.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/controllers/offer_editor_controller.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/controllers/offer_management_controller.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/mobile/mobile_recruiter_offers_screen.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/web/offer_editor_screen.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/web/recruiter_offers_screen.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/web/web_offer_detail_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('mobile : la gestion des offres reste lisible sur 320 px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = MockRecruiterOffersRepository(latency: Duration.zero);
    final controller = OfferManagementController(repository);
    await controller.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: MobileRecruiterOffersScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Mes offres'), findsOneWidget);
    expect(find.textContaining('Développeur·se Full-Stack'), findsOneWidget);
    expect(find.textContaining('Lire la suite'), findsWidgets);
    final mobileDescription = tester
        .widgetList<Text>(find.byType(Text))
        .where(
          (widget) => widget.data?.contains('Rejoignez notre équipe') ?? false,
        );
    expect(mobileDescription.any((widget) => widget.maxLines == 2), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('web : la création rend le formulaire et son aperçu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = MockRecruiterOffersRepository(latency: Duration.zero);
    final controller = OfferEditorController(repository);
    await controller.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: WebOfferEditorScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Créer une offre'), findsOneWidget);
    expect(find.text('Choisir une entreprise *'), findsOneWidget);
    expect(find.text('Aperçu de l’offre'), findsOneWidget);
    expect(find.text('Publier l’offre'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'web : les cartes premium et le menu options restent sans overflow',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = MockRecruiterOffersRepository(latency: Duration.zero);
      final controller = OfferManagementController(repository);
      await controller.load();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: const MaterialApp(home: WebRecruiterOffersScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Mes offres'), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsWidgets);
      expect(find.textContaining('Développeur·se Full-Stack'), findsOneWidget);
      expect(find.textContaining('Lire la suite'), findsWidgets);
      final webDescription = tester
          .widgetList<Text>(find.byType(Text))
          .where(
            (widget) =>
                widget.data?.contains('Rejoignez notre équipe') ?? false,
          );
      expect(webDescription.any((widget) => widget.maxLines == 2), isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('web : le détail affiche toute l’offre en lecture seule', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = MockRecruiterOffersRepository(latency: Duration.zero);
    final controller = OfferDetailController(repository, 1);
    await controller.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: WebOfferDetailScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.text('Description complète'), findsOneWidget);
    expect(find.text('Informations de l’offre'), findsOneWidget);
    expect(find.text('Détails de l’alternance'), findsOneWidget);
    expect(find.text('Entreprise'), findsWidgets);
    expect(find.textContaining('Développeur·se Full-Stack'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
