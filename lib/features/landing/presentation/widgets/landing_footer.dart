// Navigation de fin de page, contrastée et animée à l’interaction.
import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import 'editorial_layout.dart';
import 'joyn_mark.dart';
import 'navigation_symbol.dart';

/// Liens utiles du pied de page, sans rubrique de données ni sélecteur de langue.
const footerGroups = [
  (
    'Candidats',
    NavigationSymbolKind.profile,
    [
      ('Les avantages candidat', 'benefices-candidat'),
      ('Mon profil', 'profil'),
      ('Offres et favoris', 'opportunites'),
      ('Mes candidatures', 'suivi'),
    ],
  ),
  (
    'Recruteurs',
    NavigationSymbolKind.company,
    [
      ('Les avantages recruteur', 'benefices-recruteur'),
      ('Présenter un poste', 'entreprises'),
      ('Gérer les candidatures', 'suivi'),
      ('Les recommandations', 'matching'),
    ],
  ),
  (
    'Formules',
    NavigationSymbolKind.comparePlans,
    [
      ('Basic, Standard, Plus et Pro', 'plans-candidat'),
      ('Membre et Membre premium', 'plans-entreprise'),
      ('Connexion', 'connexion'),
    ],
  ),
  (
    'Assistance',
    NavigationSymbolKind.support,
    [
      ('Centre d’aide', 'assistance'),
      ('Questions fréquentes', 'questions'),
      ('Guide du profil', 'guide-profil'),
      ('Préparer un entretien', 'guide-entretien'),
    ],
  ),
];

/// Colonnes sur ordinateur, panneaux dépliables sur mobile et tracé à la sélection.
class LandingFooter extends StatefulWidget {
  const LandingFooter({super.key, required this.onNavigate});
  final ValueChanged<String> onNavigate;
  @override
  State<LandingFooter> createState() => _LandingFooterState();
}

class _LandingFooterState extends State<LandingFooter>
    with SingleTickerProviderStateMixin {
  int? expanded;
  int? hovered;
  late final trace = AnimationController(
    vsync: this,
    duration: JoynTokens.footerTraceDuration,
    value: 1,
  );

  void playTrace() {
    if (!MediaQuery.disableAnimationsOf(context)) {
      trace.forward(from: 0);
    }
  }

  @override
  void dispose() {
    trace.dispose();
    super.dispose();
  }

  ButtonStyle get linkStyle => ButtonStyle(
    foregroundColor: const WidgetStatePropertyAll(JoynTokens.paper),
    alignment: Alignment.centerLeft,
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(vertical: JoynTokens.sm, horizontal: JoynTokens.xs),
    ),
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)
          ? JoynTokens.navyLight
          : JoynTokens.ink,
    ),
    side: WidgetStateProperty.resolveWith(
      (states) => BorderSide(
        color: states.contains(WidgetState.focused)
            ? JoynTokens.orange
            : JoynTokens.ink,
        width: JoynTokens.focusWidth,
      ),
    ),
  );

  Widget links(int index) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final link in footerGroups[index].$3)
        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: linkStyle,
            onPressed: () => widget.onNavigate(link.$2),
            child: Text(link.$1),
          ),
        ),
    ],
  );

  Widget heading(int index, {required bool mobile}) => MouseRegion(
    onEnter: (_) {
      setState(() => hovered = index);
      playTrace();
    },
    onExit: (_) => setState(() => hovered = null),
    child: TextButton(
      key: ValueKey('footer-group-$index'),
      style: linkStyle,
      onFocusChange: (value) {
        if (value) {
          playTrace();
        }
      },
      onPressed: mobile
          ? () {
              setState(() => expanded = expanded == index ? null : index);
              playTrace();
            }
          : () => widget.onNavigate(footerGroups[index].$3.first.$2),
      child: Row(
        children: [
          NavigationSymbol(
            kind: footerGroups[index].$2,
            color: JoynTokens.paper,
            active: hovered == index || expanded == index,
            size: JoynTokens.smallSymbol,
          ),
          const SizedBox(width: JoynTokens.sm),
          Expanded(child: Text(footerGroups[index].$1)),
          if (mobile) Text(expanded == index ? '−' : '+'),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: JoynTokens.ink,
    child: EditorialSection(
      transparent: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedJoynMark(active: hovered != null || expanded != null),
              const SizedBox(width: JoynTokens.sm),
              Text(
                'joyn',
                style: Theme.of(context).textTheme.headlineLarge
                    ?.copyWith(color: JoynTokens.paper),
              ),
            ],
          ),
          const SizedBox(height: JoynTokens.lg),
          Text(
            'Une offre à lire.\nUne candidature à suivre.',
            style: Theme.of(context).textTheme.headlineLarge
                ?.copyWith(color: JoynTokens.paper),
          ),
          const SizedBox(height: JoynTokens.md),
          Text(
            'Les parcours, les formules et l’aide, au même endroit.',
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: JoynTokens.blue),
          ),
          SizedBox(
            height: JoynTokens.footerTraceHeight,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: trace,
              builder: (context, child) =>
                  CustomPaint(painter: _FooterThread(trace.value)),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < JoynTokens.mobile) {
                return Column(
                  children: [
                    for (var i = 0; i < footerGroups.length; i++) ...[
                      Divider(
                        color: JoynTokens.cyan.withValues(
                          alpha: JoynTokens.disabledAlpha,
                        ),
                      ),
                      Semantics(
                        expanded: expanded == i,
                        child: heading(i, mobile: true),
                      ),
                      AnimatedSize(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? JoynTokens.instant
                            : JoynTokens.menuDuration,
                        alignment: Alignment.topCenter,
                        child: expanded == i
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  left: JoynTokens.lg,
                                ),
                                child: links(i),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < footerGroups.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: JoynTokens.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [heading(i, mobile: false), links(i)],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: JoynTokens.lg),
          Divider(
            color: JoynTokens.cyan.withValues(alpha: JoynTokens.disabledAlpha),
          ),
          const SizedBox(height: JoynTokens.md),
          Wrap(
            spacing: JoynTokens.lg,
            runSpacing: JoynTokens.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'JOYN · Emploi et recrutement',
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: JoynTokens.paper),
              ),
              TextButton(
                style: linkStyle,
                onPressed: () => widget.onNavigate('hero'),
                child: const Text('RETOUR EN HAUT ↑'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Une courbe traverse le pied de page ; elle se redessine à l’activation d’une rubrique.
class _FooterThread extends CustomPainter {
  const _FooterThread(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..cubicTo(
        size.width * .3,
        0,
        size.width * .7,
        size.height,
        size.width,
        size.height / 2,
      );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = JoynTokens.hairline
      ..color = JoynTokens.cyan.withValues(alpha: JoynTokens.disabledAlpha);
    canvas.drawPath(path, paint);
    paint.color = JoynTokens.orange;
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FooterThread oldDelegate) =>
      oldDelegate.progress != progress;
}
