import 'package:flutter/widgets.dart';

import '../core/config/app_environment.dart';
import '../core/network/api_client.dart';
import '../features/admin_companies/data/admin_company_repository.dart';
import '../features/admin_companies/data/api_admin_company_repository.dart';
import '../features/admin_companies/data/fake_admin_company_repository.dart';
import '../features/admin_users/data/admin_user_repository.dart';
import '../features/admin_users/data/api_admin_user_repository.dart';
import '../features/admin_users/data/fake_admin_user_repository.dart';
import '../features/admin_verifications/data/api_verification_repository.dart';
import '../features/admin_verifications/data/fake_verification_repository.dart';
import '../features/admin_verifications/data/verification_repository.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/fake_auth_repository.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/dashboard/data/fake_dashboard_repository.dart';
import '../features/registration/data/auth_registration_repository.dart';
import '../features/registration/data/mock_registration_repository.dart';
import '../features/registration/data/registration_repository.dart';
import '../features/recruiter_dashboard/data/api_recruiter_dashboard_repository.dart';
import '../features/recruiter_dashboard/data/cached_recruiter_dashboard_repository.dart';
import '../features/recruiter_dashboard/data/mock_recruiter_dashboard_repository.dart';
import '../features/recruiter_dashboard/data/recruiter_dashboard_repository.dart';
import '../features/recruiter_candidates/data/api_recruiter_candidate_repository.dart';
import '../features/recruiter_candidates/data/cached_recruiter_candidate_repository.dart';
import '../features/recruiter_candidates/data/mock_recruiter_candidate_repository.dart';
import '../features/recruiter_candidates/data/recruiter_candidate_repository.dart';
import '../features/recruiter_offers/data/mock_recruiter_offers_repository.dart';
import '../features/recruiter_offers/data/recruiter_offers_repository.dart';
import 'app.dart';

/// Initialise les dépendances partagées puis lance l'expérience demandée.
Future<void> bootstrapJoyn({bool? webOverride}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = AppEnvironment.fromCompileTime()..validate();
  final AuthRepository authRepository = FakeAuthRepository();
  final DashboardRepository dashboardRepository = FakeDashboardRepository();
  final RecruiterDashboardRepository recruiterDashboardRepository =
      CachedRecruiterDashboardRepository(
        environment.useApi
            ? ApiRecruiterDashboardRepository(
                ApiClient(
                  baseUrl: environment.apiBaseUrl,
                  timeout: environment.apiTimeout,
                ),
              )
            : MockRecruiterDashboardRepository(),
      );
  final RecruiterOffersRepository recruiterOffersRepository =
      MockRecruiterOffersRepository();
  final RecruiterCandidateRepository recruiterCandidateRepository =
      CachedRecruiterCandidateRepository(
        environment.useApi
            ? ApiRecruiterCandidateRepository(
                ApiClient(
                  baseUrl: environment.apiBaseUrl,
                  timeout: environment.apiTimeout,
                ),
              )
            : MockRecruiterCandidateRepository(),
      );
  final AdminCompanyRepository adminCompanyRepository = environment.useApi
      ? ApiAdminCompanyRepository(
          ApiClient(
            baseUrl: environment.apiBaseUrl,
            timeout: environment.apiTimeout,
          ),
        )
      : FakeAdminCompanyRepository();
  final AdminUserRepository adminUserRepository = environment.useApi
      ? ApiAdminUserRepository(
          ApiClient(
            baseUrl: environment.apiBaseUrl,
            timeout: environment.apiTimeout,
          ),
        )
      : FakeAdminUserRepository();
  final VerificationRepository verificationRepository = environment.useApi
      ? ApiVerificationRepository(
          ApiClient(
            baseUrl: environment.apiBaseUrl,
            timeout: environment.apiTimeout,
          ),
        )
      : FakeVerificationRepository();
  final RegistrationRepository registrationRepository =
      AuthRegistrationRepository(
        authRepository,
        companyLookupRepository: MockRegistrationRepository(),
      );

  final authController = AuthController(authRepository);
  await authController.restoreSession();

  runApp(
    JoynApp(
      webOverride: webOverride,
      authController: authController,
      dashboardRepository: dashboardRepository,
      recruiterDashboardRepository: recruiterDashboardRepository,
      registrationRepository: registrationRepository,
      recruiterOffersRepository: recruiterOffersRepository,
      recruiterCandidateRepository: recruiterCandidateRepository,
      adminCompanyRepository: adminCompanyRepository,
      adminUserRepository: adminUserRepository,
      verificationRepository: verificationRepository,
    ),
  );
}
