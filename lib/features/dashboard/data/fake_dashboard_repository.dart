import '../domain/candidate_profile.dart';
import '../domain/experience.dart';
import '../domain/skill_comparison.dart';
import 'dashboard_repository.dart';

/// Implémentation SIMULÉE de [DashboardRepository], en attendant le backend.
///
/// Toutes les valeurs sont à `null` : l'écran affiche sa structure (lignes du
/// tableau, étapes du parcours…) avec des tirets à la place des données.
class FakeDashboardRepository implements DashboardRepository {
  FakeDashboardRepository({this.latency = const Duration(milliseconds: 600)});

  /// Délai simulé de chaque appel (mettre `Duration.zero` dans les tests).
  final Duration latency;

  @override
  Future<CandidateProfile> fetchCandidateProfile() async {
    await Future<void>.delayed(latency);
    return const CandidateProfile(
      // Lignes vides, pour voir la mise en page du tableau et du parcours.
      skills: [
        SkillComparison(),
        SkillComparison(),
        SkillComparison(),
        SkillComparison(),
        SkillComparison(),
      ],
      experiences: [Experience(), Experience()],
    );
  }
}
