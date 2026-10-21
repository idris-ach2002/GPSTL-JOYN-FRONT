/// Erreurs d'authentification connues de l'application.
///
/// Toute implémentation de `AuthRepository` doit traduire les erreurs de son
/// backend (codes HTTP, codes Firebase…) vers l'un de ces codes. Ainsi,
/// l'interface n'a jamais à connaître le backend.
enum AuthErrorCode {
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  tooManyRequests,
  network,
  unknown,
}

class AuthException implements Exception {
  const AuthException(this.code);

  final AuthErrorCode code;

  /// Message prêt à être affiché à l'utilisateur.
  String get message => switch (code) {
    AuthErrorCode.invalidCredentials => 'E-mail ou mot de passe incorrect.',
    AuthErrorCode.emailAlreadyInUse =>
      'Un compte existe déjà avec cette adresse e-mail.',
    AuthErrorCode.weakPassword => 'Ce mot de passe est trop faible.',
    AuthErrorCode.tooManyRequests =>
      'Trop de tentatives. Réessaie dans quelques minutes.',
    AuthErrorCode.network =>
      'Impossible de joindre le serveur. Vérifie ta connexion internet.',
    AuthErrorCode.unknown => 'Une erreur est survenue. Réessaie plus tard.',
  };

  @override
  String toString() => 'AuthException($code)';
}
