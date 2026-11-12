import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/theme/joyn_material_theme.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/admin/presentation/shared/admin_ui.dart';
import 'package:joyn_front/features/admin/presentation/web/admin_shell.dart';
import 'package:joyn_front/features/admin_users/domain/user_query.dart';
import 'package:joyn_front/features/admin_users/presentation/controllers/admin_users_controller.dart';
import 'package:joyn_front/features/admin_users/presentation/shared/user_actions.dart';
import 'package:joyn_front/features/admin_users/presentation/shared/user_detail_panel.dart';
import 'package:joyn_front/features/admin_users/presentation/shared/user_visuals.dart';
import 'package:joyn_front/features/admin_users/presentation/shared/users_url_sync.dart';

/// Back-office : gestion et modération des utilisateurs (web).
class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({required this.urlQuery, super.key});

  /// Requête lue dans l'URL (pagination, recherche, filtres, tri).
  final UserQuery urlQuery;

  @override
  Widget build(BuildContext context) {
    // Le contenu est un widget à part : son `context` est sous le thème
    // Material JOYN, que les modales ouvertes depuis la page reprennent.
    return JoynMaterialScope(child: _AdminUsersView(urlQuery: urlQuery));
  }
}

class _AdminUsersView extends StatefulWidget {
  const _AdminUsersView({required this.urlQuery});

  final UserQuery urlQuery;

  @override
  State<_AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<_AdminUsersView>
    with AdminUsersUrlSync<_AdminUsersView> {
  @override
  UserQuery get urlQuery => widget.urlQuery;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminUsersController>();
    final handler = UserActionsHandler(controller);

    return AdminShell(
      section: AdminSection.users,
      child: controller.status == AdminUsersStatus.forbidden
          ? AdminForbiddenView(
              message: controller.error,
              onLeave: () => context.go(AppRoutes.dashboard),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AdminPageHeader(
                        title: 'Utilisateurs',
                        subtitle: 'Gérer les comptes candidats, recruteurs et administrateurs.',
                        actions: [
                          FilledButton.icon(
                            key: const ValueKey('admin-invite-admin'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AdminShell.sidebarColor,
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            onPressed: controller.isInviting
                                ? null
                                : () => handler.inviteAdmin(context),
                            icon: const Icon(
                              Icons.person_add_alt_1_outlined,
                              size: 18,
                            ),
                            label: const Text('Ajouter un admin'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AdminPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: _Toolbar(controller: controller),
                            ),
                            if (controller.isRefreshing ||
                                controller.isInviting)
                              const LinearProgressIndicator(minHeight: 2)
                            else
                              const Divider(height: 2, thickness: 1),
                            _TableArea(controller: controller),
                            if (controller.status == AdminUsersStatus.ready &&
                                controller.users.isNotEmpty) ...[
                              const Divider(height: 1),
                              if (controller.page case final page?)
                                AdminPagination(
                                  firstIndex: page.firstIndex,
                                  lastIndex: page.lastIndex,
                                  total: page.total,
                                  page: page.page,
                                  totalPages: page.totalPages,
                                  onPage: controller.goToPage,
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

/// Recherche (300 ms), rôle, statut, tri et réinitialisation.
class _Toolbar extends StatefulWidget {
  const _Toolbar({required this.controller});

  final AdminUsersController controller;

  @override
  State<_Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<_Toolbar> {
  late final _search = TextEditingController(
    text: widget.controller.query.search,
  );
  final _searchFocus = FocusNode();

  @override
  void didUpdateWidget(covariant _Toolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // URL modifiée de l'extérieur (retour arrière, réinitialisation).
    final search = widget.controller.query.search;
    if (!_searchFocus.hasFocus && _search.text.trim() != search) {
      _search.text = search;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final query = controller.query;

    return AdminDenseFields(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 280,
            child: TextField(
              key: const ValueKey('admin-user-search'),
              controller: _search,
              focusNode: _searchFocus,
              onChanged: (value) {
                controller.setSearch(value);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Nom, prénom ou e-mail',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Effacer',
                        onPressed: () {
                          _search.clear();
                          controller.setSearch('');
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded, size: 16),
                      ),
              ),
            ),
          ),
          DropdownMenu<UserRoleFilter>(
            key: ValueKey('role-${query.role.name}'),
            width: 170,
            requestFocusOnTap: false,
            label: const Text('Rôle'),
            initialSelection: query.role,
            onSelected: (role) {
              if (role != null) controller.setRoleFilter(role);
            },
            dropdownMenuEntries: [
              for (final role in UserRoleFilter.values)
                DropdownMenuEntry(value: role, label: role.label),
            ],
          ),
          DropdownMenu<UserStatusFilter>(
            key: ValueKey('status-${query.status.name}'),
            width: 180,
            requestFocusOnTap: false,
            label: const Text('Statut'),
            initialSelection: query.status,
            onSelected: (status) {
              if (status != null) controller.setStatusFilter(status);
            },
            dropdownMenuEntries: [
              for (final status in UserStatusFilter.values)
                DropdownMenuEntry(value: status, label: status.label),
            ],
          ),
          DropdownMenu<UserSort>(
            key: ValueKey('sort-${query.sort.name}'),
            width: 200,
            requestFocusOnTap: false,
            label: const Text('Trier par'),
            initialSelection: query.sort,
            onSelected: (sort) {
              if (sort != null) controller.setSort(sort);
            },
            dropdownMenuEntries: [
              for (final sort in UserSort.values)
                DropdownMenuEntry(value: sort, label: sort.label),
            ],
          ),
          TextButton.icon(
            key: const ValueKey('admin-user-reset'),
            onPressed: query.hasFilters
                ? () {
                    _search.clear();
                    controller.resetFilters();
                  }
                : null,
            icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
            label: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }
}

class _TableArea extends StatelessWidget {
  const _TableArea({required this.controller});

  final AdminUsersController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final handler = UserActionsHandler(controller);

    if (controller.showSkeleton) return const _TableSkeleton();

    if (controller.status == AdminUsersStatus.error) {
      return AdminMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Chargement impossible',
        text: controller.error ?? '',
        action: FilledButton(
          onPressed: controller.load,
          child: const Text('Réessayer'),
        ),
      );
    }

    final users = controller.users;
    if (users.isEmpty) {
      final filtered = controller.query.hasFilters;
      return AdminMessage(
        icon: Icons.person_search_outlined,
        title: filtered ? 'Aucun utilisateur trouvé' : 'Aucun utilisateur',
        text: filtered
            ? 'Aucun compte ne correspond à cette recherche ou à ces filtres.'
            : 'Aucun compte n’est encore inscrit.',
        action: filtered
            ? TextButton(
                onPressed: controller.resetFilters,
                child: const Text('Réinitialiser les filtres'),
              )
            : null,
      );
    }

    final sort = controller.query.sort;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: AdminTableTheme(
            child: DataTable(
              showCheckboxColumn: false,
              sortColumnIndex: sort.byName ? 0 : 4,
              sortAscending: sort.ascending,
              columns: [
                DataColumn(
                  label: const Text('UTILISATEUR'),
                  onSort: (_, ascending) => controller.setSort(
                    ascending ? UserSort.nameAsc : UserSort.nameDesc,
                  ),
                ),
                const DataColumn(label: Text('RÔLE')),
                const DataColumn(label: Text('STATUT')),
                const DataColumn(label: Text('ENTREPRISE')),
                DataColumn(
                  label: const Text('INSCRIPTION'),
                  onSort: (_, ascending) => controller.setSort(
                    ascending ? UserSort.oldest : UserSort.newest,
                  ),
                ),
                const DataColumn(label: Text('DERNIÈRE CONNEXION')),
                const DataColumn(label: Text('ACTIONS')),
              ],
              rows: [
                for (final user in users)
                  DataRow(
                    key: ValueKey(user.id),
                    onSelectChanged: (_) => showUserDetails(
                      context,
                      controller: controller,
                      user: user,
                    ),
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            UserAvatar(user: user, radius: 15),
                            const SizedBox(width: 10),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 240),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.isSelf(user)
                                        ? '${user.fullName} (vous)'
                                        : user.fullName,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  Text(
                                    user.email,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(RoleBadge(role: user.role)),
                      DataCell(AccountStatusBadge(status: user.status)),
                      DataCell(
                        user.companyName == null
                            ? Text('—', style: textTheme.bodySmall)
                            : InkWell(
                                onTap: () =>
                                    context.go(AppRoutes.adminCompanies),
                                child: Text(
                                  user.companyName!,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 13,
                                    color: AppColors.navy,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                      ),
                      DataCell(Text(formatAdminDate(user.createdAt))),
                      DataCell(
                        Text(
                          formatLastSeen(user.lastLoginAt),
                          style: textTheme.bodySmall,
                        ),
                      ),
                      DataCell(
                        UserRowMenu(
                          user: user,
                          handler: handler,
                          isSelf: controller.isSelf(user),
                          busy: controller.isBusy(user.id),
                          onShowDetails: () => showUserDetails(
                            context,
                            controller: controller,
                            user: user,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TableSkeleton extends StatelessWidget {
  const _TableSkeleton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Chargement des utilisateurs',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            // Une boucle `for` n'est pas permise dans une liste `const` :
            // seules les lignes sont constantes.
            for (var i = 0; i < 8; i++)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 11),
                child: Row(
                  children: [
                    SkeletonBox(width: 30, height: 30, radius: 15),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 140),
                          SizedBox(height: 8),
                          SkeletonBox(width: 180, height: 10),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SkeletonBox(width: 80, height: 22, radius: 99),
                    ),
                    Expanded(
                      child: SkeletonBox(width: 70, height: 22, radius: 99),
                    ),
                    Expanded(child: SkeletonBox(width: 90)),
                    Expanded(child: SkeletonBox(width: 80)),
                    SkeletonBox(width: 32, height: 32, radius: 16),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
