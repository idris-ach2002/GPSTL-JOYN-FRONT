import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/conversation.dart';
import 'messaging_repository.dart';

/// Messagerie branchée sur le back JOYN (tag « Messaging » du Swagger).
///
/// - `GET    /api/v1/conversations`
/// - `POST   /api/v1/conversations` `{application_id}`
/// - `GET    /api/v1/conversations/{id}/messages?before&limit&order`
/// - `POST   /api/v1/conversations/{id}/messages` `{text, clientId}`
/// - `PATCH  /api/v1/conversations/{id}/read`
class ApiMessagingRepository implements MessagingRepository {
  ApiMessagingRepository(this._api);

  final ApiClient _api;

  static const String basePath = '/api/v1/conversations';

  @override
  Future<ConversationList> fetchConversations() async {
    final root = _asMap(await _api.getJson(basePath));
    final items = _asList(root['data'] ?? root['items'] ?? root['content']);
    return ConversationList(
      items: items.map((e) => mapConversation(_asMap(e))).toList(),
      totalUnread: _int(root['totalUnread'] ?? root['total_unread']),
    );
  }

  @override
  Future<Conversation> openForApplication(String applicationId) async {
    try {
      final json = await _api.postJson(
        basePath,
        body: {'application_id': int.tryParse(applicationId) ?? applicationId},
      );
      return mapConversation(_unwrap(_asMap(json)));
    } on ApiException catch (error) {
      throw MessagingException(switch (error.statusCode) {
        403 =>
          'La conversation s’ouvrira quand l’entreprise t’aura proposé un '
              'entretien.',
        404 => 'Cette candidature est introuvable.',
        409 => 'Cette candidature est close : la conversation est fermée.',
        _ => 'Impossible d’ouvrir la conversation. Réessaie plus tard.',
      });
    }
  }

  @override
  Future<MessagePage> fetchMessages(
    String conversationId, {
    String? before,
    int limit = 30,
  }) async {
    final root = _asMap(
      await _api.getJson(
        '$basePath/$conversationId/messages',
        query: {'before': before, 'limit': '$limit', 'order': 'asc'},
      ),
    );
    final messages =
        _asList(root['data'] ?? root['items'])
            .map((e) => mapMessage(_asMap(e)))
            .toList()
          // Ordre chronologique quel que soit l'ordre renvoyé.
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return MessagePage(
      messages: messages,
      nextCursor: _nullableString(root['nextCursor'] ?? root['next_cursor']),
      hasMore: root['hasMore'] == true || root['has_more'] == true,
    );
  }

  @override
  Future<ChatMessage> send(
    String conversationId,
    String text, {
    required String clientId,
  }) async {
    final json = await _api.postJson(
      '$basePath/$conversationId/messages',
      body: {'text': text, 'clientId': clientId},
    );
    return mapMessage(_unwrap(_asMap(json)));
  }

  @override
  Future<void> markRead(String conversationId) async {
    await _api.patchJson(
      '$basePath/$conversationId/read',
      body: {'read': true},
    );
  }

  /// Convertit un `ConversationItem` du back.
  static Conversation mapConversation(Map<String, dynamic> json) {
    return Conversation(
      id: _string(json['id']),
      applicationId: _nullableString(
        json['applicationId'] ?? json['application_id'],
      ),
      jobOfferId: _nullableString(json['jobOfferId'] ?? json['job_offer_id']),
      offerTitle: _string(json['offerTitle'] ?? json['offer_title']),
      companyName: _string(json['companyName'] ?? json['company_name']),
      companyLogoUrl: _nullableString(json['companyLogoUrl']),
      candidateId: _nullableString(json['candidateId']),
      candidateName: _string(json['candidateName'] ?? json['name']),
      candidatePhotoUrl: _nullableString(json['candidatePhotoUrl']),
      lastMessage: _string(json['lastMessage'] ?? json['last_message']),
      lastMessageAt: _date(json['lastMessageAt'] ?? json['updatedAt']),
      unread: _int(json['unread']),
    );
  }

  /// Convertit un `MessageItem` du back.
  static ChatMessage mapMessage(Map<String, dynamic> json) {
    return ChatMessage(
      id: _string(json['id']),
      text: _string(json['text'] ?? json['content']),
      fromMe: json['fromMe'] == true || json['from_me'] == true,
      createdAt:
          _date(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
      senderName: _string(json['senderName'] ?? json['sender_name']),
      readAt: _date(json['readAt'] ?? json['read_at']),
      clientId: _nullableString(json['clientId'] ?? json['client_id']),
    );
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> root) {
    final data = root['data'];
    return data is Map<String, dynamic> ? data : root;
  }

  static Map<String, dynamic> _asMap(Object? value) =>
      value is Map<String, dynamic> ? value : const {};

  static List<Object?> _asList(Object? value) =>
      value is List ? value : const [];

  static String _string(Object? value) => value?.toString().trim() ?? '';

  static String? _nullableString(Object? value) {
    final text = _string(value);
    return text.isEmpty ? null : text;
  }

  static int _int(Object? value) => switch (value) {
    int v => v,
    num v => v.round(),
    String v => int.tryParse(v) ?? 0,
    _ => 0,
  };

  static DateTime? _date(Object? value) =>
      value == null ? null : DateTime.tryParse(value.toString())?.toLocal();
}
