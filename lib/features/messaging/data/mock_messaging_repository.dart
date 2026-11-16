import '../../candidate_applications/data/mock_candidate_applications_repository.dart';
import '../../candidate_applications/domain/candidate_application.dart';
import '../domain/conversation.dart';
import 'messaging_repository.dart';

/// Messagerie SIMULÉE, vue du candidat de démonstration.
///
/// Cohérente avec les candidatures de démo : Banque Horizon (entretien) a déjà
/// écrit ; Kanopé (entretien) n'a pas encore de conversation, que le candidat
/// peut ouvrir. Comme le back, seules les candidatures au stade entretien
/// peuvent ouvrir une conversation. Aucune réponse du recruteur n'est inventée
/// après un envoi.
class MockMessagingRepository implements MessagingRepository {
  MockMessagingRepository({
    this.latency = const Duration(milliseconds: 350),
    this.applications,
    DateTime Function()? clock,
    bool seed = true,
  }) : _clock = clock ?? DateTime.now {
    if (seed) _seed();
  }

  final Duration latency;

  /// Candidatures simulées, pour savoir quelles conversations peuvent s'ouvrir.
  final MockCandidateApplicationsRepository? applications;
  final DateTime Function() _clock;

  final List<Conversation> _conversations = [];
  final Map<String, List<ChatMessage>> _messages = {};
  int _nextId = 100;

  void _seed() {
    final now = _clock();
    DateTime ago({int days = 0, int hours = 0, int minutes = 0}) =>
        now.subtract(Duration(days: days, hours: hours, minutes: minutes));
    final interview = DateTime(now.year, now.month, now.day + 2, 13);
    final day =
        '${interview.day.toString().padLeft(2, '0')}/'
        '${interview.month.toString().padLeft(2, '0')}';

    const id = 'conv-horizon';
    final messages = [
      ChatMessage(
        id: 'm1',
        text:
            'Bonjour Alex, merci pour votre candidature. Votre profil nous '
            'intéresse beaucoup pour l’alternance Java.',
        fromMe: false,
        senderName: 'Camille Martin · Banque Horizon',
        createdAt: ago(days: 3, hours: 2),
      ),
      ChatMessage(
        id: 'm2',
        text:
            'Bonjour, merci beaucoup ! Je serais ravi d’échanger avec vous '
            'sur le poste.',
        fromMe: true,
        createdAt: ago(days: 3, hours: 1),
        readAt: ago(days: 3),
      ),
      ChatMessage(
        id: 'm3',
        text:
            'Parfait. Je vous propose un entretien le $day à 13 h, en visio. '
            'Le lien vous sera envoyé la veille.',
        fromMe: false,
        senderName: 'Camille Martin · Banque Horizon',
        createdAt: ago(hours: 3),
      ),
    ];
    _messages[id] = messages;
    _conversations.add(
      Conversation(
        id: id,
        applicationId: 'app-seed-4',
        jobOfferId: 'seed-4',
        offerTitle: 'Développeur·euse Java en alternance',
        companyName: 'Banque Horizon',
        candidateName: 'Alex Dupont',
        lastMessage: messages.last.text,
        lastMessageAt: messages.last.createdAt,
        unread: 1,
      ),
    );
  }

  @override
  Future<ConversationList> fetchConversations() async {
    await Future<void>.delayed(latency);
    final items = [..._conversations]
      ..sort(
        (a, b) => (b.lastMessageAt ?? DateTime(0)).compareTo(
          a.lastMessageAt ?? DateTime(0),
        ),
      );
    return ConversationList(
      items: items,
      totalUnread: items.fold(0, (sum, c) => sum + c.unread),
    );
  }

  @override
  Future<Conversation> openForApplication(String applicationId) async {
    await Future<void>.delayed(latency);
    for (final c in _conversations) {
      if (c.applicationId == applicationId) return c;
    }
    final application = applications?.applications
        .where((a) => a.id == applicationId)
        .firstOrNull;
    if (application == null) {
      throw const MessagingException('Cette candidature est introuvable.');
    }
    if (application.status != ApplicationStatus.interview) {
      throw const MessagingException(
        'La conversation s’ouvrira quand l’entreprise t’aura proposé un '
        'entretien.',
      );
    }
    final conversation = Conversation(
      id: 'conv-${_nextId++}',
      applicationId: application.id,
      jobOfferId: application.offerId,
      offerTitle: application.jobTitle ?? '',
      companyName: application.companyName ?? '',
      candidateName: 'Alex Dupont',
      lastMessageAt: _clock(),
    );
    _conversations.add(conversation);
    _messages[conversation.id] = [];
    return conversation;
  }

  @override
  Future<MessagePage> fetchMessages(
    String conversationId, {
    String? before,
    int limit = 30,
  }) async {
    await Future<void>.delayed(latency);
    final all = _messages[conversationId] ?? const <ChatMessage>[];
    var end = all.length;
    if (before != null) {
      final index = all.indexWhere((m) => m.id == before);
      if (index >= 0) end = index;
    }
    final start = (end - limit).clamp(0, end);
    return MessagePage(
      messages: all.sublist(start, end),
      nextCursor: start > 0 ? all[start].id : null,
      hasMore: start > 0,
    );
  }

  @override
  Future<ChatMessage> send(
    String conversationId,
    String text, {
    required String clientId,
  }) async {
    await Future<void>.delayed(latency);
    final list = _messages[conversationId];
    if (list == null) {
      throw const MessagingException('Conversation introuvable.');
    }
    for (final m in list) {
      if (m.clientId == clientId) return m;
    }
    final message = ChatMessage(
      id: 'm${_nextId++}',
      text: text,
      fromMe: true,
      createdAt: _clock(),
      clientId: clientId,
    );
    list.add(message);
    _replace(
      conversationId,
      (c) => c.copyWith(lastMessage: text, lastMessageAt: message.createdAt),
    );
    return message;
  }

  @override
  Future<void> markRead(String conversationId) async {
    await Future<void>.delayed(latency);
    _replace(conversationId, (c) => c.copyWith(unread: 0));
  }

  void _replace(String id, Conversation Function(Conversation) update) {
    final index = _conversations.indexWhere((c) => c.id == id);
    if (index >= 0) _conversations[index] = update(_conversations[index]);
  }
}
