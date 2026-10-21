/// Chemins des routes de l'application (aussi visibles dans l'URL sur le web).
abstract final class AppRoutes {
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';

  /// Racine du site : redirige vers [dashboard] (ou [login] si déconnecté).
  static const String root = '/';

  /// Page affichée après la connexion.
  static const String afterLogin = dashboard;

  /// Routes accessibles sans être connecté.
  /// (Penser à y ajouter la future route d'inscription.)
  static const Set<String> public = {login, forgotPassword};
}
