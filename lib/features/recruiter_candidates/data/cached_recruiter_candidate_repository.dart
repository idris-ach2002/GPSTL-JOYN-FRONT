import '../domain/recruiter_candidate_models.dart';
import 'recruiter_candidate_repository.dart';

class CachedRecruiterCandidateRepository
    implements RecruiterCandidateRepository {
  CachedRecruiterCandidateRepository(
    this._delegate, {
    this.ttl = const Duration(seconds: 90),
  });

  final RecruiterCandidateRepository _delegate;
  final Duration ttl;
  final Map<String, _CacheEntry<CandidateRecommendationData>> _cache = {};

  @override
  Future<CandidateRecommendationData> fetchRecommendations(
    CandidateRecommendationQuery query,
  ) async {
    final key = query.cacheKey;
    final cached = _cache[key];
    final now = DateTime.now();
    if (cached != null && now.difference(cached.createdAt) < ttl) {
      return cached.value;
    }
    final value = await _delegate.fetchRecommendations(query);
    _cache[key] = _CacheEntry(value, now);
    return value;
  }

  @override
  Future<RecruiterCandidateRecommendation> fetchCandidate(String candidateId) =>
      _delegate.fetchCandidate(candidateId);

  @override
  Future<RecruiterCandidateRecommendation> updateStatus(
    String candidateId,
    CandidateRecommendationStatus status,
  ) async {
    final result = await _delegate.updateStatus(candidateId, status);
    _cache.clear();
    return result;
  }
}

class _CacheEntry<T> {
  const _CacheEntry(this.value, this.createdAt);
  final T value;
  final DateTime createdAt;
}
