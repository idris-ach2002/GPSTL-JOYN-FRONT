import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../../domain/landing_navigation.dart';
import 'joyn_mark.dart';
import 'navigation_symbol.dart';

const _primaryGroups = [0, 1, 2, 3, 5];
const _mobileGroupTitles = [
  'Comprendre JOYN',
  'Fonctionnalités',
  'Candidats',
  'Recruteurs',
  'Ressources',
  'Formules',
];
const _groupSymbols = [
  NavigationSymbolKind.principle,
  NavigationSymbolKind.functionality,
  NavigationSymbolKind.profile,
  NavigationSymbolKind.company,
  NavigationSymbolKind.book,
  NavigationSymbolKind.comparePlans,
];

class LandingMegaNavigation extends StatefulWidget {
  const LandingMegaNavigation({
    super.key,
    required this.onNavigate,
    this.onExtentChanged,
  });
  final ValueChanged<String> onNavigate;
  final ValueChanged<double>? onExtentChanged;
  @override
  State<LandingMegaNavigation> createState() => _LandingMegaNavigationState();
}

class _LandingMegaNavigationState extends State<LandingMegaNavigation>
    with SingleTickerProviderStateMixin {
  final portal = OverlayPortalController();
  final link = LayerLink();
  final barKey = GlobalKey();
  final search = TextEditingController();
  final triggerFocus = List.generate(8, (_) => FocusNode());
  late final motion = AnimationController(
    vsync: this,
    duration: JoynTokens.menuDuration,
  );
  late final curve = CurvedAnimation(
    parent: motion,
    curve: Curves.easeOutCubic,
  );
  Timer? closing;
  bool shown = false;
  bool brandHovered = false;
  int active = 0;
  int? mobileLevel;
  LandingLink? preview;
  double lastExtent = 0;
  bool get compact => MediaQuery.sizeOf(context).width < JoynTokens.content;
  LandingGroup get currentGroup => active == 6
      ? assistanceGroup
      : active == 7
      ? accountGroup
      : landingGroups[active];
  void open(int index, {bool root = false}) {
    closing?.cancel();
    setState(() {
      active = index;
      preview = null;
      mobileLevel = root ? null : index;
      search.clear();
    });
    if (!shown) {
      shown = true;
      portal.show();
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      motion.value = 1;
    } else {
      motion.forward();
    }
  }

  void scheduleClose() {
    closing?.cancel();
    if (!shown || compact) {
      return;
    }
    closing = Timer(JoynTokens.menuExitDelay, () => close());
  }

  Future<void> close({bool restoreFocus = false}) async {
    closing?.cancel();
    if (!shown) {
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      motion.value = 0;
    } else {
      await motion.reverse();
    }
    if (!mounted || motion.value != 0) {
      return;
    }
    portal.hide();
    setState(() => shown = false);
    if (restoreFocus) {
      triggerFocus[compact ? 0 : active].requestFocus();
    }
  }

  void choose(String target) {
    close();
    widget.onNavigate(target);
  }

  ButtonStyle get textStyle => ButtonStyle(
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: JoynTokens.xs, vertical: JoynTokens.xs),
    ),
    backgroundColor: WidgetStatePropertyAll(
      JoynTokens.paper.withValues(alpha: 0),
    ),
    foregroundColor: const WidgetStatePropertyAll(JoynTokens.ink),
    overlayColor: WidgetStatePropertyAll(JoynTokens.paper.withValues(alpha: 0)),
    side: WidgetStateProperty.resolveWith(
      (states) => BorderSide(
        color: states.contains(WidgetState.focused)
            ? JoynTokens.ink
            : JoynTokens.paper.withValues(alpha: 0),
        width: JoynTokens.focusWidth,
      ),
    ),
  );
  @override
  void dispose() {
    closing?.cancel();
    curve.dispose();
    motion.dispose();
    search.dispose();
    for (final focus in triggerFocus) {
      focus.dispose();
    }
    super.dispose();
  }

  void reportExtent() {
    final box = barKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }
    final extent = box.localToGlobal(Offset(0, box.size.height)).dy;
    if ((lastExtent - extent).abs() > .5) {
      lastExtent = extent;
      widget.onExtentChanged?.call(extent);
    }
  }

  Widget primary(int index) => MouseRegion(
    onEnter: (_) => open(index),
    child: Semantics(
      expanded: shown && active == index,
      child: TextButton(
        key: ValueKey('nav-group-$index'),
        focusNode: triggerFocus[index],
        style: textStyle,
        onPressed: () {
          if (shown && active == index) {
            close();
          } else {
            open(index);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NavigationSymbol(
              kind: index == 6
                  ? NavigationSymbolKind.support
                  : _groupSymbols[index],
              active: shown && active == index,
              size: JoynTokens.smallSymbol,
            ),
            Text(
              index == 6
                  ? 'Assistance'
                  : index == 3
                  ? 'Recruteurs'
                  : index == 5
                  ? 'Formules'
                  : _mobileGroupTitles[index],
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: JoynTokens.xs),
            Container(
              height: JoynTokens.hairline,
              width: JoynTokens.lg,
              color: shown && active == index
                  ? JoynTokens.ink
                  : JoynTokens.paper.withValues(alpha: 0),
            ),
          ],
        ),
      ),
    ),
  );
  Widget iconAction(
    NavigationSymbolKind kind,
    String label,
    VoidCallback action, {
    bool active = false,
    FocusNode? focusNode,
  }) => Tooltip(
    message: label,
    child: Semantics(
      label: label,
      button: true,
      child: TextButton(
        style: textStyle,
        focusNode: focusNode,
        key: ValueKey(
          kind == NavigationSymbolKind.menu
              ? 'nav-menu-toggle'
              : 'nav-account-mobile',
        ),
        onPressed: action,
        child: NavigationSymbol(
          kind: kind,
          active: active,
          size: JoynTokens.smallSymbol,
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        reportExtent();
      }
    });
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            close(restoreFocus: true),
      },
      child: OverlayPortal(
        controller: portal,
        overlayChildBuilder: (context) {
          final box = barKey.currentContext?.findRenderObject() as RenderBox?;
          final bottom = box == null
              ? JoynTokens.navHeight
              : box.localToGlobal(Offset(0, box.size.height)).dy;
          return Stack(
            children: [
              Positioned(
                top: bottom,
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => close(),
                  child: ColoredBox(
                    color: JoynTokens.ink.withValues(alpha: .22),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: CompositedTransformFollower(
                  link: link,
                  targetAnchor: Alignment.bottomLeft,
                  followerAnchor: Alignment.topLeft,
                  showWhenUnlinked: false,
                  child: MouseRegion(
                    onEnter: (_) => closing?.cancel(),
                    onExit: (_) => scheduleClose(),
                    child: CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.escape): () =>
                            close(restoreFocus: true),
                      },
                      child: SizeTransition(
                        sizeFactor: curve,
                        alignment: Alignment.topCenter,
                        child: Material(
                          color: JoynTokens.paper,
                          child: compact
                              ? _mobilePanel(context, bottom)
                              : _desktopPanel(context, bottom),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        child: CompositedTransformTarget(
          key: barKey,
          link: link,
          child: MouseRegion(
            onEnter: (_) => closing?.cancel(),
            onExit: (_) => scheduleClose(),
            child: Container(
              decoration: const BoxDecoration(
                color: JoynTokens.paper,
                border: Border(bottom: BorderSide(color: JoynTokens.line)),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: JoynTokens.md,
                vertical: JoynTokens.xs,
              ),
              child: Align(
                alignment: Alignment.center,
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: JoynTokens.content,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          MouseRegion(
                            onEnter: (_) => setState(() => brandHovered = true),
                            onExit: (_) => setState(() => brandHovered = false),
                            child: TextButton(
                              style: textStyle,
                              onPressed: () => choose('hero'),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedJoynMark(
                                    active: brandHovered || (compact && shown),
                                  ),
                                  const SizedBox(width: JoynTokens.sm),
                                  Text(
                                    'joyn',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!compact) ...[
                            const SizedBox(width: JoynTokens.md),
                            Expanded(
                              child: Row(
                                children: [
                                  for (final index in _primaryGroups)
                                    Expanded(child: primary(index)),
                                ],
                              ),
                            ),
                            const SizedBox(width: JoynTokens.md),
                            primary(6),
                            MouseRegion(
                              onEnter: (_) => open(7),
                              child: TextButton(
                                key: const ValueKey('nav-account'),
                                style: textStyle,
                                focusNode: triggerFocus[7],
                                onPressed: () => choose('connexion'),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    NavigationSymbol(
                                      kind: NavigationSymbolKind.account,
                                      active: shown && active == 7,
                                      size: JoynTokens.smallSymbol,
                                    ),
                                    const Text('Connexion'),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            const Spacer(),
                            iconAction(
                              NavigationSymbolKind.account,
                              'Connexion',
                              () => choose('connexion'),
                            ),
                            iconAction(
                              NavigationSymbolKind.menu,
                              shown ? 'Fermer le menu' : 'Ouvrir le menu',
                              () {
                                if (shown) {
                                  close();
                                } else {
                                  open(0, root: true);
                                }
                              },
                              active: shown,
                              focusNode: triggerFocus[0],
                            ),
                          ],
                        ],
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

  Widget _desktopPanel(BuildContext context, double bottom) {
    final group = currentGroup;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: math.max(
          JoynTokens.touch,
          math.min(
            JoynTokens.menuPanelMaxHeight,
            MediaQuery.sizeOf(context).height - bottom,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: JoynTokens.xl,
            vertical: JoynTokens.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: JoynTokens.content),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final columns =
                            constraints.maxWidth >= JoynTokens.mobile ? 4 : 3;
                        final width =
                            (constraints.maxWidth -
                                JoynTokens.md * (columns - 1)) /
                            columns;
                        return Wrap(
                          spacing: JoynTokens.md,
                          runSpacing: JoynTokens.lg,
                          children: [
                            for (final item in group.links)
                              SizedBox(
                                width: width,
                                child: _NavigationTile(
                                  item: item,
                                  onChoose: choose,
                                  onPreview: () =>
                                      setState(() => preview = item),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: JoynTokens.lg),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: JoynTokens.md),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: JoynTokens.line),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.label,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: JoynTokens.md),
                          Text(
                            preview?.label ?? group.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: JoynTokens.md),
                          Text(preview?.description ?? group.description),
                          const SizedBox(height: JoynTokens.lg),
                          TextButton(
                            style: textStyle,
                            onPressed: () => choose(
                              preview?.target ?? group.links.first.target,
                            ),
                            child: const Text('Ouvrir cette partie →'),
                          ),
                          const SizedBox(height: JoynTokens.md),
                          const Divider(),
                          TextButton(
                            style: textStyle,
                            onPressed: () => choose('assistance'),
                            child: const Text('Besoin d’aide ?'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobilePanel(BuildContext context, double bottom) {
    final query = search.text.trim().toLowerCase();
    final entries = [
      ...landingGroups.expand((group) => group.links),
      ...assistanceGroup.links,
      ...accountGroup.links,
    ];
    final unique = <String, LandingLink>{
      for (final item in entries) '${item.target}/${item.label}': item,
    };
    final results = unique.values
        .where(
          (item) =>
              '${item.label} ${item.description}'.toLowerCase().contains(query),
        )
        .toList();
    return SizedBox(
      height: math.max(
        JoynTokens.touch,
        MediaQuery.sizeOf(context).height - bottom,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(JoynTokens.md),
            child: TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Rechercher une rubrique',
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  JoynTokens.md,
                  0,
                  JoynTokens.md,
                  JoynTokens.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (query.isNotEmpty) ...[
                      Text(
                        '${results.length} résultat(s)',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      if (results.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(JoynTokens.md),
                          child: Text(
                            'Aucune rubrique trouvée. Essaie « profil », « aide » ou « offre ».',
                          ),
                        ),
                      for (final item in results) _mobileLink(item),
                    ] else if (mobileLevel == null) ...[
                      Text(
                        'PARCOURIR JOYN',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: JoynTokens.sm),
                      for (final i in _primaryGroups) ...[
                        const Divider(),
                        _category(i),
                      ],
                      const SizedBox(height: JoynTokens.md),
                      const Divider(),
                      _mobileLink(
                        const LandingLink(
                          'Assistance',
                          'Guides et questions fréquentes.',
                          'assistance',
                        ),
                      ),
                      _mobileLink(
                        const LandingLink(
                          'Connexion',
                          'Accéder à ton espace.',
                          'connexion',
                        ),
                      ),
                    ] else ...[
                      TextButton(
                        key: const ValueKey('menu-back'),
                        style: textStyle,
                        onPressed: () => setState(() {
                          mobileLevel = null;
                          preview = null;
                        }),
                        child: const Text('← Toutes les rubriques'),
                      ),
                      const SizedBox(height: JoynTokens.md),
                      Row(
                        children: [
                          NavigationSymbol(
                            kind: mobileLevel! < 6
                                ? _groupSymbols[mobileLevel!]
                                : NavigationSymbolKind.support,
                            active: true,
                            size: JoynTokens.smallSymbol,
                          ),
                          const SizedBox(width: JoynTokens.sm),
                          Expanded(
                            child: Text(
                              currentGroup.label,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: JoynTokens.md),
                      for (final item in currentGroup.links) _mobileLink(item),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _category(int index) => TextButton(
    key: ValueKey('mobile-category-$index'),
    style: textStyle,
    onPressed: () => open(index),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: JoynTokens.sm),
      child: Row(
        children: [
          NavigationSymbol(
            kind: _groupSymbols[index],
            size: JoynTokens.smallSymbol,
          ),
          const SizedBox(width: JoynTokens.md),
          Expanded(
            child: Text(
              _mobileGroupTitles[index],
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const NavigationSymbol(
            kind: NavigationSymbolKind.arrow,
            size: JoynTokens.smallSymbol,
          ),
        ],
      ),
    ),
  );
  Widget _mobileLink(LandingLink item) => SizedBox(
    width: double.infinity,
    child: _NavigationTile(item: item, onChoose: choose, onPreview: () {}),
  );
}

class _NavigationTile extends StatefulWidget {
  const _NavigationTile({
    required this.item,
    required this.onChoose,
    required this.onPreview,
  });
  final LandingLink item;
  final ValueChanged<String> onChoose;
  final VoidCallback onPreview;
  @override
  State<_NavigationTile> createState() => _NavigationTileState();
}

class _NavigationTileState extends State<_NavigationTile> {
  bool engaged = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) {
      setState(() => engaged = true);
      widget.onPreview();
    },
    onExit: (_) => setState(() => engaged = false),
    child: TextButton(
      key: ValueKey('mega-${widget.item.target}-${widget.item.label}'),
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(JoynTokens.paper),
        foregroundColor: const WidgetStatePropertyAll(JoynTokens.ink),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(JoynTokens.sm)),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.focused)
                ? JoynTokens.ink
                : JoynTokens.paper,
            width: JoynTokens.focusWidth,
          ),
        ),
      ),
      onFocusChange: (value) => setState(() => engaged = value),
      onPressed: () => widget.onChoose(widget.item.target),
      child: Column(
        children: [
          NavigationSymbol(kind: symbolFor(widget.item.label), active: engaged),
          const SizedBox(height: JoynTokens.md),
          Text(
            widget.item.label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}
