import 'package:shared_preferences/shared_preferences.dart';

/// Stockage de préférences et données de démonstration, jamais de jetons.
abstract interface class StudioStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class MemoryStudioStore implements StudioStore {
  final Map<String, String> _values = {};
  @override
  Future<String?> read(String key) async => _values[key];
  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}

class DeviceStudioStore implements StudioStore {
  DeviceStudioStore(this.preferences);
  final SharedPreferences preferences;
  @override
  Future<String?> read(String key) async => preferences.getString(key);
  @override
  Future<void> write(String key, String value) async {
    if (!await preferences.setString(key, value)) {
      throw StateError('Enregistrement local impossible');
    }
  }
}
