import '../../../core/network/api_client.dart';
import '../domain/recruiter_candidate_models.dart';
import 'recruiter_candidate_repository.dart';

class ApiRecruiterCandidateRepository implements RecruiterCandidateRepository {
  ApiRecruiterCandidateRepository(this._api);

  final ApiClient _api;

  @override
  Future<CandidateRecommendationData> fetchRecommendations(
    CandidateRecommendationQuery query,
  ) async {
    final json = await _api.getJson(
      '/api/v1/recruiters/recommendations',
      query: query.toQueryParameters(),
    );
    return _mapData(_asMap(json));
  }

  @override
  Future<RecruiterCandidateRecommendation> fetchCandidate(
    String candidateId,
  ) async {
    final json = await _api.getJson(
      '/api/v1/recruiters/recommendations/$candidateId',
    );
    final root = _asMap(json);
    return _mapCandidate(_unwrapObject(root));
  }

  @override
  Future<RecruiterCandidateRecommendation> updateStatus(
    String candidateId,
    CandidateRecommendationStatus status,
  ) async {
    final path = switch (status) {
      CandidateRecommendationStatus.saved => 'save',
      CandidateRecommendationStatus.interested => 'interest',
      CandidateRecommendationStatus.rejected => 'reject',
      CandidateRecommendationStatus.recommended => 'save',
      CandidateRecommendationStatus.matched => 'interest',
    };
    final Object? json;
    if (status == CandidateRecommendationStatus.recommended) {
      json = await _api.deleteJson(
        '/api/v1/recruiters/recommendations/$candidateId/save',
      );
    } else {
      json = await _api.postJson(
        '/api/v1/recruiters/recommendations/$candidateId/$path',
      );
    }
    final root = _asMap(json);
    if (root.isEmpty) return fetchCandidate(candidateId);
    return _mapCandidate(_unwrapObject(root));
  }

  CandidateRecommendationData _mapData(Map<String, dynamic> root) {
    final body = _unwrapObject(root);
    final itemsJson = _asList(
      body['items'] ?? body['recommendations'] ?? body['content'],
    );
    final offersJson = _asList(body['offers']);
    final statsJson = _asMap(body['stats']);
    final pagination = _asMap(body['pagination']);

    return CandidateRecommendationData(
      items: itemsJson.map((item) => _mapCandidate(_asMap(item))).toList(),
      offers: offersJson.map((item) => _mapOffer(_asMap(item))).toList(),
      stats: CandidateRecommendationStats(
        recommended: _int(statsJson['recommended']),
        saved: _int(statsJson['saved']),
        interested: _int(statsJson['interested']),
        matches: _int(statsJson['matches']),
      ),
      page: _int(body['page'] ?? pagination['page'], fallback: 1),
      totalPages: _int(
        body['totalPages'] ?? pagination['totalPages'],
        fallback: 1,
      ),
      totalItems: _int(
        body['totalItems'] ?? pagination['totalItems'],
        fallback: itemsJson.length,
      ),
      selectedOfferId: _nullableInt(body['selectedOfferId']),
    );
  }

  RecruiterCandidateOffer _mapOffer(Map<String, dynamic> json) =>
      RecruiterCandidateOffer(
        id: _int(json['id']),
        title: _string(json['title']),
        location: _string(json['location']),
        contract: _string(json['contract'] ?? json['contractType']),
      );

  RecruiterCandidateRecommendation _mapCandidate(Map<String, dynamic> json) {
    final match = _asMap(json['match'] ?? json['matching']);
    return RecruiterCandidateRecommendation(
      id: _string(json['id']),
      firstName: _string(json['firstName']),
      lastName: _string(json['lastName']),
      jobTitle: _string(json['jobTitle'] ?? json['title']),
      avatarUrl: _nullableString(json['avatarUrl']),
      location: _string(json['location']),
      education: _string(json['education']),
      experienceYears: _double(json['experienceYears']),
      availability: _string(json['availability']),
      contractPreference: _string(json['contractPreference']),
      remotePreference: _string(json['remotePreference']),
      skills: _asList(json['skills'])
          .map(_string)
          .where((e) => e.isNotEmpty)
          .toList(),
      compatibilityScore: _double(json['compatibilityScore'] ?? json['score']),
      match: CandidateMatchBreakdown(
        skills: _double(match['skills']),
        experience: _double(match['experience']),
        education: _double(match['education']),
        location: _double(match['location']),
        availability: _double(match['availability']),
      ),
      strengths: _asList(json['strengths'])
          .map(_string)
          .where((e) => e.isNotEmpty)
          .toList(),
      warnings: _asList(json['warnings'])
          .map(_string)
          .where((e) => e.isNotEmpty)
          .toList(),
      summary: _string(json['summary']),
      status: CandidateRecommendationStatus.fromApi(
        _nullableString(json['status']),
      ),
      reciprocalMatch: json['reciprocalMatch'] == true,
      connections: _int(json['connections']),
    );
  }

  Map<String, dynamic> _unwrapObject(Map<String, dynamic> json) {
    final data = json['data'];
    return data is Map<String, dynamic> ? data : json;
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((key, value) => MapEntry('$key', value));
    return <String, dynamic>{};
  }

  List<dynamic> _asList(Object? value) => value is List ? value : const [];
  String _string(Object? value) => value?.toString() ?? '';
  String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  int _int(Object? value, {int fallback = 0}) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
  int? _nullableInt(Object? value) => value == null ? null : _int(value);
  double _double(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}
