import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

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
    logoUrl: (j['logoUrl'] ?? j['logo_url'])?.toString(),
    siret: '${j['siret'] ?? ''}',
    activity: '${j['activity'] ?? ''}',
    sector: '${j['sector'] ?? ''}',
    sizeRange: '${j['companySize'] ?? j['sizeRange'] ?? j['size_range'] ?? ''}',
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
    isSummary: j['is_summary'] == true,
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
    Map<String, dynamic> detail = {'id': companyId, 'name': name};
    if (companyId > 0) {
      try {
        detail = apiObject(
          await api.getJson(
            '/api/v1/companies/$companyId',
            query: {'include_jobs': 'false'},
          ),
        );
      } catch (_) {
        /* Identity from the authenticated profile remains usable. */
      }
    }
    _linkedCompany = _company(detail);
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
    var page = 1;
    while (true) {
      final response = apiObject(
        await api.getJson(offersPath, query: {'page': '$page', 'limit': '100'}),
      );
      for (final record in response['content'] as List? ?? const []) {
        final wrapper = apiObject(record);
        final payload = apiObject(wrapper['offer']);
        final offer = _offer({
          ...payload,
          'candidate_count': wrapper['candidate_count'] ?? 0,
        });
        session[offer.id] = offer;
        _partialOffers.remove(offer.id);
      }
      if (response['hasNext'] != true) break;
      page++;
    }
    return session.values.toList();
  }

  /// Only existing GET contracts. Never issue an empty PATCH to read a job.
  Future<Map<String, dynamic>> fetchOfferContext(int id) async {
    await _session();
    final dashboard = apiObject(
      await api.getJson('/api/v1/recruiters/dashboard'),
    );
    final companyId = _int(dashboard['companyId'] ?? 0);
    if (companyId <= 0) return {};
    final company = apiObject(
      await api.getJson(
        '/api/v1/companies/$companyId',
        query: {'include_jobs': 'true'},
      ),
    );
    final jobs = company['jobs'] as List? ?? const [];
    final job = jobs
        .whereType<Map>()
        .where((row) => '${row['id']}' == '$id')
        .firstOrNull;
    return {
      'company': company,
      if (job != null) 'job': Map<String, dynamic>.from(job),
    };
  }

  @override
  Future<JobOffer?> fetchOffer(int id) async {
    final session = await _session();
    try {
      final wrapper = apiObject(await api.getJson('$offersPath/$id'));
      final payload = apiObject(wrapper['offer']);
      final offer = _offer({
        ...payload,
        'candidate_count': wrapper['candidate_count'] ?? 0,
      });
      session[id] = offer;
      _partialOffers.remove(id);
      final company = apiObject(wrapper['company']);
      if (company['id'] != null && company['name'] != null) {
        _linkedCompany = _company(company);
      }
      return offer;
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
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
    final current = await fetchOffer(id);
    if (current == null) throw StateError('Offre introuvable.');
    final body = JobOfferApiMapper.toCreateJson(draft, JobOfferStatus.draft)
      ..remove('status')
      ..remove('contract_type');
    body['remote_mode'] = body.remove('remote_policy');
    body['experience_level_required'] = body.remove('experience_level');
    body['salary_currency'] = body.remove('currency');
    if (!draft.contractType.isWorkStudy) {
      // Removing the work-study contract also removes its obsolete fields.
      body.addAll({
        'rhythm_type': null,
        'start_date': null,
        'duration_months': null,
        'degree_level_required': null,
      });
    }
    // PATCH uses the real contract_type_id foreign key, unlike POST.
    if (current.contractType != draft.contractType) {
      final rows =
          await api.getJson('$offersPath/contract-types') as List? ?? const [];
      final matching = rows
          .map(apiObject)
          .where((row) => '${row['code']}' == draft.contractType.apiValue)
          .firstOrNull;
      if (matching == null) {
        throw StateError('Type de contrat introuvable dans la base.');
      }
      body['contract_type_id'] = _int(matching['id']);
    }
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
      'candidate_count': current.candidateCount,
    });
    session[id] = offer;
    _partialOffers.remove(id);
    return offer;
  }

  @override
  Future<void> closeOffer(int id, {String? reason}) async {
    final session = await _session();
    // Closing keeps the listing and its application history; DELETE soft-deletes.
    await api.patchJson(
      JobOfferApiMapper.jobPath(id),
      body: {'status': JobOfferStatus.closed.apiValue},
    );
    final updated = session[id];
    if (updated != null)
      session[id] = updated.copyWith(status: JobOfferStatus.closed);
  }

  @override
  Future<void> deleteOffer(int id) async {
    final session = await _session();
    await api.deleteJson(JobOfferApiMapper.jobPath(id));
    session.remove(id);
  }
}
