import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/recruiter_candidates/data/cached_recruiter_candidate_repository.dart';
import 'package:joyn_front/features/recruiter_candidates/data/mock_recruiter_candidate_repository.dart';
import 'package:joyn_front/features/recruiter_candidates/domain/recruiter_candidate_models.dart';

void main() {
  test('le mock expose recommandations, offres et statistiques', () async {
    final repository = MockRecruiterCandidateRepository(latency: Duration.zero);

    final data = await repository.fetchRecommendations(
      const CandidateRecommendationQuery(),
    );

    expect(data.offers, isNotEmpty);
    expect(data.items, isNotEmpty);
    expect(data.items.first.compatibilityScore, greaterThanOrEqualTo(80));
    expect(data.stats.recommended, greaterThan(0));
  });

  test('une action déplace le candidat vers le statut choisi', () async {
    final repository = MockRecruiterCandidateRepository(latency: Duration.zero);
    final initial = await repository.fetchRecommendations(
      const CandidateRecommendationQuery(),
    );
    final candidate = initial.items.first;

    await repository.updateStatus(
      candidate.id,
      CandidateRecommendationStatus.saved,
    );

    final saved = await repository.fetchRecommendations(
      const CandidateRecommendationQuery(
        status: CandidateRecommendationStatus.saved,
      ),
    );
    expect(saved.items.any((item) => item.id == candidate.id), isTrue);
  });

  test('le cache renvoie la même instance pendant le TTL', () async {
    final repository = CachedRecruiterCandidateRepository(
      MockRecruiterCandidateRepository(latency: Duration.zero),
      ttl: const Duration(minutes: 2),
    );
    const query = CandidateRecommendationQuery();

    final first = await repository.fetchRecommendations(query);
    final second = await repository.fetchRecommendations(query);

    expect(identical(first, second), isTrue);
  });
}
