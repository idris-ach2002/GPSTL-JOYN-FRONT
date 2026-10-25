import '../domain/student_profile.dart';
import 'profile_repository.dart';

/// Implémentation SIMULÉE de [ProfileRepository], en attendant le backend.
///
/// Le profil vit en mémoire : les modifications sont conservées tant que
/// l'application tourne. Il démarre avec un profil d'exemple.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({
    this.latency = const Duration(milliseconds: 500),
    StudentProfile? initialProfile,
  }) : _profile = initialProfile ?? sampleProfile;

  /// Délai simulé de chaque appel (mettre `Duration.zero` dans les tests).
  final Duration latency;

  StudentProfile _profile;

  @override
  Future<StudentProfile> fetchProfile() async {
    await Future<void>.delayed(latency);
    return _profile;
  }

  @override
  Future<StudentProfile> saveProfile(StudentProfile profile) async {
    await Future<void>.delayed(latency);
    _profile = profile;
    return _profile;
  }

  /// Profil d'exemple, repris de la maquette.
  static const sampleProfile = StudentProfile(
    firstName: 'Ariel',
    lastName: 'Benatsi',
    headline: 'Développeuse Full-Stack en devenir · M2 Informatique',
    city: 'Paris 13e',
    email: 'ariel.benatsi@etu.exemple.fr',
    bio:
        'Passionnée par les produits web bien construits, j’aime autant '
        'soigner une interface en React que concevoir une API propre. Je '
        'cherche une alternance d’un an dans une équipe produit où je peux '
        'livrer vite, apprendre des seniors et progresser sur le DevOps.',
    educations: [
      ProfileEducation(
        title: 'Master Informatique · M2',
        school: 'Sorbonne Université',
        period: '2025 – 2027 · alternance en M2',
      ),
      ProfileEducation(
        title: 'Licence Informatique',
        school: 'Sorbonne Université',
        period: '2022 – 2025',
      ),
    ],
    experiences: [
      ProfileExperience(
        title: 'Stage développeuse web',
        organization: 'Entreprise X',
        period: 'juin – juillet 2026 · 3 mois',
        description:
            "Refonte d'un back-office en React, API REST Node.js, tests "
            'unitaires. Temps de chargement divisé par deux.',
      ),
      ProfileExperience(
        title: 'Tutrice en algorithmique',
        organization: 'Université Paris Cité',
        period: '2025 – 2026',
      ),
    ],
    projects: [
      ProfileProject(
        title: "Pulse · moniteur d'uptime",
        description:
            'Mini-SaaS de monitoring avec alertes et dashboard temps réel.',
        tags: ['TypeScript', 'React', 'PostgreSQL'],
      ),
      ProfileProject(
        title: 'DepGraph · analyse de dépendances',
        description: "Analyseur de dépendances entre les fichiers d'un projet.",
        tags: ['TypeScript', 'React'],
      ),
    ],
    skills: [
      ProfileSkill('React', ProfileSkillLevel.advanced),
      ProfileSkill('Node.js', ProfileSkillLevel.advanced),
      ProfileSkill('Python', ProfileSkillLevel.advanced),
      ProfileSkill('TypeScript', ProfileSkillLevel.intermediate),
      ProfileSkill('SQL', ProfileSkillLevel.intermediate),
      ProfileSkill('Git', ProfileSkillLevel.intermediate),
      ProfileSkill('Figma', ProfileSkillLevel.intermediate),
      ProfileSkill('Docker', ProfileSkillLevel.beginner),
    ],
    links: ProfileLinks(
      github: 'github.com/BenatsiAriel',
      linkedin: 'linkedin.com/in/BenatsiAriel',
      portfolio: 'monportfolio.dev',
    ),
    cv: ProfileCv(
      fileName: 'CV_Ariel_Benatsi.pdf',
      updatedLabel: 'Mis à jour il y a 3 jours',
    ),
    availability: ProfileAvailability(
      start: 'Septembre 2027',
      durationMonths: 12,
      rhythm: '3 sem / 1 sem',
    ),
  );
}
