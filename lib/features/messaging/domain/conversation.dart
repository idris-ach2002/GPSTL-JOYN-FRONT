/// Conversation entre un candidat et un recruteur, liée à une candidature.
///
/// Correspond à `ConversationItem` du back (`GET /api/v1/conversations`).
class Conversation {
  const Conversation({
    required this.id,
    this.applicationId,
    this.jobOfferId,
    this.offerTitle = '',
    this.companyName = '',
    this.companyLogoUrl,
    this.candidateId,
    this.candidateName = '',
    this.candidatePhotoUrl,
    this.lastMessage = '',
    this.lastMessageAt,
    this.unread = 0,
  });

  final String id;
  final String? applicationId;
  final String? jobOfferId;
  final String offerTitle;
  final String companyName;
  final String? companyLogoUrl;
  final String? candidateId;
  final String candidateName;
  final String? candidatePhotoUrl;
  final String lastMessage;
  final DateTime? lastMessageAt;

  /// Messages non lus par l'utilisateur connecté.
  final int unread;

  Conversation copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unread,
  }) {
    return Conversation(
      id: id,
      applicationId: applicationId,
      jobOfferId: jobOfferId,
      offerTitle: offerTitle,
      companyName: companyName,
      companyLogoUrl: companyLogoUrl,
      candidateId: candidateId,
      candidateName: candidateName,
      candidatePhotoUrl: candidatePhotoUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unread: unread ?? this.unread,
    );
  }
}

/// Liste des conversations et total des non-lus.
class ConversationList {
  const ConversationList({required this.items, this.totalUnread = 0});

  final List<Conversation> items;
  final int totalUnread;
}

/// État d'envoi d'un message écrit par l'utilisateur.
enum MessageDelivery { sending, sent, failed }

/// Un message du fil.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.fromMe,
    required this.createdAt,
    this.senderName = '',
    this.readAt,
    this.clientId,
    this.delivery = MessageDelivery.sent,
  });

  final String id;
  final String text;

  /// `true` si l'utilisateur connecté en est l'auteur.
  final bool fromMe;
  final DateTime createdAt;
  final String senderName;

  /// Date de lecture par le destinataire (accusé « Lu »).
  final DateTime? readAt;

  /// Identifiant temporaire choisi par le front, renvoyé tel quel par le back.
  /// Il permet de remplacer le message « en cours d'envoi » par le vrai.
  final String? clientId;
  final MessageDelivery delivery;

  ChatMessage copyWith({MessageDelivery? delivery}) {
    return ChatMessage(
      id: id,
      text: text,
      fromMe: fromMe,
      createdAt: createdAt,
      senderName: senderName,
      readAt: readAt,
      clientId: clientId,
      delivery: delivery ?? this.delivery,
    );
  }
}

/// Une page de messages, du plus ancien au plus récent.
class MessagePage {
  const MessagePage({
    required this.messages,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<ChatMessage> messages;

  /// À passer en `before` pour charger les messages plus anciens.
  final String? nextCursor;
  final bool hasMore;
}

/// Erreur métier de la messagerie, affichable telle quelle.
class MessagingException implements Exception {
  const MessagingException(this.message);

  final String message;

  @override
  String toString() => 'MessagingException: $message';
}
