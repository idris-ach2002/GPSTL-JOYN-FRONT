import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/dashboard/data/dashboard_repository.dart';

/// Widget racine : thème, langue, routeur et état global.
class JoynApp extends StatefulWidget {
  const JoynApp({
    super.key,
    required this.authController,
    required this.dashboardRepository,
    this.skipLogin = AppConfig.skipLogin,
  });

  final AuthController authController;
  final DashboardRepository dashboardRepository;

  /// Mode démo : démarrer sur le dashboard sans se connecter.
  final bool skipLogin;

  @override
  State<JoynApp> createState() => _JoynAppState();
}

class _JoynAppState extends State<JoynApp> {
  // Créé une seule fois, pour ne pas perdre la navigation à chaque rebuild.
  late final GoRouter _router = createAppRouter(
    widget.authController,
    skipLogin: widget.skipLogin,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(
          value: widget.authController,
        ),
        Provider<DashboardRepository>.value(value: widget.dashboardRepository),
      ],
      child: MaterialApp.router(
        title: 'Joyn',
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
