import '../domain/candidate_profile.dart';

/// Contrat d'accès aux données du dashboard, indépendant du backend.
///
/// Même principe que `AuthRepository` : pour brancher la vraie API, écrire
/// une implémentation (ex. `ApiDashboardRepository`) et l'injecter dans
/// `main.dart` à la place de `FakeDashboardRepository`.
abstract interface class DashboardRepository {
  /// Profil du candidat affiché sur le dashboard.
  ///
  /// TODO(backend): ajouter l'identifiant du candidat (et de l'offre) quand
  /// le format de l'API sera fixé.
  Future<CandidateProfile> fetchCandidateProfile();
}
