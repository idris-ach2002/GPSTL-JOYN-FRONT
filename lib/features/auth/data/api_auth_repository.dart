import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/user_role.dart';
import 'auth_repository.dart';

/// Jeton en mémoire uniquement. Aucun secret n'est écrit dans l'environnement.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this.api);
  final ApiClient api;
  String? accessToken;
  AppUser? _user;
  @override
  Future<AppUser?> currentUser() async => _user;
  Map<String, dynamic> _object(Object? value) {
    if (value is! Map) throw const AuthException(AuthErrorCode.unknown);
    return Map<String, dynamic>.from(
      value['data'] is Map ? value['data'] as Map : value,
    );
  }

  AppUser _mapUser(Object? value) {
    final data = _object(value);
    final role = '${data['role']}'.toUpperCase();
    if (!['COMPANY', 'RECRUITER', 'STUDENT', 'CANDIDATE'].contains(role) ||
        data['id'] == null ||
        data['email'] == null) {
      throw const AuthException(AuthErrorCode.unknown);
    }
    return AppUser(
      id: '${data['id']}',
      email: '${data['email']}',
      role: ['COMPANY', 'RECRUITER'].contains(role)
          ? UserRole.company
          : UserRole.student,
    );
  }

  Future<AppUser> _authenticate(String path, Map<String, dynamic> body) async {
    try {
      final data = _object(await api.postJson(path, body: body));
      final token = data['accessToken'] ?? data['access_token'];
      if (token is! String || token.isEmpty)
        throw const AuthException(AuthErrorCode.unknown);
      final user = _mapUser(data['user']);
      accessToken = token;
      _user = user;
      return user;
    } on ApiException catch (e) {
      throw AuthException(switch (e.statusCode) {
        401 || 403 => AuthErrorCode.invalidCredentials,
        409 => AuthErrorCode.emailAlreadyInUse,
        429 => AuthErrorCode.tooManyRequests,
        null => AuthErrorCode.network,
        _ => AuthErrorCode.unknown,
      });
    }
  }

  Future<AppUser> register(Map<String, dynamic> body) =>
      _authenticate('/api/v1/auth/register', body);

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) => _authenticate('/api/v1/auth/login', {
    'email': email.trim(),
    'password': password,
  });
  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required UserRole role,
  }) => _authenticate('/api/v1/auth/register', {
    'email': email.trim(),
    'password': password,
    'role': role == UserRole.company ? 'COMPANY' : 'STUDENT',
  });
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await api.postJson(
        '/api/v1/auth/forgot-password',
        body: {'email': email.trim()},
      );
    } on ApiException {
      throw const AuthException(AuthErrorCode.network);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await api.postJson('/api/v1/auth/logout');
    } finally {
      accessToken = null;
      _user = null;
    }
  }
}
