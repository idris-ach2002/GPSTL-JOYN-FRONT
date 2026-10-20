import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../navigation/landing_section.dart';
import 'joyn_mark.dart';

/// Navigation en capsule inspirée de la référence Orbix, couleurs JOYN.
///
/// Les contrôles Material assurent clavier, focus, sémantique et retour tactile.
/// Le menu compact utilise MenuAnchor plutôt qu'un OverlayEntry personnalisé.
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
  Widget build(BuildContext context) => ContentContainer(
    maxWidth: 1440,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Material(
        color: AppColors.white,
        shape: StadiumBorder(
          side: BorderSide(color: AppColors.greyLight.withValues(alpha: .6)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 1080;
              final brand = TextButton(
                onPressed: () => _navigate(LandingSection.hero),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    JoynMark(size: 34),
                    SizedBox(width: 10),
                    Text(
                      'joyn',
                      style: TextStyle(
                        fontSize: 25,
                        color: AppColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
              const login = _AuthButton(
                label: 'Connexion',
                route: '/connexion',
              );
              const register = _AuthButton(
                label: 'Inscription',
                route: '/inscription',
                filled: true,
              );
              final narrow = constraints.maxWidth < 650;
              final actions = Row(
                mainAxisSize: narrow ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (narrow) const Expanded(child: login) else login,
                  const SizedBox(width: 8),
                  if (narrow) const Expanded(child: register) else register,
                ],
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
                  icon: const Icon(Icons.menu_rounded),
                ),
              );
              if (constraints.maxWidth < 650) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [brand, const Spacer(), menu]),
                    const SizedBox(height: 6),
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
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.blueGrey10,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          for (final link in _links.entries)
                            TextButton(
                              onPressed: () => _navigate(link.key),
                              style: TextButton.styleFrom(
                                foregroundColor: _selected == link.key
                                    ? AppColors.orange
                                    : AppColors.navy,
                              ),
                              child: Text(link.value),
                            ),
                        ],
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
}

/// CTA d'accès au compte : la micro-interaction combine déplacement, halo,
/// inversion de surface et mouvement de l'icône. Aucun ticker ne tourne au repos.
class _AuthButton extends StatefulWidget {
  const _AuthButton({
    required this.label,
    required this.route,
    this.filled = false,
  });
  final String label;
  final String route;
  final bool filled;

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final active = (_hovered || _focused) && !reduceMotion;
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 360);

    final foreground = widget.filled
        ? AppColors.white
        : active
        ? AppColors.white
        : AppColors.navy;
    final background = widget.filled
        ? null
        : active
        ? AppColors.navy
        : AppColors.white;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Focus(
        onFocusChange: (value) => setState(() => _focused = value),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: active ? 1 : 0),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Transform.translate(
            offset: Offset(0, -2.5 * value),
            child: Transform.scale(
              scale: 1 + .025 * value,
              child: child,
            ),
          ),
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: background,
              gradient: widget.filled
                  ? LinearGradient(
                      begin: active ? Alignment.centerLeft : Alignment.topLeft,
                      end: active ? Alignment.centerRight : Alignment.bottomRight,
                      colors: active
                          ? const [AppColors.navy, AppColors.orange]
                          : const [AppColors.orange, AppColors.orangeLight],
                    )
                  : null,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: widget.filled
                    ? AppColors.orange.withValues(alpha: .25)
                    : active
                    ? AppColors.orange.withValues(alpha: .8)
                    : AppColors.navy.withValues(alpha: .18),
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: (widget.filled ? AppColors.orange : AppColors.blue)
                            .withValues(alpha: .28),
                        blurRadius: 28,
                        spreadRadius: 1,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const StadiumBorder(),
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => Navigator.pushNamed(context, widget.route),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: duration,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        child: Text(widget.label),
                      ),
                      const SizedBox(width: 9),
                      AnimatedContainer(
                        duration: duration,
                        width: 27,
                        height: 27,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? AppColors.white.withValues(alpha: .17)
                              : widget.filled
                              ? AppColors.white.withValues(alpha: .16)
                              : AppColors.blueGrey10,
                        ),
                        child: AnimatedSlide(
                          duration: duration,
                          offset: active ? const Offset(.12, 0) : Offset.zero,
                          child: Icon(
                            widget.filled
                                ? Icons.north_east_rounded
                                : Icons.arrow_forward_rounded,
                            size: 15,
                            color: foreground,
                          ),
                        ),
                      ),
                    ],
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
