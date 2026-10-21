import 'package:go_router/go_router.dart';

import '../../features/landing/presentation/screens/landing_screen.dart';
import '../../features/onboarding/presentation/onboarding_scope.dart';
import '../../features/onboarding/presentation/screens/cv_import_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/registration/presentation/screens/company_register_screen.dart';
import '../../features/registration/presentation/screens/register_choice_screen.dart';
import '../../features/registration/presentation/screens/student_register_screen.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.landing,
  routes: [
    GoRoute(
      path: AppRoutes.landing,
      name: 'landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterChoiceScreen(),
    ),
    GoRoute(
      path: AppRoutes.candidateRegister,
      name: 'candidateRegister',
      builder: (context, state) => const StudentRegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.recruiterRegister,
      name: 'recruiterRegister',
      builder: (context, state) => const CompanyRegisterScreen(),
    ),

    // Onboarding étudiant : le ShellRoute garde le même OnboardingScope
    // (et donc les mêmes données) entre l'onboarding et l'import du CV.
    ShellRoute(
      builder: (context, state, child) => OnboardingScope(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.candidateOnboarding,
          name: 'candidateOnboarding',
          builder: (context, state) => const OnboardingScreen(),
          routes: [
            // Chemin relatif : donne /candidate/onboarding/cv
            // (= AppRoutes.candidateCvImport).
            GoRoute(
              path: 'cv',
              name: 'candidateCvImport',
              builder: (context, state) => const CvImportScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
