import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/core/theme/app_colors.dart';
import 'package:joyn_front/core/theme/app_dimens.dart';
import 'package:joyn_front/core/utils/placeholders.dart';
import 'package:joyn_front/core/widgets/coming_soon.dart';
import 'package:joyn_front/core/widgets/joyn_logo.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';

/// Barre du haut : logo, onglets, raccourcis et menu du compte.
///
/// Sur petit écran, les onglets passent sous la barre.
class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({super.key, required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final bar = Row(
      children: [
        const JoynLogo(size: 30, wordmarkColor: Colors.white),
        const Spacer(),
        if (isWide) ...[const _NavTabs(showLabels: true), const Spacer()],
        _RoundIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          onPressed: () => showComingSoon(context, 'Notifications'),
        ),
        if (isWide) ...[
          const SizedBox(width: AppSpacing.sm),
          _RoundIconButton(
            icon: Icons.settings_outlined,
            tooltip: 'Paramètres',
            onPressed: () => showComingSoon(context, 'Paramètres'),
          ),
          const SizedBox(width: AppSpacing.sm),
          _RoundIconButton(
            icon: Icons.chat_bubble_outline_rounded,
            tooltip: 'Messages',
            onPressed: () => showComingSoon(context, 'Messages'),
          ),
        ],
        const SizedBox(width: AppSpacing.sm),
        _AccountMenu(showName: isWide),
      ],
    );

    if (isWide) return bar;

    return Column(
      children: [
        bar,
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) =>
              _NavTabs(showLabels: constraints.maxWidth >= 440),
        ),
      ],
    );
  }
}

/// Onglets « Offres / Dashboard / Candidatures » dans une pilule translucide.
class _NavTabs extends StatelessWidget {
  const _NavTabs({required this.showLabels});

  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    // TODO(navigation): brancher Offres et Candidatures quand les pages
    // existeront (routes à ajouter dans app_routes.dart / app_router.dart).
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavTab(
            icon: Icons.work_outline_rounded,
            label: 'Offres',
            showLabel: showLabels,
            onTap: () => showComingSoon(context, 'Offres'),
          ),
          _NavTab(
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
            showLabel: showLabels,
            isActive: true,
            onTap: () {},
          ),
          _NavTab(
            icon: Icons.description_outlined,
            label: 'Candidatures',
            showLabel: showLabels,
            onTap: () => showComingSoon(context, 'Candidatures'),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.label,
    required this.showLabel,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final bool showLabel;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.pill);
    return Tooltip(
      message: showLabel ? '' : label,
      child: Material(
        color: isActive
            ? Colors.white.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                if (showLabel) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      color: Colors.white,
      style: IconButton.styleFrom(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
        minimumSize: const Size.square(40),
      ),
    );
  }
}

/// Pastille du compte connecté, avec un menu « Se déconnecter ».
class _AccountMenu extends StatelessWidget {
  const _AccountMenu({required this.showName});

  final bool showName;

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthController>().signOut();
    // Navigation explicite : en mode démo (SKIP_LOGIN), le routeur ne
    // redirige pas tout seul vers la connexion.
    if (context.mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    // TODO(backend): afficher le vrai nom quand AppUser en contiendra un.
    final name = Placeholders.text(user?.email.split('@').first);

    return PopupMenuButton<void>(
      tooltip: 'Mon compte',
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () => _signOut(context),
          child: const Row(
            children: [
              Icon(Icons.logout_rounded, size: 18),
              SizedBox(width: AppSpacing.sm),
              Text('Se déconnecter'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.skySoft,
              child: Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: AppColors.navy,
              ),
            ),
            if (showName) ...[
              const SizedBox(width: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.expand_more_rounded, color: AppColors.ink),
          ],
        ),
      ),
    );
  }
}
