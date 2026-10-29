import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/utils/lifecycle_notifier.dart';
import '../data/studio_store.dart';
import '../data/studio_repository.dart';

class StudioController extends LifecycleNotifier {
  StudioController({StudioStore? store, StudioRepository? repository})
    : store = store ?? MemoryStudioStore() {
    this.repository = repository ?? LocalStudioRepository(this.store);
  }
  final StudioStore store;
  late final StudioRepository repository;
  VoidCallback? settingsBack;
  String? userId;
  Map<String, dynamic> preferences = {};
  Map<String, dynamic> data = {};
  bool loading = false;
  bool saving = false;
  String? error;
  String? deviceError;
  int _epoch = 0;
  Future<void> _writes = Future.value();
  Future<void> _deviceWrites = Future.value();
  Map<String, dynamic> _persistedPreferences = {};
  int _preferenceRevision = 0;
  ThemeMode get themeMode => switch (preferences['theme']) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };
  bool get compact => preferences['density'] == 'compact';
  bool get reducedMotion => preferences['reducedMotion'] == true;
  bool get highContrast => preferences['highContrast'] == true;
  double get textScale =>
      (preferences['textScale'] as num? ?? 1).toDouble().clamp(1, 1.3);
  String get accent => '${preferences['accent'] ?? 'coral'}';
  Color get accentColor => switch (accent) {
    'blue' => const Color(0xFF3D86F5),
    'mint' => const Color(0xFF198B75),
    _ => const Color(0xFFFF6538),
  };
  Future<void> restoreDevice() async {
    try {
      final value = await store.read('joyn.appearance.v2');
      if (value != null) {
        preferences = Map<String, dynamic>.from(jsonDecode(value) as Map);
      }
    } catch (_) {
      deviceError = 'Impossible de restaurer les préférences de cet appareil.';
    }
    _persistedPreferences = Map.from(preferences);
    notifyListeners();
  }

  Future<bool> setPreference(String key, Object value) {
    final revision = ++_preferenceRevision;
    preferences = {...preferences, key: value};
    final snapshot = Map<String, dynamic>.from(preferences);
    deviceError = null;
    notifyListeners();
    final operation = _deviceWrites.then((_) async {
      try {
        await store.write('joyn.appearance.v2', jsonEncode(snapshot));
        _persistedPreferences = snapshot;
        return true;
      } catch (_) {
        if (revision == _preferenceRevision) {
          preferences = Map.from(_persistedPreferences);
          deviceError = 'Impossible d’enregistrer sur cet appareil.';
          notifyListeners();
        }
        return false;
      }
    });
    _deviceWrites = operation.then<void>((_) {});
    return operation;
  }

  Future<void> bind(String? id) async {
    final epoch = ++_epoch;
    userId = id;
    data = {};
    saving = false;
    error = null;
    loading = id != null;
    notifyListeners();
    if (id == null) return;
    try {
      final value = await repository.load(id);
      if (epoch == _epoch) data = value;
    } catch (_) {
      if (epoch == _epoch) {
        error = 'Votre espace de travail n’a pas pu être chargé. Réessayez.';
      }
    } finally {
      if (epoch == _epoch) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> save(String key, Object? value) => change(key, () => value);

  Future<bool> change(String key, Object? Function() derive) {
    final id = userId;
    final epoch = _epoch;
    if (id == null || loading || error != null) return Future.value(false);
    final operation = _writes.then((_) async {
      if (epoch != _epoch || isDisposed) return false;
      saving = true;
      notifyListeners();
      try {
        final result = await repository.patch(id, {key: derive()});
        if (epoch != _epoch) return false;
        data = result;
        return true;
      } catch (_) {
        if (epoch == _epoch) error = 'Enregistrement impossible. Votre dernière version est conservée.';
        return false;
      } finally {
        if (epoch == _epoch) {
          saving = false;
          notifyListeners();
        }
      }
    });
    _writes = operation.then<void>((_) {});
    return operation;
  }

  Future<void> retry() => bind(userId);
  List<Map<String, dynamic>> list(String key) => (data[key] as List? ?? [])
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
  Map<String, dynamic> object(String key) =>
      Map<String, dynamic>.from(data[key] as Map? ?? {});
  bool contains(String key, String id) =>
      (data[key] as List? ?? []).contains(id);
  Future<bool> toggle(String key, String id) => change(key, () {
    final values = List<String>.from(data[key] as List? ?? []);
    values.contains(id) ? values.remove(id) : values.add(id);
    return values;
  });
  Future<bool> upsert(String key, Map<String, dynamic> value) =>
      change(key, () {
        final values = list(key);
        final index = values.indexWhere((v) => v['id'] == value['id']);
        if (index < 0) {
          values.insert(0, value);
        } else {
          values[index] = value;
        }
        return values;
      });
  Future<bool> remove(String key, String id) =>
      change(key, () => list(key)..removeWhere((v) => '${v['id']}' == id));
  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();
}
