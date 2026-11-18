import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../messaging/data/messaging_repository.dart';
import '../data/notifications_repository.dart';
import '../domain/app_notification.dart';

/// Notifications et compteurs de non-lus de l'espace candidat.
///
/// Fourni au niveau de l'app (pastilles de la cloche et de l'icône messages
/// sur toutes les pages). Démarré à la connexion d'un candidat, arrêté à la
/// déconnexion.
class NotificationsController extends ChangeNotifier {
  NotificationsController(
    this._repository, {
    this.messaging,
    this.pollInterval = const Duration(seconds: 60),
  });

  final NotificationsRepository _repository;

  /// Pour le compteur de messages non lus (optionnel).
  final MessagingRepository? messaging;

  /// `null` désactive le rafraîchissement automatique (tests).
  final Duration? pollInterval;
  Timer? _timer;
  bool _disposed = false;
  bool _active = false;

  List<AppNotification> _items = const [];
  List<AppNotification> get items => _items;

  int _unread = 0;
  int get unreadCount => _unread;

  int _unreadMessages = 0;

  /// Messages non lus, toutes conversations confondues.
  int get unreadMessages => _unreadMessages;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  /// Démarre le suivi (connexion d'un candidat).
  Future<void> start() async {
    _active = true;
    await load();
    final interval = pollInterval;
    if (interval != null) {
      _timer ??= Timer.periodic(interval, (_) => load(silent: true));
    }
  }

  /// Arrête le suivi et vide les données (déconnexion).
  void stop() {
    _active = false;
    _timer?.cancel();
    _timer = null;
    _items = const [];
    _unread = 0;
    _unreadMessages = 0;
    _notify();
  }

  Future<void> load({bool silent = false}) async {
    if (!_active) return;
    if (!silent) {
      _loading = true;
      _error = null;
      _notify();
    }
    try {
      final page = await _repository.fetch();
      _items = page.items;
      _unread = page.unreadCount;
      _error = null;
    } catch (_) {
      if (!silent) _error = 'Impossible de charger les notifications.';
    }
    final messaging = this.messaging;
    if (messaging != null) {
      try {
        _unreadMessages = (await messaging.fetchConversations()).totalUnread;
      } catch (_) {
        // Le compteur de messages est secondaire.
      }
    }
    _loading = false;
    _notify();
  }

  /// Met à jour le compteur de messages (après lecture d'une conversation).
  void setUnreadMessages(int value) {
    if (value == _unreadMessages) return;
    _unreadMessages = value;
    _notify();
  }

  Future<void> markRead(AppNotification notification) async {
    if (notification.isRead) return;
    _items = [
      for (final n in _items) n.id == notification.id ? n.markRead() : n,
    ];
    _unread = (_unread - 1).clamp(0, 1 << 30);
    _notify();
    try {
      await _repository.markRead(notification.id);
    } catch (_) {
      await load(silent: true);
    }
  }

  Future<void> markUnread(AppNotification notification) async {
    if (!notification.isRead) return;
    try {
      await _repository.markUnread(notification.id);
      await load(silent: true);
    } catch (_) {
      _error = 'Impossible de marquer cette notification comme non lue.';
      _notify();
    }
  }

  Future<void> markAllRead() async {
    _items = [for (final n in _items) n.markRead()];
    _unread = 0;
    _notify();
    try {
      await _repository.markAllRead();
    } catch (_) {
      await load(silent: true);
    }
  }

  Future<void> delete(AppNotification notification) async {
    _items = [
      for (final n in _items)
        if (n.id != notification.id) n,
    ];
    if (!notification.isRead) _unread = (_unread - 1).clamp(0, 1 << 30);
    _notify();
    try {
      await _repository.delete(notification.id);
    } catch (_) {
      await load(silent: true);
    }
  }

  /// Supprime les notifications lues ; renvoie le nombre supprimé.
  Future<int> deleteRead() async {
    try {
      final count = await _repository.deleteRead();
      _items = [
        for (final n in _items)
          if (!n.isRead) n,
      ];
      _notify();
      return count;
    } catch (_) {
      await load(silent: true);
      rethrow;
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
