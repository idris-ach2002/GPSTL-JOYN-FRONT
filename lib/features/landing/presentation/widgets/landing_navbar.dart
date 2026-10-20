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
        shape: StadiumBorder(side: BorderSide(
          color: AppColors.greyLight.withValues(alpha: .6))),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxWidth < 1080;
            final brand = TextButton(
              onPressed: () => _navigate(LandingSection.hero),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                JoynMark(size: 34), SizedBox(width: 10),
                Text('joyn', style: TextStyle(fontSize: 25,
                  color: AppColors.navy, fontWeight: FontWeight.w800)),
              ]),
            );
            final actions = Row(mainAxisSize: MainAxisSize.min, children: [
              _AuthButton(label: 'Connexion', route: '/connexion'),
              const SizedBox(width: 8),
              _AuthButton(label: 'Inscription', route: '/inscription', filled: true),
            ]);
            final menu = MenuAnchor(
              menuChildren: [
                for (final link in _links.entries)
                  MenuItemButton(onPressed: () => _navigate(link.key),
                    child: Text(link.value)),
              ],
              builder: (_, controller, child) => IconButton(
                tooltip: 'Ouvrir la navigation',
                onPressed: () => controller.isOpen
                  ? controller.close() : controller.open(),
                icon: const Icon(Icons.menu_rounded),
              ),
            );
            if (constraints.maxWidth < 650) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [brand, const Spacer(), menu]),
                const SizedBox(height: 6),
                actions,
              ]);
            }
            return Row(children: [
              brand, const Spacer(),
              if (compact) menu else Container(
                decoration: BoxDecoration(
                  color: AppColors.blueGrey10,
                  borderRadius: BorderRadius.circular(100)),
                child: Row(children: [
                  for (final link in _links.entries)
                    TextButton(
                      onPressed: () => _navigate(link.key),
                      style: TextButton.styleFrom(
                        foregroundColor: _selected == link.key
                          ? AppColors.orange : AppColors.navy),
                      child: Text(link.value)),
                ]),
              ),
              const Spacer(), actions,
            ]);
          }),
        ),
      ),
    ),
  );
}

/// Mouvement au survol et au focus uniquement, sans animation perpétuelle.
/// La préférence système de réduction des mouvements neutralise les effets.
class _AuthButton extends StatefulWidget {
  const _AuthButton({required this.label, required this.route, this.filled = false});
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
    final active = (_hovered || _focused) && !MediaQuery.disableAnimationsOf(context);
    final duration = MediaQuery.disableAnimationsOf(context)
      ? Duration.zero : const Duration(milliseconds: 220);
    void open() => Navigator.pushNamed(context, widget.route);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Focus(
        onFocusChange: (value) => setState(() => _focused = value),
        child: AnimatedScale(
          scale: active ? 1.04 : 1, duration: duration,
          child: AnimatedContainer(
            duration: duration,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: active ? [BoxShadow(
                color: AppColors.orange.withValues(alpha: .24),
                blurRadius: 18, offset: const Offset(0, 6))] : [],
            ),
            child: widget.filled
              ? FilledButton(onPressed: open,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.orange),
                  child: Text(widget.label))
              : OutlinedButton(onPressed: open, child: Text(widget.label)),
          ),
        ),
      ),
    );
  }
}
