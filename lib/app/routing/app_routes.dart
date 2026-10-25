abstract final class AppRoutes {
  // Entrées publiques
  static const String landing = '/';
  static const String login = '/login';
  static const String connexion = '/connexion';
  static const String forgotPassword = '/forgot-password';

  // Inscription
  static const String register = '/register';
  static const String inscription = '/inscription';
  static const String candidateRegister = '/register/candidate';
  static const String recruiterRegister = '/register/recruiter';

  // Candidat
  static const String candidate = '/candidate';
  static const String candidateDiscover = '/candidate/discover';
  static const String candidateProfile = '/candidate/profile';
  static const String candidateProfileEdit = '/candidate/profile/edit';
  static const String candidateApplications = '/candidate/applications';
  static const String candidateOnboarding = '/candidate/onboarding';
  static const String candidateCvImport = '/candidate/onboarding/cv';

  // Entreprise / espace connecté
  static const String dashboard = '/dashboard';
  static const String recruiter = '/recruiter';
  static const String recruiterJobs = '/recruiter/jobs';
  static const String recruiterCandidates = '/recruiter/candidates';
  static const String recruiterCompany = '/recruiter/company';

  static const String messages = '/messages';

  static const Set<String> authEntryRoutes = {login, connexion};

  static const Set<String> registrationRoutes = {
    register,
    inscription,
    candidateRegister,
    recruiterRegister,
  };
}
