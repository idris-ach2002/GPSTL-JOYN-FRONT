import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/user_role.dart';

/// État de l'authentification, partagé dans toute l'application via Provider.
///
/// Les écrans lisent [user], [isLoading] et [errorMessage], et appellent les
/// méthodes ci-dessous. Le routeur écoute ce contrôleur pour rediriger
/// automatiquement vers l'accueil ou la connexion.
class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  /// Dernière erreur à afficher (en français), ou `null`.
  String? get errorMessage => _errorMessage;

  /// À appeler au démarrage pour reprendre une session existante.
  Future<void> restoreSession() async {
    _user = await _repository.currentUser();
    notifyListeners();
  }

  /// Retourne `true` en cas de succès.
  Future<bool> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) {
    return _run(() async {
      _user = await _repository.signIn(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
    });
  }

  /// Retourne `true` en cas de succès.
  Future<bool> signUp({
    required String email,
    required String password,
    required UserRole role,
  }) {
    return _run(() async {
      _user = await _repository.signUp(
        email: email,
        password: password,
        role: role,
      );
    });
  }

  /// Retourne `true` si la demande a bien été envoyée.
  Future<bool> sendPasswordReset(String email) {
    return _run(() => _repository.sendPasswordResetEmail(email));
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    notifyListeners();
  }

  /// Efface l'erreur affichée (ex. en changeant d'écran).
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Exécute [action] en gérant le chargement et la traduction des erreurs.
  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      debugPrint('Erreur inattendue pendant l’authentification : $e');
      _errorMessage = const AuthException(AuthErrorCode.unknown).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
