/// Options choisies au lancement avec `--dart-define=NOM=valeur`.
abstract final class AppConfig {
  /// Mode démo : l'application s'ouvre directement sur le dashboard, sans
  /// passer par la connexion (la page `/login` reste accessible).
  ///
  /// Activation : `flutter run --dart-define=SKIP_LOGIN=true`.
  /// À ne jamais activer en production.
  static const bool skipLogin = bool.fromEnvironment('SKIP_LOGIN');
}
