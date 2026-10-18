import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/dashboard/data/dashboard_repository.dart';
import '../../features/dashboard/presentation/dashboard_controller.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import 'app_routes.dart';

/// Crée le routeur de l'application.
///
/// Il écoute [auth] : à chaque connexion / déconnexion, [GoRouter.redirect]
/// est réévalué et l'utilisateur est envoyé au bon endroit.
///
/// [skipLogin] (mode démo) : démarre sur le dashboard et laisse accéder aux
/// pages privées sans être connecté. Voir `AppConfig.skipLogin`.
GoRouter createAppRouter(AuthController auth, {required bool skipLogin}) {
  return GoRouter(
    initialLocation: skipLogin ? AppRoutes.dashboard : AppRoutes.login,
    refreshListenable: auth,
    redirect: (context, state) {
      final isPublicRoute = AppRoutes.public.contains(state.matchedLocation);
      if (!auth.isAuthenticated && !isPublicRoute && !skipLogin) {
        return AppRoutes.login;
      }
      if (auth.isAuthenticated && isPublicRoute) return AppRoutes.afterLogin;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.dashboard,
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      // TODO(inscription): ajouter ici la route de la page d'inscription.
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => ChangeNotifierProvider(
          // Un contrôleur neuf à chaque ouverture : les données sont rechargées.
          create: (context) =>
              DashboardController(context.read<DashboardRepository>())..load(),
          child: const DashboardPage(),
        ),
      ),
    ],
  );
}
