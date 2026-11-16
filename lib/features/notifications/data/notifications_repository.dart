import '../domain/app_notification.dart';

/// Notifications de l'utilisateur connecté (tag « Notifications » du back).
abstract interface class NotificationsRepository {
  /// Dernières notifications, les plus récentes d'abord.
  Future<NotificationPage> fetch({int limit = 30});

  Future<void> markRead(String id);

  Future<void> markAllRead();

  Future<void> delete(String id);

  /// Supprime toutes les notifications déjà lues ; renvoie leur nombre.
  Future<int> deleteRead();
}
