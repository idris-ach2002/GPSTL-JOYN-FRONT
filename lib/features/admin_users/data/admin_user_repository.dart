import '../domain/admin_user.dart';
import '../domain/user_query.dart';

/// Erreur affichable renvoyée par la gestion des utilisateurs.
class AdminUserException implements Exception {
  const AdminUserException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  /// L'utilisateur connecté n'a pas le rôle `admin` (HTTP 403).
  bool get isForbidden => statusCode == 403;

  @override
  String toString() => 'AdminUserException($statusCode): $message';
}

/// Endpoints d'administration des comptes.
///
/// - `GET    /api/v1/admin/users`             → [fetchUsers]
/// - `PATCH  /api/v1/admin/users/{id}/status` → [updateStatus]
/// - `PATCH  /api/v1/admin/users/{id}/role`   → [updateRole]
/// - `DELETE /api/v1/admin/users/{id}`        → [deleteUser]
/// - `POST   /api/v1/admin/users`             → [inviteAdmin]
///   (à confirmer avec l'équipe back : absent du contrat initial)
abstract interface class AdminUserRepository {
  /// Une page de résultats, recherchée, filtrée et triée par le serveur.
  Future<UserPage> fetchUsers(UserQuery query);

  /// Active, suspend ou bannit. [reason] est obligatoire pour une sanction.
  Future<AdminUserAccount> updateStatus(
    String id,
    AccountStatus status, {
    String? reason,
  });

  /// Attribue ou révoque des droits (candidat, recruteur, admin).
  Future<AdminUserAccount> updateRole(String id, AccountRole role);

  /// Suppression logique avec anonymisation RGPD.
  Future<void> deleteUser(String id);

  /// Crée un compte administrateur et envoie une invitation par e-mail
  /// (le compte reste « En attente » jusqu'à la première connexion).
  Future<AdminUserAccount> inviteAdmin({
    required String firstName,
    required String lastName,
    required String email,
  });
}
