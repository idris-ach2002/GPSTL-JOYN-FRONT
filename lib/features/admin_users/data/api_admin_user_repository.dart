import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/admin_user.dart';
import '../domain/user_query.dart';
import 'admin_user_repository.dart';

/// Implémentation de [AdminUserRepository] branchée sur l'API.
///
/// Format attendu de `GET /api/v1/admin/users` :
/// `{ "items": [...], "total": 4820, "page": 1, "pageSize": 20 }`.
class ApiAdminUserRepository implements AdminUserRepository {
  ApiAdminUserRepository(this._api);

  final ApiClient _api;

  static const String _basePath = '/api/v1/admin/users';

  @override
  Future<UserPage> fetchUsers(UserQuery query) => _guard(() async {
    final json = _object(
      await _api.getJson(
        _basePath,
        query: {
          'page': '${query.page}',
          'pageSize': '${query.pageSize}',
          'search': query.search.trim(),
          'role': query.role.role?.apiValue,
          'status': query.status.status?.apiValue,
          'sort': query.sort.field,
          'order': query.sort.direction,
        },
      ),
    );
    final items = (json['items'] as List<Object?>? ?? const [])
        .map((item) => _user(_object(item)))
        .toList();
    return UserPage(
      items: items,
      total: (json['total'] as num?)?.toInt() ?? items.length,
      page: (json['page'] as num?)?.toInt() ?? query.page,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? query.pageSize,
    );
  });

  @override
  Future<AdminUserAccount> updateStatus(
    String id,
    AccountStatus status, {
    String? reason,
  }) => _guard(() async {
    final json = await _api.patchJson(
      '$_basePath/$id/status',
      body: {
        'status': status.apiValue,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return _user(_object(json));
  });

  @override
  Future<AdminUserAccount> updateRole(String id, AccountRole role) =>
      _guard(() async {
        final json = await _api.patchJson(
          '$_basePath/$id/role',
          body: {'role': role.apiValue},
        );
        return _user(_object(json));
      });

  @override
  Future<AdminUserAccount> inviteAdmin({
    required String firstName,
    required String lastName,
    required String email,
  }) => _guard(() async {
    final json = await _api.postJson(
      _basePath,
      body: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim().toLowerCase(),
        'role': AccountRole.admin.apiValue,
        'sendInvitation': true,
      },
    );
    return _user(_object(json));
  });

  @override
  Future<void> deleteUser(String id) =>
      _guard(() => _api.deleteJson('$_basePath/$id'));

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (error) {
      throw AdminUserException(switch (error.statusCode) {
        401 => 'Ta session a expiré. Reconnecte-toi.',
        403 => 'Accès refusé : cette page est réservée aux administrateurs.',
        404 => 'Ce compte n’existe plus.',
        409 => 'Un compte existe déjà avec cette adresse e-mail.',
        422 => 'Certaines informations sont invalides.',
        _ => 'Le serveur ne répond pas. Réessaie dans un instant.',
      }, statusCode: error.statusCode);
    }
  }

  Map<String, Object?> _object(Object? value) {
    if (value case final Map<String, dynamic> map) return map;
    if (value case final Map<Object?, Object?> map) {
      return map.map((key, value) => MapEntry('$key', value));
    }
    throw const AdminUserException('Réponse inattendue du serveur.');
  }

  AdminUserAccount _user(Map<String, Object?> json) {
    final company = json['company'];
    final companyJson = company == null ? null : _object(company);
    final history = (json['moderationHistory'] as List<Object?>? ?? const [])
        .map((entry) => _object(entry))
        .map(
          (entry) => ModerationEntry(
            kind: ModerationKind.values.firstWhere(
              (kind) => kind.name == entry['kind'],
              orElse: () => ModerationKind.suspended,
            ),
            date:
                DateTime.tryParse(entry['date'] as String? ?? '') ??
                DateTime.now(),
            author: entry['author'] as String? ?? '',
            reason: entry['reason'] as String? ?? '',
          ),
        )
        .toList();
    return AdminUserAccount(
      id: '${json['id']}',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: AccountRole.fromApi(json['role'] as String?),
      status: AccountStatus.fromApi(json['status'] as String?),
      emailVerified: json['emailVerified'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      companyId: companyJson?['id']?.toString(),
      companyName: companyJson?['name'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      lastLoginAt: DateTime.tryParse(json['lastLoginAt'] as String? ?? ''),
      applicationsCount: (json['applicationsCount'] as num?)?.toInt() ?? 0,
      offersCount: (json['offersCount'] as num?)?.toInt() ?? 0,
      moderationHistory: history,
    );
  }
}
