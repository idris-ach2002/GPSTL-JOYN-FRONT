import 'package:flutter/widgets.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/fake_auth_repository.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/dashboard/data/fake_dashboard_repository.dart';
import '../features/registration/data/auth_registration_repository.dart';
import '../features/registration/data/mock_registration_repository.dart';
import '../features/registration/data/registration_repository.dart';
import '../features/recruiter_offers/data/mock_recruiter_offers_repository.dart';
import '../features/recruiter_offers/data/recruiter_offers_repository.dart';
import 'app.dart';

/// Initialise les dépendances partagées puis lance l'expérience demandée.
Future<void> bootstrapJoyn({bool? webOverride}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthRepository authRepository = FakeAuthRepository();
  final DashboardRepository dashboardRepository = FakeDashboardRepository();
  final RecruiterOffersRepository recruiterOffersRepository =
      MockRecruiterOffersRepository();
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
      registrationRepository: registrationRepository,
      recruiterOffersRepository: recruiterOffersRepository,
    ),
  );
}
