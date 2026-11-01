import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/core/feedback/coming_soon.dart';
import 'package:joyn_front/design_system/components/joyn_logo.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';
import 'package:joyn_front/features/profile/domain/student_profile.dart';
import 'package:joyn_front/features/profile/presentation/shared/profile_view_sections.dart';

/// Barre de navigation de l'espace étudiant, posée sur le dégradé bleu :
/// logo, onglets, icônes et menu du compte.
class ProfileNavBar extends StatelessWidget {
  const ProfileNavBar({
    required this.firstName,
    required this.initials,
    this.photo,
    super.key,
  });

  final String firstName;
  final String initials;
  final ProfilePhoto? photo;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showTabs = width >= 760;
    final tabLabels = width >= 1040;

    return Row(
      children: [
        Tooltip(
          message: 'Tableau de bord',
          child: InkWell(
            onTap: () => context.go(AppRoutes.dashboard),
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: JoynLogo(onDark: true, markSize: 30),
            ),
          ),
        ),
        Expanded(
          child: showTabs
              ? Center(child: _Tabs(showLabels: tabLabels))
              : const SizedBox.shrink(),
        ),
        _CircleAction(
          tooltip: 'Notifications',
          icon: const Badge(
            smallSize: 8,
            backgroundColor: AppColors.orange,
            child: Icon(Icons.notifications_none_rounded),
          ),
          onPressed: () => showComingSoon(context, 'Les notifications'),
        ),
        const SizedBox(width: 10),
        _CircleAction(
          tooltip: 'Paramètres',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => showComingSoon(context, 'Les paramètres'),
        ),
        const SizedBox(width: 10),
        _CircleAction(
          tooltip: 'Messages',
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          onPressed: () => showComingSoon(context, 'La messagerie'),
        ),
        const SizedBox(width: 12),
        _AccountMenu(firstName: firstName, initials: initials, photo: photo),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.showLabels});

  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (
        Icons.work_outline_rounded,
        'Offres',
        () => showComingSoon(context, 'Les offres'),
      ),
      (
        Icons.grid_view_rounded,
        'Dashboard',
        () => context.go(AppRoutes.dashboard),
      ),
      (
        Icons.article_outlined,
        'Candidatures',
        () => showComingSoon(context, 'Les candidatures'),
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x80FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (icon, label, onPressed) in tabs)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: showLabels
                    ? TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: onPressed,
                        icon: Icon(icon, size: 20),
                        label: Text(label),
                      )
                    : IconButton(
                        tooltip: label,
                        color: AppColors.white,
                        onPressed: onPressed,
                        icon: Icon(icon, size: 20),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: AppColors.white,
        side: const BorderSide(color: Color(0xCCFFFFFF), width: 1.5),
      ),
      icon: icon,
    );
  }
}

enum _AccountAction { dashboard, signOut }

class _AccountMenu extends StatelessWidget {
  const _AccountMenu({
    required this.firstName,
    required this.initials,
    required this.photo,
  });

  final String firstName;
  final String initials;
  final ProfilePhoto? photo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopupMenuButton<_AccountAction>(
      tooltip: 'Mon compte',
      position: PopupMenuPosition.under,
      onSelected: (action) {
        switch (action) {
          case _AccountAction.dashboard:
            context.go(AppRoutes.dashboard);
          case _AccountAction.signOut:
            context.read<AuthController>().signOut();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _AccountAction.dashboard,
          child: ListTile(
            leading: Icon(Icons.grid_view_rounded),
            title: Text('Tableau de bord'),
          ),
        ),
        PopupMenuItem(
          value: _AccountAction.signOut,
          child: ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text('Se déconnecter'),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileAvatar(initials: initials, photo: photo, radius: 16),
            const SizedBox(width: 10),
            Text(
              firstName.isEmpty ? 'Mon compte' : firstName,
              style: textTheme.titleSmall,
            ),
            const SizedBox(width: 6),
            const Icon(Icons.expand_more_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
