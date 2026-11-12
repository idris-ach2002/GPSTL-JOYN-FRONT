import 'package:flutter/foundation.dart';

import 'admin_user.dart';

/// Filtre de rôle (`null` = tous).
enum UserRoleFilter {
  all('Tous les rôles', null),
  candidate('Candidats', AccountRole.candidate),
  recruiter('Recruteurs', AccountRole.recruiter),
  admin('Admins', AccountRole.admin);

  const UserRoleFilter(this.label, this.role);

  final String label;
  final AccountRole? role;
}

/// Filtre de statut (`null` = tous).
enum UserStatusFilter {
  all('Tous les statuts', null),
  active('Actifs', AccountStatus.active),
  suspended('Suspendus', AccountStatus.suspended),
  banned('Bannis', AccountStatus.banned);

  const UserStatusFilter(this.label, this.status);

  final String label;
  final AccountStatus? status;
}

/// Tri de la liste : par date d'inscription (`created_at`) ou par nom.
enum UserSort {
  newest('Inscription récente', 'created_at', 'desc'),
  oldest('Inscription ancienne', 'created_at', 'asc'),
  nameAsc('Nom A → Z', 'name', 'asc'),
  nameDesc('Nom Z → A', 'name', 'desc');

  const UserSort(this.label, this.field, this.direction);

  final String label;
  final String field;
  final String direction;

  bool get byName => field == 'name';
  bool get ascending => direction == 'asc';

  /// Valeur courte utilisée dans l'URL : `created_at.desc`, `name.asc`…
  String get urlValue => '$field.$direction';
}

/// Paramètres d'une page de résultats.
///
/// Ils sont recopiés dans l'URL (`?page=2&q=emma&role=recruiter…`) : un
/// rafraîchissement ou un lien partagé retrouve la même vue.
@immutable
class UserQuery {
  const UserQuery({
    this.page = 1,
    this.pageSize = defaultPageSize,
    this.search = '',
    this.role = UserRoleFilter.all,
    this.status = UserStatusFilter.all,
    this.sort = UserSort.newest,
  });

  static const int defaultPageSize = 20;

  final int page;
  final int pageSize;

  /// Recherche plein texte (prénom, nom, e-mail).
  final String search;
  final UserRoleFilter role;
  final UserStatusFilter status;
  final UserSort sort;

  bool get hasFilters =>
      search.trim().isNotEmpty ||
      role != UserRoleFilter.all ||
      status != UserStatusFilter.all;

  UserQuery copyWith({
    int? page,
    String? search,
    UserRoleFilter? role,
    UserStatusFilter? status,
    UserSort? sort,
  }) {
    return UserQuery(
      page: page ?? this.page,
      pageSize: pageSize,
      search: search ?? this.search,
      role: role ?? this.role,
      status: status ?? this.status,
      sort: sort ?? this.sort,
    );
  }

  /// Paramètres d'URL ; les valeurs par défaut sont omises.
  Map<String, String> toQueryParameters() => {
    if (page > 1) 'page': '$page',
    if (search.trim().isNotEmpty) 'q': search.trim(),
    if (role.role case final accountRole?) 'role': accountRole.apiValue,
    if (status.status case final accountStatus?)
      'status': accountStatus.apiValue,
    if (sort != UserSort.newest) 'sort': sort.urlValue,
  };

  /// Lecture tolérante des paramètres d'URL (valeurs inconnues ignorées).
  factory UserQuery.fromQueryParameters(Map<String, String> params) {
    final page = int.tryParse(params['page'] ?? '') ?? 1;
    return UserQuery(
      page: page < 1 ? 1 : page,
      search: params['q'] ?? '',
      role: UserRoleFilter.values.firstWhere(
        (filter) => filter.role?.apiValue == params['role'],
        orElse: () => UserRoleFilter.all,
      ),
      status: UserStatusFilter.values.firstWhere(
        (filter) => filter.status?.apiValue == params['status'],
        orElse: () => UserStatusFilter.all,
      ),
      sort: UserSort.values.firstWhere(
        (sort) => sort.urlValue == params['sort'],
        orElse: () => UserSort.newest,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserQuery &&
      other.page == page &&
      other.pageSize == pageSize &&
      other.search.trim() == search.trim() &&
      other.role == role &&
      other.status == status &&
      other.sort == sort;

  @override
  int get hashCode =>
      Object.hash(page, pageSize, search.trim(), role, status, sort);
}

/// Une page de résultats renvoyée par le serveur.
@immutable
class UserPage {
  const UserPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<AdminUserAccount> items;
  final int total;
  final int page;
  final int pageSize;

  int get totalPages => total == 0 ? 1 : (total / pageSize).ceil();
  int get firstIndex => items.isEmpty ? 0 : (page - 1) * pageSize + 1;
  int get lastIndex => items.isEmpty ? 0 : firstIndex + items.length - 1;
}
