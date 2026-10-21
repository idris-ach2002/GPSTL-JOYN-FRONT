import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/dashboard/data/dashboard_repository.dart';
import '../../features/dashboard/presentation/dashboard_controller.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/information/domain/information_content.dart';
import '../../features/information/presentation/information_screen.dart';
import '../../features/landing/presentation/screens/landing_screen.dart';
import '../../features/onboarding/presentation/onboarding_scope.dart';
import '../../features/onboarding/presentation/screens/cv_import_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/registration/presentation/screens/company_register_screen.dart';
import '../../features/registration/presentation/screens/register_choice_screen.dart';
import '../../features/registration/presentation/screens/student_register_screen.dart';
import '../../features/startup/mobile_startup_screen.dart';
import 'app_routes.dart';

/// Routeur unique pour le web et les applications natives.
///
/// - Web : `/` affiche la landing marketing.
/// - Android/iOS : `/` affiche l'animation d'entrée, puis bascule vers la
///   connexion ou l'espace connecté selon la session restaurée.
/// - Les écrans d'authentification, d'inscription et d'onboarding partagent le
///   même graphe de navigation et le même [AuthController].
GoRouter createAppRouter(
  AuthController auth, {
  bool? webOverride,
}) {
  final web = webOverride ?? kIsWeb;

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

      if (!auth.isAuthenticated && !isPublic) {
        return AppRoutes.login;
      }

      // Une connexion réussie doit quitter l'écran de connexion. On ne force
      // pas la sortie des écrans d'inscription afin de laisser leur transition
      // vers l'onboarding se terminer proprement.
      if (auth.isAuthenticated && AppRoutes.authEntryRoutes.contains(location)) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.landing,
        name: 'landing',
        builder: (context, state) => web
            ? const LandingScreen()
            : const MobileStartupScreen(),
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
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
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
      ShellRoute(
        builder: (context, state, child) => OnboardingScope(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.candidateOnboarding,
            name: 'candidateOnboarding',
            builder: (context, state) => const OnboardingScreen(),
            routes: [
              GoRoute(
                path: 'cv',
                name: 'candidateCvImport',
                builder: (context, state) => const CvImportScreen(),
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
          child: const DashboardPage(),
        ),
      ),
      for (final entry in informationPages.entries)
        GoRoute(
          path: entry.key,
          builder: (context, state) => InformationScreen(page: entry.value),
        ),
    ],
  );
}
