# Design system

[Sommaire](README.md) · [Jetons](fichiers/joyn_tokens.md) · [Thème](fichiers/app_theme_data.md)

## Palette et typographie

Les valeurs visuelles Dart sont regroupées dans `JoynTokens`. Le fond sombre utilise le bleu nuit ; les fonds de lecture utilisent le blanc et canvas. L’orange porte les accents et actions. Les couleurs sémantiques restent disponibles dans les jetons.

Le corps utilise Inter ; les titres utilisent Space Grotesk via `google_fonts`. Les fichiers de police sont embarqués et le chargement distant est désactivé dans `main`. Le mot manuscrit du hero utilise GreatVibes.

Les tailles principales de titre sont 81, 54 et 36 pixels selon la place disponible ; les titres de section utilisent 36 pixels, les sous-titres 24 pixels, le corps 16 pixels et les libellés 12 pixels. Les réglages de hauteur et d’approche sont également portés par les jetons.

## Composition responsive

| Usage | Seuil |
| --- | --- |
| Téléphone | Largeur inférieure à 600 pixels |
| Tablette | À partir de 600 et sous 1024 pixels |
| Ordinateur | À partir de 1024 pixels |
| Barre de navigation complète | À partir de 1280 pixels de vue |
| Deux colonnes `EditorialSplit` | Largeur locale d’au moins 896 pixels |

Le seuil d’`EditorialSplit` est local à sa composition : `tablet - 2 * xl`. Le mode de la navbar se fonde sur la vue, pas sur cette largeur locale. Les sections mobiles utilisent un espacement horizontal de 24 pixels et vertical de 64 pixels ; les autres sections utilisent 64 et 104 pixels, avec un contenu borné à 1280 pixels.

Le rayon des surfaces et contrôles est de 16 pixels et leur forme est exposée par `JoynTokens.shape`. Les petits rayons inscrits dans les tracés vectoriels appartiennent à la géométrie des illustrations ; ils ne définissent pas une nouvelle forme de contrôle.

## États des contrôles

Le thème résout les fonds, couleurs de texte et bordures selon focus, pression, survol et désactivation. Les boutons de texte gardent un fond clair, car certains titres enfants portent explicitement le bleu nuit. Les contrôles de navigation précisent leurs propres styles pour conserver la lisibilité et le focus sur la barre blanche.

Les surfaces utilisent `ProductSurface` et les fonds illustrés `ProductAtmosphere`. Les compositions réutilisent `EditorialSection`, `SectionHeading`, `EditorialSplit` et `InformationRow` plutôt que de répéter les marges dans chaque section.

## Valeurs de référence

| Jeton | Valeur déclarée |
| --- | --- |
| `ink` | `Color(0xFF001E3B)` |
| `orange` | `Color(0xFFFF6731)` |
| `paper` | `Color(0xFFFFFFFF)` |
| `canvas` | `Color(0xFFF5F8FB)` |
| `muted` | `Color(0xFF102A43)` |
| `line` | `Color(0xFF9DA5AC)` |
| `error` | `Color(0xFFE24B4B)` |
| `radius` | `16.0` |
| `navyLight` | `Color(0xFF00254A)` |
| `blue` | `Color(0xFF60A0FF)` |
| `cyan` | `Color(0xFF489EC9)` |
| `orangeLight` | `Color(0xFFFF8559)` |
| `greyLight` | `Color(0xFFD9D9D9)` |
| `success` | `Color(0xFF68B266)` |
| `warning` | `Color(0xFFF5A623)` |
| `grid` | `32.0` |
| `portrait` | `64.0` |
| `portraitLarge` | `96.0` |
| `joySize` | `88.0` |
| `logo` | `40.0` |
| `shadowBlur` | `32.0` |
| `shadowOffset` | `Offset(0, 16)` |
| `subtleAlpha` | `.12` |
| `glowAlpha` | `.25` |
| `gridAlpha` | `.08` |
| `sceneHeight` | `520.0` |
| `compactSceneHeight` | `640.0` |
| `sceneLineHeight` | `40.0` |
| `smallPreview` | `280.0` |
| `heroMinHeight` | `620.0` |
| `hairline` | `1.0` |
| `focusWidth` | `3.0` |
| `xs` | `8.0` |
| `sm` | `16.0` |
| `md` | `24.0` |
| `lg` | `40.0` |
| `xl` | `64.0` |
| `section` | `104.0` |
| `content` | `1280.0` |
| `mobile` | `600.0` |
| `tablet` | `1024.0` |
| `touch` | `48.0` |
| `navHeight` | `88.0` |
| `previewHeight` | `380.0` |
| `previewCompact` | `460.0` |
| `carouselHeight` | `600.0` |
| `carouselCompactHeight` | `920.0` |
| `desktopDisplay` | `81.0` |
| `tabletDisplay` | `54.0` |
| `mobileDisplay` | `36.0` |
| `heading` | `36.0` |
| `subheading` | `24.0` |
| `body` | `16.0` |
| `label` | `12.0` |
| `textHeight` | `1.5` |
| `titleHeight` | `1.05` |
| `tracking` | `-1.5` |
| `indicatorWidth` | `96.0` |
| `swipeVelocity` | `240.0` |
| `iconHoverGrowth` | `.12` |
| `navSymbol` | `64.0` |
| `smallSymbol` | `32.0` |
| `menuPanelMaxHeight` | `580.0` |
| `utilityHeight` | `40.0` |
| `navTileWidth` | `168.0` |
| `navDescriptionHeight` | `72.0` |
| `menuDuration` | `Duration(milliseconds: 250)` |
| `menuExitDelay` | `Duration(milliseconds: 180)` |
| `parallaxTravel` | `8.0` |
| `stickySceneHeight` | `900.0` |
| `duration` | `Duration(milliseconds: 650)` |
| `instant` | `Duration.zero` |
| `shape` | `RoundedRectangleBorder( borderRadius: BorderRadius.all(Radius.circular(radius)), )` |
