import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/app/navigation/candidate_account_menu.dart';
import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/core/theme/app_colors.dart';
import 'package:joyn_front/core/theme/app_dimens.dart';
import 'package:joyn_front/core/utils/placeholders.dart';
import 'package:joyn_front/core/widgets/coming_soon.dart';
import 'package:joyn_front/core/widgets/joyn_logo.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';
import 'package:joyn_front/features/notifications/presentation/notifications_controller.dart';
import 'package:joyn_front/features/notifications/presentation/shared/notifications_panel.dart';

/// Onglet (ou raccourci) mis en avant dans la barre du haut.
enum DashboardTab { offers, dashboard, applications, messages, settings }

/// Compteurs de non-lus, si le contrôleur est fourni (absent de certains
/// tests de widgets isolés).
NotificationsController? _inbox(BuildContext context) {
  try {
    return context.watch<NotificationsController>();
  } on ProviderNotFoundException {
    return null;
  }
}

/// Barre du haut : logo, onglets, raccourcis et menu du compte.
///
/// Sur petit écran, les onglets passent sous la barre.
class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    super.key,
    required this.isWide,
    this.activeTab = DashboardTab.dashboard,
  });

  final bool isWide;
  final DashboardTab activeTab;

  @override
  Widget build(BuildContext context) {
    final inbox = _inbox(context);
    final bar = Row(
      children: [
        const JoynLogo(size: 30, wordmarkColor: Colors.white),
        const Spacer(),
        if (isWide) ...[
          _NavTabs(showLabels: true, activeTab: activeTab),
          const Spacer(),
        ],
        _RoundIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          badge: inbox?.unreadCount ?? 0,
          onPressed: () => inbox == null
              ? showComingSoon(context, 'Notifications')
              : showNotificationsPanel(context, asSheet: !isWide),
        ),
        const SizedBox(width: AppSpacing.sm),
        _RoundIconButton(
          icon: Icons.settings_outlined,
          tooltip: 'Paramètres',
          active: activeTab == DashboardTab.settings,
          onPressed: () => context.go(AppRoutes.candidateSettings),
        ),
        const SizedBox(width: AppSpacing.sm),
        _RoundIconButton(
          icon: Icons.chat_bubble_outline_rounded,
          tooltip: 'Messages',
          badge: inbox?.unreadMessages ?? 0,
          active: activeTab == DashboardTab.messages,
          onPressed: () => context.go(AppRoutes.candidateMessages),
        ),
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
          builder: (context, constraints) => _NavTabs(
            showLabels: constraints.maxWidth >= 440,
            activeTab: activeTab,
          ),
        ),
      ],
    );
  }
}

/// Onglets « Offres / Dashboard / Candidatures » dans une pilule translucide.
class _NavTabs extends StatelessWidget {
  const _NavTabs({required this.showLabels, required this.activeTab});

  final bool showLabels;
  final DashboardTab activeTab;

  /// Va sur [route], sauf si l'onglet est déjà ouvert.
  void _open(BuildContext context, DashboardTab tab, String route) {
    if (tab != activeTab) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
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
            isActive: activeTab == DashboardTab.offers,
            onTap: () => _open(
              context,
              DashboardTab.offers,
              AppRoutes.candidateDiscover,
            ),
          ),
          _NavTab(
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
            showLabel: showLabels,
            isActive: activeTab == DashboardTab.dashboard,
            onTap: () =>
                _open(context, DashboardTab.dashboard, AppRoutes.dashboard),
          ),
          _NavTab(
            icon: Icons.description_outlined,
            label: 'Candidatures',
            showLabel: showLabels,
            isActive: activeTab == DashboardTab.applications,
            onTap: () => _open(
              context,
              DashboardTab.applications,
              AppRoutes.candidateApplications,
            ),
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
    this.badge = 0,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  /// Nombre affiché en pastille (masquée à 0).
  final int badge;

  /// Page en cours : fond orange, comme sur la maquette.
  final bool active;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: badge > 0 ? '$tooltip ($badge non lus)' : tooltip,
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: badge > 0,
        backgroundColor: AppColors.coral,
        label: Text(badge > 9 ? '9+' : '$badge'),
        child: Icon(icon, size: 20),
      ),
      color: Colors.white,
      style: IconButton.styleFrom(
        backgroundColor: active ? AppColors.coral : Colors.transparent,
        side: BorderSide(
          color: active ? AppColors.coral : Colors.white.withValues(alpha: 0.6),
        ),
        minimumSize: const Size.square(40),
      ),
    );
  }
}

/// Pastille du compte connecté, avec un menu « Se déconnecter ».
class _AccountMenu extends StatelessWidget {
  const _AccountMenu({required this.showName});

  final bool showName;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    // TODO(backend): afficher le vrai nom quand AppUser en contiendra un.
    final name = Placeholders.text(user?.email.split('@').first);

    return CandidateAccountMenu(
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
