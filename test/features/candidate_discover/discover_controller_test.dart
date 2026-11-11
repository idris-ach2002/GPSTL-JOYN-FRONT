import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/candidate_applications/data/mock_candidate_applications_repository.dart';
import 'package:joyn_front/features/candidate_applications/domain/candidate_application.dart';
import 'package:joyn_front/features/candidate_discover/data/mock_recommended_offers_repository.dart';
import 'package:joyn_front/features/candidate_discover/data/recommended_offers_repository.dart';
import 'package:joyn_front/features/candidate_discover/domain/recommended_offer.dart';
import 'package:joyn_front/features/candidate_discover/presentation/controllers/discover_controller.dart';

/// Dépôt qui échoue à la demande, pour tester le retour arrière optimiste.
class _FailingRepository extends MockRecommendedOffersRepository {
  _FailingRepository() : super(latency: Duration.zero);

  bool failDecisions = false;
  bool failLoad = false;

  @override
  Future<DiscoverFeed> fetchFeed({
    DiscoverFilters filters = const DiscoverFilters(),
  }) {
    if (failLoad) throw Exception('réseau');
    return super.fetchFeed(filters: filters);
  }

  @override
  Future<void> submitDecision(String offerId, SwipeDecision decision) {
    if (failDecisions) throw Exception('refus');
    return super.submitDecision(offerId, decision);
  }

  @override
  Future<void> cancelDecision(String offerId) {
    if (failDecisions) throw Exception('refus');
    return super.cancelDecision(offerId);
  }
}

void main() {
  late MockRecommendedOffersRepository repository;
  late DiscoverController controller;

  setUp(() {
    repository = MockRecommendedOffersRepository(latency: Duration.zero);
    controller = DiscoverController(repository);
  });

  tearDown(() => controller.dispose());

  test('charge la pile triée par compatibilité décroissante', () async {
    await controller.load();

    expect(controller.status, DiscoverStatus.ready);
    expect(controller.offers, hasLength(demoRecommendedOffers.length));
    final scores = controller.offers.map((o) => o.compatibility).toList();
    expect(scores, [...scores]..sort((a, b) => b.compareTo(a)));
    expect(controller.current?.id, 'demo-1');
    expect(controller.filters.rhythm, '3 sem / 1 sem');
    expect(controller.filters.location, 'Paris');
  });

  test('postuler retire la carte et enregistre la candidature', () async {
    await controller.load();

    final ok = await controller.decide(SwipeDecision.interested);

    expect(ok, isTrue);
    expect(controller.current?.id, 'demo-2');
    expect(controller.interestedCount, 1);
    expect(repository.decisions, {'demo-1': SwipeDecision.interested});
  });

  test('une offre traitée ne revient pas au rechargement', () async {
    await controller.load();
    await controller.decide(SwipeDecision.skip);
    await controller.decide(SwipeDecision.save);

    await controller.load();

    expect(controller.offers.map((o) => o.id), isNot(contains('demo-1')));
    expect(controller.offers.map((o) => o.id), isNot(contains('demo-2')));
  });

  test('annuler remet la carte en tête et efface le geste', () async {
    await controller.load();
    await controller.decide(SwipeDecision.interested);

    final ok = await controller.undo();

    expect(ok, isTrue);
    expect(controller.current?.id, 'demo-1');
    expect(controller.canUndo, isFalse);
    expect(controller.interestedCount, 0);
    expect(repository.decisions, isEmpty);
  });

  test(
    'si le backend refuse, la carte revient en tête avec une erreur',
    () async {
      final failing = _FailingRepository();
      final c = DiscoverController(failing);
      addTearDown(c.dispose);
      await c.load();
      failing.failDecisions = true;

      final ok = await c.decide(SwipeDecision.interested);

      expect(ok, isFalse);
      expect(c.current?.id, 'demo-1');
      expect(c.canUndo, isFalse);
      expect(
        c.actionError,
        "L'offre n'a pas pu être ajoutée à vos candidatures.",
      );
    },
  );

  test('si l’annulation échoue, la carte reste traitée', () async {
    final failing = _FailingRepository();
    final c = DiscoverController(failing);
    addTearDown(c.dispose);
    await c.load();
    await c.decide(SwipeDecision.skip);
    failing.failDecisions = true;

    final ok = await c.undo();

    expect(ok, isFalse);
    expect(c.current?.id, 'demo-2');
    expect(c.canUndo, isTrue);
    expect(c.actionError, isNotNull);
  });

  test('passe en erreur si le chargement échoue', () async {
    final failing = _FailingRepository()..failLoad = true;
    final c = DiscoverController(failing);
    addTearDown(c.dispose);

    await c.load();

    expect(c.status, DiscoverStatus.error);
    expect(c.errorMessage, isNotNull);
  });

  test('aucun geste possible quand la pile est vide', () async {
    final RecommendedOffersRepository empty = MockRecommendedOffersRepository(
      latency: Duration.zero,
      offers: const [],
    );
    final c = DiscoverController(empty);
    addTearDown(c.dispose);
    await c.load();

    expect(c.current, isNull);
    expect(await c.decide(SwipeDecision.interested), isFalse);
  });

  test(
    'une offre « Intéressé » rejoint les candidatures, et en sort si on annule',
    () async {
      final applications = MockCandidateApplicationsRepository(
        latency: Duration.zero,
      );
      final c = DiscoverController(
        MockRecommendedOffersRepository(
          latency: Duration.zero,
          applications: applications,
        ),
      );
      addTearDown(c.dispose);
      await c.load();

      await c.decide(SwipeDecision.interested);
      await c.decide(SwipeDecision.skip);

      final added = applications.applications.single;
      expect(added.offerId, 'demo-1');
      expect(added.status, ApplicationStatus.interested);
      expect(added.companyName, 'Entreprise Beta');
      expect(added.matchScore, 92);

      await c.undo(); // annule « passer »
      await c.undo(); // annule « intéressé »
      expect(applications.applications, isEmpty);
    },
  );
}
