import '../domain/admin_company.dart';

/// Erreur affichable renvoyée par la gestion des entreprises.
class AdminCompanyException implements Exception {
  const AdminCompanyException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  /// L'utilisateur n'a pas le rôle `admin` (HTTP 403).
  bool get isForbidden => statusCode == 403;

  @override
  String toString() => 'AdminCompanyException($statusCode): $message';
}

/// Endpoints d'administration des entreprises.
///
/// - `GET    /api/v1/admin/companies`             → [fetchCompanies]
/// - `POST   /api/v1/admin/companies`             → [createCompany]
/// - `PATCH  /api/v1/admin/companies/{id}`        → [updateCompany]
/// - `PATCH  /api/v1/admin/companies/{id}/status` → [updateStatus]
/// - `DELETE /api/v1/admin/companies/{id}`        → [deleteCompany]
abstract interface class AdminCompanyRepository {
  /// Une page de résultats, filtrée et triée par le serveur.
  Future<CompanyPage> fetchCompanies(CompanyQuery query);

  Future<AdminCompany> createCompany(CompanyDraft draft);

  /// Modifie les informations légales et visuelles (pas le statut).
  Future<AdminCompany> updateCompany(String id, CompanyDraft draft);

  /// Valide, rejette, suspend ou réactive. [reason] est obligatoire pour un
  /// rejet ou une suspension : le serveur l'envoie par e-mail au recruteur.
  Future<AdminCompany> updateStatus(
    String id,
    CompanyStatus status, {
    String? reason,
  });

  /// Suppression logique : l'entreprise et ses offres sont masquées, mais
  /// l'historique des candidatures est conservé.
  Future<void> deleteCompany(String id);
}
