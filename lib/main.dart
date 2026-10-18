import 'package:flutter/material.dart';

import 'app.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/fake_auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/dashboard/data/dashboard_repository.dart';
import 'features/dashboard/data/fake_dashboard_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Point unique de branchement du backend : pour utiliser la vraie API,
  // remplacer chaque Fake…Repository par une implémentation du contrat
  // correspondant qui appelle le serveur.
  final AuthRepository authRepository = FakeAuthRepository();
  final DashboardRepository dashboardRepository = FakeDashboardRepository();

  final authController = AuthController(authRepository);
  await authController.restoreSession();

  runApp(
    JoynApp(
      authController: authController,
      dashboardRepository: dashboardRepository,
    ),
  );
}
