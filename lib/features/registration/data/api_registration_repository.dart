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
  final Map<String, String> _selectedCompanyNames = {};
  @override
  Future<CompanyInfo?> findCompanyBySiret(String siret) async {
    try {
      final j = apiObject(
        await api.getJson('/api/v1/companies/lookup', query: {'siret': siret}),
      );
      final selectedName = '${j['displayName'] ?? j['legalName'] ?? ''}'.trim();
      if (selectedName.isNotEmpty) _selectedCompanyNames[siret] = selectedName;
      return CompanyInfo(
        siret: '${j['siret'] ?? siret}',
        legalName: '${j['legalName'] ?? ''}',
        displayName: '${j['displayName'] ?? j['legalName'] ?? ''}',
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

  Future<void> _loginAfterRegistration(String email, String password) async {
    try {
      await auth.signIn(email: email, password: password);
    } on AuthException catch (error) {
      // Account was created successfully; allow sign-in from the login page.
      throw RegistrationException('Compte créé. Connectez-vous avec vos identifiants (${error.message}).');
    }
  }

  @override
  Future<void> createCompanyAccount(CompanyAccountDraft draft) async {
    // The API links the new recruiter to one company based on companyName.
    // SIRET, position and phone are UI data, not accepted in this payload.
    if (!draft.acceptedTerms) {
      throw const RegistrationException('Veuillez accepter les conditions.');
    }
    final companyName = _selectedCompanyNames[draft.siret];
    if (companyName == null || companyName.isEmpty) {
      throw const RegistrationException('Recherchez votre entreprise avant de continuer.');
    }
    try {
      await api.postJson('/api/v1/recruiters/register', body: {
        'email': draft.email.trim(),
        'password': draft.password,
        'firstName': draft.firstName.trim(),
        'lastName': draft.lastName.trim(),
        'companyName': companyName,
      });
      await _loginAfterRegistration(draft.email, draft.password);
    } on ApiException catch (error) {
      throw RegistrationException(error.statusCode == 409
          ? 'Ce compte recruteur existe déjà.'
          : 'Inscription recruteur refusée (${error.statusCode ?? 'réseau'}).');
    }
  }

  @override
  Future<void> createStudentAccount(StudentAccountDraft draft) async {
    if (!draft.acceptedTerms) {
      throw const RegistrationException('Veuillez accepter les conditions.');
    }
    try {
      await api.sendMultipart('POST', '/api/v1/candidates/register', fields: {
        'email': draft.email.trim(),
        'password': draft.password,
        'firstName': draft.firstName.trim(),
        'lastName': draft.lastName.trim(),
      });
      await _loginAfterRegistration(draft.email, draft.password);
    } on ApiException catch (error) {
      throw RegistrationException(error.statusCode == 409
          ? 'Cette adresse e-mail est déjà utilisée.'
          : 'Inscription candidat refusée (${error.statusCode ?? 'réseau'}).');
    }
  }
}
