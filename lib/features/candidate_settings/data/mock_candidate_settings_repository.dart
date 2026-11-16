import '../domain/candidate_settings.dart';
import 'candidate_settings_repository.dart';

/// Paramètres SIMULÉS du candidat de démonstration (alternance, hybride).
class MockCandidateSettingsRepository implements CandidateSettingsRepository {
  MockCandidateSettingsRepository({
    this.latency = const Duration(milliseconds: 300),
    CandidateSettings? initial,
  }) : _settings =
           initial ??
           const CandidateSettings(
             email: 'etudiant@joyn.fr',
             preferences: SearchPreferences(
               contractTypes: {
                 ContractType.apprenticeship,
                 ContractType.professionalization,
               },
               remotePolicy: RemotePolicy.hybrid,
               minSalary: 1200,
             ),
           );

  final Duration latency;
  CandidateSettings _settings;

  @override
  Future<CandidateSettings> fetch() async {
    await Future<void>.delayed(latency);
    return _settings;
  }

  @override
  Future<CandidateSettings> saveVisibility(
    VisibilitySettings visibility,
  ) async {
    await Future<void>.delayed(latency);
    return _settings = _settings.copyWith(visibility: visibility);
  }

  @override
  Future<CandidateSettings> savePreferences(
    SearchPreferences preferences,
  ) async {
    await Future<void>.delayed(latency);
    return _settings = _settings.copyWith(preferences: preferences);
  }
}
