import '../domain/company_account_draft.dart';
import '../domain/company_info.dart';
import '../domain/student_account_draft.dart';

/// Erreur métier renvoyée lors de l'inscription, avec un message affichable.
class RegistrationException implements Exception {
  const RegistrationException(this.message);

  final String message;

  @override
  String toString() => 'RegistrationException: $message';
}

/// Point d'accès aux opérations d'inscription.
///
/// Les écrans ne dépendent que de ce contrat : remplacer
/// [MockRegistrationRepository] par l'implémentation API ne touche pas l'UI.
abstract interface class RegistrationRepository {
  /// Crée le compte. Lève une [RegistrationException] en cas de refus.
  Future<void> createStudentAccount(StudentAccountDraft draft);

  /// Cherche une entreprise par son SIRET (14 chiffres, sans espaces).
  /// Renvoie `null` si aucune entreprise ne correspond.
  Future<CompanyInfo?> findCompanyBySiret(String siret);

  /// Crée l'espace entreprise. Lève une [RegistrationException] en cas de refus.
  Future<void> createCompanyAccount(CompanyAccountDraft draft);
}
