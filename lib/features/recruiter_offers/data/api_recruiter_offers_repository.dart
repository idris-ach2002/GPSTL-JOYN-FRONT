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
  static const companiesPath = '/api/v1/recruiters/companies';
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
      j['experience_level'] as String?,
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
    updatedAt: DateTime.parse('${j['updated_at']}'),
    candidateCount: _int(j['candidate_count'] ?? 0),
  );
  @override
  Future<List<RecruiterCompany>> fetchCompanies() async =>
      apiList(await api.getJson(companiesPath)).map(_company).toList();
  @override
  Future<RecruiterCompany?> findCompanyBySiret(String siret) async {
    final items = apiList(
      await api.getJson(companiesPath, query: {'siret': siret}),
    );
    return items.isEmpty ? null : _company(items.first);
  }

  @override
  Future<RecruiterCompany> createCompany(RecruiterCompanyDraft draft) async =>
      _company(
        apiObject(
          await api.postJson(
            companiesPath,
            body: {
              'name': draft.name,
              'sector': draft.sector,
              'sizeRange': draft.sizeRange,
              'city': draft.city,
              'siret': draft.siret,
              'website': draft.website,
              'description': draft.description,
            },
          ),
        ),
      );
  @override
  Future<List<JobOffer>> fetchOffers() async =>
      apiList(await api.getJson(offersPath)).map(_offer).toList();
  @override
  Future<JobOffer?> fetchOffer(int id) async {
    try {
      return _offer(
        apiObject(await api.getJson(JobOfferApiMapper.jobPath(id))),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<JobOffer> createOffer(
    JobOfferDraft draft,
    JobOfferStatus status,
  ) async => _offer(
    apiObject(
      await api.postJson(
        offersPath,
        body: JobOfferApiMapper.toCreateJson(draft, status),
      ),
    ),
  );
  @override
  Future<JobOffer> updateOffer(int id, JobOfferDraft draft) async {
    final body = JobOfferApiMapper.toCreateJson(draft, JobOfferStatus.draft)
      ..remove('status');
    final response = await api.putJson(
      JobOfferApiMapper.jobPath(id),
      body: body,
    );
    return response == null
        ? (await fetchOffer(id))!
        : _offer(apiObject(response));
  }

  @override
  Future<void> closeOffer(int id, {String? reason}) async {
    await api.patchJson(
      JobOfferApiMapper.jobPath(id),
      body: {'status': 'CLOSED', 'reason': ?reason},
    );
  }

  @override
  Future<void> deleteOffer(int id) async {
    await api.deleteJson(JobOfferApiMapper.jobPath(id));
  }
}
