import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../navigation/landing_section.dart';
import 'joyn_mark.dart';
import 'landing_motion.dart';

/// Navigation web JOYN.
///
/// La barre reste fixe en haut pendant toute la visite. Le style reste proche
/// de la maquette validée : surface bleu nuit, navigation centrale en teintes
/// blanches/grises et CTA plus sobres, sans flèches décoratives.
class LandingNavbar extends StatefulWidget {
  const LandingNavbar({
    required this.onNavigate,
    required this.scrollController,
    super.key,
  });

  final LandingNavigate onNavigate;
  final ScrollController scrollController;

  @override
  State<LandingNavbar> createState() => _LandingNavbarState();
}

class _LandingNavbarState extends State<LandingNavbar> {
  LandingSection _selected = LandingSection.hero;

  static const _links = {
    LandingSection.hero: 'Accueil',
    LandingSection.features: 'Fonctionnalités',
    LandingSection.companies: 'Entreprises',
    LandingSection.pricing: 'Formules',
  };

  void _navigate(LandingSection section) {
    setState(() => _selected = section);
    widget.onNavigate(section);
  }

  @override
  Widget build(BuildContext context) => ContentContainer(
    maxWidth: 1440,
    child: const Padding(
      padding: EdgeInsets.only(top: 18, bottom: 8),
      child: _NavbarSurface(),
    ),
  );
}

class _NavbarSurface extends StatelessWidget {
  const _NavbarSurface();

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_LandingNavbarState>();
    if (state == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.white.withValues(alpha: .12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: .18),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 1100;
            final narrow = constraints.maxWidth < 760;

            final brand = LandingReveal(
              duration: const Duration(milliseconds: 460),
              offset: const Offset(0, -12),
              child: TextButton(
                onPressed: () => state._navigate(LandingSection.hero),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  foregroundColor: AppColors.white,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    JoynMark(size: 34),
                    SizedBox(width: 12),
                    Text(
                      'joyn',
                      style: TextStyle(
                        fontSize: 24,
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.7,
                      ),
                    ),
                  ],
                ),
              ),
            );

            const login = _AccountAccessButton(
              label: 'Connexion',
              route: '/connexion',
            );
            const register = _AccountAccessButton(
              label: 'Inscription',
              route: '/inscription',
              primary: true,
            );

            final actions = LandingReveal(
              delay: const Duration(milliseconds: 220),
              duration: const Duration(milliseconds: 500),
              offset: const Offset(0, -10),
              child: Row(
                mainAxisSize: narrow ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (narrow)
                    const Expanded(child: login)
                  else
                    login,
                  const SizedBox(width: 12),
                  if (narrow)
                    const Expanded(child: register)
                  else
                    register,
                ],
              ),
            );

            final menu = MenuAnchor(
              menuChildren: [
                for (final link in _LandingNavbarState._links.entries)
                  MenuItemButton(
                    onPressed: () => state._navigate(link.key),
                    child: Text(link.value),
                  ),
              ],
              builder: (_, controller, child) => IconButton(
                tooltip: 'Ouvrir la navigation',
                onPressed: () => controller.isOpen
                    ? controller.close()
                    : controller.open(),
                color: AppColors.white,
                icon: const Icon(Icons.menu_rounded),
              ),
            );

            if (narrow) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [brand, const Spacer(), menu]),
                  const SizedBox(height: 8),
                  actions,
                ],
              );
            }

            return Row(
              children: [
                brand,
                const Spacer(),
                if (compact)
                  menu
                else
                  LandingReveal(
                    delay: const Duration(milliseconds: 110),
                    duration: const Duration(milliseconds: 480),
                    offset: const Offset(0, -10),
                    child: _NavigationLinks(
                      selected: state._selected,
                      onNavigate: state._navigate,
                    ),
                  ),
                const Spacer(),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavigationLinks extends StatelessWidget {
  const _NavigationLinks({required this.selected, required this.onNavigate});

  final LandingSection selected;
  final ValueChanged<LandingSection> onNavigate;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: AppColors.white.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.white.withValues(alpha: .14)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final link in _LandingNavbarState._links.entries)
          _NavLink(
            label: link.value,
            selected: selected == link.key,
            onPressed: () => onNavigate(link.key),
          ),
      ],
    ),
  );
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: widget.selected
            ? AppColors.white.withValues(alpha: .12)
            : _hovered
                ? AppColors.white.withValues(alpha: .075)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        border: widget.selected
            ? Border.all(color: AppColors.white.withValues(alpha: .08))
            : null,
      ),
      child: TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          foregroundColor: widget.selected
              ? AppColors.orangeLight
              : AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        ),
        child: Text(
          widget.label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),
    ),
  );
}

class _AccountAccessButton extends StatefulWidget {
  const _AccountAccessButton({
    required this.label,
    required this.route,
    this.primary = false,
  });

  final String label;
  final String route;
  final bool primary;

  @override
  State<_AccountAccessButton> createState() => _AccountAccessButtonState();
}

class _AccountAccessButtonState extends State<_AccountAccessButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final active = (_hovered || _focused) && !reduceMotion;
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 280);

    final background = widget.primary
        ? (active ? AppColors.orangeLight : AppColors.orange)
        : AppColors.navy.withValues(alpha: active ? .15 : .08);
    final foreground = AppColors.white;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Focus(
        onFocusChange: (focused) => setState(() => _focused = focused),
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.primary
                  ? AppColors.orange.withValues(alpha: .32)
                  : AppColors.white.withValues(alpha: active ? .22 : .18),
            ),
            boxShadow: widget.primary && active
                ? [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: .22),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.pushNamed(context, widget.route),
              child: AnimatedPadding(
                duration: duration,
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: active ? 28 : 25,
                  vertical: active ? 17 : 16,
                ),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
