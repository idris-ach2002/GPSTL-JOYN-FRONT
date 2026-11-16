import '../domain/candidate_settings.dart';

/// Paramètres du candidat, stockés dans son profil côté back.
abstract interface class CandidateSettingsRepository {
  Future<CandidateSettings> fetch();

  /// Enregistre la visibilité et renvoie la version enregistrée.
  Future<CandidateSettings> saveVisibility(VisibilitySettings visibility);

  /// Enregistre les critères de recherche et renvoie la version enregistrée.
  Future<CandidateSettings> savePreferences(SearchPreferences preferences);
}
