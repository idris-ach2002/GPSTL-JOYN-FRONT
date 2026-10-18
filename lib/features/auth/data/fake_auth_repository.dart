import '../domain/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/user_role.dart';
import 'auth_repository.dart';

/// Implémentation SIMULÉE de [AuthRepository], en attendant le backend.
///
/// - Comptes stockés en mémoire (perdus au redémarrage).
/// - Délai artificiel pour simuler le réseau (états de chargement visibles).
///
/// Comptes de démonstration (mot de passe `Joyn2026`) :
/// - `etudiant@joyn.fr` (profil étudiant)
/// - `recruteur@joyn.fr` (profil entreprise)
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.latency = const Duration(milliseconds: 800)});

  /// Délai simulé de chaque appel (mettre `Duration.zero` dans les tests).
  final Duration latency;

  static const String demoPassword = 'Joyn2026';

  final Map<String, _FakeAccount> _accounts = {
    'etudiant@joyn.fr': const _FakeAccount(
      password: demoPassword,
      user: AppUser(
        id: 'demo-student',
        email: 'etudiant@joyn.fr',
        role: UserRole.student,
      ),
    ),
    'recruteur@joyn.fr': const _FakeAccount(
      password: demoPassword,
      user: AppUser(
        id: 'demo-company',
        email: 'recruteur@joyn.fr',
        role: UserRole.company,
      ),
    ),
  };

  AppUser? _currentUser;
  int _nextId = 1;

  Future<void> _simulateNetwork() => Future<void>.delayed(latency);

  @override
  Future<AppUser?> currentUser() async => _currentUser;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    await _simulateNetwork();
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthException(AuthErrorCode.invalidCredentials);
    }
    // [rememberMe] est ignoré : la session simulée n'est jamais persistée.
    return _currentUser = account.user;
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await _simulateNetwork();
    final normalizedEmail = email.trim().toLowerCase();
    if (_accounts.containsKey(normalizedEmail)) {
      throw const AuthException(AuthErrorCode.emailAlreadyInUse);
    }
    final user = AppUser(
      id: 'fake-${_nextId++}',
      email: normalizedEmail,
      role: role,
    );
    _accounts[normalizedEmail] = _FakeAccount(password: password, user: user);
    return _currentUser = user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Aucun e-mail n'est réellement envoyé.
    await _simulateNetwork();
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}

class _FakeAccount {
  const _FakeAccount({required this.password, required this.user});

  final String password;
  final AppUser user;
}
