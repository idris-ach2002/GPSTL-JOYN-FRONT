import '../../../core/network/api_client.dart';
import '../domain/recruiter_candidate_models.dart';
import 'recruiter_candidate_repository.dart';

/// The backend recommends *applicants for a job*, never all candidates.
/// Preserve the current screen but map its cards to real applications.
class ApiRecruiterCandidateRepository implements RecruiterCandidateRepository {
  ApiRecruiterCandidateRepository(this.api);
  final ApiClient api;
  final Map<String, RecruiterCandidateRecommendation> _cache = {};

  @override
  Future<CandidateRecommendationData> fetchRecommendations(
    CandidateRecommendationQuery query,
  ) async {
    final overview = _map(await api.getJson('/api/v1/recruiters/dashboard'));
    final summary = overview['topOffers'] as List? ?? const [];
    final offers = [
      for (final item in summary)
        if (item is Map)
          RecruiterCandidateOffer(
            id: _int(item['id']),
            title: '${item['title'] ?? ''}',
            location: '${item['location'] ?? ''}',
            contract: '${item['contract'] ?? ''}',
          ),
    ];
    final selected =
        query.offerId ?? (offers.isNotEmpty ? offers.first.id : null);
    if (selected == null) {
      return CandidateRecommendationData(
        items: const [],
        offers: offers,
        stats: const CandidateRecommendationStats(
          recommended: 0,
          saved: 0,
          interested: 0,
          matches: 0,
        ),
        page: 1,
        totalPages: 1,
        totalItems: 0,
        selectedOfferId: null,
      );
    }
    final mapped = <RecruiterCandidateRecommendation>[];
    final pageSize = query.limit.clamp(1, 50).toInt();
    for (var page = 1; ; page++) {
      final response = _map(
        await api.getJson(
          '/api/v1/recruiters/jobs/$selected/recommendations',
          query: {'page': '$page', 'limit': '$pageSize'},
        ),
      );
      final rows = response['content'] as List? ?? const [];
      mapped.addAll(rows.map((row) => _candidate(_map(row))));
      if (rows.isEmpty || page >= _int(response['totalPages'], fallback: 1)) {
        break;
      }
    }
    for (final item in mapped) {
      _cache[item.id] = item;
    }
    final filtered = mapped.where((item) {
      if (item.compatibilityScore < query.scoreMin) return false;
      if (query.location != null &&
          !item.location.toLowerCase().contains(
            query.location!.toLowerCase(),
          )) {
        return false;
      }
      if (query.skills.isNotEmpty &&
          !query.skills.every(
            (skill) =>
                item.skills.any((s) => s.toLowerCase() == skill.toLowerCase()),
          )) {
        return false;
      }
      if (query.experienceMin != null &&
          item.experienceYears < query.experienceMin!) {
        return false;
      }
      if (query.experienceMax != null &&
          item.experienceYears > query.experienceMax!) {
        return false;
      }
      if (query.contractType != null &&
          !item.contractPreference.toLowerCase().contains(
            query.contractType!.toLowerCase(),
          )) {
        return false;
      }
      return item.status == query.status;
    }).toList();
    final totalPages = filtered.isEmpty
        ? 1
        : (filtered.length / pageSize).ceil();
    final page = query.page.clamp(1, totalPages).toInt();
    return CandidateRecommendationData(
      items: filtered.skip((page - 1) * pageSize).take(pageSize).toList(),
      offers: offers,
      stats: CandidateRecommendationStats(
        recommended: mapped
            .where((c) => c.status == CandidateRecommendationStatus.recommended)
            .length,
        saved: mapped
            .where((c) => c.status == CandidateRecommendationStatus.saved)
            .length,
        interested: mapped
            .where((c) => c.status == CandidateRecommendationStatus.interested)
            .length,
        matches: mapped
            .where((c) => c.status == CandidateRecommendationStatus.matched)
            .length,
      ),
      page: page,
      totalPages: totalPages,
      totalItems: filtered.length,
      selectedOfferId: selected,
    );
  }

  @override
  Future<RecruiterCandidateRecommendation> fetchCandidate(
    String candidateId,
  ) async {
    final cached = _cache[candidateId];
    if (cached == null) {
      throw StateError('Ouvrez une candidature depuis une offre.');
    }
    return cached;
  }

  @override
  Future<RecruiterCandidateRecommendation> updateStatus(
    String candidateId,
    CandidateRecommendationStatus status,
  ) async {
    final current = await fetchCandidate(candidateId);
    final backendStatus = switch (status) {
      CandidateRecommendationStatus.saved => 'VIEWED',
      CandidateRecommendationStatus.interested => 'IN_REVIEW',
      CandidateRecommendationStatus.rejected => 'REJECTED',
      CandidateRecommendationStatus.matched => 'ACCEPTED',
      CandidateRecommendationStatus.recommended => 'PENDING',
    };
    await api.patchJson(
      '/api/v1/applications/$candidateId/status',
      body: {'status': backendStatus},
    );
    final updated = current.copyWith(status: status);
    _cache[candidateId] = updated;
    return updated;
  }

  RecruiterCandidateRecommendation _candidate(Map<String, dynamic> row) {
    final p = _map(row['candidate']);
    final score = _map(row['score_breakdown']);
    final state = '${row['application_status'] ?? 'PENDING'}'.toUpperCase();
    final status = switch (state) {
      'VIEWED' => CandidateRecommendationStatus.saved,
      'IN_REVIEW' || 'INTERVIEW' => CandidateRecommendationStatus.interested,
      'ACCEPTED' => CandidateRecommendationStatus.matched,
      'REJECTED' || 'WITHDRAWN' => CandidateRecommendationStatus.rejected,
      _ => CandidateRecommendationStatus.recommended,
    };
    final education =
        p['educations'] is List && (p['educations'] as List).isNotEmpty
        ? _map((p['educations'] as List).first)
        : <String, dynamic>{};
    final alt = _map(p['alternance']);
    final preferences = _map(p['preferences']);
    return RecruiterCandidateRecommendation(
      profileId: p['id']?.toString(),
      id: '${row['application_id']}',
      firstName: '${p['first_name'] ?? ''}',
      lastName: '${p['last_name'] ?? ''}',
      jobTitle: '${p['headline'] ?? ''}',
      avatarUrl: p['photo_url']?.toString(),
      location: '${p['location'] ?? ''}',
      education: '${education['school_name'] ?? ''}',
      experienceYears: _double(p['years_of_experience']),
      availability: '${alt['available_from'] ?? ''}',
      contractPreference: (preferences['contract_types'] as List? ?? const [])
          .join(', '),
      remotePreference: '${preferences['remote_policy'] ?? ''}',
      skills: [for (final s in p['skills'] as List? ?? const []) '$s'],
      compatibilityScore: _double(row['match_score']),
      match: CandidateMatchBreakdown(
        skills: _double(score['skills']),
        experience: _double(score['experience']),
        education: _double(score['education']),
        location: _double(score['location']),
        availability: _double(score['availability']),
      ),
      strengths: const [],
      warnings: const [],
      summary: '${p['bio'] ?? ''}',
      status: status,
      reciprocalMatch: false,
      connections: 0,
    );
  }

  Map<String, dynamic> _map(Object? raw) =>
      raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  int _int(Object? raw, {int fallback = 0}) =>
      raw is num ? raw.toInt() : int.tryParse('$raw') ?? fallback;
  double _double(Object? raw) =>
      raw is num ? raw.toDouble() : double.tryParse('$raw') ?? 0;
}
