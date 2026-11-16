import '../../../core/network/api_client.dart';
import '../domain/candidate_settings.dart';
import 'candidate_settings_repository.dart';

/// Paramètres lus et écrits dans le profil candidat du back.
///
/// `PATCH /api/v1/candidates/profile` fusionne les objets imbriqués champ par
/// champ : on n'envoie que le bloc modifié (`visibility` ou `preferences`),
/// sans toucher au reste du profil.
class ApiCandidateSettingsRepository implements CandidateSettingsRepository {
  ApiCandidateSettingsRepository(this._api);

  final ApiClient _api;

  static const String path = '/api/v1/candidates/profile';

  @override
  Future<CandidateSettings> fetch() async => map(await _api.getJson(path));

  @override
  Future<CandidateSettings> saveVisibility(
    VisibilitySettings visibility,
  ) async =>
      map(await _api.patchJson(path, body: {'visibility': visibility.toApi()}));

  @override
  Future<CandidateSettings> savePreferences(
    SearchPreferences preferences,
  ) async => map(
    await _api.patchJson(path, body: {'preferences': preferences.toApi()}),
  );

  /// Extrait les paramètres d'un `CandidateProfile` du back.
  static CandidateSettings map(Object? json) {
    var root = json is Map<String, dynamic> ? json : const <String, dynamic>{};
    if (root['data'] is Map<String, dynamic>) {
      root = root['data'] as Map<String, dynamic>;
    }
    final v = _map(root['visibility']);
    final p = _map(root['preferences']);
    bool flag(String key) => v[key] != false;
    final salary = p['min_salary'];
    return CandidateSettings(
      email: root['email']?.toString() ?? '',
      visibility: VisibilitySettings(
        visibleToRecruiters: flag('visible_to_recruiters'),
        visibleToOthers: flag('visible_to_others'),
        showLastName: flag('show_last_name'),
        showContactLinks: flag('show_contact_links'),
      ),
      preferences: SearchPreferences(
        contractTypes: {
          for (final code
              in (p['contract_types'] is List
                  ? p['contract_types'] as List
                  : const []))
            ?ContractType.fromCode(code?.toString()),
        },
        remotePolicy: RemotePolicy.fromCode(p['remote_policy']?.toString()),
        minSalary: salary is num ? salary.round() : int.tryParse('$salary'),
      ),
    );
  }

  static Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : const {};
}
