# `joyn_tokens.dart`

Centralise les couleurs, dimensions, espacements, formes et durées de la landing.

[Code source](../../../lib/design_system/joyn_tokens.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `JoynTokens` | `Bibliothèque` | Référentiel des valeurs visuelles ; ne porte aucun état de session. | `abstract final class JoynTokens` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `ink` | `JoynTokens` | Couleur du référentiel visuel JOYN. | `static const ink = Color(0xFF001E3B)` |
| `orange` | `JoynTokens` | Couleur du référentiel visuel JOYN. | `static const orange = Color(0xFFFF6731)` |
| `paper` | `JoynTokens` | Couleur du référentiel visuel JOYN. | `static const paper = Color(0xFFFFFFFF)` |
| `canvas` | `JoynTokens` | Surface de dessin fournie par Flutter. | `static const canvas = Color(0xFFF5F8FB)` |
| `muted` | `JoynTokens` | Couleur du référentiel visuel JOYN. | `static const muted = Color(0xFF102A43)` |
| `line` | `JoynTokens` | Style du trait utilisé pour le dessin. | `static const line = Color(0xFF9DA5AC)` |
| `error` | `JoynTokens` | Couleur du référentiel visuel JOYN. | `static const error = Color(0xFFE24B4B)` |
| `radius` | `JoynTokens` | Forme commune des contrôles et surfaces. | `static const radius = 16.0` |
| `navyLight` | `JoynTokens` | Couleur du référentiel visuel JOYN. | `static const navyLight = Color(0xFF00254A)` |
| `blue` | `JoynTokens` | Couleur du référentiel visuel JOYN. | `static const blue = Color(0xFF60A0FF)` |
| `cyan` | `JoynTokens` | Couleur du référentiel visuel JOYN. | `static const cyan = Color(0xFF489EC9)` |
| `orangeLight` | `JoynTokens` | Couleur du référentiel visuel JOYN. | `static const orangeLight = Color(0xFFFF8559)` |
| `greyLight` | `JoynTokens` | Couleur du référentiel visuel JOYN. | `static const greyLight = Color(0xFFD9D9D9)` |
| `success` | `JoynTokens` | Couleur du référentiel visuel JOYN. | `static const success = Color(0xFF68B266)` |
| `warning` | `JoynTokens` | Couleur du référentiel visuel JOYN. | `static const warning = Color(0xFFF5A623)` |
| `grid` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const grid = 32.0` |
| `portrait` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const portrait = 64.0` |
| `portraitLarge` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const portraitLarge = 96.0` |
| `joySize` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const joySize = 88.0` |
| `logo` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const logo = 40.0` |
| `shadowBlur` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const shadowBlur = 32.0` |
| `shadowOffset` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const shadowOffset = Offset(0, 16)` |
| `subtleAlpha` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const subtleAlpha = .12` |
| `glowAlpha` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const glowAlpha = .25` |
| `gridAlpha` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const gridAlpha = .08` |
| `sceneHeight` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const sceneHeight = 520.0` |
| `compactSceneHeight` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const compactSceneHeight = 640.0` |
| `sceneLineHeight` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const sceneLineHeight = 40.0` |
| `smallPreview` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const smallPreview = 280.0` |
| `heroMinHeight` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const heroMinHeight = 620.0` |
| `hairline` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const hairline = 1.0` |
| `focusWidth` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const focusWidth = 3.0` |
| `xs` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const xs = 8.0` |
| `sm` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const sm = 16.0` |
| `md` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const md = 24.0` |
| `lg` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const lg = 40.0` |
| `xl` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const xl = 64.0` |
| `section` | `JoynTokens` | Associe une clé d’ancre au contenu d’une section. | `static const section = 104.0` |
| `content` | `JoynTokens` | Seuil ou largeur de référence de la composition responsive. | `static const content = 1280.0` |
| `mobile` | `JoynTokens` | Seuil ou contenu de la variante mobile, selon la déclaration. | `static const mobile = 600.0` |
| `tablet` | `JoynTokens` | Seuil ou contenu de la variante tablette, selon la déclaration. | `static const tablet = 1024.0` |
| `touch` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const touch = 48.0` |
| `navHeight` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const navHeight = 88.0` |
| `previewHeight` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const previewHeight = 380.0` |
| `previewCompact` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const previewCompact = 460.0` |
| `carouselHeight` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const carouselHeight = 600.0` |
| `carouselCompactHeight` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const carouselCompactHeight = 920.0` |
| `desktopDisplay` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const desktopDisplay = 81.0` |
| `tabletDisplay` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const tabletDisplay = 54.0` |
| `mobileDisplay` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const mobileDisplay = 36.0` |
| `heading` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const heading = 36.0` |
| `subheading` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const subheading = 24.0` |
| `body` | `JoynTokens` | Base typographique Inter utilisée pour les textes de lecture. | `static const body = 16.0` |
| `label` | `JoynTokens` | Libellé présenté à l’utilisateur. | `static const label = 12.0` |
| `textHeight` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const textHeight = 1.5` |
| `titleHeight` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const titleHeight = 1.05` |
| `tracking` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const tracking = -1.5` |
| `indicatorWidth` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const indicatorWidth = 96.0` |
| `swipeVelocity` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const swipeVelocity = 240.0` |
| `iconHoverGrowth` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const iconHoverGrowth = .12` |
| `navSymbol` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const navSymbol = 64.0` |
| `smallSymbol` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const smallSymbol = 32.0` |
| `menuPanelMaxHeight` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const menuPanelMaxHeight = 580.0` |
| `utilityHeight` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const utilityHeight = 40.0` |
| `navTileWidth` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const navTileWidth = 168.0` |
| `navDescriptionHeight` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const navDescriptionHeight = 72.0` |
| `menuDuration` | `JoynTokens` | Durée partagée des transitions. | `static const menuDuration = Duration(milliseconds: 250)` |
| `menuExitDelay` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const menuExitDelay = Duration(milliseconds: 180)` |
| `parallaxTravel` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const parallaxTravel = 8.0` |
| `stickySceneHeight` | `JoynTokens` | Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure. | `static const stickySceneHeight = 900.0` |
| `duration` | `JoynTokens` | Durée partagée des transitions. | `static const duration = Duration(milliseconds: 650)` |
| `instant` | `JoynTokens` | Désactive la transition de défilement lorsqu’il vaut true. | `static const instant = Duration.zero` |
| `shape` | `JoynTokens` | Forme commune des contrôles et surfaces. | `static const shape = RoundedRectangleBorder( borderRadius: BorderRadius.all(Radius.circular(radius)), )` |

