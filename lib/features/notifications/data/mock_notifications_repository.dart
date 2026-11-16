import '../domain/app_notification.dart';
import 'notifications_repository.dart';

/// Notifications SIMULÉES du candidat de démonstration, cohérentes avec les
/// offres (« Matchs »), les candidatures et la messagerie de démo.
class MockNotificationsRepository implements NotificationsRepository {
  MockNotificationsRepository({
    this.latency = const Duration(milliseconds: 300),
    DateTime Function()? clock,
    List<AppNotification>? items,
  }) : _items = items ?? _demo((clock ?? DateTime.now)());

  final Duration latency;
  final List<AppNotification> _items;

  static List<AppNotification> _demo(DateTime now) {
    DateTime ago({int days = 0, int hours = 0}) =>
        now.subtract(Duration(days: days, hours: hours));
    return [
      AppNotification(
        id: 'n1',
        kind: NotificationKind.newMessage,
        title: 'Nouveau message de Banque Horizon',
        message: 'Camille Martin vous propose un créneau d’entretien.',
        createdAt: ago(hours: 3),
      ),
      AppNotification(
        id: 'n2',
        kind: NotificationKind.interview,
        title: 'Entretien proposé par Kanopé',
        message: 'Démarrez la conversation pour convenir d’un créneau.',
        createdAt: ago(days: 1),
      ),
      AppNotification(
        id: 'n3',
        kind: NotificationKind.newMatch,
        title: 'Nouveau match à 92 %',
        message: 'Entreprise Beta · Développeur·euse Full-Stack en alternance',
        createdAt: ago(days: 1, hours: 5),
      ),
      AppNotification(
        id: 'n4',
        kind: NotificationKind.applicationUpdate,
        title: 'Candidature mise à jour',
        message: 'Datalis n’a pas retenu votre candidature.',
        createdAt: ago(days: 4),
        isRead: true,
      ),
    ];
  }

  @override
  Future<NotificationPage> fetch({int limit = 30}) async {
    await Future<void>.delayed(latency);
    final items = [..._items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return NotificationPage(
      items: items.take(limit).toList(),
      unreadCount: _items.where((n) => !n.isRead).length,
    );
  }

  @override
  Future<void> markRead(String id) async {
    await Future<void>.delayed(latency);
    final i = _items.indexWhere((n) => n.id == id);
    if (i >= 0) _items[i] = _items[i].markRead();
  }

  @override
  Future<void> markAllRead() async {
    await Future<void>.delayed(latency);
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].markRead();
    }
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(latency);
    _items.removeWhere((n) => n.id == id);
  }

  @override
  Future<int> deleteRead() async {
    await Future<void>.delayed(latency);
    final before = _items.length;
    _items.removeWhere((n) => n.isRead);
    return before - _items.length;
  }
}
