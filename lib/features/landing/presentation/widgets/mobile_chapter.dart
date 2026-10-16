import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import 'navigation_symbol.dart';

class MobileChapter extends StatelessWidget {
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
  final String id;
  final String title;
  final String summary;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;
  final NavigationSymbolKind kind;
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

class MobileReveal extends StatefulWidget {
  const MobileReveal({super.key, required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  State<MobileReveal> createState() => _MobileRevealState();
}

class _MobileRevealState extends State<MobileReveal> {
  bool expanded = false;
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
