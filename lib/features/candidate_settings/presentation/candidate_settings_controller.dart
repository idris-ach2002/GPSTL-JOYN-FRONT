import 'package:flutter/foundation.dart';

import '../data/candidate_settings_repository.dart';
import '../domain/candidate_settings.dart';

enum SettingsStatus { loading, ready, error }

/// État de la page « Paramètres » du candidat, partagé Web / Mobile.
///
/// - La visibilité est enregistrée dès qu'un interrupteur change (et annulée
///   si le back refuse).
/// - Les critères de recherche sont modifiés en brouillon, puis enregistrés
///   avec le bouton « Enregistrer ».
class CandidateSettingsController extends ChangeNotifier {
  CandidateSettingsController(this._repository);

  final CandidateSettingsRepository _repository;
  bool _disposed = false;

  SettingsStatus _status = SettingsStatus.loading;
  SettingsStatus get status => _status;

  CandidateSettings _saved = const CandidateSettings();
  CandidateSettings get saved => _saved;

  SearchPreferences _draft = const SearchPreferences();

  /// Critères en cours de modification.
  SearchPreferences get draft => _draft;

  bool get preferencesDirty => _draft != _saved.preferences;

  bool _savingVisibility = false;
  bool get savingVisibility => _savingVisibility;

  bool _savingPreferences = false;
  bool get savingPreferences => _savingPreferences;

  /// Message ponctuel à afficher dans un SnackBar.
  String? notice;

  Future<void> load() async {
    _status = SettingsStatus.loading;
    _notify();
    try {
      _saved = await _repository.fetch();
      _draft = _saved.preferences;
      _status = SettingsStatus.ready;
    } catch (_) {
      _status = SettingsStatus.error;
    }
    _notify();
  }

  Future<void> setVisibility(VisibilitySettings visibility) async {
    if (_savingVisibility || visibility == _saved.visibility) return;
    final previous = _saved;
    _saved = _saved.copyWith(visibility: visibility);
    _savingVisibility = true;
    _notify();
    try {
      final result = await _repository.saveVisibility(visibility);
      _saved = _saved.copyWith(visibility: result.visibility);
    } catch (_) {
      _saved = previous;
      notice = 'La visibilité n’a pas pu être enregistrée.';
    }
    _savingVisibility = false;
    _notify();
  }

  void editPreferences(SearchPreferences preferences) {
    _draft = preferences;
    _notify();
  }

  void toggleContract(ContractType type) {
    final next = {..._draft.contractTypes};
    if (!next.remove(type)) next.add(type);
    editPreferences(_draft.copyWith(contractTypes: next));
  }

  void discardPreferences() => editPreferences(_saved.preferences);

  Future<bool> savePreferences() async {
    if (!preferencesDirty || _savingPreferences) return false;
    _savingPreferences = true;
    _notify();
    try {
      final result = await _repository.savePreferences(_draft);
      _saved = _saved.copyWith(preferences: result.preferences);
      _draft = _saved.preferences;
      notice = 'Critères enregistrés. Tes recommandations vont s’adapter.';
      return true;
    } catch (_) {
      notice = 'Les critères n’ont pas pu être enregistrés.';
      return false;
    } finally {
      _savingPreferences = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
