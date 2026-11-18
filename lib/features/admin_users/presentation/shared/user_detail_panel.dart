import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/material/joyn_notice.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../admin/presentation/shared/admin_ui.dart';
import '../../domain/admin_user.dart';
import '../controllers/admin_users_controller.dart';
import 'user_actions.dart';
import 'user_visuals.dart';

/// Ouvre le détail d'un compte : tiroir latéral sur grand écran, feuille en
/// bas d'écran sur mobile.
Future<void> showUserDetails(
  BuildContext context, {
  required AdminUsersController controller,
  required AdminUserAccount user,
}) {
  final theme = Theme.of(context);
  final panel = Theme(
    data: theme,
    child: _UserDetailPanel(
      controller: controller,
      userId: user.id,
      initial: user,
    ),
  );

  if (MediaQuery.sizeOf(context).width < 700) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (_) => FractionallySizedBox(heightFactor: 0.9, child: panel),
    );
  }

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fermer le détail',
    barrierColor: const Color(0x66000000),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, _, _) => Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: AppColors.surface,
        elevation: 16,
        child: SizedBox(width: 440, height: double.infinity, child: panel),
      ),
    ),
    transitionBuilder: (_, animation, _, child) => SlideTransition(
      position: Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

class _UserDetailPanel extends StatelessWidget {
  const _UserDetailPanel({
    required this.controller,
    required this.userId,
    required this.initial,
  });

  final AdminUsersController controller;
  final String userId;
  final AdminUserAccount initial;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // Après une action, on affiche la version à jour du compte.
        final user = controller.findById(userId) ?? initial;
        final handler = UserActionsHandler(controller);
        final isSelf = controller.isSelf(user);
        final busy = controller.isBusy(user.id);
        final textTheme = Theme.of(context).textTheme;
        final sanctioned =
            user.status == AccountStatus.suspended ||
            user.status == AccountStatus.banned;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Détail du compte',
                        style: textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fermer',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  children: [
                    Row(
                      children: [
                        UserAvatar(user: user, radius: 30),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.fullName, style: textTheme.titleMedium),
                              Text(user.email, style: textTheme.bodySmall),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  RoleBadge(role: user.role),
                                  AccountStatusBadge(status: user.status),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isSelf) ...[
                      const SizedBox(height: 16),
                      const JoynNotice(
                        message: 'C’est votre compte : vous ne pouvez ni le sanctionner ni retirer vos droits d’administration ici.',
                      ),
                    ],
                    const SizedBox(height: 20),
                    const _SectionTitle('Informations'),
                    _InfoRow(
                      label: 'Identifiant (UUID)',
                      value: user.id,
                      trailing: IconButton(
                        tooltip: 'Copier l’identifiant',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: user.id));
                          showAdminToast(context, 'Identifiant copié.');
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                      ),
                    ),
                    _InfoRow(
                      label: 'E-mail',
                      value: user.emailVerified ? 'Vérifié' : 'Non vérifié',
                      valueColor: user.emailVerified
                          ? AppColors.successDeep
                          : AppColors.warningDeep,
                    ),
                    _InfoRow(
                      label: 'Inscription',
                      value: formatAdminDate(user.createdAt),
                    ),
                    _InfoRow(
                      label: 'Dernière connexion',
                      value: formatLastSeen(user.lastLoginAt),
                    ),
                    if (user.role == AccountRole.recruiter)
                      _InfoRow(
                        label: 'Entreprise',
                        value: user.companyName ?? 'Aucune',
                        trailing: user.companyName == null
                            ? null
                            : TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  context.go(AppRoutes.adminCompanies);
                                },
                                child: const Text('Voir la fiche'),
                              ),
                      ),
                    const SizedBox(height: 20),
                    const _SectionTitle('Activité'),
                    _InfoRow(
                      label: switch (user.role) {
                        AccountRole.recruiter => 'Offres créées',
                        _ => 'Candidatures envoyées',
                      },
                      value: switch (user.role) {
                        AccountRole.recruiter => '${user.offersCount}',
                        _ => '${user.applicationsCount}',
                      },
                    ),
                    const SizedBox(height: 20),
                    const _SectionTitle('Journal de modération'),
                    if (user.moderationHistory.isEmpty)
                      Text(
                        'Aucune sanction ni décision de modération.',
                        style: textTheme.bodySmall,
                      )
                    else
                      for (final entry in user.moderationHistory)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.background,
                            child: Icon(
                              switch (entry.kind) {
                                ModerationKind.suspended =>
                                  Icons.pause_circle_outline_rounded,
                                ModerationKind.banned => Icons.block_rounded,
                                ModerationKind.reactivated =>
                                  Icons.restart_alt_rounded,
                                ModerationKind.roleChanged =>
                                  Icons.manage_accounts_outlined,
                              },
                              size: 18,
                              color: AppColors.slateDark,
                            ),
                          ),
                          title: Text(entry.kind.label),
                          subtitle: Text(
                            [
                              formatAdminDate(entry.date),
                              entry.author,
                              if (entry.reason.isNotEmpty) entry.reason,
                            ].join(' · '),
                          ),
                        ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: busy
                    ? const LinearProgressIndicator()
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (sanctioned)
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.successDeep,
                              ),
                              onPressed: () =>
                                  handler.reactivate(context, user),
                              icon: const Icon(Icons.restart_alt_rounded),
                              label: const Text('Réactiver'),
                            ),
                          if (user.status != AccountStatus.suspended)
                            OutlinedButton(
                              onPressed: isSelf
                                  ? null
                                  : () => handler.suspend(context, user),
                              child: const Text('Suspendre'),
                            ),
                          if (user.status != AccountStatus.banned)
                            OutlinedButton(
                              onPressed: isSelf
                                  ? null
                                  : () => handler.ban(context, user),
                              child: const Text('Bannir'),
                            ),
                          OutlinedButton(
                            onPressed: isSelf
                                ? null
                                : () => handler.changeRole(context, user),
                            child: const Text('Modifier le rôle'),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: AppColors.slate),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(label, style: textTheme.bodySmall)),
          Expanded(
            child: SelectableText(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: valueColor == null ? null : FontWeight.w600,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
