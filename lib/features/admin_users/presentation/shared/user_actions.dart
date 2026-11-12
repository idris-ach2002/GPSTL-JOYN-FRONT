import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../admin/presentation/shared/admin_ui.dart';
import '../../domain/admin_user.dart';
import '../controllers/admin_users_controller.dart';
import 'user_dialogs.dart';

/// Enchaîne modale → appel au contrôleur → notification.
class UserActionsHandler {
  const UserActionsHandler(this.controller);

  final AdminUsersController controller;

  Future<void> suspend(BuildContext context, AdminUserAccount user) async {
    final messenger = ScaffoldMessenger.of(context);
    final reason = await showSanctionDialog(
      context,
      user: user,
      kind: SanctionKind.suspend,
    );
    if (reason == null) return;
    _toast(messenger, await controller.suspend(user, reason));
  }

  Future<void> ban(BuildContext context, AdminUserAccount user) async {
    final messenger = ScaffoldMessenger.of(context);
    final reason = await showSanctionDialog(
      context,
      user: user,
      kind: SanctionKind.ban,
    );
    if (reason == null) return;
    _toast(messenger, await controller.ban(user, reason));
  }

  Future<void> reactivate(BuildContext context, AdminUserAccount user) async {
    final messenger = ScaffoldMessenger.of(context);
    _toast(messenger, await controller.reactivate(user));
  }

  Future<void> changeRole(BuildContext context, AdminUserAccount user) async {
    final messenger = ScaffoldMessenger.of(context);
    final role = await showChangeRoleDialog(context, user);
    if (role == null) return;
    _toast(messenger, await controller.changeRole(user, role));
  }

  Future<void> inviteAdmin(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final invitation = await showInviteAdminDialog(context);
    if (invitation == null) return;
    _toast(
      messenger,
      await controller.inviteAdmin(
        firstName: invitation.firstName,
        lastName: invitation.lastName,
        email: invitation.email,
      ),
    );
  }

  Future<void> delete(BuildContext context, AdminUserAccount user) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDeleteUserDialog(context, user);
    if (!confirmed) return;
    _toast(messenger, await controller.delete(user));
  }

  void _toast(ScaffoldMessengerState messenger, UserActionResult result) {
    showAdminToastWith(messenger, result.message, error: !result.succeeded);
  }
}

enum _UserAction { details, reactivate, suspend, ban, role, delete }

/// Menu « ⋮ » d'un compte. Les actions sur son propre compte sont grisées.
class UserRowMenu extends StatelessWidget {
  const UserRowMenu({
    required this.user,
    required this.handler,
    required this.isSelf,
    required this.busy,
    required this.onShowDetails,
    super.key,
  });

  final AdminUserAccount user;
  final UserActionsHandler handler;
  final bool isSelf;
  final bool busy;
  final VoidCallback onShowDetails;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: SizedBox.square(
          dimension: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            semanticsLabel: 'Action en cours',
          ),
        ),
      );
    }

    if (!handler.controller.canManageUsers) {
      return IconButton(
        tooltip: 'Voir le détail',
        icon: const Icon(Icons.badge_outlined),
        onPressed: onShowDetails,
      );
    }
    final sanctioned =
        user.status == AccountStatus.suspended ||
        user.status == AccountStatus.banned;
    const selfHint = 'Impossible sur votre propre compte';

    PopupMenuItem<_UserAction> item(
      _UserAction value,
      IconData icon,
      String label, {
      Color? color,
      bool enabled = true,
    }) => PopupMenuItem(
      value: value,
      enabled: enabled,
      child: ListTile(
        enabled: enabled,
        leading: Icon(icon, color: enabled ? color : null),
        title: Text(label, style: TextStyle(color: enabled ? color : null)),
        subtitle: enabled ? null : const Text(selfHint),
      ),
    );

    return PopupMenuButton<_UserAction>(
      key: ValueKey('user-menu-${user.id}'),
      tooltip: 'Actions',
      onSelected: (action) => switch (action) {
        _UserAction.details => onShowDetails(),
        _UserAction.reactivate => handler.reactivate(context, user),
        _UserAction.suspend => handler.suspend(context, user),
        _UserAction.ban => handler.ban(context, user),
        _UserAction.role => handler.changeRole(context, user),
        _UserAction.delete => handler.delete(context, user),
      },
      itemBuilder: (context) => [
        item(_UserAction.details, Icons.badge_outlined, 'Voir le détail'),
        const PopupMenuDivider(),
        if (sanctioned)
          item(
            _UserAction.reactivate,
            Icons.restart_alt_rounded,
            'Réactiver',
            color: AppColors.successDeep,
          ),
        if (user.status != AccountStatus.suspended)
          item(
            _UserAction.suspend,
            Icons.pause_circle_outline_rounded,
            'Suspendre',
            color: AppColors.errorDeep,
            enabled: !isSelf,
          ),
        if (user.status != AccountStatus.banned)
          item(
            _UserAction.ban,
            Icons.block_rounded,
            'Bannir',
            color: AppColors.errorDeep,
            enabled: !isSelf,
          ),
        item(
          _UserAction.role,
          Icons.manage_accounts_outlined,
          'Modifier le rôle',
          enabled: !isSelf,
        ),
        const PopupMenuDivider(),
        item(
          _UserAction.delete,
          Icons.delete_outline_rounded,
          'Supprimer (RGPD)',
          color: AppColors.errorDeep,
          enabled: !isSelf,
        ),
      ],
    );
  }
}
