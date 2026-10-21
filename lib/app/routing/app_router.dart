import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/mobile/mobile_forgot_password_screen.dart';
import '../../features/auth/presentation/mobile/mobile_login_screen.dart';
import '../../features/auth/presentation/web/forgot_password_page.dart';
import '../../features/auth/presentation/web/login_page.dart';
import '../../features/dashboard/data/dashboard_repository.dart';
import '../../features/dashboard/presentation/dashboard_controller.dart';
import '../../features/dashboard/presentation/mobile/mobile_dashboard_screen.dart';
import '../../features/dashboard/presentation/web/dashboard_page.dart';
import '../../features/information/domain/information_content.dart';
import '../../features/information/presentation/mobile/information_screen.dart';
import '../../features/information/presentation/web/information_screen.dart';
import '../../features/landing/presentation/web/landing_screen.dart';
import '../../features/onboarding/presentation/mobile/mobile_cv_import_screen.dart';
import '../../features/onboarding/presentation/mobile/mobile_onboarding_screen.dart';
import '../../features/onboarding/presentation/onboarding_scope.dart';
import '../../features/onboarding/presentation/web/cv_import_screen.dart';
import '../../features/onboarding/presentation/web/onboarding_screen.dart';
import '../../features/registration/presentation/mobile/mobile_company_register_screen.dart';
import '../../features/registration/presentation/mobile/mobile_register_choice_screen.dart';
import '../../features/registration/presentation/mobile/mobile_student_register_screen.dart';
import '../../features/registration/presentation/web/company_register_screen.dart';
import '../../features/registration/presentation/web/register_choice_screen.dart';
import '../../features/registration/presentation/web/student_register_screen.dart';
import '../../features/startup/presentation/mobile/mobile_startup_screen.dart';
import '../experience/experience_target.dart';
import 'app_routes.dart';

/// Routeur partagé par deux produits de présentation distincts.
///
/// Le domaine, les repositories et les controllers restent communs. Seule la
/// couche presentation bascule entre web et mobile.
GoRouter createAppRouter(
  AuthController auth, {
  bool? webOverride,
}) {
  final target = ExperienceResolver.resolve(webOverride: webOverride);
  final mobile = target == ExperienceTarget.mobile;

  return GoRouter(
    initialLocation: AppRoutes.landing,
    refreshListenable: auth,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isInformationPage = informationPages.containsKey(location);
      final isRegistration = AppRoutes.registrationRoutes.contains(location);
      final isPublic = location == AppRoutes.landing ||
          AppRoutes.authEntryRoutes.contains(location) ||
          location == AppRoutes.forgotPassword ||
          isRegistration ||
          isInformationPage;

      if (!auth.isAuthenticated && !isPublic) return AppRoutes.login;

      if (auth.isAuthenticated && AppRoutes.authEntryRoutes.contains(location)) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.landing,
        name: 'landing',
        builder: (context, state) =>
            mobile ? const MobileStartupScreen() : const LandingScreen(),
      ),
      GoRoute(
        path: AppRoutes.connexion,
        redirect: (context, state) => AppRoutes.login,
      ),
      GoRoute(
        path: AppRoutes.inscription,
        redirect: (context, state) => AppRoutes.register,
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) =>
            mobile ? const MobileLoginScreen() : const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => mobile
            ? const MobileForgotPasswordScreen()
            : const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => mobile
            ? const MobileRegisterChoiceScreen()
            : const RegisterChoiceScreen(),
      ),
      GoRoute(
        path: AppRoutes.candidateRegister,
        name: 'candidateRegister',
        builder: (context, state) => mobile
            ? const MobileStudentRegisterScreen()
            : const StudentRegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.recruiterRegister,
        name: 'recruiterRegister',
        builder: (context, state) => mobile
            ? const MobileCompanyRegisterScreen()
            : const CompanyRegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => OnboardingScope(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.candidateOnboarding,
            name: 'candidateOnboarding',
            builder: (context, state) => mobile
                ? const MobileOnboardingScreen()
                : const OnboardingScreen(),
            routes: [
              GoRoute(
                path: 'cv',
                name: 'candidateCvImport',
                builder: (context, state) => mobile
                    ? const MobileCvImportScreen()
                    : const CvImportScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => DashboardController(
            context.read<DashboardRepository>(),
          )..load(),
          child: mobile ? const MobileDashboardScreen() : const DashboardPage(),
        ),
      ),
      for (final entry in informationPages.entries)
        GoRoute(
          path: entry.key,
          builder: (context, state) => mobile
              ? MobileInformationScreen(page: entry.value)
              : InformationScreen(page: entry.value),
        ),
    ],
  );
}
