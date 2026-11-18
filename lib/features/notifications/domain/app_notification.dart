/// Type de notification renvoyé par le back.
enum NotificationKind {
  newMatch,
  newMessage,
  applicationUpdate,
  newApplication,
  interview,
  newOffer,
  recommendation,
  system;

  static NotificationKind fromApi(String? value) =>
      switch (value?.trim().toUpperCase()) {
        'NEW_MATCH' => newMatch,
        'NEW_MESSAGE' => newMessage,
        'APPLICATION_UPDATE' => applicationUpdate,
        'NEW_APPLICATION' => newApplication,
        'INTERVIEW' => interview,
        'NEW_OFFER' => newOffer,
        'RECOMMENDATION' => recommendation,
        _ => system,
      };
}

/// Une notification de l'utilisateur connecté.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.createdAt,
    this.message = '',
    this.link,
    this.isRead = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String message;

  /// Lien éventuel fourni par le back (non utilisé pour naviguer : on
  /// s'appuie sur [kind], plus fiable côté front).
  final String? link;
  final bool isRead;
  final DateTime createdAt;

  AppNotification markRead([bool read = true]) => AppNotification(
    id: id,
    kind: kind,
    title: title,
    createdAt: createdAt,
    message: message,
    link: link,
    isRead: read,
  );
}

/// Une page de notifications et le nombre total de non-lues.
class NotificationPage {
  const NotificationPage({required this.items, this.unreadCount = 0});

  final List<AppNotification> items;
  final int unreadCount;
}
