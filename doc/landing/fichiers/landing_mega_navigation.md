# `landing_mega_navigation.dart`

Gère l’ouverture des menus, leur positionnement, la recherche mobile et le retour du focus.

[Code source](../../../lib/features/landing/presentation/widgets/landing_mega_navigation.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `dart:async`
- `dart:math`
- `package:flutter/material.dart`
- `package:flutter/services.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../../domain/landing_navigation.dart`
- `joyn_mark.dart`
- `navigation_symbol.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `LandingMegaNavigation` | `Bibliothèque` | Barre de navigation et panneaux associés sur ordinateur et mobile. | `class LandingMegaNavigation extends StatefulWidget` |
| `LandingMegaNavigation` | `LandingMegaNavigation` | Initialise les paramètres de LandingMegaNavigation ; les valeurs par défaut figurent dans la signature. | `const LandingMegaNavigation({super.key, required this.onNavigate, this.onExtentChanged})` |
| `_LandingMegaNavigationState` | `Bibliothèque` | État de LandingMegaNavigation ; définit ses données mutables et son rendu. | `class _LandingMegaNavigationState extends State<LandingMegaNavigation> with SingleTickerProviderStateMixin` |
| `_NavigationTile` | `Bibliothèque` | Entrée de menu avec pictogramme, libellé et actions de sélection/prévisualisation. | `class _NavigationTile extends StatefulWidget` |
| `_NavigationTile` | `_NavigationTile` | Initialise les paramètres de _NavigationTile ; les valeurs par défaut figurent dans la signature. | `const _NavigationTile({required this.item,required this.onChoose,required this.onPreview})` |
| `_NavigationTileState` | `Bibliothèque` | État de survol ou de focus d’une entrée de menu. | `class _NavigationTileState extends State<_NavigationTile>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `LandingMegaNavigation` | Crée l’état local associé au widget. | `State<LandingMegaNavigation> createState()` |
| `compact` | `_LandingMegaNavigationState` | Indique si la barre utilise sa présentation compacte sous 1280 pixels. | `bool get compact` |
| `currentGroup` | `_LandingMegaNavigationState` | Résout le groupe principal, d’assistance ou de compte à partir de l’indice actif. | `LandingGroup get currentGroup` |
| `open` | `_LandingMegaNavigationState` | Ouvre le panneau du groupe demandé et réinitialise son contexte de recherche. | `void open(int index, {bool root = false})` |
| `scheduleClose` | `_LandingMegaNavigationState` | Programme la fermeture après le délai de tolérance du pointeur sur ordinateur. | `void scheduleClose()` |
| `close` | `_LandingMegaNavigationState` | Referme le panneau et restaure éventuellement le focus sur son déclencheur. | `Future<void> close({bool restoreFocus = false})` |
| `choose` | `_LandingMegaNavigationState` | Ferme le menu puis transmet la cible à la page. | `void choose(String target)` |
| `textStyle` | `_LandingMegaNavigationState` | Style des déclencheurs de navigation sur fond clair. | `ButtonStyle get textStyle` |
| `dispose` | `_LandingMegaNavigationState` | Libère les ressources détenues par cet état avant sa destruction. | `void dispose()` |
| `reportExtent` | `_LandingMegaNavigationState` | Mesure la barre et remonte sa nouvelle hauteur si elle a changé. | `void reportExtent()` |
| `primary` | `_LandingMegaNavigationState` | Construit un déclencheur de groupe avec son pictogramme et son indicateur actif. | `Widget primary(int index)` |
| `iconAction` | `_LandingMegaNavigationState` | Construit une commande iconographique avec infobulle et libellé sémantique. | `Widget iconAction(NavigationSymbolKind kind, String label, VoidCallback action, {bool active = false, FocusNode? focusNode})` |
| `build` | `_LandingMegaNavigationState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `_desktopPanel` | `_LandingMegaNavigationState` | Construit les liens en colonnes et la zone de contexte sur ordinateur. | `Widget _desktopPanel(BuildContext context, double bottom)` |
| `_mobilePanel` | `_LandingMegaNavigationState` | Construit le niveau mobile courant ou les résultats de recherche. | `Widget _mobilePanel(BuildContext context, double bottom)` |
| `_category` | `_LandingMegaNavigationState` | Construit la commande qui ouvre une rubrique mobile. | `Widget _category(int index)` |
| `_mobileLink` | `_LandingMegaNavigationState` | Réutilise une vignette de menu dans la liste mobile. | `Widget _mobileLink(LandingLink item)` |
| `createState` | `_NavigationTile` | Crée l’état local associé au widget. | `State<_NavigationTile> createState()` |
| `build` | `_NavigationTileState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `_primaryGroups` | `Bibliothèque` | Indices des groupes exposés dans la navigation principale. | `_primaryGroups = [0,1,2,3,5]` |
| `_mobileGroupTitles` | `Bibliothèque` | Libellés des rubriques dans la navigation compacte. | `_mobileGroupTitles = ['Comprendre JOYN','Fonctionnalités','Candidats','Recruteurs','Ressources','Formules']` |
| `_groupSymbols` | `Bibliothèque` | Pictogrammes associés aux groupes de navigation. | `_groupSymbols = [NavigationSymbolKind.principle,NavigationSymbolKind.functionality,NavigationSymbolKind.profile, NavigationSymbolKind.company,NavigationSymbolKind.book,NavigationSymbolKind.comparePlans]` |
| `onNavigate` | `LandingMegaNavigation` | Action remontant une cible de navigation au propriétaire de la page. | `final ValueChanged<String> onNavigate` |
| `onExtentChanged` | `LandingMegaNavigation` | Remonte la hauteur mesurée de la barre de navigation. | `final ValueChanged<double>? onExtentChanged` |
| `portal` | `_LandingMegaNavigationState` | Contrôleur d’affichage du panneau superposé. | `final portal = OverlayPortalController()` |
| `link` | `_LandingMegaNavigationState` | Lien de positionnement entre la barre et son panneau. | `final link = LayerLink()` |
| `barKey` | `_LandingMegaNavigationState` | Clé de mesure de la barre de navigation. | `final barKey = GlobalKey()` |
| `search` | `_LandingMegaNavigationState` | Contrôleur du champ de recherche de ce composant ; libéré dans dispose. | `final search = TextEditingController()` |
| `triggerFocus` | `_LandingMegaNavigationState` | Nœuds de focus des déclencheurs du menu ; restaurés à la fermeture clavier. | `final triggerFocus = List.generate(8, (_) => FocusNode())` |
| `motion` | `_LandingMegaNavigationState` | Contrôleur temporel d’ouverture et de fermeture du panneau. | `late final motion = AnimationController(vsync: this, duration: JoynTokens.menuDuration)` |
| `curve` | `_LandingMegaNavigationState` | Courbe appliquée à la progression du panneau. | `late final curve = CurvedAnimation(parent: motion, curve: Curves.easeOutCubic)` |
| `closing` | `_LandingMegaNavigationState` | Fermeture différée du menu à la sortie du pointeur. | `Timer? closing` |
| `shown` | `_LandingMegaNavigationState` | Indique si le panneau du menu est affiché. | `bool shown = false` |
| `brandHovered` | `_LandingMegaNavigationState` | Indique le survol du signe JOYN. | `bool brandHovered = false` |
| `active` | `_LandingMegaNavigationState` | Indice ou indicateur d’activation utilisé par cette composition. | `int active = 0` |
| `mobileLevel` | `_LandingMegaNavigationState` | Groupe mobile ouvert ; null représente la liste des rubriques. | `int? mobileLevel` |
| `preview` | `_LandingMegaNavigationState` | Lien dont le libellé et la description alimentent la colonne de contexte. | `LandingLink? preview` |
| `lastExtent` | `_LandingMegaNavigationState` | Dernière hauteur remontée pour éviter des notifications identiques. | `double lastExtent = 0` |
| `item` | `_NavigationTile` | Lien représenté par la vignette. | `final LandingLink item` |
| `onChoose` | `_NavigationTile` | Action appelée à la sélection de la vignette. | `final ValueChanged<String> onChoose` |
| `onPreview` | `_NavigationTile` | Action appelée au survol pour alimenter le contexte du panneau. | `final VoidCallback onPreview` |
| `engaged` | `_NavigationTileState` | Active le dessin lorsque la vignette est survolée ou reçoit le focus. | `bool engaged = false` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `box` | `_LandingMegaNavigationState` | Boîte de rendu mesurée pour calculer une position ou une taille. | `final box = barKey.currentContext?.findRenderObject() as RenderBox?;` |
| `extent` | `_LandingMegaNavigationState` | Position du bas de la barre, mesurée dans la vue. | `final extent = box.localToGlobal(Offset(0,box.size.height)).dy;` |
| `box` | `_LandingMegaNavigationState` | Boîte de rendu mesurée pour calculer une position ou une taille. | `final box = barKey.currentContext?.findRenderObject() as RenderBox?;` |
| `bottom` | `_LandingMegaNavigationState` | Position du bas de la barre dans la vue. | `final bottom = box == null ? JoynTokens.navHeight : box.localToGlobal(Offset(0,box.size.height)).dy;` |
| `group` | `_LandingMegaNavigationState` | Groupe de navigation actuellement examiné. | `final group = currentGroup;` |
| `columns` | `_LandingMegaNavigationState` | Nombre de colonnes de liens dans le panneau. | `final columns = constraints.maxWidth >= JoynTokens.mobile ? 4 : 3;` |
| `width` | `_LandingMegaNavigationState` | Largeur disponible ou calculée pour cette composition. | `final width = (constraints.maxWidth - JoynTokens.md*(columns-1))/columns;` |
| `query` | `_LandingMegaNavigationState` | Texte utilisé pour filtrer la liste d’offres. | `final query = search.text.trim().toLowerCase();` |
| `entries` | `_LandingMegaNavigationState` | Liens de tous les groupes examinés par la recherche mobile. | `final entries = [...landingGroups.expand((group) => group.links),...assistanceGroup.links,...accountGroup.links];` |
| `unique` | `_LandingMegaNavigationState` | Liens dédoublonnés par combinaison de cible et de libellé. | `final unique = <String,LandingLink>{for(final item in entries) '${item.target}/${item.label}':item};` |
| `results` | `_LandingMegaNavigationState` | Éléments qui satisfont les filtres et la recherche. | `final results = unique.values .where((item) => '${item.label} ${item.description}'.toLowerCase().contains(query)).toList();` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `LandingMegaNavigation` | Identité du widget dans l’arbre Flutter. |
| `this.onNavigate` | `LandingMegaNavigation` | Action remontant une cible de navigation au propriétaire de la page. |
| `this.onExtentChanged` | `LandingMegaNavigation` | Remonte la hauteur mesurée de la barre de navigation. |
| `_` | `_LandingMegaNavigationState` | Paramètre reçu sans être utilisé dans ce callback. |
| `int index` | `void open(int index, {bool root = false})` | Indice de l’élément demandé. |
| `bool root` | `void open(int index, {bool root = false})` | Ouvre le niveau racine du menu mobile lorsqu’il vaut true. |
| `bool restoreFocus` | `Future<void> close({bool restoreFocus = false})` | Rend le focus au déclencheur après la fermeture du panneau. |
| `String target` | `void choose(String target)` | Cible d’ancre ou de route transmise à la navigation. |
| `states` | `_LandingMegaNavigationState` | Ensemble des états visuels du bouton. |
| `int index` | `Widget primary(int index)` | Indice de l’élément demandé. |
| `NavigationSymbolKind kind` | `Widget iconAction(NavigationSymbolKind kind, String label, VoidCallback action, {bool active = false, FocusNode? focusNode})` | Dessin vectoriel à utiliser. |
| `String label` | `Widget iconAction(NavigationSymbolKind kind, String label, VoidCallback action, {bool active = false, FocusNode? focusNode})` | Libellé présenté à l’utilisateur. |
| `VoidCallback action` | `Widget iconAction(NavigationSymbolKind kind, String label, VoidCallback action, {bool active = false, FocusNode? focusNode})` | Action appelée lors de l’activation. |
| `bool active` | `Widget iconAction(NavigationSymbolKind kind, String label, VoidCallback action, {bool active = false, FocusNode? focusNode})` | Indice ou indicateur d’activation utilisé par cette composition. |
| `FocusNode? focusNode` | `Widget iconAction(NavigationSymbolKind kind, String label, VoidCallback action, {bool active = false, FocusNode? focusNode})` | Nœud de focus associé à la commande. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `context` | `_LandingMegaNavigationState` | Contexte Flutter de l’élément en cours de construction. |
| `BuildContext context` | `Widget _desktopPanel(BuildContext context, double bottom)` | Contexte Flutter de l’élément en cours de construction. |
| `double bottom` | `Widget _desktopPanel(BuildContext context, double bottom)` | Position du bas de la barre dans la vue. |
| `constraints` | `_LandingMegaNavigationState` | Contraintes de largeur et de hauteur reçues du parent. |
| `BuildContext context` | `Widget _mobilePanel(BuildContext context, double bottom)` | Contexte Flutter de l’élément en cours de construction. |
| `double bottom` | `Widget _mobilePanel(BuildContext context, double bottom)` | Position du bas de la barre dans la vue. |
| `group` | `_LandingMegaNavigationState` | Groupe de navigation actuellement examiné. |
| `item` | `_LandingMegaNavigationState` | Lien représenté par la vignette. |
| `int index` | `Widget _category(int index)` | Indice de l’élément demandé. |
| `LandingLink item` | `Widget _mobileLink(LandingLink item)` | Lien représenté par la vignette. |
| `this.item` | `_NavigationTile` | Lien représenté par la vignette. |
| `this.onChoose` | `_NavigationTile` | Action appelée à la sélection de la vignette. |
| `this.onPreview` | `_NavigationTile` | Action appelée au survol pour alimenter le contexte du panneau. |
| `_` | `_NavigationTileState` | Paramètre reçu sans être utilisé dans ce callback. |
| `states` | `_NavigationTileState` | Ensemble des états visuels du bouton. |
| `value` | `_NavigationTileState` | Valeur reçue par le paramètre ou affichée dans la ligne, selon la portée. |


## Variables de parcours

Ces variables prennent successivement les éléments de la collection indiquée ; elles ne constituent pas un état conservé entre deux rendus.

| Variable | Boucle et collection |
| --- | --- |
| `focus` | `(final focus in triggerFocus)` |
| `index` | `(final index in _primaryGroups)` |
| `item` | `(final item in group.links)` |
| `item` | `(final item in entries)` |
| `item` | `(final item in results)` |
| `i` | `(final i in _primaryGroups)` |
| `item` | `(final item in currentGroup.links)` |
