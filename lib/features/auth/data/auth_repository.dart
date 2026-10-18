import '../domain/app_user.dart';
import '../domain/user_role.dart';

/// Contrat de l'authentification, indépendant du backend.
///
/// L'interface utilisateur ne dépend QUE de cette interface. Pour brancher la
/// vraie API, il suffit d'écrire une nouvelle implémentation (ex.
/// `ApiAuthRepository`) et de l'injecter dans `main.dart` à la place de
/// `FakeAuthRepository`.
///
/// Règles pour toute implémentation :
/// - en cas d'échec, lever une `AuthException` (jamais une exception brute
///   du client HTTP) ;
/// - gérer elle-même le stockage du jeton de session.
abstract interface class AuthRepository {
  /// Utilisateur de la session en cours (ex. jeton encore valide), sinon `null`.
  Future<AppUser?> currentUser();

  /// Connexion par e-mail / mot de passe.
  ///
  /// [rememberMe] : conserver la session après fermeture de l'application.
  Future<AppUser> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  /// Création d'un compte ; l'utilisateur est connecté en cas de succès.
  Future<AppUser> signUp({
    required String email,
    required String password,
    required UserRole role,
  });

  /// Envoie un e-mail de réinitialisation du mot de passe.
  ///
  /// Ne doit pas indiquer si l'adresse correspond à un compte (sécurité).
  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
