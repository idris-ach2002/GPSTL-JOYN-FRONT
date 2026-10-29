import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/recruiter_workspace_repository.dart';

class WorkspaceController extends ChangeNotifier {
  WorkspaceController(this.repository);
  RecruiterWorkspaceRepository repository;
  Map<String, dynamic>? profile;
  Map<String, dynamic>? settings;
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> conversations = [];
  int _pending = 0;
  bool get busy => _pending > 0;
  String? error;
  bool profileDirty = false;
  bool _disposed = false;
  int _generation = 0;
  int get unread => notifications.where((n) => n['read'] != true).length;
  int get unreadMessages => conversations.fold(
    0,
    (sum, c) => sum + ((c['unread'] as num?)?.toInt() ?? 0),
  );
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }

  void reset() {
    _generation++;
    profileDirty = false;
    profile = null;
    settings = null;
    notifications = [];
    conversations = [];
    error = null;
    _pending = 0;
    notifyListeners();
  }

  Future<bool> run(Future<void> Function() action) async {
    final generation = _generation;
    _pending++;
    error = null;
    notifyListeners();
    try {
      await action();
      return generation == _generation;
    } catch (e) {
      if (generation == _generation) {
        error = e is ApiException && e.statusCode == 403
            ? 'Vous n’avez pas accès à cette action.'
            : 'Impossible de terminer cette action. Réessayez.';
      }
      return false;
    } finally {
      if (generation == _generation) {
        _pending--;
        notifyListeners();
      }
    }
  }

  Future<bool> load(String section) => run(() async {
    final generation = _generation;
    switch (section) {
      case 'profile':
        final value = await repository.profile();
        if (generation == _generation) profile = value;
      case 'settings':
        final value = await repository.settings();
        if (generation == _generation) settings = value;
      case 'notifications':
        final value = await repository.notifications();
        if (generation == _generation) notifications = value;
      case 'messages':
        final value = await repository.conversations();
        if (generation == _generation) conversations = value;
    }
  });
  Future<bool> saveProfile(Map<String, dynamic> value) => run(() async {
    final generation = _generation;
    final saved = await repository.saveProfile(value);
    if (generation == _generation) profile = saved;
  });
  Future<bool> saveSettings(Map<String, dynamic> value) => run(() async {
    final generation = _generation;
    final saved = await repository.saveSettings(value);
    if (generation == _generation) settings = saved;
  });
  Future<bool> readNotification(String id) => run(() async {
    final generation = _generation;
    await repository.readNotification(id);
    final saved = await repository.notifications();
    if (generation == _generation) notifications = saved;
  });
  Future<bool> setRead(Iterable<String> ids, bool read) => run(() async {
    final epoch = _generation;
    for (final id in ids) {
      await repository.updateNotification(id, {'read': read});
    }
    final value = await repository.notifications();
    if (epoch == _generation) notifications = value;
  });
  Future<bool> readAll() => run(() async {
    for (final n in notifications.where((n) => n['read'] != true)) {
      await repository.readNotification('${n['id']}');
      n['read'] = true;
    }
  });
  Future<bool> deleteNotification(String id) => run(() async {
    await repository.deleteNotification(id);
    notifications.removeWhere((n) => '${n['id']}' == id);
  });
}
