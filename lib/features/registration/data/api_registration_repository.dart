import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/data/api_auth_repository.dart';
import '../../auth/domain/auth_exception.dart';
import '../../recruiter_workspace/data/recruiter_workspace_repository.dart';
import '../domain/company_account_draft.dart';
import '../domain/company_info.dart';
import '../domain/student_account_draft.dart';
import 'registration_repository.dart';

class ApiRegistrationRepository implements RegistrationRepository {
  ApiRegistrationRepository(this.api, this.auth);
  final ApiClient api;
  final ApiAuthRepository auth;
  @override
  Future<CompanyInfo?> findCompanyBySiret(String siret) async {
    try {
      final j = apiObject(
        await api.getJson('/api/v1/companies/lookup', query: {'siret': siret}),
      );
      return CompanyInfo(
        siret: '${j['siret']}',
        legalName: '${j['legalName']}',
        displayName: '${j['displayName']}',
        city: '${j['city'] ?? ''}',
        activity: '${j['activity'] ?? ''}',
        emailDomain: '${j['emailDomain'] ?? ''}',
        sector: j['sector'] as String?,
        sizeRange: j['sizeRange'] as String?,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      throw const RegistrationException(
        'Recherche d’entreprise indisponible. Réessayez.',
      );
    }
  }

  Future<void> _register(Map<String, dynamic> body) async {
    try {
      await auth.register(body);
    } on AuthException catch (e) {
      throw RegistrationException(e.message);
    }
  }

  @override
  Future<void> createCompanyAccount(CompanyAccountDraft d) => _register({
    'role': 'COMPANY',
    'email': d.email,
    'password': d.password,
    'firstName': d.firstName,
    'lastName': d.lastName,
    'jobTitle': d.jobTitle,
    'phone': d.phone,
    'siret': d.siret,
    'sector': d.sector,
    'sizeRange': d.sizeRange,
    'acceptedTerms': d.acceptedTerms,
  });
  @override
  Future<void> createStudentAccount(StudentAccountDraft d) => _register({
    'role': 'STUDENT',
    'email': d.email,
    'password': d.password,
    'firstName': d.firstName,
    'lastName': d.lastName,
    'acceptedTerms': d.acceptedTerms,
    'weeklyDigest': d.weeklyDigest,
  });
}
