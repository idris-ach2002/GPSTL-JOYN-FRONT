import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../navigation/landing_section.dart';
import 'joyn_mark.dart';
import 'landing_motion.dart';

/// Navigation web JOYN.
///
/// La barre reste très légère dans le hero puis devient une surface flottante
/// bleu nuit pendant le scroll. Les CTA d'accès au compte sont volontairement
/// asymétriques : « Connexion » reste secondaire alors que « Inscription »
/// porte l'action principale.
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
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.scrollController,
    builder: (context, _) {
      final offset = widget.scrollController.hasClients
          ? widget.scrollController.offset
          : 0.0;
      final progress = (offset / 140).clamp(0.0, 1.0).toDouble();
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      final effectiveProgress = reduceMotion && offset > 0 ? 1.0 : progress;

      return ContentContainer(
        maxWidth: 1440 - (220 * effectiveProgress),
        child: Padding(
          padding: EdgeInsets.only(
            top: 18 - (8 * effectiveProgress),
            bottom: 8,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(
                alpha: .03 + (.94 * effectiveProgress),
              ),
              borderRadius: BorderRadius.circular(
                24 - (5 * effectiveProgress),
              ),
              border: Border.all(
                color: AppColors.white.withValues(
                  alpha: .02 + (.13 * effectiveProgress),
                ),
              ),
              boxShadow: effectiveProgress == 0
                  ? const []
                  : [
                      BoxShadow(
                        color: AppColors.navy.withValues(
                          alpha: .22 * effectiveProgress,
                        ),
                        blurRadius: 34 * effectiveProgress,
                        offset: Offset(0, 14 * effectiveProgress),
                      ),
                    ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10 + (6 * effectiveProgress),
                vertical: 8 - (2 * effectiveProgress),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 1080;
                  final narrow = constraints.maxWidth < 690;

                  final brand = LandingReveal(
                    duration: const Duration(milliseconds: 460),
                    offset: const Offset(0, -12),
                    child: TextButton(
                      onPressed: () => _navigate(LandingSection.hero),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        foregroundColor: AppColors.white,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          JoynMark(size: 32),
                          SizedBox(width: 9),
                          Text(
                            'joyn',
                            style: TextStyle(
                              fontSize: 23,
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
                        const SizedBox(width: 9),
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
                      color: AppColors.white,
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
                          delay: const Duration(milliseconds: 110),
                          duration: const Duration(milliseconds: 480),
                          offset: const Offset(0, -10),
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
      );
    },
  );
}

class _NavigationLinks extends StatelessWidget {
  const _NavigationLinks({required this.selected, required this.onNavigate});

  final LandingSection selected;
  final ValueChanged<LandingSection> onNavigate;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.white.withValues(alpha: .055),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.white.withValues(alpha: .11)),
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
      decoration: BoxDecoration(
        color: widget.selected
            ? AppColors.white.withValues(alpha: .11)
            : _hovered
            ? AppColors.white.withValues(alpha: .065)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
      ),
      child: TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          foregroundColor: widget.selected
              ? AppColors.orangeLight
              : AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        ),
        child: Text(
          widget.label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    ),
  );
}

/// CTA asymétrique de la navbar.
///
/// Le secondaire se transforme en surface blanche au survol. Le primaire reste
/// orange et anime surtout sa pastille terminale, ce qui évite l'effet de deux
/// boutons Material identiques ou d'une simple capsule « glass ».
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
        : const Duration(milliseconds: 300);

    final background = widget.primary
        ? (active ? AppColors.orangeLight : AppColors.orange)
        : (active ? AppColors.white : Colors.transparent);
    final foreground = widget.primary
        ? AppColors.white
        : (active ? AppColors.navy : AppColors.white);

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
            borderRadius: BorderRadius.circular(widget.primary ? 15 : 14),
            border: Border.all(
              color: widget.primary
                  ? AppColors.orange.withValues(alpha: .2)
                  : active
                  ? AppColors.white
                  : AppColors.white.withValues(alpha: .34),
            ),
            boxShadow: widget.primary && active
                ? [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: .25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.primary ? 15 : 14),
              onTap: () => Navigator.pushNamed(context, widget.route),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  widget.primary ? 16 : 17,
                  8,
                  widget.primary ? 8 : 14,
                  8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSlide(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      offset: active ? const Offset(-.035, 0) : Offset.zero,
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(width: widget.primary ? 13 : 9),
                    if (widget.primary)
                      AnimatedContainer(
                        duration: duration,
                        curve: Curves.easeOutCubic,
                        width: active ? 36 : 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? AppColors.white
                              : AppColors.white.withValues(alpha: .16),
                        ),
                        child: AnimatedSlide(
                          duration: duration,
                          curve: Curves.easeOutCubic,
                          offset: active ? const Offset(.08, 0) : Offset.zero,
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 17,
                            color: active ? AppColors.orange : AppColors.white,
                          ),
                        ),
                      )
                    else
                      AnimatedSlide(
                        duration: duration,
                        curve: Curves.easeOutCubic,
                        offset: active ? const Offset(.18, 0) : Offset.zero,
                        child: Icon(
                          Icons.north_east_rounded,
                          size: 17,
                          color: foreground,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
