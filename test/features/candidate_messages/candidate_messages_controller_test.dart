import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/candidate_applications/data/mock_candidate_applications_repository.dart';
import 'package:joyn_front/features/candidate_messages/presentation/controllers/candidate_messages_controller.dart';
import 'package:joyn_front/features/messaging/data/mock_messaging_repository.dart';
import 'package:joyn_front/features/messaging/domain/conversation.dart';

/// Mercredi 11 novembre 2026, 10 h.
final DateTime now = DateTime(2026, 11, 11, 10);

/// Dépôt dont l'envoi échoue à la demande.
class _FlakyMessaging extends MockMessagingRepository {
  _FlakyMessaging(MockCandidateApplicationsRepository apps)
    : super(latency: Duration.zero, applications: apps, clock: () => now);

  bool failSend = false;

  @override
  Future<ChatMessage> send(
    String conversationId,
    String text, {
    required String clientId,
  }) {
    if (failSend) throw Exception('réseau');
    return super.send(conversationId, text, clientId: clientId);
  }
}

void main() {
  late MockCandidateApplicationsRepository applications;
  late _FlakyMessaging messaging;
  late CandidateMessagesController controller;

  setUp(() {
    applications = MockCandidateApplicationsRepository.demo(
      latency: Duration.zero,
      clock: () => now,
    );
    messaging = _FlakyMessaging(applications);
    controller = CandidateMessagesController(
      messaging,
      applicationsRepository: applications,
      pollInterval: null,
      clock: () => now,
    );
  });

  tearDown(() => controller.dispose());

  test('fusionne conversations, entretiens à démarrer et attentes', () async {
    await controller.load();

    final byCompany = {
      for (final t in controller.threads) t.companyName: t.state,
    };
    // Conversation existante (démo).
    expect(byCompany['Banque Horizon'], ThreadState.open);
    // Entretien sans conversation : on peut la démarrer.
    expect(byCompany['Kanopé'], ThreadState.startable);
    // Candidatures envoyées : verrouillées en attente de réponse.
    expect(byCompany['Atelier Numérique'], ThreadState.locked);
    expect(byCompany['Medisoft'], ThreadState.locked);
    // Refus et « Intéressé » (non envoyée) ne sont pas listés.
    expect(byCompany.containsKey('Datalis'), isFalse);
    expect(byCompany.containsKey('Orbit Paiements'), isFalse);
    expect(controller.totalUnread, 1);
  });

  test(
    'ouvrir une conversation charge les messages et la marque lue',
    () async {
      await controller.load(select: 'app-seed-4');

      expect(controller.selected?.companyName, 'Banque Horizon');
      expect(controller.messages, hasLength(3));
      expect(controller.totalUnread, 0);
      final list = await messaging.fetchConversations();
      expect(list.totalUnread, 0);
    },
  );

  test('envoyer affiche le message tout de suite puis le confirme', () async {
    await controller.load(select: 'app-seed-4');

    final future = controller.send('  Parfait, à jeudi !  ');
    expect(controller.messages.last.delivery, MessageDelivery.sending);
    expect(controller.messages.last.text, 'Parfait, à jeudi !');
    await future;

    expect(controller.messages.last.delivery, MessageDelivery.sent);
    expect(controller.threads.first.preview, 'Parfait, à jeudi !');
  });

  test('un envoi raté reste visible et peut être renvoyé', () async {
    await controller.load(select: 'app-seed-4');
    messaging.failSend = true;

    await controller.send('Bonjour');
    final failed = controller.messages.last;
    expect(failed.delivery, MessageDelivery.failed);
    expect(controller.notice, isNotNull);

    messaging.failSend = false;
    await controller.retry(failed);
    expect(controller.messages.last.delivery, MessageDelivery.sent);
    expect(controller.messages.where((m) => m.text == 'Bonjour'), hasLength(1));
  });

  test('démarrer la conversation d’un entretien l’ouvre', () async {
    await controller.load(select: 'app-seed-5');
    final kanope = controller.selected!;
    expect(kanope.state, ThreadState.startable);

    await controller.start(kanope);

    expect(controller.selected?.state, ThreadState.open);
    expect(controller.selected?.companyName, 'Kanopé');
    await controller.send('Bonjour, merci pour la proposition !');
    expect(controller.messages, hasLength(1));
  });

  test('on ne peut pas écrire dans un fil verrouillé', () async {
    await controller.load(select: 'app-seed-2');
    expect(controller.selected?.state, ThreadState.locked);

    await controller.send('Bonjour ?');

    expect(controller.messages, isEmpty);
  });

  test('la recherche filtre par entreprise ou par offre', () async {
    await controller.load();

    controller.search('java');

    expect(controller.threads.map((t) => t.companyName), ['Banque Horizon']);
  });
}
