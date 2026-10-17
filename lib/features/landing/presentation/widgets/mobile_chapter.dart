// Gère les détails repliables sur mobile tout en conservant l’état des contenus masqués.
//
// Référence : doc/landing.md#mobile_chapterdart.

import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import 'navigation_symbol.dart';

/// Chapitre contrôlé de l’extérieur, repliable sans perdre son contenu.
class MobileChapter extends StatelessWidget {
  /// Initialise les paramètres de MobileChapter ; les valeurs par défaut figurent dans la signature.
  const MobileChapter({
    super.key,
    required this.id,
    required this.title,
    required this.summary,
    required this.expanded,
    required this.onToggle,
    required this.children,
    required this.kind,
  });

  /// Identifiant stable de l’élément.
  final String id;

  /// Titre affiché dans cette composition.
  final String title;

  /// Résumé visible lorsque le chapitre est replié.
  final String summary;

  /// Indice du détail ouvert, ou état ouvert/fermé selon le composant.
  final bool expanded;

  /// Action de dépliage ou de repli du chapitre.
  final VoidCallback onToggle;

  /// Contenus du chapitre, conservés lorsque celui-ci est replié.
  final List<Widget> children;

  /// Dessin vectoriel à utiliser.
  final NavigationSymbolKind kind;

  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: JoynTokens.md,
          vertical: JoynTokens.sm,
        ),
        child: Semantics(
          expanded: expanded,
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              key: ValueKey('chapter-$id'),
              style: const ButtonStyle(
                alignment: Alignment.centerLeft,
                padding: WidgetStatePropertyAll(EdgeInsets.all(JoynTokens.sm)),
              ),
              onPressed: onToggle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NavigationSymbol(
                        kind: kind,
                        active: expanded,
                        size: JoynTokens.smallSymbol,
                      ),
                      const SizedBox(width: JoynTokens.sm),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: JoynTokens.sm),
                  Text(summary),
                  const SizedBox(height: JoynTokens.sm),
                  Text(
                    expanded ? 'RÉDUIRE LES DÉTAILS −' : 'VOIR LES DÉTAILS +',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // Keep local forms and favorites alive without exposing hidden controls.
      ExcludeFocus(
        excluding: !expanded,
        child: TickerMode(
          enabled: expanded,
          child: Offstage(
            offstage: !expanded,
            child: Column(children: children),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: JoynTokens.md),
        child: Divider(),
      ),
    ],
  );
}

/// Commande autonome qui affiche ou masque une scène sur mobile.
class MobileReveal extends StatefulWidget {
  /// Initialise les paramètres de MobileReveal ; les valeurs par défaut figurent dans la signature.
  const MobileReveal({super.key, required this.label, required this.child});

  /// Libellé présenté à l’utilisateur.
  final String label;

  /// Contenu enveloppé par le composant.
  final Widget child;

  /// Crée l’état local associé au widget.
  @override
  State<MobileReveal> createState() => _MobileRevealState();
}

/// État de MobileReveal ; définit ses données mutables et son rendu.
class _MobileRevealState extends State<MobileReveal> {
  /// Indice du détail ouvert, ou état ouvert/fermé selon le composant.
  bool expanded = false;

  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      OutlinedButton(
        onPressed: () => setState(() => expanded = !expanded),
        style: OutlinedButton.styleFrom(
          backgroundColor: JoynTokens.paper,
          foregroundColor: JoynTokens.ink,
        ),
        child: Text(expanded ? 'RÉDUIRE LA SCÈNE −' : '${widget.label} +'),
      ),
      if (expanded) ...[const SizedBox(height: JoynTokens.md), widget.child],
    ],
  );
}
