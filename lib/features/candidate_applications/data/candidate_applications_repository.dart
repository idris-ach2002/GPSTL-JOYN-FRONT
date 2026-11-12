import '../domain/candidate_application.dart';

/// Contrat d'accès aux candidatures du candidat connecté.
///
/// Implémentations : `ApiCandidateApplicationsRepository` (vraie API) et
/// `MockCandidateApplicationsRepository` (données simulées), choisies dans
/// `app/bootstrap.dart` selon `JOYN_DATA_MODE`.
abstract interface class CandidateApplicationsRepository {
  static const int defaultPageSize = 20;

  /// Candidatures de la page [page] (à partir de 1), les plus récentes
  /// d'abord.
  Future<ApplicationsPage> fetchApplications({
    int page = 1,
    int pageSize = defaultPageSize,
  });

  /// Crée le fil de discussion lié à la candidature et renvoie son id.
  Future<String> createConversation(String applicationId);

  /// Envoie une candidature de la colonne « Intéressé » à l'entreprise et
  /// renvoie sa nouvelle version (statut « envoyée »).
  Future<CandidateApplication> sendApplication(String applicationId);
}
