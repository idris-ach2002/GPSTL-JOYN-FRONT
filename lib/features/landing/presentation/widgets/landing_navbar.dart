import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_shadows.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import 'joyn_mark.dart';

class LandingNavbar extends StatefulWidget {
  const LandingNavbar({super.key});

  @override
  State<LandingNavbar> createState() => _LandingNavbarState();
}

class _LandingNavbarState extends State<LandingNavbar> {
  OverlayEntry? _megaMenuEntry;
  Timer? _closeTimer;

  String? _activeMenu;

  bool _mobileMenuOpen = false;

  @override
  void dispose() {
    _closeTimer?.cancel();
    _megaMenuEntry?.remove();

    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Desktop mega menu
  // --------------------------------------------------------------------------

  void _showMegaMenu(String section) {
    _closeTimer?.cancel();

    if (_activeMenu == section && _megaMenuEntry != null) {
      return;
    }

    _megaMenuEntry?.remove();

    setState(() {
      _activeMenu = section;
    });

    _megaMenuEntry = OverlayEntry(
      builder: (overlayContext) {
        final screenWidth = MediaQuery.sizeOf(overlayContext).width;

        final panelWidth = math.min(screenWidth - 48, 1120.0);

        return Positioned(
          top: 92,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: MouseRegion(
                onEnter: (_) {
                  _closeTimer?.cancel();
                },
                onExit: (_) {
                  _scheduleMegaMenuClose();
                },
                child: SizedBox(
                  width: panelWidth,
                  child: _MegaMenuPanel(
                    section: section,
                    onClose: _closeMegaMenu,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_megaMenuEntry!);
  }

  void _toggleMegaMenu(String section) {
    if (_activeMenu == section && _megaMenuEntry != null) {
      _closeMegaMenu();
      return;
    }

    _showMegaMenu(section);
  }

  void _scheduleMegaMenuClose() {
    _closeTimer?.cancel();

    _closeTimer = Timer(const Duration(milliseconds: 220), _closeMegaMenu);
  }

  void _closeMegaMenu() {
    _closeTimer?.cancel();

    _megaMenuEntry?.remove();
    _megaMenuEntry = null;

    if (mounted) {
      setState(() {
        _activeMenu = null;
      });
    }
  }

  // --------------------------------------------------------------------------
  // Mobile menu
  // --------------------------------------------------------------------------

  void _toggleMobileMenu() {
    setState(() {
      _mobileMenuOpen = !_mobileMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ContentContainer(
      maxWidth: 1440,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Le précédent breakpoint utilisait un desktop trop tôt.
            // À environ 916 px disponibles, la Row débordait.
            //
            // On utilise donc une navbar compacte sous ~1040 px.
            final useDesktopNavigation = constraints.maxWidth >= 1040;

            if (useDesktopNavigation) {
              return _DesktopNavbar(
                activeMenu: _activeMenu,
                onMenuEnter: _showMegaMenu,
                onMenuExit: _scheduleMegaMenuClose,
                onMenuTap: _toggleMegaMenu,
                onSimpleItemEnter: _closeMegaMenu,
              );
            }

            // Ne jamais appeler setState() directement pendant build().
            //
            // Si un mega-menu desktop était encore ouvert lors d'un
            // redimensionnement vers mobile/tablette, on le ferme une fois
            // la frame courante terminée.
            if (_megaMenuEntry != null || _activeMenu != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) {
                  return;
                }

                if (_megaMenuEntry != null || _activeMenu != null) {
                  _closeMegaMenu();
                }
              });
            }

            return _MobileNavbar(
              open: _mobileMenuOpen,
              onToggle: _toggleMobileMenu,
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// DESKTOP
// =============================================================================

class _DesktopNavbar extends StatelessWidget {
  const _DesktopNavbar({
    required this.activeMenu,
    required this.onMenuEnter,
    required this.onMenuExit,
    required this.onMenuTap,
    required this.onSimpleItemEnter,
  });

  final String? activeMenu;

  final ValueChanged<String> onMenuEnter;
  final VoidCallback onMenuExit;
  final ValueChanged<String> onMenuTap;
  final VoidCallback onSimpleItemEnter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _JoynLogo(),

        const SizedBox(width: 28),

        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _NavigationPill(
                activeMenu: activeMenu,
                onMenuEnter: onMenuEnter,
                onMenuExit: onMenuExit,
                onMenuTap: onMenuTap,
                onSimpleItemEnter: onSimpleItemEnter,
              ),
            ),
          ),
        ),

        const SizedBox(width: 28),

        const _DesktopActions(),
      ],
    );
  }
}

class _NavigationPill extends StatelessWidget {
  const _NavigationPill({
    required this.activeMenu,
    required this.onMenuEnter,
    required this.onMenuExit,
    required this.onMenuTap,
    required this.onSimpleItemEnter,
  });

  final String? activeMenu;

  final ValueChanged<String> onMenuEnter;
  final VoidCallback onMenuExit;
  final ValueChanged<String> onMenuTap;
  final VoidCallback onSimpleItemEnter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DesktopNavItem(
            label: 'Comment ça marche',
            onEnter: onSimpleItemEnter,
            onTap: () {},
          ),

          _DesktopNavItem(
            label: 'Fonctionnalités',
            hasMegaMenu: true,
            selected: activeMenu == 'Fonctionnalités',
            onEnter: () {
              onMenuEnter('Fonctionnalités');
            },
            onExit: onMenuExit,
            onTap: () {
              onMenuTap('Fonctionnalités');
            },
          ),

          _DesktopNavItem(
            label: 'Entreprises',
            hasMegaMenu: true,
            selected: activeMenu == 'Entreprises',
            onEnter: () {
              onMenuEnter('Entreprises');
            },
            onExit: onMenuExit,
            onTap: () {
              onMenuTap('Entreprises');
            },
          ),

          _DesktopNavItem(
            label: 'Témoignages',
            onEnter: onSimpleItemEnter,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _DesktopNavItem extends StatefulWidget {
  const _DesktopNavItem({
    required this.label,
    required this.onEnter,
    required this.onTap,
    this.onExit,
    this.hasMegaMenu = false,
    this.selected = false,
  });

  final String label;

  final VoidCallback onEnter;
  final VoidCallback onTap;
  final VoidCallback? onExit;

  final bool hasMegaMenu;
  final bool selected;

  @override
  State<_DesktopNavItem> createState() => _DesktopNavItemState();
}

class _DesktopNavItemState extends State<_DesktopNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = _hovered || widget.selected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });

        widget.onEnter();
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });

        widget.onExit?.call();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: highlighted
                ? AppColors.white.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: AppColors.white.withValues(
                    alpha: highlighted ? 1 : 0.88,
                  ),
                  fontSize: 13,
                  fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                ),
              ),

              if (widget.hasMegaMenu) ...[
                const SizedBox(width: 5),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 160),
                  turns: widget.selected ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.white.withValues(alpha: 0.72),
                    size: 17,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopActions extends StatelessWidget {
  const _DesktopActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavActionButton(
          label: 'Se connecter',
          filled: false,
          onPressed: () {},
        ),

        const SizedBox(width: 10),

        _NavActionButton(label: 'Commencer', filled: true, onPressed: () {}),
      ],
    );
  }
}

// =============================================================================
// MOBILE / TABLET
// =============================================================================
// =============================================================================
// MOBILE / TABLET
// =============================================================================

class _MobileNavbar extends StatelessWidget {
  const _MobileNavbar({required this.open, required this.onToggle});

  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const _JoynLogo(),

            const Spacer(),

            Semantics(
              button: true,
              expanded: open,
              label: open ? 'Fermer le menu' : 'Ouvrir le menu',
              child: _MobileMenuButton(open: open, onPressed: onToggle),
            ),
          ],
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: open
              ? const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.md),
                  child: _MobileMenuPanel(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _MobileMenuButton extends StatelessWidget {
  const _MobileMenuButton({required this.open, required this.onPressed});

  final bool open;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: open ? AppColors.white : AppColors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.16)),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: Icon(
            open ? Icons.close_rounded : Icons.menu_rounded,
            key: ValueKey(open),
            color: open ? AppColors.navy : AppColors.white,
          ),
        ),
      ),
    );
  }
}

class _MobileMenuPanel extends StatefulWidget {
  const _MobileMenuPanel();

  @override
  State<_MobileMenuPanel> createState() => _MobileMenuPanelState();
}

class _MobileMenuPanelState extends State<_MobileMenuPanel> {
  String? _expandedSection;

  void _toggleSection(String section) {
    setState(() {
      if (_expandedSection == section) {
        _expandedSection = null;
      } else {
        _expandedSection = section;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.grey20),
        boxShadow: AppShadows.floating,
      ),
      child: Column(
        children: [
          const _MobileDirectMenuItem(
            icon: Icons.route_outlined,
            label: 'Comment ça marche',
          ),

          _MobileExpandableMenuItem(
            icon: Icons.auto_awesome_outlined,
            label: 'Fonctionnalités',
            expanded: _expandedSection == 'features',
            onTap: () {
              _toggleSection('features');
            },
            children: const [
              _MobileSubMenuItem(
                icon: Icons.auto_awesome_rounded,
                title: 'Matching intelligent',
                description: 'Comprends pourquoi chaque offre te correspond.',
              ),
              _MobileSubMenuItem(
                icon: Icons.swipe_outlined,
                title: 'Découverte fluide',
                description: 'Explore les opportunités adaptées à ton profil.',
              ),
              _MobileSubMenuItem(
                icon: Icons.forum_outlined,
                title: 'Échange direct',
                description: 'Discute dès que candidat et entreprise matchent.',
              ),
            ],
          ),

          _MobileExpandableMenuItem(
            icon: Icons.business_outlined,
            label: 'Entreprises',
            expanded: _expandedSection == 'companies',
            onTap: () {
              _toggleSection('companies');
            },
            children: const [
              _MobileSubMenuItem(
                icon: Icons.post_add_outlined,
                title: 'Publier une offre',
                description: 'Crée des opportunités ciblées et lisibles.',
              ),
              _MobileSubMenuItem(
                icon: Icons.people_alt_outlined,
                title: 'Trouver les bons profils',
                description: 'Découvre les candidats les plus compatibles.',
              ),
              _MobileSubMenuItem(
                icon: Icons.insights_outlined,
                title: 'Piloter le recrutement',
                description: 'Centralise candidatures, échanges et suivi.',
              ),
            ],
          ),

          const _MobileDirectMenuItem(
            icon: Icons.format_quote_rounded,
            label: 'Témoignages',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(),
          ),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.grey),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Se connecter',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Commencer',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MOBILE DIRECT LINK
// =============================================================================

class _MobileDirectMenuItem extends StatelessWidget {
  const _MobileDirectMenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 15,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.navy, size: 21),

            const SizedBox(width: AppSpacing.sm),

            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.grey,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// MOBILE EXPANDABLE LINK
// =============================================================================

class _MobileExpandableMenuItem extends StatelessWidget {
  const _MobileExpandableMenuItem({
    required this.icon,
    required this.label,
    required this.expanded,
    required this.onTap,
    required this.children,
  });

  final IconData icon;
  final String label;

  final bool expanded;
  final VoidCallback onTap;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: expanded ? AppColors.background : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: expanded ? AppColors.orange : AppColors.navy,
                  size: 21,
                ),

                const SizedBox(width: AppSpacing.sm),

                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 16,
                      fontWeight: expanded ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),

                AnimatedRotation(
                  duration: const Duration(milliseconds: 180),
                  turns: expanded ? 0.5 : 0,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.grey,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.xs,
                    bottom: AppSpacing.sm,
                    left: AppSpacing.sm,
                  ),
                  child: Column(children: children),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// =============================================================================
// MOBILE SUBMENU
// =============================================================================

class _MobileSubMenuItem extends StatefulWidget {
  const _MobileSubMenuItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  State<_MobileSubMenuItem> createState() => _MobileSubMenuItemState();
}

class _MobileSubMenuItemState extends State<_MobileSubMenuItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });
      },
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: _pressed
              ? AppColors.blue.withValues(alpha: 0.08)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.grey20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(widget.icon, color: AppColors.blue, size: 19),
            ),

            const SizedBox(width: AppSpacing.sm),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.description,
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.xs),

            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.grey,
                size: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// LOGO
// =============================================================================

class _JoynLogo extends StatelessWidget {
  const _JoynLogo();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        JoynMark(),

        SizedBox(width: AppSpacing.sm),

        Text(
          'joyn',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 23,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CTA NAVBAR
// =============================================================================

class _NavActionButton extends StatefulWidget {
  const _NavActionButton({
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final bool filled;
  final VoidCallback onPressed;

  @override
  State<_NavActionButton> createState() => _NavActionButtonState();
}

class _NavActionButtonState extends State<_NavActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _hovered ? 1.025 : 1,
        child: FilledButton(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: widget.filled
                ? AppColors.white
                : AppColors.white.withValues(alpha: 0.07),
            foregroundColor: widget.filled ? AppColors.navy : AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            side: widget.filled
                ? BorderSide.none
                : BorderSide(color: AppColors.white.withValues(alpha: 0.16)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MEGA MENU
// =============================================================================

class _MegaMenuPanel extends StatelessWidget {
  const _MegaMenuPanel({required this.section, required this.onClose});

  final String section;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isCompanies = section == 'Entreprises';

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey20),
        boxShadow: AppShadows.floating,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompanies
                          ? 'Recrute autrement.'
                          : 'Tout JOYN en un coup d’œil.',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      isCompanies
                          ? 'Matching, offres et relation candidat réunis dans une seule expérience.'
                          : 'Découvre les fonctionnalités pensées pour rendre la recherche plus simple.',
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                tooltip: 'Fermer',
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, color: AppColors.navy),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: isCompanies
                ? const [
                    Expanded(
                      child: _MegaMenuCard(
                        icon: Icons.post_add_outlined,
                        title: 'Publier une offre',
                        description:
                            'Crée des opportunités claires et ciblées.',
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _MegaMenuCard(
                        icon: Icons.people_alt_outlined,
                        title: 'Trouver les bons profils',
                        description:
                            'Découvre des candidats selon leur compatibilité.',
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _MegaMenuCard(
                        icon: Icons.insights_outlined,
                        title: 'Piloter le recrutement',
                        description:
                            'Centralise candidatures, échanges et suivi.',
                      ),
                    ),
                  ]
                : const [
                    Expanded(
                      child: _MegaMenuCard(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Matching intelligent',
                        description: 'Comprends immédiatement pourquoi une offre te correspond.',
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _MegaMenuCard(
                        icon: Icons.swipe_outlined,
                        title: 'Découverte fluide',
                        description:
                            'Explore rapidement les opportunités qui comptent.',
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _MegaMenuCard(
                        icon: Icons.forum_outlined,
                        title: 'Échange direct',
                        description:
                            'Discute dès que candidat et entreprise matchent.',
                      ),
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}

class _MegaMenuCard extends StatefulWidget {
  const _MegaMenuCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  State<_MegaMenuCard> createState() => _MegaMenuCardState();
}

class _MegaMenuCardState extends State<_MegaMenuCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.background : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _hovered
                ? AppColors.blue.withValues(alpha: 0.30)
                : AppColors.grey20,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _hovered
                    ? AppColors.blue.withValues(alpha: 0.14)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                widget.icon,
                color: _hovered ? AppColors.blue : AppColors.navy,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Text(
              widget.title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              widget.description,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
