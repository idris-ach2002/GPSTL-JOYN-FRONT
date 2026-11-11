import '../domain/company_verification.dart';

/// Erreur affichable de la file de vérification.
class VerificationException implements Exception {
  const VerificationException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isForbidden => statusCode == 403;

  @override
  String toString() => 'VerificationException($statusCode): $message';
}

/// Vérification des entreprises.
///
/// Le back vérifie automatiquement chaque inscription via l'API SIRENE ;
/// cet écran traite les cas où cette vérification n'a pas abouti.
/// Endpoints proposés (à confirmer avec l'équipe back) :
///
/// - `GET  /api/v1/admin/verifications`               → [fetchVerifications]
/// - `POST /api/v1/admin/verifications/{id}/retry`    → [retryAutomatic]
/// - `POST /api/v1/admin/verifications/{id}/decision` → [decide]
abstract interface class VerificationRepository {
  Future<List<CompanyVerification>> fetchVerifications({
    required VerificationFilter filter,
    String search = '',
  });

  /// Relance la vérification automatique (utile si l'API était indisponible).
  Future<CompanyVerification> retryAutomatic(String id);

  /// Décision manuelle. [note] est obligatoire pour un refus ou une demande
  /// de justificatif : elle est transmise au recruteur.
  Future<CompanyVerification> decide(
    String id,
    VerificationDecision decision, {
    String note = '',
  });
}
