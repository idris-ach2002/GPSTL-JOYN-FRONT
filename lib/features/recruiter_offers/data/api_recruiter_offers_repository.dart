import '../../../core/network/api_client.dart';

import '../../recruiter_workspace/data/recruiter_workspace_repository.dart';
import '../domain/job_offer.dart';
import '../domain/job_offer_draft.dart';
import '../domain/recruiter_company.dart';
import 'job_offer_api_mapper.dart';
import 'recruiter_offers_repository.dart';

class ApiRecruiterOffersRepository implements RecruiterOffersRepository {
  ApiRecruiterOffersRepository(this.api);
  final ApiClient api;
  static const offersPath = '/api/v1/recruiters/jobs';
  int _int(Object? v) => v is num ? v.toInt() : int.parse('$v');
  double? _double(Object? v) => v == null ? null : double.parse('$v');
  T _enum<T>(List<T> values, String? value, String Function(T) key) =>
      values.firstWhere(
        (v) => key(v) == value,
        orElse: () => throw FormatException('Valeur inconnue : $value'),
      );
  RecruiterCompany _company(Map<String, dynamic> j) => RecruiterCompany(
    id: _int(j['id']),
    name: '${j['name'] ?? ''}',
    siret: '${j['siret'] ?? ''}',
    activity: '${j['activity'] ?? ''}',
    sector: '${j['sector'] ?? ''}',
    sizeRange: '${j['sizeRange'] ?? j['size_range'] ?? ''}',
    city: '${j['city'] ?? ''}',
    website: j['website'] as String?,
    description: '${j['description'] ?? ''}',
  );
  JobOffer _offer(Map<String, dynamic> j) => JobOffer(
    id: _int(j['id']),
    companyId: _int(j['company_id'] ?? j['companyId']),
    title: '${j['title']}',
    contractType: _enum(
      ContractType.values,
      j['contract_type'] as String?,
      (v) => v.apiValue,
    ),
    location: '${j['location'] ?? ''}',
    remoteMode: _enum(
      RemoteMode.values,
      j['remote_policy'] as String?,
      (v) => v.apiValue,
    ),
    experienceLevel: _enum(
      ExperienceLevel.values,
      (j['experience_level'] ?? 'JUNIOR') as String?,
      (v) => v.apiValue,
    ),
    description: '${j['description'] ?? ''}',
    skills: (j['skills'] as List? ?? []).map((s) => '$s').toList(),
    status: _enum(
      JobOfferStatus.values,
      j['status'] as String?,
      (v) => v.apiValue,
    ),
    salaryMin: _double(j['salary_min']),
    salaryMax: _double(j['salary_max']),
    currency: '${j['currency'] ?? 'EUR'}',
    salaryPeriod: _enum(
      SalaryPeriod.values,
      j['salary_period'] as String? ?? 'YEAR',
      (v) => v.apiValue,
    ),
    rhythmType: j['rhythm_type'] as String?,
    startDate: DateTime.tryParse('${j['start_date']}'),
    durationMonths: j['duration_months'] == null
        ? null
        : _int(j['duration_months']),
    degreeLevelRequired: j['degree_level_required'] as String?,
    publishedAt: DateTime.tryParse('${j['published_at']}'),
    updatedAt:
        DateTime.tryParse('${j['updated_at']}') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    candidateCount: _int(j['candidate_count'] ?? 0),
  );
  bool hasFullOffer(int id) =>
      _offers.containsKey(id) && !_partialOffers.contains(id);
  String? _token;
  Map<int, JobOffer> _offers = {};
  final Set<int> _partialOffers = {};
  RecruiterCompany? _linkedCompany;

  Future<Map<int, JobOffer>> _session() async {
    final token = await api.tokenProvider?.call();
    if (token != _token) {
      _token = token;
      _offers = {};
      _partialOffers.clear();
      _linkedCompany = null;
    }
    return _offers;
  }

  @override
  Future<List<RecruiterCompany>> fetchCompanies() async {
    await _session();
    final profile = apiObject(await api.getJson('/api/v1/recruiters/profile'));
    final name = '${profile['companyName'] ?? ''}'.trim();
    if (name.isEmpty) return const [];
    int companyId = _linkedCompany?.id ?? 0;
    if (companyId == 0) {
      try {
        final dashboard = apiObject(
          await api.getJson('/api/v1/recruiters/dashboard'),
        );
        companyId = _int(dashboard['companyId'] ?? 0);
      } catch (_) {
        // The company still belongs to the user, even if KPIs are offline.
      }
    }
    // One company per recruiter. Company ID is not returned by /profile;
    // the temporary 0 is only an editor value, never sent to the backend.
    _linkedCompany = _company({'id': companyId, 'name': name});
    return [_linkedCompany!];
  }

  @override
  Future<RecruiterCompany?> findCompanyBySiret(String siret) async => null;

  @override
  Future<RecruiterCompany> createCompany(RecruiterCompanyDraft draft) async =>
      throw UnsupportedError('Votre entreprise est déjà liée à votre compte.');

  @override
  Future<List<JobOffer>> fetchOffers() async {
    final session = await _session();
    // There is no full GET recruiter jobs endpoint on the current API.
    // Dashboard topOffers is a PARTIAL list, not a complete job catalog.
    final dashboard = apiObject(
      await api.getJson('/api/v1/recruiters/dashboard'),
    );
    final summaries = dashboard['topOffers'] as List? ?? const [];
    for (final item in summaries) {
      if (item is! Map) continue;
      final row = Map<String, dynamic>.from(item);
      final id = _int(row['id']);
      if (session.containsKey(id)) continue;
      final contract = '${row['contract'] ?? 'CDI'}';
      final status = '${row['status'] ?? 'PUBLISHED'}';
      session[id] = _offer({
        'id': id,
        'company_id': _linkedCompany?.id ?? 0,
        'title': row['title'] ?? 'Offre',
        'contract_type': ContractType.values.any((c) => c.apiValue == contract)
            ? contract
            : 'CDI',
        'location': row['location'] ?? '',
        'remote_policy': 'ONSITE',
        'experience_level': 'JUNIOR',
        'status': JobOfferStatus.values.any((c) => c.apiValue == status)
            ? status
            : 'PUBLISHED',
        'description': '',
        'skills': const <String>[],
        'candidate_count': row['applications'] ?? 0,
        'updated_at': null,
      });
      _partialOffers.add(id);
    }
    return session.values.toList();
  }

  @override
  Future<JobOffer?> fetchOffer(int id) async {
    final session = await _session();
    if (_partialOffers.contains(id)) {
      throw UnsupportedError(
        'Le backend ne fournit que le résumé de cette offre : édition indisponible.',
      );
    }
    return session[id];
  }

  @override
  Future<JobOffer> createOffer(
    JobOfferDraft draft,
    JobOfferStatus status,
  ) async {
    final session = await _session();
    final offer = _offer(
      apiObject(
        await api.postJson(
          offersPath,
          body: JobOfferApiMapper.toCreateJson(draft, status),
        ),
      ),
    );
    session[offer.id] = offer;
    _linkedCompany = _linkedCompany == null
        ? null
        : _company({'id': offer.companyId, 'name': _linkedCompany!.name});
    return offer;
  }

  @override
  Future<JobOffer> updateOffer(int id, JobOfferDraft draft) async {
    final session = await _session();
    if (_partialOffers.contains(id)) {
      throw UnsupportedError(
        'Édition indisponible : la route de lecture complète manque.',
      );
    }
    if (session[id]?.contractType != draft.contractType) {
      throw UnsupportedError(
        'Le changement de contrat nécessite le catalogue des contrats.',
      );
    }
    final body = JobOfferApiMapper.toCreateJson(draft, JobOfferStatus.draft)
      ..remove('status')
      ..remove('contract_type');
    body['remote_mode'] = body.remove('remote_policy');
    body['experience_level_required'] = body.remove('experience_level');
    body['salary_currency'] = body.remove('currency');
    body.remove('contract_type');
    body.remove('status');
    final json = apiObject(
      await api.patchJson(JobOfferApiMapper.jobPath(id), body: body),
    );
    final offer = _offer({
      ...json,
      'contract_type': draft.contractType.apiValue,
      'remote_policy':
          json['remote_policy'] ??
          json['remote_mode'] ??
          draft.remoteMode.apiValue,
      'experience_level':
          json['experience_level'] ??
          json['experience_level_required'] ??
          draft.experienceLevel.apiValue,
      'currency': json['currency'] ?? json['salary_currency'] ?? draft.currency,
    });
    session[id] = offer;
    return offer;
  }

  @override
  Future<void> closeOffer(int id, {String? reason}) async {
    final session = await _session();
    await api.deleteJson(
      JobOfferApiMapper.jobPath(id),
      body: reason == null ? null : {'reason': reason},
    );
    session.remove(id);
  }

  @override
  Future<void> deleteOffer(int id) => closeOffer(id);
}
