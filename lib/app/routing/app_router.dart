import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/mobile/mobile_entry_transition.dart';
import '../../features/auth/domain/user_role.dart';
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
import '../../features/recruiter_offers/data/recruiter_offers_repository.dart';
import '../../features/recruiter_offers/presentation/controllers/offer_detail_controller.dart';
import '../../features/recruiter_offers/presentation/controllers/offer_editor_controller.dart';
import '../../features/recruiter_offers/presentation/controllers/offer_management_controller.dart';
import '../../features/recruiter_offers/presentation/mobile/mobile_offer_detail_screen.dart';
import '../../features/recruiter_offers/presentation/mobile/mobile_offer_editor_screen.dart';
import '../../features/recruiter_offers/presentation/mobile/mobile_recruiter_offers_screen.dart';
import '../../features/recruiter_offers/presentation/web/offer_editor_screen.dart';
import '../../features/recruiter_offers/presentation/web/recruiter_offers_screen.dart';
import '../../features/recruiter_offers/presentation/web/web_offer_detail_screen.dart';
import '../../features/startup/presentation/mobile/mobile_startup_screen.dart';
import '../experience/experience_target.dart';
import 'app_routes.dart';

GoRouter createAppRouter(AuthController auth, {bool? webOverride}) {
  bool useMobile(BuildContext context) {
    return ExperienceResolver.resolve(
          webOverride: webOverride,
          logicalWidth: MediaQuery.sizeOf(context).width,
        ) ==
        ExperienceTarget.mobile;
  }

  Widget adaptiveAuth(
    BuildContext context, {
    required Widget mobile,
    required Widget web,
  }) {
    return useMobile(context) ? MobileEntryTransition(child: mobile) : web;
  }

  return GoRouter(
    initialLocation: AppRoutes.landing,
    refreshListenable: auth,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isInformationPage = informationPages.containsKey(location);
      final isRegistration = AppRoutes.registrationRoutes.contains(location);
      final isPublic =
          location == AppRoutes.landing ||
          AppRoutes.authEntryRoutes.contains(location) ||
          location == AppRoutes.forgotPassword ||
          isRegistration ||
          isInformationPage;

      if (!auth.isAuthenticated && !isPublic) return AppRoutes.login;

      final isRecruiterArea =
          location == AppRoutes.recruiter ||
          location.startsWith('${AppRoutes.recruiter}/');
      if (auth.isAuthenticated &&
          isRecruiterArea &&
          auth.user?.role != UserRole.company) {
        return AppRoutes.dashboard;
      }

      if (auth.isAuthenticated &&
          AppRoutes.authEntryRoutes.contains(location)) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.landing,
        name: 'landing',
        builder: (context, state) => useMobile(context)
            ? const MobileStartupScreen()
            : const LandingScreen(),
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
        builder: (context, state) => adaptiveAuth(
          context,
          mobile: const MobileLoginScreen(),
          web: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => adaptiveAuth(
          context,
          mobile: const MobileForgotPasswordScreen(),
          web: const ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => adaptiveAuth(
          context,
          mobile: const MobileRegisterChoiceScreen(),
          web: const RegisterChoiceScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.candidateRegister,
        name: 'candidateRegister',
        builder: (context, state) => adaptiveAuth(
          context,
          mobile: const MobileStudentRegisterScreen(),
          web: const StudentRegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.recruiterRegister,
        name: 'recruiterRegister',
        builder: (context, state) => adaptiveAuth(
          context,
          mobile: const MobileCompanyRegisterScreen(),
          web: const CompanyRegisterScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => OnboardingScope(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.candidateOnboarding,
            name: 'candidateOnboarding',
            builder: (context, state) => useMobile(context)
                ? const MobileOnboardingScreen()
                : const OnboardingScreen(),
            routes: [
              GoRoute(
                path: 'cv',
                name: 'candidateCvImport',
                builder: (context, state) => useMobile(context)
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
          create: (context) =>
              DashboardController(context.read<DashboardRepository>())..load(),
          child: useMobile(context)
              ? const MobileDashboardScreen()
              : const DashboardPage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.recruiterJobs,
        name: 'recruiterJobs',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => OfferManagementController(
            context.read<RecruiterOffersRepository>(),
          )..load(),
          child: useMobile(context)
              ? const MobileRecruiterOffersScreen()
              : const WebRecruiterOffersScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.recruiterJobCreate,
        name: 'recruiterJobCreate',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) =>
              OfferEditorController(context.read<RecruiterOffersRepository>())
                ..load(),
          child: useMobile(context)
              ? const MobileOfferEditorScreen()
              : const WebOfferEditorScreen(),
        ),
      ),
      GoRoute(
        path: '/recruiter/jobs/:jobId/edit',
        name: 'recruiterJobEdit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['jobId'] ?? '');
          if (id == null) return const SizedBox.shrink();
          return ChangeNotifierProvider(
            create: (context) => OfferEditorController(
              context.read<RecruiterOffersRepository>(),
              offerId: id,
            )..load(),
            child: useMobile(context)
                ? const MobileOfferEditorScreen()
                : const WebOfferEditorScreen(),
          );
        },
      ),
      GoRoute(
        path: '/recruiter/jobs/:jobId',
        name: 'recruiterJobDetail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['jobId'] ?? '');
          if (id == null) return const SizedBox.shrink();
          if (useMobile(context)) {
            return ChangeNotifierProvider(
              create: (context) => OfferDetailController(
                context.read<RecruiterOffersRepository>(),
                id,
              )..load(),
              child: const MobileOfferDetailScreen(),
            );
          }
          return ChangeNotifierProvider(
            create: (context) => OfferDetailController(
              context.read<RecruiterOffersRepository>(),
              id,
            )..load(),
            child: const WebOfferDetailScreen(),
          );
        },
      ),
      for (final entry in informationPages.entries)
        GoRoute(
          path: entry.key,
          builder: (context, state) => useMobile(context)
              ? MobileInformationScreen(page: entry.value)
              : InformationScreen(page: entry.value),
        ),
    ],
  );
}
