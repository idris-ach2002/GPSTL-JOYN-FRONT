import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/core/feedback/coming_soon.dart';
import 'package:joyn_front/design_system/components/joyn_logo.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/admin/presentation/shared/admin_section.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';

export 'package:joyn_front/features/admin/presentation/shared/admin_section.dart';

/// Cadre de l'espace administrateur (web) : barre latérale bleu nuit et
/// zone de contenu sur fond clair uni.
class AdminShell extends StatelessWidget {
  const AdminShell({required this.section, required this.child, super.key});

  /// Rubrique affichée (mise en avant dans la barre latérale).
  final AdminSection section;
  final Widget child;

  static const sidebarColor = Color(0xFF10212D);

  @override
  Widget build(BuildContext context) {
    final compactSidebar = MediaQuery.sizeOf(context).width < 1100;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: sidebarColor,
            child: SizedBox(
              width: compactSidebar ? 72 : 220,
              child: SafeArea(
                child: _Sidebar(compact: compactSidebar, current: section),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.compact, required this.current});

  final bool compact;
  final AdminSection current;

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthController, String?>(
      (auth) => auth.user?.email,
    );
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(compact ? 0 : 20, 22, 12, 28),
          child: compact
              ? const Center(
                  child: JoynLogo(
                    onDark: true,
                    markSize: 28,
                    showWordmark: false,
                  ),
                )
              : const JoynLogo(onDark: true, markSize: 26),
        ),
        for (final section in AdminSection.values)
          _NavItem(
            section: section,
            selected: section == current,
            compact: compact,
          ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.orange,
                child: Text(
                  'AD',
                  style: TextStyle(
                    fontSize: 12,
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

/// Entrée de la barre latérale. La rubrique active est signalée par une
/// barre orange à gauche, un fond éclairci et un texte en gras.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.section,
    required this.selected,
    required this.compact,
  });

  final AdminSection section;
  final bool selected;
  final bool compact;

  static const _muted = Color(0xA6FFFFFF);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = selected ? AppColors.white : _muted;

    void open() {
      final route = section.route;
      if (route == null) {
        showComingSoon(context, section.label);
      } else {
        context.go(route);
      }
    }

    return Semantics(
      selected: selected,
      button: true,
      child: Tooltip(
        message: compact ? section.label : '',
        child: Material(
          color: selected ? const Color(0x14FFFFFF) : Colors.transparent,
          child: InkWell(
            key: ValueKey('admin-nav-${section.name}'),
            onTap: selected ? null : open,
            hoverColor: const Color(0x0DFFFFFF),
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  // Indicateur de la rubrique active.
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 3,
                    height: selected ? 22 : 0,
                    color: AppColors.orange,
                  ),
                  SizedBox(width: compact ? 22 : 17),
                  Icon(section.icon, size: 19, color: color),
                  if (!compact) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        section.label,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: color,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
