import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/admin_user_repository.dart';
import '../../domain/admin_user.dart';
import '../../domain/admin_user_options.dart';
import '../../domain/user_query.dart';

enum AdminUsersStatus { loading, ready, error, forbidden }

/// Résultat d'une action : message de la notification et succès ou échec.
@immutable
class UserActionResult {
  const UserActionResult.success(this.message) : succeeded = true;
  const UserActionResult.failure(this.message) : succeeded = false;

  final String message;
  final bool succeeded;
}

/// État de la page « Utilisateurs » de l'administration.
///
/// La requête ([query]) est le reflet des paramètres de l'URL : chaque
/// changement est signalé via [onQueryChanged] pour mettre l'URL à jour, et
/// [syncWithUrl] applique l'URL au chargement ou après un retour arrière.
class AdminUsersController extends ChangeNotifier {
  AdminUsersController(
    this._repository, {
    required this.currentUserId,
    this.searchDebounce = AdminUserOptions.searchDebounce,
  });

  final AdminUserRepository _repository;

  /// Identifiant de l'administrateur connecté (protection anti auto-sanction).
  final String? currentUserId;

  /// Délai de la recherche pendant la saisie (debounce).
  final Duration searchDebounce;

  /// Appelé quand la requête change, pour la recopier dans l'URL.
  ValueChanged<UserQuery>? onQueryChanged;

  UserQuery _query = const UserQuery();
  UserPage? _page;
  AdminUsersStatus _status = AdminUsersStatus.loading;
  bool _refreshing = false;
  bool _inviting = false;
  bool _loadedOnce = false;
  String? _error;
  final Set<String> _busyIds = {};
  Timer? _debounce;
  int _requestId = 0;
  bool _disposed = false;

  // ---------------------------------------------------------------------------
  // Lecture
  // ---------------------------------------------------------------------------

  UserQuery get query => _query;
  UserPage? get page => _page;
  List<AdminUserAccount> get users => _page?.items ?? const [];
  AdminUsersStatus get status => _status;
  String? get error => _error;
  bool get showSkeleton => _status == AdminUsersStatus.loading;
  bool get isRefreshing => _refreshing;
  bool isBusy(String id) => _busyIds.contains(id);

  /// Une invitation d'administrateur est en cours d'envoi.
  bool get isInviting => _inviting;

  /// Le compte affiché est celui de l'administrateur connecté.
  bool isSelf(AdminUserAccount user) =>
      currentUserId != null && user.id == currentUserId;

  // ---------------------------------------------------------------------------
  // Chargement et synchronisation avec l'URL
  // ---------------------------------------------------------------------------

  /// Applique la requête lue dans l'URL (chargement, rafraîchissement,
  /// bouton « retour »). Ne recharge que si elle a changé.
  void syncWithUrl(UserQuery urlQuery) {
    if (_loadedOnce && urlQuery == _query) return;
    _debounce?.cancel();
    _query = urlQuery;
    load();
  }

  Future<void> load({bool showSkeleton = true}) async {
    _loadedOnce = true;
    final requestId = ++_requestId;
    if (showSkeleton) {
      _status = AdminUsersStatus.loading;
    } else {
      _refreshing = true;
    }
    _error = null;
    _notify();

    try {
      final page = await _repository.fetchUsers(_query);
      if (requestId != _requestId) return;
      if (page.items.isEmpty && page.page > 1 && page.total > 0) {
        _setQuery(_query.copyWith(page: page.totalPages), showSkeleton);
        return;
      }
      _page = page;
      _status = AdminUsersStatus.ready;
    } on AdminUserException catch (error) {
      if (requestId != _requestId) return;
      _error = error.message;
      _status = error.isForbidden
          ? AdminUsersStatus.forbidden
          : AdminUsersStatus.error;
    } catch (_) {
      if (requestId != _requestId) return;
      _error = 'Impossible de charger les utilisateurs. Réessaie.';
      _status = AdminUsersStatus.error;
    }
    _refreshing = false;
    _notify();
  }

  void _setQuery(UserQuery query, [bool showSkeleton = true]) {
    _query = query;
    onQueryChanged?.call(query);
    load(showSkeleton: showSkeleton);
  }

  // ---------------------------------------------------------------------------
  // Recherche, filtres, tri, pagination
  // ---------------------------------------------------------------------------

  /// Recherche sur le prénom, le nom et l'e-mail, lancée après 300 ms sans
  /// frappe.
  void setSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(searchDebounce, () {
      if (text.trim() == _query.search.trim()) return;
      _setQuery(_query.copyWith(search: text.trim(), page: 1));
    });
  }

  void setRoleFilter(UserRoleFilter role) {
    if (role == _query.role) return;
    _setQuery(_query.copyWith(role: role, page: 1));
  }

  void setStatusFilter(UserStatusFilter status) {
    if (status == _query.status) return;
    _setQuery(_query.copyWith(status: status, page: 1));
  }

  void setSort(UserSort sort) {
    if (sort == _query.sort) return;
    _setQuery(_query.copyWith(sort: sort, page: 1));
  }

  void goToPage(int page) {
    final target = page.clamp(1, _page?.totalPages ?? 1).toInt();
    if (target == _query.page) return;
    _setQuery(_query.copyWith(page: target));
  }

  /// Remet recherche, rôle et statut à zéro (le tri est conservé).
  void resetFilters() {
    _debounce?.cancel();
    _setQuery(UserQuery(sort: _query.sort));
  }

  // ---------------------------------------------------------------------------
  // Modération
  // ---------------------------------------------------------------------------

  Future<UserActionResult> suspend(AdminUserAccount user, String reason) {
    if (isSelf(user)) return _selfBlocked('suspendre');
    return _run(
      user,
      () => _repository.updateStatus(
        user.id,
        AccountStatus.suspended,
        reason: reason,
      ),
      '${user.fullName} est suspendu·e.',
    );
  }

  Future<UserActionResult> ban(AdminUserAccount user, String reason) {
    if (isSelf(user)) return _selfBlocked('bannir');
    return _run(
      user,
      () => _repository.updateStatus(
        user.id,
        AccountStatus.banned,
        reason: reason,
      ),
      '${user.fullName} est banni·e.',
    );
  }

  Future<UserActionResult> reactivate(AdminUserAccount user) => _run(
    user,
    () => _repository.updateStatus(user.id, AccountStatus.active),
    'Le compte de ${user.fullName} est réactivé.',
  );

  Future<UserActionResult> changeRole(AdminUserAccount user, AccountRole role) {
    if (isSelf(user) && role != AccountRole.admin) {
      return _selfBlocked('retirer vos droits d’administration');
    }
    if (role == user.role) {
      return Future.value(
        const UserActionResult.failure('Ce compte a déjà ce rôle.'),
      );
    }
    return _run(
      user,
      () => _repository.updateRole(user.id, role),
      '${user.fullName} est maintenant ${role.label.toLowerCase()}.',
    );
  }

  /// Invite un nouvel administrateur (compte « En attente » jusqu'à sa
  /// première connexion).
  Future<UserActionResult> inviteAdmin({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    if (_inviting) {
      return const UserActionResult.failure('Invitation déjà en cours.');
    }
    _inviting = true;
    _notify();
    try {
      final user = await _repository.inviteAdmin(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      await load(showSkeleton: false);
      return UserActionResult.success(
        'Invitation envoyée à ${user.email}. Le compte admin est en attente.',
      );
    } on AdminUserException catch (error) {
      if (error.isForbidden) {
        _status = AdminUsersStatus.forbidden;
        _error = error.message;
      }
      return UserActionResult.failure(error.message);
    } catch (_) {
      return const UserActionResult.failure(
        'L’invitation a échoué. Réessaie dans un instant.',
      );
    } finally {
      _inviting = false;
      _notify();
    }
  }

  /// Suppression logique avec anonymisation RGPD.
  Future<UserActionResult> delete(AdminUserAccount user) {
    if (isSelf(user)) return _selfBlocked('supprimer');
    return _run(user, () async {
      await _repository.deleteUser(user.id);
      return user;
    }, 'Le compte de ${user.fullName} a été supprimé et anonymisé.');
  }

  Future<UserActionResult> _selfBlocked(String action) => Future.value(
    UserActionResult.failure(
      'Vous ne pouvez pas $action votre propre compte depuis cette vue.',
    ),
  );

  Future<UserActionResult> _run(
    AdminUserAccount user,
    Future<AdminUserAccount> Function() action,
    String successMessage,
  ) async {
    if (_busyIds.contains(user.id)) {
      return const UserActionResult.failure('Action déjà en cours.');
    }
    _busyIds.add(user.id);
    _notify();
    try {
      await action();
      await load(showSkeleton: false);
      return UserActionResult.success(successMessage);
    } on AdminUserException catch (error) {
      if (error.isForbidden) {
        _status = AdminUsersStatus.forbidden;
        _error = error.message;
      }
      return UserActionResult.failure(error.message);
    } catch (_) {
      return const UserActionResult.failure(
        'L’action a échoué. Réessaie dans un instant.',
      );
    } finally {
      _busyIds.remove(user.id);
      _notify();
    }
  }

  /// Version à jour d'un compte affiché (après une action).
  AdminUserAccount? findById(String id) {
    for (final user in users) {
      if (user.id == id) return user;
    }
    return null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}
