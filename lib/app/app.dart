import '../features/recruiter_workspace/data/recruiter_workspace_repository.dart';
import '../features/recruiter_workspace/presentation/workspace_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/auth/data/fake_auth_repository.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/dashboard/data/fake_dashboard_repository.dart';
import '../features/profile/data/fake_profile_repository.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/registration/data/auth_registration_repository.dart';
import '../features/recruiter_dashboard/data/mock_recruiter_dashboard_repository.dart';
import '../features/recruiter_dashboard/data/recruiter_dashboard_repository.dart';
import '../features/recruiter_candidates/data/mock_recruiter_candidate_repository.dart';
import '../features/recruiter_candidates/data/recruiter_candidate_repository.dart';
import '../features/registration/data/mock_registration_repository.dart';
import '../features/registration/data/registration_repository.dart';
import '../features/recruiter_offers/data/mock_recruiter_offers_repository.dart';
import '../features/recruiter_offers/data/recruiter_offers_repository.dart';
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
    this.workspaceRepository,
    this.authController,
    this.dashboardRepository,
    this.registrationRepository,
    this.profileRepository,
    this.recruiterDashboardRepository,
    this.recruiterOffersRepository,
    this.recruiterCandidateRepository,
  });

  final RecruiterWorkspaceRepository? workspaceRepository;
  final bool? webOverride;
  final AuthController? authController;
  final DashboardRepository? dashboardRepository;
  final RegistrationRepository? registrationRepository;
  final ProfileRepository? profileRepository;
  final RecruiterDashboardRepository? recruiterDashboardRepository;
  final RecruiterOffersRepository? recruiterOffersRepository;
  final RecruiterCandidateRepository? recruiterCandidateRepository;

  @override
  State<JoynApp> createState() => _JoynAppState();
}

class _JoynAppState extends State<JoynApp> {
  late final AuthController _authController;
  late final DashboardRepository _dashboardRepository;
  late final RegistrationRepository _registrationRepository;
  late final ProfileRepository _profileRepository;
  late final RecruiterDashboardRepository _recruiterDashboardRepository;
  late final RecruiterOffersRepository _recruiterOffersRepository;
  late final RecruiterCandidateRepository _recruiterCandidateRepository;
  late final GoRouter _router;
  late final WorkspaceController _workspaceController;
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
    _recruiterDashboardRepository =
        widget.recruiterDashboardRepository ??
        MockRecruiterDashboardRepository(latency: Duration.zero);
    _recruiterOffersRepository =
        widget.recruiterOffersRepository ??
        MockRecruiterOffersRepository(latency: Duration.zero);
    _recruiterCandidateRepository =
        widget.recruiterCandidateRepository ??
        MockRecruiterCandidateRepository(latency: Duration.zero);

    _profileRepository =
        widget.profileRepository ??
        FakeProfileRepository(latency: Duration.zero);

    _workspaceController = WorkspaceController(
      widget.workspaceRepository ?? MockRecruiterWorkspaceRepository(),
    );
    _lastUserId = _authController.user?.id;
    _authController.addListener(_onAuthChanged);
    _router = createAppRouter(_authController, webOverride: widget.webOverride);
  }

  String? _lastUserId;
  void _onAuthChanged() {
    final id = _authController.user?.id;
    if (id != _lastUserId) {
      _lastUserId = id;
      _workspaceController.reset();
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthChanged);
    _workspaceController.dispose();
    _router.dispose();
    if (_ownsAuthController) _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WorkspaceController>.value(
          value: _workspaceController,
        ),
        ChangeNotifierProvider<AuthController>.value(value: _authController),
        Provider<DashboardRepository>.value(value: _dashboardRepository),
        Provider<RegistrationRepository>.value(value: _registrationRepository),
        Provider<ProfileRepository>.value(value: _profileRepository),
        Provider<RecruiterDashboardRepository>.value(
          value: _recruiterDashboardRepository,
        ),
        Provider<RecruiterOffersRepository>.value(
          value: _recruiterOffersRepository,
        ),
        Provider<RecruiterCandidateRepository>.value(
          value: _recruiterCandidateRepository,
        ),
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
