import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import 'editorial_layout.dart';
import 'joyn_mark.dart';
import 'navigation_symbol.dart';

const footerGroups = [
  (
    'Candidats',
    NavigationSymbolKind.profile,
    [
      ('Le parcours', 'parcours'),
      ('Mon profil', 'profil'),
      ('Offres et favoris', 'opportunites'),
      ('Mes candidatures', 'suivi'),
    ],
  ),
  (
    'Recruteurs',
    NavigationSymbolKind.work,
    [
      ('Présenter un poste', 'entreprises'),
      ('Gérer les candidatures', 'suivi'),
      ('Comprendre les recommandations', 'matching'),
      ('Les services JOYN', 'offres'),
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
  (
    'JOYN & compte',
    NavigationSymbolKind.account,
    [
      ('Présentation de JOYN', 'presentation'),
      ('Connexion', 'connexion'),
      ('Lire un matching', 'guide-matching'),
      ('Données de navigation', 'donnees'),
    ],
  ),
];

class LandingFooter extends StatefulWidget {
  const LandingFooter({super.key, required this.onNavigate});
  final ValueChanged<String> onNavigate;
  @override
  State<LandingFooter> createState() => _LandingFooterState();
}

class _LandingFooterState extends State<LandingFooter> {
  int? expanded;
  ButtonStyle get linkStyle => ButtonStyle(
    alignment: Alignment.centerLeft,
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(vertical: JoynTokens.xs),
    ),
    backgroundColor: WidgetStatePropertyAll(
      JoynTokens.paper.withValues(alpha: 0),
    ),
    foregroundColor: const WidgetStatePropertyAll(JoynTokens.ink),
    side: WidgetStateProperty.resolveWith(
      (states) => BorderSide(
        color: states.contains(WidgetState.focused)
            ? JoynTokens.ink
            : JoynTokens.paper,
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
  @override
  Widget build(BuildContext context) => EditorialSection(
    tinted: false,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: JoynTokens.lg),
        Row(
          children: [
            const JoynMark(),
            const SizedBox(width: JoynTokens.sm),
            Text('joyn', style: Theme.of(context).textTheme.headlineLarge),
          ],
        ),
        const SizedBox(height: JoynTokens.md),
        Text(
          'Les bons points communs.\nUne vraie conversation.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: JoynTokens.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < JoynTokens.mobile) {
              return Column(
                children: [
                  for (var i = 0; i < footerGroups.length; i++) ...[
                    const Divider(),
                    Semantics(
                      expanded: expanded == i,
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          key: ValueKey('footer-group-$i'),
                          style: linkStyle,
                          onPressed: () => setState(
                            () => expanded = expanded == i ? null : i,
                          ),
                          child: Row(
                            children: [
                              NavigationSymbol(
                                kind: footerGroups[i].$2,
                                active: expanded == i,
                                size: JoynTokens.smallSymbol,
                              ),
                              const SizedBox(width: JoynTokens.sm),
                              Expanded(child: Text(footerGroups[i].$1)),
                              Text(expanded == i ? '−' : '+'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (expanded == i)
                      Padding(
                        padding: const EdgeInsets.only(left: JoynTokens.md),
                        child: links(i),
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
                        children: [
                          Text(
                            footerGroups[i].$1,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: JoynTokens.sm),
                          links(i),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: JoynTokens.lg),
        const Divider(),
        const SizedBox(height: JoynTokens.md),
        Wrap(
          spacing: JoynTokens.lg,
          runSpacing: JoynTokens.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('JOYN · Emploi et recrutement'),
            const Text('FR / Français'),
            TextButton(
              style: linkStyle,
              onPressed: () => widget.onNavigate('accessibilite'),
              child: const Text('Accessibilité'),
            ),
            TextButton(
              style: linkStyle,
              onPressed: () => widget.onNavigate('hero'),
              child: const Text('Retour en haut ↑'),
            ),
          ],
        ),
      ],
    ),
  );
}
