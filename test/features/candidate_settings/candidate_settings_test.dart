import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/candidate_settings/data/api_candidate_settings_repository.dart';
import 'package:joyn_front/features/candidate_settings/data/mock_candidate_settings_repository.dart';
import 'package:joyn_front/features/candidate_settings/domain/candidate_settings.dart';
import 'package:joyn_front/features/candidate_settings/presentation/candidate_settings_controller.dart';

/// Dépôt qui refuse d'enregistrer la visibilité.
class _RefusingRepository extends MockCandidateSettingsRepository {
  _RefusingRepository() : super(latency: Duration.zero);

  @override
  Future<CandidateSettings> saveVisibility(VisibilitySettings visibility) =>
      throw Exception('refus');
}

void main() {
  test('lit la visibilité et les critères du profil candidat', () {
    final settings = ApiCandidateSettingsRepository.map({
      'email': 'alex@joyn.fr',
      'visibility': {
        'visible_to_recruiters': false,
        'visible_to_others': true,
        'show_last_name': false,
        'show_contact_links': true,
      },
      'preferences': {
        'contract_types': ['APPRENTICESHIP', 'INCONNU', 'CDI'],
        'remote_policy': 'HYBRID',
        'min_salary': 1300,
        'currency': 'EUR',
      },
    });

    expect(settings.email, 'alex@joyn.fr');
    expect(settings.visibility.visibleToRecruiters, isFalse);
    expect(settings.visibility.showLastName, isFalse);
    expect(settings.preferences.contractTypes, {
      ContractType.apprenticeship,
      ContractType.cdi,
    });
    expect(settings.preferences.remotePolicy, RemotePolicy.hybrid);
    expect(settings.preferences.minSalary, 1300);
  });

  test('n’envoie que le bloc modifié au PATCH du profil', () async {
    final bodies = <Object?>[];
    final repo = ApiCandidateSettingsRepository(
      ApiClient(
        baseUrl: 'https://api.joyn.test',
        httpClient: MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(request.url.path, '/api/v1/candidates/profile');
          bodies.add(jsonDecode(request.body));
          return http.Response(
            '{}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      ),
    );

    await repo.saveVisibility(
      const VisibilitySettings(showContactLinks: false),
    );
    await repo.savePreferences(
      const SearchPreferences(
        contractTypes: {ContractType.internship, ContractType.apprenticeship},
        remotePolicy: RemotePolicy.remote,
      ),
    );

    expect(bodies[0], {
      'visibility': {
        'visible_to_recruiters': true,
        'visible_to_others': true,
        'show_last_name': true,
        'show_contact_links': false,
      },
    });
    expect(bodies[1], {
      'preferences': {
        'contract_types': ['APPRENTICESHIP', 'INTERNSHIP'],
        'remote_policy': 'REMOTE',
        'min_salary': null,
        'currency': 'EUR',
      },
    });
  });

  test('les critères se modifient en brouillon puis s’enregistrent', () async {
    final c = CandidateSettingsController(
      MockCandidateSettingsRepository(latency: Duration.zero),
    );
    addTearDown(c.dispose);
    await c.load();
    expect(c.preferencesDirty, isFalse);

    c.toggleContract(ContractType.internship);
    expect(c.preferencesDirty, isTrue);
    c.discardPreferences();
    expect(c.preferencesDirty, isFalse);

    c.toggleContract(ContractType.internship);
    expect(await c.savePreferences(), isTrue);
    expect(
      c.saved.preferences.contractTypes,
      contains(ContractType.internship),
    );
    expect(c.preferencesDirty, isFalse);
  });

  test(
    'la visibilité refusée par le back revient à l’état précédent',
    () async {
      final c = CandidateSettingsController(_RefusingRepository());
      addTearDown(c.dispose);
      await c.load();

      await c.setVisibility(
        c.saved.visibility.copyWith(visibleToRecruiters: false),
      );

      expect(c.saved.visibility.visibleToRecruiters, isTrue);
      expect(c.notice, isNotNull);
    },
  );
}
