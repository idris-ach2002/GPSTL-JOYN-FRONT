import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/admin_user.dart';
import '../domain/user_query.dart';
import 'admin_user_repository.dart';

/// Liste des comptes, une rubrique à la fois, avec pagination serveur :
///
/// - Candidats : `GET /api/v1/admin/candidates?page=1&limit=20`
/// - Recruteurs : `GET /api/v1/admin/recruiters?page=1&limit=20`
///
/// Réponse attendue : `{ "data": [...], "pagination": { "page", "limit",
/// "total", "total_pages" } }`.
class ApiAdminUserRepository implements AdminUserRepository {
  ApiAdminUserRepository(this.api);
  final ApiClient api;

  @override
  Future<UserPage> fetchUsers(UserQuery query) async {
    // Le back n'expose pas de liste des administrateurs.
    if (query.role == UserRoleFilter.admin ||
        query.status == UserStatusFilter.banned) {
      return UserPage(
        items: const [],
        total: 0,
        page: query.page,
        pageSize: query.pageSize,
      );
    }
    final isRecruiters = query.role == UserRoleFilter.recruiter;
    final path = isRecruiters
        ? '/api/v1/admin/recruiters'
        : '/api/v1/admin/candidates';
    try {
      final body = _map(
        await api.getJson(
          path,
          query: {
            'page': '${query.page}',
            'limit': '${query.pageSize}',
            if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
            if (query.status.status case final status?)
              'status': status.apiValue.toUpperCase(),
          },
        ),
      );
      final data = body['data'] as List? ?? const [];
      final items = [
        for (final item in data)
          isRecruiters ? _recruiter(_map(item)) : _candidate(_map(item)),
      ];
      // Tri de la page reçue (le back ne propose pas de paramètre de tri).
      items.sort((a, b) {
        final comparison = query.sort.byName
            ? '${a.lastName} ${a.firstName}'.toLowerCase().compareTo(
                '${b.lastName} ${b.firstName}'.toLowerCase(),
              )
            : a.createdAt.compareTo(b.createdAt);
        return query.sort.ascending ? comparison : -comparison;
      });

      final pagination = _map(body['pagination']);
      final limit = _int(pagination['limit'], fallback: query.pageSize);
      final totalPages = _int(pagination['total_pages'], fallback: 1);
      final total = _int(
        pagination['total'],
        fallback: totalPages <= 1 ? items.length : totalPages * limit,
      );
      return UserPage(
        items: items,
        total: total,
        page: _int(pagination['page'], fallback: query.page),
        pageSize: limit,
      );
    } on ApiException catch (error) {
      throw AdminUserException(
        'Liste des comptes indisponible (${error.statusCode ?? 'réseau'}).',
        statusCode: error.statusCode,
      );
    }
  }

  AdminUserAccount _candidate(Map<String, dynamic> j) => AdminUserAccount(
    id: '${j['id']}',
    firstName: '${j['first_name'] ?? ''}',
    lastName: '${j['last_name'] ?? ''}',
    email: '${j['email'] ?? ''}',
    role: AccountRole.candidate,
    status: AccountStatus.fromApi(j['status']?.toString()),
    createdAt: _date(j['created_at']),
    lastLoginAt: _optionalDate(j['last_login_at']),
    emailVerified: j['is_email_verified'] == true,
    avatarUrl: j['avatar_url']?.toString(),
  );

  AdminUserAccount _recruiter(Map<String, dynamic> j) => AdminUserAccount(
    id: '${j['userId'] ?? j['id']}',
    firstName: '${j['firstName'] ?? ''}',
    lastName: '${j['lastName'] ?? ''}',
    email: '${j['email'] ?? ''}',
    role: AccountRole.recruiter,
    status: AccountStatus.fromApi(j['userStatus']?.toString()),
    createdAt: _date(j['createdAt']),
    companyId: j['companyId']?.toString(),
    companyName: j['companyName']?.toString(),
  );

  @override
  Future<AdminUserAccount> updateStatus(
    String id,
    AccountStatus status, {
    String? reason,
  }) async => throw const AdminUserException(
    'Gestion des statuts non disponible dans cette API.',
  );
  @override
  Future<AdminUserAccount> updateRole(String id, AccountRole role) async =>
      throw const AdminUserException(
        'Modification du rôle non disponible dans cette API.',
      );
  @override
  Future<void> deleteUser(String id) async =>
      throw const AdminUserException('Suppression non déployée sur main.');

  Map<String, dynamic> _map(Object? v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
  int _int(Object? v, {int fallback = 0}) =>
      v is num ? v.toInt() : int.tryParse('$v') ?? fallback;
  DateTime _date(Object? raw) =>
      _optionalDate(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? _optionalDate(Object? raw) => DateTime.tryParse('${raw ?? ''}');
}
