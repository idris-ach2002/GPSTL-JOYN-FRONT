import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_shadows.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../navigation/landing_section.dart';
import 'joyn_mark.dart';

class LandingNavbar extends StatefulWidget {
  const LandingNavbar({
    required this.onNavigate,
    this.companyMode = false,
    this.activeSection = LandingSection.hero,
    super.key,
  });

  final LandingNavigate onNavigate;
  final bool companyMode;
  final LandingSection activeSection;

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

  void _navigate(LandingSection destination) {
    _closeMegaMenu();

    if (_mobileMenuOpen && mounted) {
      setState(() {
        _mobileMenuOpen = false;
      });
    }

    widget.onNavigate(destination);
  }

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
                    onNavigate: _navigate,
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

    if (_megaMenuEntry == null && _activeMenu == null) {
      return;
    }

    _megaMenuEntry?.remove();
    _megaMenuEntry = null;

    if (mounted) {
      setState(() {
        _activeMenu = null;
      });
    }
  }

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
            final useDesktopNavigation = constraints.maxWidth >= 1040;

            if (useDesktopNavigation) {
              return _DesktopNavbar(
                activeMenu: _activeMenu,
                onNavigate: _navigate,
                onMenuEnter: _showMegaMenu,
                onMenuExit: _scheduleMegaMenuClose,
                onMenuTap: _toggleMegaMenu,
                companyMode: widget.companyMode,
                activeSection: widget.activeSection,
              );
            }

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
              onNavigate: _navigate,
              companyMode: widget.companyMode,
            );
          },
        ),
      ),
    );
  }
}

class _DesktopNavbar extends StatelessWidget {
  const _DesktopNavbar({
    required this.activeMenu,
    required this.onNavigate,
    required this.onMenuEnter,
    required this.onMenuExit,
    required this.onMenuTap,
    required this.companyMode,
    required this.activeSection,
  });

  final String? activeMenu;
  final LandingNavigate onNavigate;

  final ValueChanged<String> onMenuEnter;

  final VoidCallback onMenuExit;

  final ValueChanged<String> onMenuTap;
  final bool companyMode;
  final LandingSection activeSection;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _JoynLogo(
          onTap: () {
            onNavigate(LandingSection.hero);
          },
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DesktopNavItem(
                      label: 'Comment ça marche',
                      active: activeSection == LandingSection.howItWorks,
                      onTap: () {
                        onNavigate(LandingSection.howItWorks);
                      },
                    ),
                    _DesktopNavItem(
                      label: 'Fonctionnalités',
                      hasMegaMenu: true,
                      selected: activeMenu == 'Fonctionnalités',
                      active: activeSection == LandingSection.features,
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
                      active: activeSection == LandingSection.companies,
                      onEnter: () {
                        onMenuEnter('Entreprises');
                      },
                      onExit: onMenuExit,
                      onTap: () {
                        onMenuTap('Entreprises');
                      },
                    ),
                    _DesktopNavItem(
                      label: 'Preuves',
                      active: activeSection == LandingSection.testimonials,
                      onTap: () {
                        onNavigate(LandingSection.testimonials);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 28),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NavActionButton(
              label: 'Se connecter',
              filled: false,
              onPressed: () {},
            ),
            const SizedBox(width: 10),
            _NavActionButton(
              label: companyMode ? 'Côté recruteur' : 'Voir les offres',
              filled: true,
              onPressed: () {
                onNavigate(
                  companyMode
                      ? LandingSection.companies
                      : LandingSection.opportunities,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _DesktopNavItem extends StatefulWidget {
  const _DesktopNavItem({
    required this.label,
    required this.onTap,
    this.onEnter,
    this.onExit,
    this.hasMegaMenu = false,
    this.selected = false,
    this.active = false,
  });

  final String label;

  final VoidCallback onTap;
  final VoidCallback? onEnter;
  final VoidCallback? onExit;

  final bool hasMegaMenu;
  final bool selected;
  final bool active;

  @override
  State<_DesktopNavItem> createState() => _DesktopNavItemState();
}

class _DesktopNavItemState extends State<_DesktopNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = _hovered || widget.selected || widget.active;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });

        widget.onEnter?.call();
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

class _MobileNavbar extends StatelessWidget {
  const _MobileNavbar({
    required this.open,
    required this.onToggle,
    required this.onNavigate,
    required this.companyMode,
  });

  final bool open;
  final VoidCallback onToggle;

  final LandingNavigate onNavigate;
  final bool companyMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _JoynLogo(
              onTap: () {
                onNavigate(LandingSection.hero);
              },
            ),
            const Spacer(),
            _MobileMenuButton(open: open, onPressed: onToggle),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: open
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: _MobileMenuPanel(
                    onNavigate: onNavigate,
                    companyMode: companyMode,
                  ),
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
        icon: Icon(
          open ? Icons.close_rounded : Icons.menu_rounded,
          color: open ? AppColors.navy : AppColors.white,
        ),
      ),
    );
  }
}

class _MobileMenuPanel extends StatefulWidget {
  const _MobileMenuPanel({required this.onNavigate, required this.companyMode});

  final LandingNavigate onNavigate;
  final bool companyMode;

  @override
  State<_MobileMenuPanel> createState() => _MobileMenuPanelState();
}

class _MobileMenuPanelState extends State<_MobileMenuPanel> {
  String? _expanded;

  void _toggle(String value) {
    setState(() {
      _expanded = _expanded == value ? null : value;
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
        boxShadow: AppShadows.floating,
      ),
      child: Column(
        children: [
          _MobileDirectItem(
            icon: Icons.route_outlined,
            label: 'Comment ça marche',
            onTap: () {
              widget.onNavigate(LandingSection.howItWorks);
            },
          ),
          _MobileExpandableItem(
            icon: Icons.auto_awesome_outlined,
            label: 'Fonctionnalités',
            expanded: _expanded == 'features',
            onTap: () {
              _toggle('features');
            },
            children: [
              _MobileSubItem(
                title: 'Matching intelligent',
                onTap: () {
                  widget.onNavigate(LandingSection.features);
                },
              ),
              _MobileSubItem(
                title: 'Découverte fluide',
                onTap: () {
                  widget.onNavigate(LandingSection.features);
                },
              ),
              _MobileSubItem(
                title: 'Échange direct',
                onTap: () {
                  widget.onNavigate(LandingSection.features);
                },
              ),
            ],
          ),
          _MobileExpandableItem(
            icon: Icons.business_outlined,
            label: 'Entreprises',
            expanded: _expanded == 'companies',
            onTap: () {
              _toggle('companies');
            },
            children: [
              _MobileSubItem(
                title: 'Publier une offre',
                onTap: () {
                  widget.onNavigate(LandingSection.companies);
                },
              ),
              _MobileSubItem(
                title: 'Trouver les bons profils',
                onTap: () {
                  widget.onNavigate(LandingSection.companies);
                },
              ),
              _MobileSubItem(
                title: 'Piloter le recrutement',
                onTap: () {
                  widget.onNavigate(LandingSection.companies);
                },
              ),
            ],
          ),
          _MobileDirectItem(
            icon: Icons.format_quote_rounded,
            label: 'Preuves',
            onTap: () {
              widget.onNavigate(LandingSection.testimonials);
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Se connecter'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onNavigate(
                  widget.companyMode
                      ? LandingSection.companies
                      : LandingSection.opportunities,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.white,
              ),
              child: Text(
                widget.companyMode ? 'Côté recruteur' : 'Voir les offres',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileDirectItem extends StatelessWidget {
  const _MobileDirectItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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

class _MobileExpandableItem extends StatelessWidget {
  const _MobileExpandableItem({
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
          key: ValueKey('mobile-nav-$label'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 15,
            ),
            child: Row(
              children: [
                Icon(icon, color: expanded ? AppColors.orange : AppColors.navy),
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
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: 28,
                    bottom: AppSpacing.sm,
                  ),
                  child: Column(children: children),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _MobileSubItem extends StatelessWidget {
  const _MobileSubItem({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('mobile-submenu-$title'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _JoynLogo extends StatelessWidget {
  const _JoynLogo({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: const Padding(
        padding: EdgeInsets.all(2),
        child: Row(
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
        ),
      ),
    );
  }
}

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

class _MegaMenuPanel extends StatelessWidget {
  const _MegaMenuPanel({
    required this.section,
    required this.onNavigate,
    required this.onClose,
  });

  final String section;
  final LandingNavigate onNavigate;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final companies = section == 'Entreprises';

    final items = companies
        ? const [
            (Icons.post_add_outlined, 'Publier une offre'),
            (Icons.people_alt_outlined, 'Trouver les bons profils'),
            (Icons.insights_outlined, 'Piloter le recrutement'),
          ]
        : const [
            (Icons.auto_awesome_outlined, 'Matching intelligent'),
            (Icons.swipe_outlined, 'Découverte fluide'),
            (Icons.forum_outlined, 'Échange direct'),
          ];

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
                child: Text(
                  companies
                      ? 'JOYN pour les entreprises.'
                      : 'Découvre l’expérience JOYN.',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Expanded(
                  child: _MegaCard(
                    icon: items[i].$1,
                    title: items[i].$2,
                    onTap: () {
                      onNavigate(
                        companies
                            ? LandingSection.companies
                            : LandingSection.features,
                      );
                    },
                  ),
                ),
                if (i != items.length - 1) const SizedBox(width: AppSpacing.md),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MegaCard extends StatefulWidget {
  const _MegaCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  State<_MegaCard> createState() => _MegaCardState();
}

class _MegaCardState extends State<_MegaCard> {
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.background : AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _hovered
                  ? AppColors.blue.withValues(alpha: 0.28)
                  : AppColors.grey20,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.icon, color: AppColors.blue),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.orange,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
