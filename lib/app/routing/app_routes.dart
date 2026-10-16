// Regroupe des chemins de navigation du projet ; leur présence ne les enregistre pas dans le routeur actif.
//
// Référence : doc/landing/fichiers/app_routes.md.

/// Catalogue de chemins du projet, distinct de la liste des routes enregistrées.
class AppRoutes {
  /// Initialise les paramètres de AppRoutes ; les valeurs par défaut figurent dans la signature.
  AppRoutes._();

  // Public
  /// Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation.
  static const String landing = '/';

  /// Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation.
  static const String login = '/login';

  // Registration
  /// Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation.
  static const String candidateRegister = '/register/candidate';

  /// Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation.
  static const String recruiterRegister = '/register/recruiter';

  // Candidate
  /// Intérêt exprimé du côté candidat dans la scène interactive.
  static const String candidate = '/candidate';

  /// Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation.
  static const String candidateDiscover = '/candidate/discover';

  /// Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation.
  static const String candidateProfile = '/candidate/profile';

  /// Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation.
  static const String candidateApplications = '/candidate/applications';

  // Recruiter
  /// Sélectionne le rôle recruteur ou son portrait selon le composant.
  static const String recruiter = '/recruiter';

  /// Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation.
  static const String recruiterJobs = '/recruiter/jobs';

  /// Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation.
  static const String recruiterCandidates = '/recruiter/candidates';

  /// Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation.
  static const String recruiterCompany = '/recruiter/company';

  // Messaging
  /// Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation.
  static const String messages = '/messages';

  // Admin
  /// Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation.
  static const String admin = '/admin';

  /// Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation.
  static const String adminUsers = '/admin/users';

  /// Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation.
  static const String adminCompanies = '/admin/companies';
}
