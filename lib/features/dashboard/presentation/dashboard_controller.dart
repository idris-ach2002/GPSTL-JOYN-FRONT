import 'package:flutter/foundation.dart';

import '../data/dashboard_repository.dart';
import '../domain/candidate_profile.dart';

/// État du dashboard : chargement, profil affiché, erreur éventuelle.
///
/// Créé à l'ouverture de la page (voir `app_router.dart`).
class DashboardController extends ChangeNotifier {
  DashboardController(this._repository);

  final DashboardRepository _repository;

  CandidateProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  CandidateProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  /// Erreur à afficher (en français), ou `null`.
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await _repository.fetchCandidateProfile();
    } catch (e) {
      debugPrint('Erreur pendant le chargement du dashboard : $e');
      _errorMessage = 'Impossible de charger le profil. Réessaie plus tard.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
