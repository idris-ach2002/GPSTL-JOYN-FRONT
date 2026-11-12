import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/admin_user.dart';
import '../domain/user_query.dart';
import 'admin_user_repository.dart';

/// Joins the two read-only admin lists. The backend does not expose /admin/users.
class ApiAdminUserRepository implements AdminUserRepository {
  ApiAdminUserRepository(this.api);
  final ApiClient api;

  @override
  Future<UserPage> fetchUsers(UserQuery query) async {
    try {
      final roles = query.role == UserRoleFilter.candidate
          ? ['candidates'] : query.role == UserRoleFilter.recruiter
              ? ['recruiters'] : ['candidates', 'recruiters'];
      // The backend does not expose a GET list of administrators.
      if (query.role == UserRoleFilter.admin) {
        return UserPage(items: const [], total: 0,
          page: query.page, pageSize: query.pageSize);
      }
      final entries = <AdminUserAccount>[];
      for (final role in roles) {
        for (var page = 1; page <= 20; page++) {
          final body = _map(await api.getJson('/api/v1/admin/$role', query: {
            'page': '$page', 'limit': '100',
            if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
            if (query.status != UserStatusFilter.all &&
                query.status.status != AccountStatus.banned)
              'status': query.status.status!.apiValue.toUpperCase(),
          }));
          final data = body['data'] as List? ?? const [];
          entries.addAll([for (final item in data)
            role == 'candidates' ? _candidate(_map(item)) : _recruiter(_map(item))]);
          final pagination = _map(body['pagination']);
          if (page >= _int(pagination['total_pages'], fallback: 1) || data.isEmpty) break;
        }
      }
      if (query.status == UserStatusFilter.banned) entries.clear();
      if (query.sort.byName) {
        entries.sort((a,b) => a.lastName.compareTo(b.lastName) *
          (query.sort.ascending ? 1 : -1));
      } else {
        entries.sort((a,b) => a.createdAt.compareTo(b.createdAt) *
          (query.sort.ascending ? 1 : -1));
      }
      final begin = (query.page - 1) * query.pageSize;
      return UserPage(
        items: begin >= entries.length ? const [] : entries.skip(begin).take(query.pageSize).toList(),
        total: entries.length, page: query.page, pageSize: query.pageSize,
      );
    } on ApiException catch (error) {
      throw AdminUserException('Liste des comptes indisponible (${error.statusCode ?? 'réseau'}).',
        statusCode: error.statusCode);
    }
  }

  AdminUserAccount _candidate(Map<String, dynamic> j) => AdminUserAccount(
    id: '${j['id']}', firstName: '${j['first_name'] ?? ''}',
    lastName: '${j['last_name'] ?? ''}', email: '${j['email'] ?? ''}',
    role: AccountRole.candidate,
    status: AccountStatus.fromApi(j['status']?.toString()),
    createdAt: _date(j['created_at']),
    lastLoginAt: _optionalDate(j['last_login_at']),
    emailVerified: j['is_email_verified'] == true,
    avatarUrl: j['avatar_url']?.toString(),
  );

  AdminUserAccount _recruiter(Map<String, dynamic> j) => AdminUserAccount(
    id: '${j['userId'] ?? j['id']}', firstName: '${j['firstName'] ?? ''}',
    lastName: '${j['lastName'] ?? ''}', email: '${j['email'] ?? ''}',
    role: AccountRole.recruiter,
    status: AccountStatus.fromApi(j['userStatus']?.toString()),
    createdAt: _date(j['createdAt']),
    companyId: j['companyId']?.toString(),
    companyName: j['companyName']?.toString(),
  );

  @override
  Future<AdminUserAccount> updateStatus(String id, AccountStatus status, {String? reason}) async =>
      throw const AdminUserException('Gestion des statuts non disponible dans cette API.');
  @override
  Future<AdminUserAccount> updateRole(String id, AccountRole role) async =>
      throw const AdminUserException('Modification du rôle non disponible dans cette API.');
  @override
  Future<AdminUserAccount> inviteAdmin({required String firstName,
      required String lastName, required String email}) async =>
      throw const AdminUserException('Création admin réservée à l’équipe backend.');
  @override
  Future<void> deleteUser(String id) async =>
      throw const AdminUserException('Suppression non déployée sur main.');

  Map<String,dynamic> _map(Object? v) =>
      v is Map ? Map<String,dynamic>.from(v) : <String,dynamic>{};
  int _int(Object? v, {int fallback = 0}) =>
      v is num ? v.toInt() : int.tryParse('$v') ?? fallback;
  DateTime _date(Object? raw) => _optionalDate(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? _optionalDate(Object? raw) => DateTime.tryParse('${raw ?? ''}');
}
