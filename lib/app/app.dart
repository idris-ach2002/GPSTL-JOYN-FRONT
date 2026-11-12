import 'package:flutter/services.dart';

import '../features/recruiter_studio/presentation/studio_search.dart';
import '../features/recruiter_studio/data/studio_store.dart';
import '../features/recruiter_studio/data/studio_repository.dart';
import '../features/recruiter_studio/presentation/studio_controller.dart';
import '../features/auth/domain/user_role.dart';
import '../features/recruiter_workspace/data/recruiter_workspace_repository.dart';
import '../features/recruiter_workspace/presentation/workspace_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/admin_companies/data/admin_company_repository.dart';
import '../features/admin_companies/data/fake_admin_company_repository.dart';
import '../features/admin_users/data/admin_user_repository.dart';
import '../features/admin_users/data/fake_admin_user_repository.dart';
import '../features/admin_verifications/data/fake_verification_repository.dart';
import '../features/admin_verifications/data/verification_repository.dart';
import '../features/auth/data/fake_auth_repository.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/candidate_applications/data/candidate_applications_repository.dart';
import '../features/candidate_applications/data/mock_candidate_applications_repository.dart';
import '../features/candidate_discover/data/mock_recommended_offers_repository.dart';
import '../features/candidate_discover/data/recommended_offers_repository.dart';
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
    this.studioStore,
    this.studioRepository,
    this.workspaceRepository,
    this.authController,
    this.dashboardRepository,
    this.registrationRepository,
    this.profileRepository,
    this.recruiterDashboardRepository,
    this.recruiterOffersRepository,
    this.recruiterCandidateRepository,
    this.recommendedOffersRepository,
    this.candidateApplicationsRepository,
    this.adminCompanyRepository,
    this.adminUserRepository,
    this.verificationRepository,
  });

  final RecruiterWorkspaceRepository? workspaceRepository;
  final StudioStore? studioStore;
  final StudioRepository? studioRepository;
  final bool? webOverride;
  final AuthController? authController;
  final DashboardRepository? dashboardRepository;
  final RegistrationRepository? registrationRepository;
  final ProfileRepository? profileRepository;
  final RecruiterDashboardRepository? recruiterDashboardRepository;
  final RecruiterOffersRepository? recruiterOffersRepository;
  final RecruiterCandidateRepository? recruiterCandidateRepository;
  final RecommendedOffersRepository? recommendedOffersRepository;
  final CandidateApplicationsRepository? candidateApplicationsRepository;
  final AdminCompanyRepository? adminCompanyRepository;
  final AdminUserRepository? adminUserRepository;
  final VerificationRepository? verificationRepository;

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
  late final RecommendedOffersRepository _recommendedOffersRepository;
  late final CandidateApplicationsRepository _candidateApplicationsRepository;
  late final AdminCompanyRepository _adminCompanyRepository;
  late final AdminUserRepository _adminUserRepository;
  late final VerificationRepository _verificationRepository;
  late final GoRouter _router;
  late final StudioController _studio;
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
    // Un seul dépôt de candidatures simulé, partagé avec « Matchs » : une
    // offre glissée à droite apparaît dans la colonne « Intéressé ».
    final mockApplications = MockCandidateApplicationsRepository(
      latency: Duration.zero,
    );
    _candidateApplicationsRepository =
        widget.candidateApplicationsRepository ?? mockApplications;
    _recommendedOffersRepository =
        widget.recommendedOffersRepository ??
        MockRecommendedOffersRepository(
          latency: Duration.zero,
          applications: mockApplications,
        );

    _profileRepository =
        widget.profileRepository ??
        FakeProfileRepository(latency: Duration.zero);
    _adminCompanyRepository =
        widget.adminCompanyRepository ??
        FakeAdminCompanyRepository(latency: Duration.zero);
    _adminUserRepository =
        widget.adminUserRepository ??
        FakeAdminUserRepository(latency: Duration.zero);
    _verificationRepository =
        widget.verificationRepository ??
        FakeVerificationRepository(latency: Duration.zero);

    _studio = StudioController(
      store: widget.studioStore,
      repository: widget.studioRepository,
    )..restoreDevice();

    _studio.bind(
      _authController.user?.role == UserRole.company
          ? _authController.user?.id
          : null,
    );

    _workspaceController = WorkspaceController(
      widget.workspaceRepository ?? MockRecruiterWorkspaceRepository(),
    );
    _lastUserId = _authController.user?.id;
    _authController.addListener(_onAuthChanged);
    _primeWorkspace();
    _router = createAppRouter(_authController, webOverride: widget.webOverride);
  }

  Future<void> _primeWorkspace() async {
    final user = _authController.user;
    if (user?.role != UserRole.company) return;
    if (widget.studioStore != null && _workspaceController.repository.isMock) {
      final repository = PersistentMockWorkspaceRepository(
        widget.studioStore!,
        user!.id,
      );
      try {
        await repository.restore();
      } catch (_) {
        if (mounted) {
          _workspaceController.error =
              'Impossible de restaurer les données de démonstration.';
          _workspaceController.notifyListeners();
        }
        return;
      }
      if (!mounted || _authController.user?.id != user.id) return;
      _workspaceController.repository = repository;
    }
    _workspaceController.load('profile');
    _workspaceController.load('notifications');
    if (!_workspaceController.repository.isMock) return;
    _workspaceController.load('messages');
    _workspaceController.load('settings');
  }

  String? _lastUserId;
  void _onAuthChanged() {
    final id = _authController.user?.id;
    if (id != _lastUserId) {
      _lastUserId = id;
      _studio.bind(_authController.user?.role == UserRole.company ? id : null);
      final workspaceRepository = _workspaceController.repository;
      if (workspaceRepository is ApiRecruiterWorkspaceRepository) {
        workspaceRepository.clearActivityState();
      }
      _workspaceController.reset();
      _primeWorkspace();
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthChanged);
    _workspaceController.dispose();
    _studio.dispose();
    _router.dispose();
    if (_ownsAuthController) _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StudioController>.value(value: _studio),
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
        Provider<RecommendedOffersRepository>.value(
          value: _recommendedOffersRepository,
        ),
        Provider<CandidateApplicationsRepository>.value(
          value: _candidateApplicationsRepository,
        ),
        Provider<AdminCompanyRepository>.value(value: _adminCompanyRepository),
        Provider<AdminUserRepository>.value(value: _adminUserRepository),
        Provider<VerificationRepository>.value(value: _verificationRepository),
      ],
      child: ListenableBuilder(
        // L'auth est écoutée aussi : le thème change à la connexion.
        listenable: Listenable.merge([_studio, _authController]),
        builder: (context, _) => MaterialApp.router(
          title: 'JOYN — Le match avant la candidature',
          debugShowCheckedModeBanner: false,
          theme: RecruiterTheme.build(
            dark: false,
            accent: _studio.accentColor,
            compact: _studio.compact,
            contrast: _studio.highContrast,
          ),
          darkTheme: RecruiterTheme.build(
            dark: true,
            accent: _studio.accentColor,
            compact: _studio.compact,
            contrast: _studio.highContrast,
          ),
          themeMode: themeModeFor(
            _authController.user?.role,
            _studio.themeMode,
          ),
          themeAnimationDuration: _studio.reducedMotion
              ? Duration.zero
              : kThemeAnimationDuration,
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(
                  media.textScaler.scale(1) * _studio.textScale,
                ),
                disableAnimations:
                    media.disableAnimations || _studio.reducedMotion,
              ),
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(
                    LogicalKeyboardKey.keyK,
                    control: true,
                  ): () {
                    if (_authController.user?.role == UserRole.company) {
                      final searchContext = _router
                          .routerDelegate
                          .navigatorKey
                          .currentState
                          ?.overlay
                          ?.context;
                      if (searchContext != null) {
                        studioOpenSearch(searchContext, router: _router);
                      }
                    }
                  },
                  const SingleActivator(
                    LogicalKeyboardKey.keyK,
                    meta: true,
                  ): () {
                    if (_authController.user?.role == UserRole.company) {
                      final searchContext = _router
                          .routerDelegate
                          .navigatorKey
                          .currentState
                          ?.overlay
                          ?.context;
                      if (searchContext != null) {
                        studioOpenSearch(searchContext, router: _router);
                      }
                    }
                  },
                },
                child: child!,
              ),
            );
          },
          routerConfig: _router,
          locale: const Locale('fr', 'FR'),
          supportedLocales: const [Locale('fr', 'FR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ),
    );
  }
}

/// Thème appliqué à l'application.
///
/// Seul l'espace recruteur sait s'afficher en sombre (réglage « Thème » du
/// studio, qui suit le système par défaut). La landing, la connexion,
/// l'inscription et l'espace candidat ne sont conçus qu'en clair : sur un
/// système en mode sombre, ils afficheraient du texte clair sur fond clair.
ThemeMode themeModeFor(UserRole? role, ThemeMode recruiterPreference) =>
    role == UserRole.company ? recruiterPreference : ThemeMode.light;
