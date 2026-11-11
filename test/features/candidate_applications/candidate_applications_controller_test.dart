import 'package:flutter_test/flutter_test.dart';

import 'package:joyn_front/features/candidate_applications/data/candidate_applications_repository.dart';
import 'package:joyn_front/features/candidate_applications/data/mock_candidate_applications_repository.dart';
import 'package:joyn_front/features/candidate_applications/domain/candidate_application.dart';
import 'package:joyn_front/features/candidate_applications/presentation/candidate_applications_controller.dart';
import 'package:joyn_front/features/candidate_applications/presentation/shared/application_formatters.dart';

/// Mercredi 14 octobre 2026.
final DateTime today = DateTime(2026, 10, 14, 10);

CandidateApplication application(
  String id,
  ApplicationStatus status, {
  int daysAgo = 0,
  DateTime? interviewAt,
  String? conversationId,
}) {
  return CandidateApplication(
    id: id,
    status: status,
    appliedAt: today.subtract(Duration(days: daysAgo)),
    interviewAt: interviewAt,
    conversationId: conversationId,
  );
}

CandidateApplicationsController controllerWith(
  List<CandidateApplication> applications,
) {
  return CandidateApplicationsController(
    MockCandidateApplicationsRepository(
      latency: Duration.zero,
      applications: applications,
    ),
    clock: () => today,
  );
}

class _FailingRepository implements CandidateApplicationsRepository {
  @override
  Future<ApplicationsPage> fetchApplications({
    int page = 1,
    int pageSize = 20,
  }) => throw Exception('hors ligne');

  @override
  Future<String> createConversation(String applicationId) =>
      throw Exception('hors ligne');

  @override
  Future<CandidateApplication> sendApplication(String applicationId) =>
      throw Exception('hors ligne');
}

void main() {
  test(
    'envoyer fait passer une candidature de « Intéressé » à « Envoyées »',
    () async {
      final controller = controllerWith([
        application('aimee', ApplicationStatus.interested, daysAgo: 1),
      ]);
      await controller.load();

      final ok = await controller.send(controller.items.single);

      expect(ok, isTrue);
      expect(controller.byStatus(ApplicationStatus.interested), isEmpty);
      expect(controller.byStatus(ApplicationStatus.sent).map((a) => a.id), [
        'aimee',
      ]);
      // Le dépôt simulé a bien enregistré l'envoi : il survit au rechargement.
      await controller.load();
      expect(controller.items.single.status, ApplicationStatus.sent);
    },
  );

  test('si l’envoi échoue, la candidature reste dans « Intéressé »', () async {
    final failing = _FailingRepository();
    final controller = CandidateApplicationsController(failing);
    const aimee = CandidateApplication(
      id: 'aimee',
      status: ApplicationStatus.interested,
    );

    // Pas de chargement possible : on teste l'envoi seul.
    final ok = await controller.send(aimee);

    expect(ok, isFalse);
    expect(controller.isSending('aimee'), isFalse);
  });

  test('une candidature déjà envoyée ne peut pas être renvoyée', () async {
    final controller = controllerWith([
      application('envoyee', ApplicationStatus.sent, daysAgo: 1),
    ]);
    await controller.load();

    expect(await controller.send(controller.items.single), isFalse);
  });

  test('sans backend : aucune candidature, aucun entretien', () async {
    final controller = controllerWith(const []);
    await controller.load();

    expect(controller.items, isEmpty);
    expect(controller.totalItems, 0);
    expect(controller.interviewsThisWeek, 0);
    expect(controller.hasMore, isFalse);
    expect(controller.errorMessage, isNull);
  });

  test('trie par date antéchronologique et regroupe par statut', () async {
    final controller = controllerWith([
      application('ancienne', ApplicationStatus.sent, daysAgo: 9),
      application('recente', ApplicationStatus.sent, daysAgo: 1),
      application('refus', ApplicationStatus.rejected, daysAgo: 4),
    ]);
    await controller.load();

    expect(controller.items.map((a) => a.id), ['recente', 'refus', 'ancienne']);
    expect(controller.byStatus(ApplicationStatus.sent).map((a) => a.id), [
      'recente',
      'ancienne',
    ]);
  });

  test('compte seulement les entretiens de la semaine en cours', () async {
    final controller = controllerWith([
      application(
        'lundi',
        ApplicationStatus.interview,
        interviewAt: DateTime(2026, 10, 12, 9),
      ),
      application(
        'dimanche',
        ApplicationStatus.interview,
        interviewAt: DateTime(2026, 10, 18, 18),
      ),
      application(
        'semaine-prochaine',
        ApplicationStatus.interview,
        interviewAt: DateTime(2026, 10, 19, 9),
      ),
    ]);
    await controller.load();

    expect(controller.interviewsThisWeek, 2);
  });

  test('charge les pages suivantes', () async {
    final controller = controllerWith([
      for (var i = 0; i < 25; i++)
        application('a$i', ApplicationStatus.sent, daysAgo: i),
    ]);
    await controller.load();
    expect(controller.items, hasLength(20));
    expect(controller.hasMore, isTrue);

    await controller.loadMore();
    expect(controller.items, hasLength(25));
    expect(controller.totalItems, 25);
    expect(controller.hasMore, isFalse);
  });

  test('affiche une erreur si le chargement échoue', () async {
    final controller = CandidateApplicationsController(_FailingRepository());
    await controller.load();

    expect(controller.errorMessage, isNotNull);
    expect(controller.isLoading, isFalse);
  });

  group('ouverture de la conversation', () {
    test('réutilise la conversation existante', () async {
      final controller = controllerWith(const []);
      final outcome = await controller.openConversation(
        application('a', ApplicationStatus.sent, conversationId: 'c-42'),
      );

      expect(outcome, isA<ConversationReady>());
      expect((outcome as ConversationReady).conversationId, 'c-42');
    });

    test('crée le fil à l’étape entretien', () async {
      final interview = application('a', ApplicationStatus.interview);
      final controller = controllerWith([interview]);
      await controller.load();

      final outcome = await controller.openConversation(interview);

      expect(outcome, isA<ConversationReady>());
      expect(controller.items.single.conversationId, 'mock-conversation-a');
    });

    test('refuse tant que le statut ne le permet pas', () async {
      final controller = controllerWith(const []);

      for (final status in [
        ApplicationStatus.interested,
        ApplicationStatus.sent,
        ApplicationStatus.rejected,
      ]) {
        expect(
          await controller.openConversation(application('a', status)),
          isA<ConversationUnavailable>(),
        );
      }
    });

    test('signale un échec de création', () async {
      final controller = CandidateApplicationsController(_FailingRepository());
      final outcome = await controller.openConversation(
        application('a', ApplicationStatus.interview),
      );

      expect(outcome, isA<ConversationFailed>());
      expect(controller.openingId, isNull);
    });
  });

  group('ApplicationFormatters', () {
    test('dates relatives', () {
      String rel(int days) => ApplicationFormatters.relativeDay(
        today.subtract(Duration(days: days)),
        today,
      );

      expect(rel(0), 'Aujourd’hui');
      expect(rel(1), 'Hier');
      expect(rel(2), 'Il y a 2 j');
      expect(rel(7), 'Il y a 1 sem');
      expect(rel(60), 'Il y a 2 mois');
      expect(ApplicationFormatters.relativeDay(null, today), '—');
    });

    test('résumé au singulier et au pluriel', () {
      expect(
        ApplicationFormatters.summary(applications: 16, interviews: 2),
        '16 candidatures · 2 entretiens cette semaine',
      );
      expect(
        ApplicationFormatters.summary(applications: 1, interviews: 0),
        '1 candidature · 0 entretien cette semaine',
      );
    });

    test('date courte et initiales', () {
      expect(
        ApplicationFormatters.shortDate(DateTime(2026, 10, 2)),
        '02/10/2026',
      );
      expect(ApplicationFormatters.companyInitials('entreprise XY'), 'En');
      expect(ApplicationFormatters.companyInitials(null), '—');
    });
  });
}
