// Centralise les couleurs, dimensions, espacements, formes et durées de la landing.
//
// Référence : doc/landing.md#joyn_tokensdart.

import 'package:flutter/material.dart';

/// Référentiel des valeurs visuelles ; ne porte aucun état de session.
abstract final class JoynTokens {
  /// Couleur du référentiel visuel JOYN.
  static const ink = Color(0xFF001E3B);

  /// Couleur du référentiel visuel JOYN.
  static const orange = Color(0xFFFF6731);

  /// Couleur du référentiel visuel JOYN.
  static const paper = Color(0xFFFFFFFF);

  /// Surface de dessin fournie par Flutter.
  static const canvas = Color(0xFFF5F8FB);

  /// Couleur du référentiel visuel JOYN.
  static const muted = Color(0xFF102A43);

  /// Style du trait utilisé pour le dessin.
  static const line = Color(0xFF9DA5AC);

  /// Couleur du référentiel visuel JOYN.
  static const error = Color(0xFFE24B4B);

  /// Forme commune des contrôles et surfaces.
  static const radius = 16.0;

  /// Couleur du référentiel visuel JOYN.
  static const navyLight = Color(0xFF00254A);

  /// Couleur du référentiel visuel JOYN.
  static const blue = Color(0xFF60A0FF);

  /// Couleur du référentiel visuel JOYN.
  static const cyan = Color(0xFF489EC9);

  /// Couleur du référentiel visuel JOYN.
  static const orangeLight = Color(0xFFFF8559);

  /// Couleur du référentiel visuel JOYN.
  static const greyLight = Color(0xFFD9D9D9);

  /// Couleur du référentiel visuel JOYN.
  static const success = Color(0xFF68B266);

  /// Couleur du référentiel visuel JOYN.
  static const warning = Color(0xFFF5A623);

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const grid = 32.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const portrait = 64.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const portraitLarge = 96.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const joySize = 88.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const logo = 40.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const shadowBlur = 32.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const shadowOffset = Offset(0, 16);

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const subtleAlpha = .12;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const glowAlpha = .25;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const gridAlpha = .08;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const sceneHeight = 520.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const compactSceneHeight = 640.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const sceneLineHeight = 40.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const smallPreview = 280.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const heroMinHeight = 620.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const hairline = 1.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const focusWidth = 3.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const xs = 8.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const sm = 16.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const md = 24.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const lg = 40.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const xl = 64.0;

  /// Associe une clé d’ancre au contenu d’une section.
  static const section = 104.0;

  /// Seuil ou largeur de référence de la composition responsive.
  static const content = 1280.0;

  /// Seuil ou contenu de la variante mobile, selon la déclaration.
  static const mobile = 600.0;

  /// Seuil ou contenu de la variante tablette, selon la déclaration.
  static const tablet = 1024.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const touch = 48.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const navHeight = 88.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const previewHeight = 380.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const previewCompact = 460.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const carouselHeight = 600.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const carouselCompactHeight = 920.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const desktopDisplay = 81.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const tabletDisplay = 54.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const mobileDisplay = 36.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const heading = 36.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const subheading = 24.0;

  /// Base typographique Inter utilisée pour les textes de lecture.
  static const body = 16.0;

  /// Libellé présenté à l’utilisateur.
  static const label = 12.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const textHeight = 1.5;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const titleHeight = 1.05;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const tracking = -1.5;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const indicatorWidth = 96.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const swipeVelocity = 240.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const iconHoverGrowth = .12;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const navSymbol = 64.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const smallSymbol = 32.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const menuPanelMaxHeight = 580.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const utilityHeight = 40.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const navTileWidth = 168.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const navDescriptionHeight = 72.0;

  /// Durée partagée des transitions.
  static const menuDuration = Duration(milliseconds: 250);

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const menuExitDelay = Duration(milliseconds: 180);

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const parallaxTravel = 8.0;

  /// Valeur visuelle partagée ; son initialisation ci-dessous fixe sa mesure.
  static const stickySceneHeight = 900.0;

  /// Durée partagée des transitions.
  static const duration = Duration(milliseconds: 650);

  /// Durée nulle lorsque les animations sont réduites.
  static const instant = Duration.zero;

  /// Paramètres des carrousels, espacements et détails de présentation.
  static const wheelThreshold = 8.0;
  static const wheelInterval = Duration(milliseconds: 350);
  static const disabledAlpha = .35;
  static const planDesktopFraction = .36;
  static const planTabletFraction = .64;
  static const planMobileFraction = .94;
  static const footerTraceHeight = 80.0;
  static const footerTraceDuration = Duration(milliseconds: 900);

  /// Forme commune des contrôles et surfaces.
  static const shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}
