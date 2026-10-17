import '../domain/company_account_draft.dart';
import '../domain/company_info.dart';
import '../domain/student_account_draft.dart';
import 'registration_repository.dart';

/// Implémentation fictive, en mémoire, en attendant l'API.
class MockRegistrationRepository implements RegistrationRepository {
  MockRegistrationRepository({
    this.latency = const Duration(milliseconds: 900),
  });

  /// Délai simulé d'un appel réseau.
  final Duration latency;

  /// Adresses déjà utilisées. Celle-ci permet de tester le cas d'erreur.
  static final Set<String> _registeredEmails = {
    'deja.inscrite@etu.sorbonne-universite.fr',
  };

  @override
  Future<void> createStudentAccount(StudentAccountDraft draft) async {
    await Future<void>.delayed(latency);

    final email = draft.email.trim().toLowerCase();
    if (_registeredEmails.contains(email)) {
      throw const RegistrationException(
        'Un compte existe déjà avec cette adresse e-mail. Connecte-toi plutôt.',
      );
    }
    _registeredEmails.add(email);
  }

  /// Entreprises de démonstration, retrouvables par leur SIRET.
  static const Map<String, CompanyInfo> demoCompanies = {
    '12345678900012': CompanyInfo(
      siret: '12345678900012',
      legalName: 'Nébula Pay SAS',
      displayName: 'Nébula Pay',
      city: 'Paris 9e',
      activity: 'Services de paiement',
      emailDomain: 'nebulapay.fr',
      sector: 'Fintech',
      sizeRange: '50 – 249',
    ),
    '55210055400021': CompanyInfo(
      siret: '55210055400021',
      legalName: 'Lumen Santé SAS',
      displayName: 'Lumen Santé',
      city: 'Lyon 3e',
      activity: 'Logiciels pour la santé',
      emailDomain: 'lumensante.fr',
      sector: 'Santé',
      sizeRange: '11 – 49',
    ),
    '81123456700018': CompanyInfo(
      siret: '81123456700018',
      legalName: 'Kôr Mobility SA',
      displayName: 'Kôr Mobility',
      city: 'Nantes',
      activity: 'Mobilité électrique',
      emailDomain: 'kor-mobility.com',
      sector: 'Industrie',
      sizeRange: '250 – 999',
    ),
  };

  @override
  Future<CompanyInfo?> findCompanyBySiret(String siret) async {
    await Future<void>.delayed(latency);
    return demoCompanies[siret];
  }

  @override
  Future<void> createCompanyAccount(CompanyAccountDraft draft) async {
    await Future<void>.delayed(latency);

    final email = draft.email.trim().toLowerCase();
    if (_registeredEmails.contains(email)) {
      throw const RegistrationException(
        'Un compte existe déjà avec cette adresse e-mail. Connectez-vous plutôt.',
      );
    }
    _registeredEmails.add(email);
  }
}
