class AppRoutes {
  AppRoutes._();

  // Public
  static const String landing = '/';
  static const String login = '/login';

  // Registration
  static const String register = '/register';
  static const String candidateRegister = '/register/candidate';
  static const String recruiterRegister = '/register/recruiter';

  // Candidate
  static const String candidate = '/candidate';
  static const String candidateDiscover = '/candidate/discover';
  static const String candidateProfile = '/candidate/profile';
  static const String candidateApplications = '/candidate/applications';
  static const String candidateOnboarding = '/candidate/onboarding';
  static const String candidateCvImport = '/candidate/onboarding/cv';

  // Recruiter
  static const String recruiter = '/recruiter';
  static const String recruiterJobs = '/recruiter/jobs';
  static const String recruiterCandidates = '/recruiter/candidates';
  static const String recruiterCompany = '/recruiter/company';

  // Messaging
  static const String messages = '/messages';

  // Admin
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminCompanies = '/admin/companies';
}
