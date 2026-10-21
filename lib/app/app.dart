import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/auth/data/fake_auth_repository.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/dashboard/data/fake_dashboard_repository.dart';
import '../features/registration/data/auth_registration_repository.dart';
import '../features/registration/data/mock_registration_repository.dart';
import '../features/registration/data/registration_repository.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

/// Racine unique de JOYN.
///
/// Les dépendances sont injectables pour les tests et pour le branchement futur
/// de la vraie API. Quand elles ne sont pas fournies, l'application installe
/// des implémentations fictives rapides, utiles aux widget tests.
class JoynApp extends StatefulWidget {
  const JoynApp({
    super.key,
    this.webOverride,
    this.authController,
    this.dashboardRepository,
    this.registrationRepository,
  });

  final bool? webOverride;
  final AuthController? authController;
  final DashboardRepository? dashboardRepository;
  final RegistrationRepository? registrationRepository;

  @override
  State<JoynApp> createState() => _JoynAppState();
}

class _JoynAppState extends State<JoynApp> {
  late final AuthController _authController;
  late final DashboardRepository _dashboardRepository;
  late final RegistrationRepository _registrationRepository;
  late final GoRouter _router;
  late final bool _ownsAuthController;

  @override
  void initState() {
    super.initState();

    if (widget.authController != null) {
      _authController = widget.authController!;
      _ownsAuthController = false;
      _registrationRepository =
          widget.registrationRepository ?? MockRegistrationRepository();
    } else {
      final authRepository = FakeAuthRepository(latency: Duration.zero);
      _authController = AuthController(authRepository);
      _ownsAuthController = true;
      _registrationRepository =
          widget.registrationRepository ??
          AuthRegistrationRepository(
            authRepository,
            companyLookupRepository: MockRegistrationRepository(
              latency: Duration.zero,
            ),
          );
    }

    _dashboardRepository =
        widget.dashboardRepository ??
        FakeDashboardRepository(latency: Duration.zero);

    _router = createAppRouter(_authController, webOverride: widget.webOverride);
  }

  @override
  void dispose() {
    _router.dispose();
    if (_ownsAuthController) _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: _authController),
        Provider<DashboardRepository>.value(value: _dashboardRepository),
        Provider<RegistrationRepository>.value(value: _registrationRepository),
      ],
      child: MaterialApp.router(
        title: 'JOYN — Le match avant la candidature',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [Locale('fr', 'FR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
      ),
    );
  }
}
