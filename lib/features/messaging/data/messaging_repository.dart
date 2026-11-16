import '../domain/conversation.dart';

/// Messagerie candidat ↔ recruteur, commune aux deux espaces.
///
/// Implémentations :
/// - `ApiMessagingRepository` : back JOYN (`/api/v1/conversations`) ;
/// - `MockMessagingRepository` : conversations de démonstration.
abstract interface class MessagingRepository {
  /// Conversations de l'utilisateur connecté, les plus actives d'abord.
  Future<ConversationList> fetchConversations();

  /// Ouvre la conversation liée à une candidature (ou renvoie celle qui
  /// existe déjà).
  ///
  /// Côté candidat, le back ne l'autorise qu'à partir de l'entretien : lève
  /// une [MessagingException] avant.
  Future<Conversation> openForApplication(String applicationId);

  /// Messages les plus récents, ou ceux d'avant [before] pour remonter le fil.
  Future<MessagePage> fetchMessages(
    String conversationId, {
    String? before,
    int limit = 30,
  });

  /// Envoie un message ; [clientId] évite les doublons en cas de nouvel essai.
  Future<ChatMessage> send(
    String conversationId,
    String text, {
    required String clientId,
  });

  /// Marque comme lus les messages reçus dans la conversation.
  Future<void> markRead(String conversationId);
}
