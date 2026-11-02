import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/core/feedback/coming_soon.dart';
import 'package:joyn_front/design_system/components/joyn_logo.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';

/// Cadre de l'espace administrateur (web) : barre latérale sombre et zone de
/// contenu posée sur un dégradé bleu nuit.
class AdminShell extends StatelessWidget {
  const AdminShell({required this.child, super.key});

  final Widget child;

  static const _sidebarColor = Color(0xFF10212D);

  @override
  Widget build(BuildContext context) {
    final compactSidebar = MediaQuery.sizeOf(context).width < 1100;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: _sidebarColor,
            child: SizedBox(
              width: compactSidebar ? 84 : 236,
              child: SafeArea(child: _Sidebar(compact: compactSidebar)),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 340,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF0E2A40),
                          Color(0xFF1C5A84),
                          AppColors.background,
                        ],
                        stops: [0, 0.55, 1],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: -160,
                  right: -120,
                  width: 420,
                  height: 420,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [Color(0x66FF8559), Color(0x00FF8559)],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthController, String?>(
      (auth) => auth.user?.email,
    );
    final textTheme = Theme.of(context).textTheme;

    final items = [
      (Icons.grid_view_rounded, 'Tableau de bord', false),
      (Icons.apartment_rounded, 'Entreprises', true),
      (Icons.group_outlined, 'Utilisateurs', false),
      (Icons.flag_outlined, 'Modération', false),
      (Icons.payments_outlined, 'Revenus', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(compact ? 0 : 24, 26, 12, 36),
          child: compact
              ? const Center(
                  child: JoynLogo(
                    onDark: true,
                    markSize: 34,
                    showWordmark: false,
                  ),
                )
              : const JoynLogo(onDark: true, markSize: 32),
        ),
        for (final (icon, label, selected) in items)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: Tooltip(
              message: compact ? label : '',
              child: ListTile(
                selected: selected,
                selectedTileColor: const Color(0x1FFFFFFF),
                iconColor: const Color(0xB3FFFFFF),
                selectedColor: AppColors.white,
                textColor: const Color(0xB3FFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: compact ? 18 : 14,
                ),
                leading: Icon(icon),
                title: compact
                    ? null
                    : Text(
                        label,
                        style: textTheme.titleSmall?.copyWith(
                          color: selected
                              ? AppColors.white
                              : const Color(0xB3FFFFFF),
                        ),
                      ),
                onTap: selected ? null : () => showComingSoon(context, label),
              ),
            ),
          ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.orange,
                child: Text(
                  'AD',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Équipe Joyn',
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        email ?? 'Administrateur',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xB3FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Se déconnecter',
                  color: const Color(0xB3FFFFFF),
                  onPressed: () => context.read<AuthController>().signOut(),
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
