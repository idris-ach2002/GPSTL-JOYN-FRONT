import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/material/joyn_chip_group.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../admin/presentation/mobile/mobile_admin_section_menu.dart';
import '../../../admin/presentation/shared/admin_ui.dart';
import '../../domain/admin_user.dart';
import '../../domain/user_query.dart';
import '../controllers/admin_users_controller.dart';
import '../shared/user_actions.dart';
import '../shared/user_detail_panel.dart';
import '../shared/user_visuals.dart';
import '../shared/users_url_sync.dart';

/// Back-office : gestion et modération des utilisateurs (mobile).
class MobileAdminUsersScreen extends StatelessWidget {
  const MobileAdminUsersScreen({required this.urlQuery, super.key});

  final UserQuery urlQuery;

  @override
  Widget build(BuildContext context) {
    return JoynMaterialScope(child: _MobileAdminUsersView(urlQuery: urlQuery));
  }
}

class _MobileAdminUsersView extends StatefulWidget {
  const _MobileAdminUsersView({required this.urlQuery});

  final UserQuery urlQuery;

  @override
  State<_MobileAdminUsersView> createState() => _MobileAdminUsersViewState();
}

class _MobileAdminUsersViewState extends State<_MobileAdminUsersView>
    with AdminUsersUrlSync<_MobileAdminUsersView> {
  late final _search = TextEditingController(text: widget.urlQuery.search);

  @override
  UserQuery get urlQuery => widget.urlQuery;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openFilters(AdminUsersController controller) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => Theme(
        data: Theme.of(context),
        child: _FiltersSheet(controller: controller, onReset: _search.clear),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminUsersController>();
    final textTheme = Theme.of(context).textTheme;

    if (controller.status == AdminUsersStatus.forbidden) {
      return MobileAppSurface(
        child: AdminForbiddenView(
          message: controller.error,
          onLeave: () => context.go(AppRoutes.dashboard),
        ),
      );
    }

    return MobileAppSurface(
      backgroundColor: AppColors.background,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ADMINISTRATION', style: textTheme.labelSmall),
                        const SizedBox(height: 2),
                        Semantics(
                          header: true,
                          child: Text(
                            'Utilisateurs',
                            style: textTheme.headlineMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (controller.canManageUsers)
                    IconButton(
                      key: const ValueKey('mobile-admin-invite'),
                      tooltip: 'Ajouter un admin',
                      onPressed: controller.isInviting
                          ? null
                          : () =>
                                UserActionsHandler(controller)
                                    .inviteAdmin(context),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                    ),
                  const MobileAdminSectionMenu(current: AdminSection.users),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('mobile-admin-user-search'),
                      controller: _search,
                      onChanged: controller.setSearch,
                      decoration: const InputDecoration(
                        hintText: 'Nom, prénom ou e-mail',
                        prefixIcon: Icon(Icons.search_rounded, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Statut et tri',
                    onPressed: () => _openFilters(controller),
                    icon: Badge(
                      isLabelVisible:
                          controller.query.status != UserStatusFilter.all,
                      smallSize: 8,
                      child: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  for (final role in UserRoleFilter.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        label: Text(role.label),
                        selected: controller.query.role == role,
                        showCheckmark: false,
                        selectedColor: AppColors.navy,
                        labelStyle: textTheme.labelMedium?.copyWith(
                          color: controller.query.role == role
                              ? AppColors.white
                              : AppColors.slateDark,
                        ),
                        onSelected: (_) => controller.setRoleFilter(role),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (controller.isRefreshing)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 3),
            ),
          ..._content(context, controller),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  List<Widget> _content(BuildContext context, AdminUsersController controller) {
    if (controller.showSkeleton) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: DecoratedSliver(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(adminRadius),
              border: Border.all(color: AppColors.line),
            ),
            sliver: SliverList.separated(
              itemCount: 6,
              separatorBuilder: (context, _) => const Divider(height: 1),
              itemBuilder: (context, _) => const _CardSkeleton(),
            ),
          ),
        ),
      ];
    }
    if (controller.status == AdminUsersStatus.error) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _CenteredMessage(
            text: controller.error ?? 'Erreur de chargement.',
            action: FilledButton(
              onPressed: controller.load,
              child: const Text('Réessayer'),
            ),
          ),
        ),
      ];
    }
    final users = controller.users;
    if (users.isEmpty) {
      final filtered = controller.query.hasFilters;
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _CenteredMessage(
            text: filtered
                ? 'Aucun compte ne correspond à cette recherche ou à ces filtres.'
                : 'Aucun compte n’est encore inscrit.',
            action: filtered
                ? TextButton(
                    onPressed: () {
                      _search.clear();
                      controller.resetFilters();
                    },
                    child: const Text('Réinitialiser les filtres'),
                  )
                : null,
          ),
        ),
      ];
    }

    final handler = UserActionsHandler(controller);
    final page = controller.page;
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: DecoratedSliver(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(adminRadius),
            border: Border.all(color: AppColors.line),
          ),
          sliver: SliverList.separated(
            itemCount: users.length,
            separatorBuilder: (context, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _UserCard(
              user: users[index],
              controller: controller,
              handler: handler,
            ),
          ),
        ),
      ),
      if (page != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${page.firstIndex}–${page.lastIndex} sur ${page.total}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Page précédente',
                  onPressed: page.page > 1
                      ? () => controller.goToPage(page.page - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text('${page.page} / ${page.totalPages}'),
                IconButton(
                  tooltip: 'Page suivante',
                  onPressed: page.page < page.totalPages
                      ? () => controller.goToPage(page.page + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ),
    ];
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.controller,
    required this.handler,
  });

  final AdminUserAccount user;
  final AdminUsersController controller;
  final UserActionsHandler handler;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isSelf = controller.isSelf(user);
    void showDetails() =>
        showUserDetails(context, controller: controller, user: user);

    // Ligne de liste (dans le panneau) plutôt qu'une carte arrondie.
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: ValueKey('user-card-${user.id}'),
        onTap: showDetails,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(user: user, radius: 17),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSelf ? '${user.fullName} (vous)' : user.fullName,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        RoleBadge(role: user.role),
                        AccountStatusBadge(status: user.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      [
                        if (user.companyName != null) user.companyName!,
                        'Inscrit·e le ${formatAdminDate(user.createdAt)}',
                        formatLastSeen(user.lastLoginAt),
                      ].join(' · '),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              UserRowMenu(
                user: user,
                handler: handler,
                isSelf: isSelf,
                busy: controller.isBusy(user.id),
                onShowDetails: showDetails,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FiltersSheet extends StatelessWidget {
  const _FiltersSheet({required this.controller, required this.onReset});

  final AdminUsersController controller;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Statut', style: textTheme.titleSmall),
              const SizedBox(height: 10),
              JoynChipGroup<UserStatusFilter>.single(
                options: UserStatusFilter.values,
                selected: controller.query.status,
                labelOf: (status) => status.label,
                onSelected: controller.setStatusFilter,
              ),
              const SizedBox(height: 20),
              Text('Trier par', style: textTheme.titleSmall),
              const SizedBox(height: 10),
              JoynChipGroup<UserSort>.single(
                options: UserSort.values,
                selected: controller.query.sort,
                labelOf: (sort) => sort.label,
                onSelected: controller.setSort,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  TextButton(
                    onPressed: controller.query.hasFilters
                        ? () {
                            onReset();
                            controller.resetFilters();
                          }
                        : null,
                    child: const Text('Réinitialiser'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Voir les résultats'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 34, height: 34, radius: 17),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 150, height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 190, height: 10),
                SizedBox(height: 12),
                SkeletonBox(width: 120, height: 22, radius: 99),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_search_outlined,
              size: 40,
              color: AppColors.slate,
            ),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 12), action],
          ],
        ),
      ),
    );
  }
}
