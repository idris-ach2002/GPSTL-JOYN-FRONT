import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../navigation/landing_section.dart';
import 'joyn_mark.dart';
import 'landing_motion.dart';

/// Navigation web JOYN.
///
/// La navbar est fixe, garde toujours la même géométrie et repose sur un
/// fond opaque blanc / gris. L'opacité du fond évite que le contenu de la
/// landing (notamment les contrôles de la démo orange) transparaisse derrière
/// elle pendant le scroll.
class LandingNavbar extends StatefulWidget {
  const LandingNavbar({required this.onNavigate, super.key});

  final LandingNavigate onNavigate;

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
  Widget build(BuildContext context) {
    final softGrey = Color.lerp(AppColors.white, AppColors.greyLight, .42)!;
    final softerGrey = Color.lerp(AppColors.white, AppColors.greyLight, .24)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, softGrey, AppColors.white],
          stops: const [0, .52, 1],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.greyLight.withValues(alpha: .9),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: .08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ContentContainer(
        maxWidth: 1440,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.white, softerGrey],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.greyLight.withValues(alpha: .95),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: .07),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 1090;
                  final narrow = constraints.maxWidth < 760;

                  final brand = LandingReveal(
                    duration: const Duration(milliseconds: 420),
                    offset: const Offset(0, -8),
                    child: TextButton(
                      onPressed: () => _navigate(LandingSection.hero),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        foregroundColor: AppColors.navy,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          JoynMark(size: 32),
                          SizedBox(width: 10),
                          Text(
                            'joyn',
                            style: TextStyle(
                              fontSize: 23,
                              color: AppColors.navy,
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
                    delay: const Duration(milliseconds: 190),
                    duration: const Duration(milliseconds: 440),
                    offset: const Offset(0, -8),
                    child: Row(
                      mainAxisSize: narrow ? MainAxisSize.max : MainAxisSize.min,
                      children: [
                        if (narrow)
                          const Expanded(child: login)
                        else
                          login,
                        const SizedBox(width: 10),
                        if (narrow)
                          const Expanded(child: register)
                        else
                          register,
                      ],
                    ),
                  );

                  final menu = MenuAnchor(
                    menuChildren: [
                      for (final link in _links.entries)
                        MenuItemButton(
                          onPressed: () => _navigate(link.key),
                          child: Text(link.value),
                        ),
                    ],
                    builder: (_, controller, child) => IconButton(
                      tooltip: 'Ouvrir la navigation',
                      onPressed: () => controller.isOpen
                          ? controller.close()
                          : controller.open(),
                      color: AppColors.navy,
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  );

                  if (narrow) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(children: [brand, const Spacer(), menu]),
                        const SizedBox(height: 7),
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
                          delay: const Duration(milliseconds: 90),
                          duration: const Duration(milliseconds: 430),
                          offset: const Offset(0, -8),
                          child: _NavigationLinks(
                            selected: _selected,
                            onNavigate: _navigate,
                          ),
                        ),
                      const Spacer(),
                      actions,
                    ],
                  );
                },
              ),
            ),
          ),
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
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: AppColors.greyLight.withValues(alpha: .38),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.greyLight),
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
          : const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: widget.selected
            ? AppColors.white
            : _hovered
                ? AppColors.white.withValues(alpha: .72)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: widget.selected
            ? Border.all(color: AppColors.white)
            : null,
        boxShadow: widget.selected
            ? [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: .07),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          foregroundColor: widget.selected ? AppColors.orange : AppColors.navy,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        : const Duration(milliseconds: 240);

    final background = widget.primary
        ? (active ? AppColors.orangeLight : AppColors.orange)
        : (active
            ? AppColors.white
            : AppColors.greyLight.withValues(alpha: .2));
    final foreground = widget.primary ? AppColors.white : AppColors.navy;

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
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: widget.primary
                  ? AppColors.orange.withValues(alpha: .32)
                  : AppColors.grey.withValues(alpha: active ? .55 : .35),
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: (widget.primary ? AppColors.orange : AppColors.navy)
                          .withValues(alpha: .12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => Navigator.pushNamed(context, widget.route),
              child: AnimatedPadding(
                duration: duration,
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: active ? 23 : 21,
                  vertical: 13,
                ),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
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
