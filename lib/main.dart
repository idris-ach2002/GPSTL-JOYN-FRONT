import 'package:flutter/material.dart';

import 'app/app.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/fake_auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/dashboard/data/dashboard_repository.dart';
import 'features/dashboard/data/fake_dashboard_repository.dart';
import 'features/registration/data/auth_registration_repository.dart';
import 'features/registration/data/mock_registration_repository.dart';
import 'features/registration/data/registration_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Point unique de remplacement par le backend réel.
  final AuthRepository authRepository = FakeAuthRepository();
  final DashboardRepository dashboardRepository = FakeDashboardRepository();
  final RegistrationRepository registrationRepository =
      AuthRegistrationRepository(
        authRepository,
        companyLookupRepository: MockRegistrationRepository(),
      );

  final authController = AuthController(authRepository);
  await authController.restoreSession();

  runApp(
    JoynApp(
      authController: authController,
      dashboardRepository: dashboardRepository,
      registrationRepository: registrationRepository,
    ),
  );
}
