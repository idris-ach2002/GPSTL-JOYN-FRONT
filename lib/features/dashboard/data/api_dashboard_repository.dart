import '../../../core/network/api_client.dart';
import '../domain/candidate_profile.dart';
import '../domain/cv_document.dart';
import '../domain/experience.dart';
import '../domain/skill_comparison.dart';
import 'dashboard_repository.dart';

/// The dashboard's existing candidate card is populated with real profile data.
/// Matching information is shown only if the API actually supplies a score.
class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository(this.api);
  final ApiClient api;

  @override
  Future<CandidateProfile> fetchCandidateProfile() async {
    final raw = await api.getJson('/api/v1/candidates/profile');
    final profile = Map<String, dynamic>.from(raw as Map);
    final educations = profile['educations'] as List? ?? const [];
    final experiences = profile['experiences'] as List? ?? const [];
    final skills = profile['skills'] as List? ?? const [];
    Map<String, dynamic>? match;
    try {
      final recommendations = await api.getJson(
        '/api/v1/candidates/recommendations',
        query: {'page': '1', 'limit': '1'},
      );
      final content = (recommendations as Map)['content'] as List? ?? const [];
      if (content.isNotEmpty)
        match = Map<String, dynamic>.from(content.first as Map);
    } catch (_) {
      // Candidate profile is still usable when no recommendation exists.
    }
    final offer = match?['offer'] is Map
        ? Map<String, dynamic>.from(match!['offer'] as Map)
        : <String, dynamic>{};
    final breakdown = match?['score_breakdown'] is Map
        ? Map<String, dynamic>.from(match!['score_breakdown'] as Map)
        : <String, dynamic>{};
    final score = (match?['match_score'] as num?)?.round();
    return CandidateProfile(
      firstName: profile['first_name']?.toString(),
      lastName: profile['last_name']?.toString(),
      headline: profile['headline']?.toString(),
      school: educations.isNotEmpty
          ? (educations.first as Map)['school_name']?.toString()
          : null,
      location: profile['location']?.toString(),
      matchScore: score,
      matchLabel: score == null ? null : '$score % de compatibilité',
      offerTitle: offer['title']?.toString(),
      matchHighlights: [
        for (final e in breakdown.entries)
          if (e.value is num) '${e.key} : ${e.value} %',
      ],
      skills: [for (final skill in skills) SkillComparison(name: '$skill')],
      experiences: [
        for (final item in experiences)
          Experience(
            title: (item as Map)['title']?.toString(),
            organization: item['organization']?.toString(),
            description: item['description']?.toString(),
            period: [
              item['start_date'],
              item['end_date'],
            ].where((e) => e != null).join(' – '),
          ),
      ],
      cv: profile['cv_url'] == null
          ? null
          : CvDocument(
              fileName: 'CV du candidat',
              url: profile['cv_url']?.toString(),
            ),
    );
  }
}
