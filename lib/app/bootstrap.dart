import 'package:shared_preferences/shared_preferences.dart';

import '../features/recruiter_studio/data/studio_store.dart';
import '../features/recruiter_studio/data/studio_repository.dart';
import '../features/registration/data/api_registration_repository.dart';
import '../features/auth/data/api_auth_repository.dart';
import '../features/recruiter_offers/data/api_recruiter_offers_repository.dart';
import '../features/recruiter_workspace/data/recruiter_workspace_repository.dart';

import 'package:flutter/widgets.dart';

import '../core/config/app_environment.dart';
import '../core/network/api_client.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/fake_auth_repository.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/dashboard/data/fake_dashboard_repository.dart';
import '../features/registration/data/auth_registration_repository.dart';
import '../features/registration/data/mock_registration_repository.dart';
import '../features/registration/data/registration_repository.dart';
import '../features/recruiter_dashboard/data/api_recruiter_dashboard_repository.dart';
import '../features/recruiter_dashboard/data/mock_recruiter_dashboard_repository.dart';
import '../features/recruiter_dashboard/data/recruiter_dashboard_repository.dart';
import '../features/recruiter_candidates/data/api_recruiter_candidate_repository.dart';
import '../features/recruiter_candidates/data/mock_recruiter_candidate_repository.dart';
import '../features/recruiter_candidates/data/recruiter_candidate_repository.dart';
import '../features/recruiter_offers/data/mock_recruiter_offers_repository.dart';
import '../features/recruiter_offers/data/recruiter_offers_repository.dart';
import 'app.dart';

/// Initialise les dépendances partagées puis lance l'expérience demandée.
Future<void> bootstrapJoyn({bool? webOverride}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final deviceStore = DeviceStudioStore(await SharedPreferences.getInstance());
  final environment = AppEnvironment.fromCompileTime()..validate();
  ApiAuthRepository? apiAuth;
  late final AuthController authController;
  final api = environment.useApi
      ? ApiClient(
          baseUrl: environment.apiBaseUrl,
          timeout: environment.apiTimeout,
          tokenProvider: () async => apiAuth?.accessToken,
          onUnauthorized: () {
            apiAuth?.accessToken = null;
            authController.invalidateSession();
          },
        )
      : null;
  final AuthRepository authRepository = api == null
      ? FakeAuthRepository()
      : (apiAuth = ApiAuthRepository(api));
  final DashboardRepository dashboardRepository = FakeDashboardRepository();
  final RecruiterDashboardRepository recruiterDashboardRepository =
      (environment.useApi
      ? ApiRecruiterDashboardRepository(api!)
      : MockRecruiterDashboardRepository());
  final RecruiterOffersRepository recruiterOffersRepository = api == null
      ? MockRecruiterOffersRepository()
      : ApiRecruiterOffersRepository(api);
  final RecruiterCandidateRepository recruiterCandidateRepository =
      (environment.useApi
      ? ApiRecruiterCandidateRepository(api!)
      : MockRecruiterCandidateRepository());
  final RegistrationRepository registrationRepository = api != null
      ? ApiRegistrationRepository(api, apiAuth!)
      : AuthRegistrationRepository(
          authRepository,
          companyLookupRepository: MockRegistrationRepository(),
        );

  authController = AuthController(authRepository);
  await authController.restoreSession();

  runApp(
    JoynApp(
      webOverride: webOverride,
      studioStore: deviceStore,
      studioRepository: LocalStudioRepository(deviceStore),
      workspaceRepository: api == null
          ? MockRecruiterWorkspaceRepository()
          : ApiRecruiterWorkspaceRepository(api),
      authController: authController,
      dashboardRepository: dashboardRepository,
      recruiterDashboardRepository: recruiterDashboardRepository,
      registrationRepository: registrationRepository,
      recruiterOffersRepository: recruiterOffersRepository,
      recruiterCandidateRepository: recruiterCandidateRepository,
    ),
  );
}
