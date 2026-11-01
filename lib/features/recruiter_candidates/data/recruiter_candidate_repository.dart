import '../domain/recruiter_candidate_models.dart';

abstract interface class RecruiterCandidateRepository {
  Future<CandidateRecommendationData> fetchRecommendations(
    CandidateRecommendationQuery query,
  );

  Future<RecruiterCandidateRecommendation> fetchCandidate(String candidateId);

  Future<RecruiterCandidateRecommendation> updateStatus(
    String candidateId,
    CandidateRecommendationStatus status,
  );
}
