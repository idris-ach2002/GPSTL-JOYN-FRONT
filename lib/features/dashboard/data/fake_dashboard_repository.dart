import '../domain/candidate_profile.dart';
import '../domain/cv_document.dart';
import '../domain/experience.dart';
import '../domain/skill_comparison.dart';
import 'dashboard_repository.dart';

/// Implémentation SIMULÉE de [DashboardRepository], en attendant le backend.
///
/// Renvoie un profil de démo cohérent avec le reste de l'application :
/// le candidat simulé de la landing (Alex Dupont) comparé à l'offre la plus
/// compatible de la page « Matchs » (Entreprise Beta, 92 %).
class FakeDashboardRepository implements DashboardRepository {
  FakeDashboardRepository({this.latency = const Duration(milliseconds: 600)});

  /// Délai simulé de chaque appel (mettre `Duration.zero` dans les tests).
  final Duration latency;

  @override
  Future<CandidateProfile> fetchCandidateProfile() async {
    await Future<void>.delayed(latency);
    return demoCandidateProfile;
  }

  /// Profil de démonstration.
  static const CandidateProfile demoCandidateProfile = CandidateProfile(
    firstName: 'Alex',
    lastName: 'Dupont',
    headline: 'Développeur Full-Stack en alternance',
    school: 'M2 STL · Sorbonne Université',
    location: 'Paris 13e',
    matchScore: 92,
    matchLabel: 'Très forte adéquation',
    ranking: 'Top 3 des 28 candidats sur cette offre',
    matchHighlights: [
      'Rythme 3 sem / 1 sem identique à celui de l’offre',
      '35 min de trajet depuis Paris 13e',
      'React, TypeScript et Node.js déjà pratiqués en stage',
      'Docker à renforcer : seule compétence manquante',
    ],
    offerTitle: 'Full-Stack · Entreprise Beta',
    skills: [
      SkillComparison(
        name: 'React',
        requiredLevel: 'Intermédiaire',
        candidateLevel: 'Avancé',
        status: SkillStatus.exceeds,
      ),
      SkillComparison(
        name: 'TypeScript',
        requiredLevel: 'Intermédiaire',
        candidateLevel: 'Intermédiaire',
        status: SkillStatus.meets,
      ),
      SkillComparison(
        name: 'Node.js',
        requiredLevel: 'Intermédiaire',
        candidateLevel: 'Intermédiaire',
        status: SkillStatus.meets,
      ),
      SkillComparison(
        name: 'PostgreSQL',
        requiredLevel: 'Débutant',
        candidateLevel: 'Intermédiaire',
        status: SkillStatus.exceeds,
      ),
      SkillComparison(
        name: 'Docker',
        requiredLevel: 'Débutant',
        candidateLevel: 'Notions',
        status: SkillStatus.toTrain,
      ),
    ],
    experiences: [
      Experience(
        title: 'Stage développeur web',
        organization: 'Atelier Numérique',
        period: 'avril – juillet 2026 · 4 mois',
        description:
            'Refonte d’un back-office en React et TypeScript, API REST '
            'Node.js, tests unitaires. Temps de chargement divisé par deux.',
      ),
      Experience(
        title: 'Projet de master · plateforme de covoiturage',
        organization: 'Sorbonne Université',
        period: '2025 – 2026',
        description:
            'Application full-stack (React, Spring Boot, PostgreSQL) réalisée '
            'en équipe de 4, déployée sur un VPS.',
      ),
    ],
    cv: CvDocument(
      fileName: 'CV_Alex_Dupont.pdf',
      updatedLabel: 'Mis à jour il y a 3 jours',
    ),
  );
}
