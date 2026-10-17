// Gère l’ouverture des menus, leur positionnement, la recherche mobile et le retour du focus.
//
// Référence : doc/landing.md#landing_mega_navigationdart.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../../domain/landing_navigation.dart';
import 'joyn_mark.dart';
import 'navigation_symbol.dart';

/// Indices des groupes exposés dans la navigation principale.
const _primaryGroups = [0, 1, 2, 3, 5];

/// Libellés des rubriques dans la navigation compacte.
const _mobileGroupTitles = [
  'Comprendre JOYN',
  'Fonctionnalités',
  'Candidats',
  'Recruteurs',
  'Ressources',
  'Formules',
];

/// Pictogrammes associés aux groupes de navigation.
const _groupSymbols = [
  NavigationSymbolKind.principle,
  NavigationSymbolKind.functionality,
  NavigationSymbolKind.profile,
  NavigationSymbolKind.company,
  NavigationSymbolKind.book,
  NavigationSymbolKind.comparePlans,
];

/// Barre de navigation et panneaux associés sur ordinateur et mobile.
class LandingMegaNavigation extends StatefulWidget {
  /// Initialise les paramètres de LandingMegaNavigation ; les valeurs par défaut figurent dans la signature.
  const LandingMegaNavigation({
    super.key,
    required this.onNavigate,
    this.onExtentChanged,
  });

  /// Action remontant une cible de navigation au propriétaire de la page.
  final ValueChanged<String> onNavigate;

  /// Remonte la hauteur mesurée de la barre de navigation.
  final ValueChanged<double>? onExtentChanged;

  /// Crée l’état local associé au widget.
  @override
  State<LandingMegaNavigation> createState() => _LandingMegaNavigationState();
}

/// État de LandingMegaNavigation ; définit ses données mutables et son rendu.
class _LandingMegaNavigationState extends State<LandingMegaNavigation>
    with SingleTickerProviderStateMixin {
  /// Contrôleur d’affichage du panneau superposé.
  final portal = OverlayPortalController();

  /// Lien de positionnement entre la barre et son panneau.
  final link = LayerLink();

  /// Clé de mesure de la barre de navigation.
  final barKey = GlobalKey();

  /// Contrôleur du champ de recherche de ce composant ; libéré dans dispose.
  final search = TextEditingController();

  /// Nœuds de focus des déclencheurs du menu ; restaurés à la fermeture clavier.
  final triggerFocus = List.generate(8, (_) => FocusNode());

  /// Contrôleur temporel d’ouverture et de fermeture du panneau.
  late final motion = AnimationController(
    vsync: this,
    duration: JoynTokens.menuDuration,
  );

  /// Courbe appliquée à la progression du panneau.
  late final curve = CurvedAnimation(
    parent: motion,
    curve: Curves.easeOutCubic,
  );

  /// Fermeture différée du menu à la sortie du pointeur.
  Timer? closing;

  /// Indique si le panneau du menu est affiché.
  bool shown = false;

  /// Indique le survol du signe JOYN.
  bool brandHovered = false;

  /// Indice ou indicateur d’activation utilisé par cette composition.
  int active = 0;

  /// Groupe mobile ouvert ; null représente la liste des rubriques.
  int? mobileLevel;

  /// Lien dont le libellé et la description alimentent la colonne de contexte.
  LandingLink? preview;

  /// Dernière hauteur remontée pour éviter des notifications identiques.
  double lastExtent = 0;

  /// Indique si la barre utilise sa présentation compacte sous 1280 pixels.
  bool get compact => MediaQuery.sizeOf(context).width < JoynTokens.content;

  /// Résout le groupe principal, d’assistance ou de compte à partir de l’indice actif.
  LandingGroup get currentGroup => active == 6
      ? assistanceGroup
      : active == 7
      ? accountGroup
      : landingGroups[active];

  /// Ouvre le panneau du groupe demandé et réinitialise son contexte de recherche.
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

  /// Programme la fermeture après le délai de tolérance du pointeur sur ordinateur.
  void scheduleClose() {
    closing?.cancel();
    if (!shown || compact) {
      return;
    }
    closing = Timer(JoynTokens.menuExitDelay, () => close());
  }

  /// Referme le panneau et restaure éventuellement le focus sur son déclencheur.
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

  /// Ferme le menu puis transmet la cible à la page.
  void choose(String target) {
    close();
    widget.onNavigate(target);
  }

  /// Style des déclencheurs de navigation sur fond clair.
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

  /// Libère les ressources détenues par cet état avant sa destruction.
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

  /// Mesure la barre et remonte sa nouvelle hauteur si elle a changé.
  void reportExtent() {
    // Boîte de rendu mesurée pour calculer une position ou une taille.
    final box = barKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }
    // Position du bas de la barre, mesurée dans la vue.
    final extent = box.localToGlobal(Offset(0, box.size.height)).dy;
    if ((lastExtent - extent).abs() > .5) {
      lastExtent = extent;
      widget.onExtentChanged?.call(extent);
    }
  }

  /// Construit un déclencheur de groupe avec son pictogramme et son indicateur actif.
  Widget primary(int index) => MouseRegion(
    onEnter: (_) => open(index),
    child: Semantics(
      expanded: shown && active == index,
      child: TextButton(
        key: ValueKey(index == 7 ? 'nav-account' : 'nav-group-$index'),
        focusNode: triggerFocus[index],
        style: textStyle,
        onPressed: () {
          if (index == 7) {
            choose('connexion');
          } else if (shown && active == index) {
            close();
          } else {
            open(index);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NavigationSymbol(
              kind: index == 7
                  ? NavigationSymbolKind.account
                  : index == 6
                  ? NavigationSymbolKind.support
                  : _groupSymbols[index],
              active: shown && active == index,
              size: JoynTokens.smallSymbol,
            ),
            Text(
              index == 7
                  ? 'Connexion'
                  : index == 6
                  ? 'Assistance'
                  : index == 3
                  ? 'Recruteurs'
                  : index == 5
                  ? 'Formules'
                  : _mobileGroupTitles[index],
              style: Theme.of(context).textTheme.labelLarge,
              maxLines: 1,
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

  /// Construit une commande iconographique avec infobulle et libellé sémantique.
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
        child: SizedBox.square(
          dimension: JoynTokens.touch,
          child: Center(
            child: NavigationSymbol(
              kind: kind,
              active: active,
              size: JoynTokens.smallSymbol,
            ),
          ),
        ),
      ),
    ),
  );

  /// Construit la présentation à partir de la configuration et de l’état courant.
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
          // Boîte de rendu mesurée pour calculer une position ou une taille.
          final box = barKey.currentContext?.findRenderObject() as RenderBox?;
          // Position du bas de la barre dans la vue.
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
                                  for (final index in [..._primaryGroups, 6, 7])
                                    Expanded(child: primary(index)),
                                ],
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

  /// Construit les liens en colonnes et la zone de contexte sur ordinateur.
  Widget _desktopPanel(BuildContext context, double bottom) {
    // Groupe de navigation actuellement examiné.
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
                        // Nombre de colonnes de liens dans le panneau.
                        final columns =
                            constraints.maxWidth >= JoynTokens.mobile ? 4 : 3;
                        // Largeur disponible ou calculée pour cette composition.
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

  /// Construit le niveau mobile courant ou les résultats de recherche.
  Widget _mobilePanel(BuildContext context, double bottom) {
    // Texte utilisé pour filtrer la liste d’offres.
    final query = search.text.trim().toLowerCase();
    // Liens de tous les groupes examinés par la recherche mobile.
    final entries = [
      ...landingGroups.expand((group) => group.links),
      ...assistanceGroup.links,
      ...accountGroup.links,
    ];
    // Liens dédoublonnés par combinaison de cible et de libellé.
    final unique = <String, LandingLink>{
      for (final item in entries) '${item.target}/${item.label}': item,
    };
    // Éléments qui satisfont les filtres et la recherche.
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

  /// Construit la commande qui ouvre une rubrique mobile.
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

  /// Réutilise une vignette de menu dans la liste mobile.
  Widget _mobileLink(LandingLink item) => SizedBox(
    width: double.infinity,
    child: _NavigationTile(item: item, onChoose: choose, onPreview: () {}),
  );
}

/// Entrée de menu avec pictogramme, libellé et actions de sélection/prévisualisation.
class _NavigationTile extends StatefulWidget {
  /// Initialise les paramètres de _NavigationTile ; les valeurs par défaut figurent dans la signature.
  const _NavigationTile({
    required this.item,
    required this.onChoose,
    required this.onPreview,
  });

  /// Lien représenté par la vignette.
  final LandingLink item;

  /// Action appelée à la sélection de la vignette.
  final ValueChanged<String> onChoose;

  /// Action appelée au survol pour alimenter le contexte du panneau.
  final VoidCallback onPreview;

  /// Crée l’état local associé au widget.
  @override
  State<_NavigationTile> createState() => _NavigationTileState();
}

/// État de survol ou de focus d’une entrée de menu.
class _NavigationTileState extends State<_NavigationTile> {
  /// Active le dessin lorsque la vignette est survolée ou reçoit le focus.
  bool engaged = false;

  /// Construit la présentation à partir de la configuration et de l’état courant.
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
