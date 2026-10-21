import '../../auth/data/auth_repository.dart';
import '../../auth/domain/auth_exception.dart';
import '../../auth/domain/user_role.dart';
import '../domain/company_account_draft.dart';
import '../domain/company_info.dart';
import '../domain/student_account_draft.dart';
import 'mock_registration_repository.dart';
import 'registration_repository.dart';

/// Relie les formulaires d'inscription au même dépôt d'authentification que
/// la connexion, tout en conservant les données métier fictives (SIRET) de la
/// branche inscription tant que le backend n'est pas branché.
class AuthRegistrationRepository implements RegistrationRepository {
  AuthRegistrationRepository(
    this._authRepository, {
    RegistrationRepository? companyLookupRepository,
  }) : _companyLookupRepository =
           companyLookupRepository ?? MockRegistrationRepository();

  final AuthRepository _authRepository;
  final RegistrationRepository _companyLookupRepository;

  @override
  Future<void> createStudentAccount(StudentAccountDraft draft) async {
    try {
      await _authRepository.signUp(
        email: draft.email,
        password: draft.password,
        role: UserRole.student,
      );
    } on AuthException catch (error) {
      throw RegistrationException(error.message);
    }
  }

  @override
  Future<CompanyInfo?> findCompanyBySiret(String siret) {
    return _companyLookupRepository.findCompanyBySiret(siret);
  }

  @override
  Future<void> createCompanyAccount(CompanyAccountDraft draft) async {
    try {
      await _authRepository.signUp(
        email: draft.email,
        password: draft.password,
        role: UserRole.company,
      );
    } on AuthException catch (error) {
      throw RegistrationException(error.message);
    }
  }
}
