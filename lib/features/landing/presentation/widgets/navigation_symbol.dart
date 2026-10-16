// Associe les libellés de menu à des pictogrammes vectoriels et anime leur tracé.
//
// Référence : doc/landing/fichiers/navigation_symbol.md.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';

/// Identifiants des dessins disponibles pour les pictogrammes.
enum NavigationSymbolKind {
  link,
  profile,
  work,
  school,
  book,
  support,
  account,
  search,
  menu,
  arrow,
  chart,
  message,
  principle,
  obstacles,
  compare,
  journey,
  matching,
  cv,
  criteria,
  favorites,
  reciprocal,
  tracking,
  editProfile,
  explore,
  interview,
  publish,
  inspectProfile,
  inbox,
  profileGuide,
  matchGuide,
  interviewGuide,
  faq,
  presentation,
  candidatePlan,
  companyPlan,
  phone,
  helpCenter,
  readMatch,
  login,
  identity,
  comparePlans,
  functionality,
  company,
}

/// Résout le dessin correspondant au libellé ; refuse les libellés sans association.
NavigationSymbolKind symbolFor(String label) => switch (label) {
  'Le principe JOYN' => NavigationSymbolKind.principle,
  'Les difficultés de recherche' => NavigationSymbolKind.obstacles,
  'Avant / après' => NavigationSymbolKind.compare,
  'Parcours candidat' => NavigationSymbolKind.journey,
  'Le matching expliqué' => NavigationSymbolKind.matching,
  'Profil et CV' => NavigationSymbolKind.cv,
  'Critères de compatibilité' => NavigationSymbolKind.criteria,
  'Favoris et alertes' => NavigationSymbolKind.favorites,
  'Messagerie réciproque' => NavigationSymbolKind.reciprocal,
  'Suivi des candidatures' => NavigationSymbolKind.tracking,
  'Construire mon profil' => NavigationSymbolKind.editProfile,
  'Explorer les offres' => NavigationSymbolKind.explore,
  'Préparer le premier échange' => NavigationSymbolKind.interview,
  'Présenter un poste' => NavigationSymbolKind.publish,
  'Comprendre un profil' => NavigationSymbolKind.inspectProfile,
  'Gérer les candidatures' => NavigationSymbolKind.inbox,
  'Guide du profil' => NavigationSymbolKind.profileGuide,
  'Comprendre un matching' => NavigationSymbolKind.matchGuide,
  'Préparer un entretien' => NavigationSymbolKind.interviewGuide,
  'Questions fréquentes' => NavigationSymbolKind.faq,
  'Présentation de JOYN' => NavigationSymbolKind.presentation,
  'Candidats' => NavigationSymbolKind.candidatePlan,
  'Recruteurs' => NavigationSymbolKind.companyPlan,
  'Sur téléphone' => NavigationSymbolKind.phone,
  'Centre d’aide' => NavigationSymbolKind.helpCenter,
  'Lire un matching' => NavigationSymbolKind.readMatch,
  'Se connecter' => NavigationSymbolKind.login,
  'Présenter mon profil' => NavigationSymbolKind.identity,
  'Comprendre les formules' => NavigationSymbolKind.comparePlans,
  'Assistance' => NavigationSymbolKind.support,
  'Connexion' => NavigationSymbolKind.account,
  _ => throw ArgumentError.value(
    label,
    'label',
    'Missing navigation pictogram',
  ),
};

/// Pictogramme avec accent tracé et agrandissement selon l’état actif.
class NavigationSymbol extends StatelessWidget {
  /// Initialise les paramètres de NavigationSymbol ; les valeurs par défaut figurent dans la signature.
  const NavigationSymbol({
    super.key,
    required this.kind,
    this.active = false,
    this.size = JoynTokens.navSymbol,
  });

  /// Dessin vectoriel à utiliser.
  final NavigationSymbolKind kind;

  /// Indice ou indicateur d’activation utilisé par cette composition.
  final bool active;

  /// Taille demandée pour le dessin ou dimensions du canevas.
  final double size;

  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: active ? 1 : 0),
        duration: MediaQuery.disableAnimationsOf(context)
            ? JoynTokens.instant
            : JoynTokens.menuDuration,
        curve: Curves.easeOutCubic,
        builder: (context, progress, child) => Transform.scale(
          scale: 1 + JoynTokens.iconHoverGrowth * progress,
          child: CustomPaint(painter: _SymbolPainter(kind, progress)),
        ),
      ),
    ),
  );
}

/// Dessin du pictogramme sélectionné et de la portion de tracé accentuée.
class _SymbolPainter extends CustomPainter {
  /// Initialise les paramètres de _SymbolPainter ; les valeurs par défaut figurent dans la signature.
  const _SymbolPainter(this.kind, this.progress);

  /// Dessin vectoriel à utiliser.
  final NavigationSymbolKind kind;

  /// Avancement de la scène ou du tracé, généralement entre zéro et un.
  final double progress;

  /// Dessine la géométrie dans le repère du canevas fourni.
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 64);
    // Style du trait utilisé pour le dessin.
    final line = Paint()
      ..color = JoynTokens.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Tracé courant du dessin vectoriel.
    final path = Path();
    switch (kind) {
      case NavigationSymbolKind.principle:
        path.addOval(const Rect.fromLTWH(8, 18, 28, 28));
        path.addOval(const Rect.fromLTWH(28, 18, 28, 28));
      case NavigationSymbolKind.obstacles:
        path.moveTo(10, 52);
        path.lineTo(10, 38);
        path.lineTo(25, 38);
        path.lineTo(25, 26);
        path.lineTo(40, 26);
        path.lineTo(40, 12);
        path.lineTo(55, 12);
      case NavigationSymbolKind.compare:
        path.moveTo(32, 8);
        path.lineTo(32, 56);
        path.addRect(const Rect.fromLTWH(8, 20, 16, 24));
        path.moveTo(40, 32);
        path.lineTo(46, 38);
        path.lineTo(58, 22);
      case NavigationSymbolKind.journey:
        path.addOval(const Rect.fromLTWH(8, 10, 12, 12));
        path.addOval(const Rect.fromLTWH(44, 42, 12, 12));
        path.moveTo(20, 16);
        path.cubicTo(60, 12, 0, 52, 44, 48);
      case NavigationSymbolKind.matching:
        path.addOval(const Rect.fromLTWH(8, 8, 48, 48));
        path.addOval(const Rect.fromLTWH(18, 18, 28, 28));
        path.moveTo(24, 32);
        path.lineTo(30, 38);
        path.lineTo(42, 24);
      case NavigationSymbolKind.cv:
        path.addRect(const Rect.fromLTWH(15, 7, 34, 50));
        path.addOval(const Rect.fromLTWH(23, 14, 10, 10));
        path.moveTo(22, 32);
        path.lineTo(42, 32);
        path.moveTo(22, 40);
        path.lineTo(42, 40);
        path.moveTo(22, 48);
        path.lineTo(35, 48);
      case NavigationSymbolKind.criteria:
        path.moveTo(8, 16);
        path.lineTo(56, 16);
        path.moveTo(8, 32);
        path.lineTo(56, 32);
        path.moveTo(8, 48);
        path.lineTo(56, 48);
        path.addRect(const Rect.fromLTWH(18, 11, 8, 10));
        path.addRect(const Rect.fromLTWH(38, 27, 8, 10));
        path.addRect(const Rect.fromLTWH(24, 43, 8, 10));
      case NavigationSymbolKind.favorites:
        path.moveTo(18, 8);
        path.lineTo(46, 8);
        path.lineTo(46, 56);
        path.lineTo(32, 44);
        path.lineTo(18, 56);
        path.close();
      case NavigationSymbolKind.reciprocal:
        path.addRect(const Rect.fromLTWH(6, 10, 32, 24));
        path.moveTo(12, 34);
        path.lineTo(12, 42);
        path.lineTo(22, 34);
        path.addRect(const Rect.fromLTWH(28, 30, 30, 22));
        path.moveTo(44, 52);
        path.lineTo(52, 58);
        path.lineTo(52, 52);
      case NavigationSymbolKind.tracking:
        path.addRect(const Rect.fromLTWH(14, 12, 36, 44));
        path.addRect(const Rect.fromLTWH(24, 7, 16, 10));
        path.moveTo(21, 29);
        path.lineTo(25, 33);
        path.lineTo(31, 25);
        path.moveTo(36, 29);
        path.lineTo(43, 29);
        path.moveTo(21, 43);
        path.lineTo(43, 43);
      case NavigationSymbolKind.editProfile:
        path.addOval(const Rect.fromLTWH(14, 9, 18, 18));
        path.moveTo(7, 49);
        path.cubicTo(7, 29, 39, 29, 39, 44);
        path.moveTo(35, 48);
        path.lineTo(50, 28);
        path.lineTo(57, 34);
        path.lineTo(42, 54);
        path.lineTo(33, 57);
        path.close();
      case NavigationSymbolKind.explore:
        path.addRect(const Rect.fromLTWH(7, 9, 38, 40));
        path.moveTo(14, 19);
        path.lineTo(37, 19);
        path.moveTo(14, 27);
        path.lineTo(30, 27);
        path.addOval(const Rect.fromLTWH(29, 29, 20, 20));
        path.moveTo(46, 46);
        path.lineTo(57, 57);
      case NavigationSymbolKind.interview:
        path.addOval(const Rect.fromLTWH(9, 10, 12, 12));
        path.addOval(const Rect.fromLTWH(43, 10, 12, 12));
        path.moveTo(5, 44);
        path.lineTo(5, 30);
        path.lineTo(24, 30);
        path.lineTo(24, 44);
        path.moveTo(40, 44);
        path.lineTo(40, 30);
        path.lineTo(59, 30);
        path.lineTo(59, 44);
        path.moveTo(13, 53);
        path.lineTo(51, 53);
      case NavigationSymbolKind.publish:
        path.addRect(const Rect.fromLTWH(9, 21, 40, 33));
        path.moveTo(19, 21);
        path.lineTo(19, 13);
        path.lineTo(36, 13);
        path.lineTo(36, 21);
        path.moveTo(47, 8);
        path.lineTo(47, 28);
        path.moveTo(37, 18);
        path.lineTo(57, 18);
      case NavigationSymbolKind.inspectProfile:
        path.addRect(const Rect.fromLTWH(8, 8, 32, 46));
        path.addOval(const Rect.fromLTWH(16, 15, 13, 13));
        path.moveTo(14, 39);
        path.quadraticBezierTo(24, 27, 34, 39);
        path.addOval(const Rect.fromLTWH(34, 32, 19, 19));
        path.moveTo(50, 48);
        path.lineTo(59, 57);
      case NavigationSymbolKind.inbox:
        path.moveTo(8, 12);
        path.lineTo(56, 12);
        path.lineTo(56, 52);
        path.lineTo(8, 52);
        path.close();
        path.moveTo(8, 35);
        path.lineTo(23, 35);
        path.lineTo(27, 42);
        path.lineTo(37, 42);
        path.lineTo(41, 35);
        path.lineTo(56, 35);
        path.moveTo(22, 21);
        path.lineTo(42, 21);
      case NavigationSymbolKind.profileGuide:
        path.addRect(const Rect.fromLTWH(10, 8, 42, 48));
        path.moveTo(18, 8);
        path.lineTo(18, 56);
        path.addOval(const Rect.fromLTWH(28, 17, 12, 12));
        path.moveTo(25, 41);
        path.quadraticBezierTo(34, 28, 44, 41);
      case NavigationSymbolKind.matchGuide:
        path.moveTo(9, 10);
        path.lineTo(49, 10);
        path.lineTo(49, 54);
        path.lineTo(9, 54);
        path.close();
        path.addOval(const Rect.fromLTWH(17, 21, 18, 18));
        path.addOval(const Rect.fromLTWH(28, 21, 18, 18));
      case NavigationSymbolKind.interviewGuide:
        path.addRect(const Rect.fromLTWH(9, 8, 36, 46));
        path.moveTo(17, 18);
        path.lineTo(35, 18);
        path.addRect(const Rect.fromLTWH(26, 29, 30, 20));
        path.moveTo(43, 49);
        path.lineTo(49, 56);
        path.lineTo(49, 49);
      case NavigationSymbolKind.faq:
        path.addOval(const Rect.fromLTWH(8, 8, 48, 48));
        path.moveTo(23, 24);
        path.cubicTo(23, 12, 46, 15, 39, 29);
        path.lineTo(32, 35);
        path.lineTo(32, 39);
        path.moveTo(32, 46);
        path.lineTo(32, 48);
      case NavigationSymbolKind.presentation:
        path.addRect(const Rect.fromLTWH(8, 10, 48, 34));
        path.moveTo(32, 44);
        path.lineTo(32, 56);
        path.moveTo(22, 56);
        path.lineTo(42, 56);
        path.moveTo(27, 20);
        path.lineTo(39, 27);
        path.lineTo(27, 34);
        path.close();
      case NavigationSymbolKind.candidatePlan:
        path.addRect(const Rect.fromLTWH(8, 14, 48, 36));
        path.addOval(const Rect.fromLTWH(16, 21, 12, 12));
        path.moveTo(13, 43);
        path.quadraticBezierTo(22, 32, 31, 43);
        path.moveTo(38, 25);
        path.lineTo(48, 25);
        path.moveTo(38, 35);
        path.lineTo(48, 35);
      case NavigationSymbolKind.companyPlan:
        path.addRect(const Rect.fromLTWH(9, 21, 46, 33));
        path.addRect(const Rect.fromLTWH(22, 11, 20, 10));
        path.moveTo(9, 33);
        path.lineTo(55, 33);
        path.moveTo(31, 42);
        path.lineTo(36, 47);
        path.lineTo(46, 37);
      case NavigationSymbolKind.phone:
        path.addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(18, 5, 28, 54),
            const Radius.circular(4),
          ),
        );
        path.moveTo(27, 12);
        path.lineTo(37, 12);
        path.moveTo(29, 51);
        path.lineTo(35, 51);
      case NavigationSymbolKind.helpCenter:
        path.moveTo(8, 29);
        path.lineTo(32, 9);
        path.lineTo(56, 29);
        path.moveTo(14, 25);
        path.lineTo(14, 55);
        path.lineTo(50, 55);
        path.lineTo(50, 25);
        path.moveTo(26, 55);
        path.lineTo(26, 37);
        path.lineTo(38, 37);
        path.lineTo(38, 55);
      case NavigationSymbolKind.readMatch:
        path.addOval(const Rect.fromLTWH(8, 8, 34, 34));
        path.moveTo(37, 37);
        path.lineTo(56, 56);
        path.moveTo(16, 25);
        path.lineTo(23, 32);
        path.lineTo(35, 18);
      case NavigationSymbolKind.login:
        path.moveTo(34, 9);
        path.lineTo(53, 9);
        path.lineTo(53, 55);
        path.lineTo(34, 55);
        path.moveTo(7, 32);
        path.lineTo(40, 32);
        path.moveTo(29, 21);
        path.lineTo(40, 32);
        path.lineTo(29, 43);
      case NavigationSymbolKind.identity:
        path.addRect(const Rect.fromLTWH(6, 15, 52, 36));
        path.addOval(const Rect.fromLTWH(14, 22, 12, 12));
        path.moveTo(11, 44);
        path.quadraticBezierTo(20, 32, 29, 44);
        path.moveTo(36, 25);
        path.lineTo(50, 25);
        path.moveTo(36, 35);
        path.lineTo(46, 35);
      case NavigationSymbolKind.comparePlans:
        path.addRect(const Rect.fromLTWH(7, 12, 21, 40));
        path.addRect(const Rect.fromLTWH(36, 12, 21, 40));
        path.moveTo(12, 25);
        path.lineTo(23, 25);
        path.moveTo(41, 25);
        path.lineTo(52, 25);
        path.moveTo(12, 36);
        path.lineTo(23, 36);
        path.moveTo(41, 36);
        path.lineTo(52, 36);
      case NavigationSymbolKind.functionality:
        path.addRect(const Rect.fromLTWH(8, 8, 18, 18));
        path.addRect(const Rect.fromLTWH(38, 8, 18, 18));
        path.addRect(const Rect.fromLTWH(8, 38, 18, 18));
        path.moveTo(38, 47);
        path.lineTo(56, 47);
        path.moveTo(47, 38);
        path.lineTo(47, 56);
      case NavigationSymbolKind.company:
        path.addRect(const Rect.fromLTWH(14, 8, 36, 48));
        path.moveTo(7, 56);
        path.lineTo(57, 56);
        path.moveTo(25, 56);
        path.lineTo(25, 42);
        path.lineTo(39, 42);
        path.lineTo(39, 56);
        path.addRect(const Rect.fromLTWH(22, 17, 7, 7));
        path.addRect(const Rect.fromLTWH(36, 17, 7, 7));
        path.addRect(const Rect.fromLTWH(22, 29, 7, 7));
        path.addRect(const Rect.fromLTWH(36, 29, 7, 7));

      case NavigationSymbolKind.profile:
        path.addOval(const Rect.fromLTWH(24, 12, 16, 16));
        path.moveTo(14, 52);
        path.cubicTo(14, 30, 50, 30, 50, 52);
        path.close();
      case NavigationSymbolKind.account:
        path.addOval(const Rect.fromLTWH(21, 8, 22, 22));
        path.moveTo(27, 29);
        path.lineTo(23, 53);
        path.lineTo(41, 53);
        path.lineTo(37, 29);
      case NavigationSymbolKind.work:
        path.addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(10, 22, 44, 30),
            const Radius.circular(4),
          ),
        );
        path.moveTo(23, 22);
        path.lineTo(23, 13);
        path.lineTo(41, 13);
        path.lineTo(41, 22);
        path.moveTo(10, 34);
        path.quadraticBezierTo(32, 45, 54, 34);
        path.moveTo(32, 34);
        path.lineTo(32, 43);
      case NavigationSymbolKind.school:
        path.moveTo(6, 24);
        path.lineTo(32, 12);
        path.lineTo(58, 24);
        path.lineTo(32, 36);
        path.close();
        path.moveTo(16, 30);
        path.lineTo(16, 44);
        path.quadraticBezierTo(32, 57, 48, 44);
        path.lineTo(48, 30);
        path.moveTo(58, 24);
        path.lineTo(58, 43);
      case NavigationSymbolKind.book:
        path.moveTo(32, 17);
        path.quadraticBezierTo(21, 9, 9, 15);
        path.lineTo(9, 49);
        path.quadraticBezierTo(22, 43, 32, 51);
        path.moveTo(32, 17);
        path.quadraticBezierTo(43, 9, 55, 15);
        path.lineTo(55, 49);
        path.quadraticBezierTo(42, 43, 32, 51);
        path.lineTo(32, 17);
      case NavigationSymbolKind.support:
        path.moveTo(12, 35);
        path.cubicTo(12, 5, 52, 5, 52, 35);
        path.lineTo(52, 45);
        path.quadraticBezierTo(52, 54, 36, 54);
        path.addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(8, 30, 10, 16),
            const Radius.circular(4),
          ),
        );
        path.addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(46, 30, 10, 16),
            const Radius.circular(4),
          ),
        );
      case NavigationSymbolKind.search:
        path.addOval(const Rect.fromLTWH(10, 10, 30, 30));
        path.moveTo(36, 36);
        path.lineTo(54, 54);
      case NavigationSymbolKind.menu:
        // Angle interpolé pour transformer les traits du menu en croix.
        final angle = progress * math.pi / 4;
        // Composante horizontale du segment animé du pictogramme.
        final dx =
            math.cos(angle) *
            18; // Composante verticale du segment animé du pictogramme.
        final dy = math.sin(angle) * 18;
        path.moveTo(32 - dx, 32 - dy);
        path.lineTo(32 + dx, 32 + dy);
        path.moveTo(32 - dx, 32 + dy);
        path.lineTo(32 + dx, 32 - dy);
        if (progress < .95) {
          path.moveTo(14, 18 + progress * 14);
          path.lineTo(50, 18 + progress * 14);
          path.moveTo(14, 46 - progress * 14);
          path.lineTo(50, 46 - progress * 14);
        }
      case NavigationSymbolKind.arrow:
        path.moveTo(24, 15);
        path.lineTo(41, 32);
        path.lineTo(24, 49);
      case NavigationSymbolKind.chart:
        path.moveTo(12, 12);
        path.lineTo(12, 52);
        path.lineTo(54, 52);
        path.moveTo(20, 42);
        path.lineTo(20, 31);
        path.moveTo(32, 42);
        path.lineTo(32, 23);
        path.moveTo(44, 42);
        path.lineTo(44, 14);
      case NavigationSymbolKind.message:
        path.addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(9, 12, 46, 34),
            const Radius.circular(6),
          ),
        );
        path.moveTo(20, 46);
        path.lineTo(16, 55);
        path.lineTo(33, 46);
        path.moveTo(19, 25);
        path.lineTo(45, 25);
        path.moveTo(19, 34);
        path.lineTo(37, 34);
      case NavigationSymbolKind.link:
        path.addOval(const Rect.fromLTWH(10, 16, 28, 32));
        path.addOval(const Rect.fromLTWH(26, 16, 28, 32));
    }
    canvas.drawPath(path, line);
    if (progress > 0) {
      line
        ..color = JoynTokens.orange
        ..strokeWidth = JoynTokens.hairline;
      // Segments mesurables du tracé.
      final metrics = path.computeMetrics().toList();
      // Longueur cumulée des segments du tracé.
      final total = metrics.fold<double>(0, (sum, m) => sum + m.length);
      // Longueur de tracé accentué restant à dessiner.
      var remaining = total * progress;
      for (final metric in metrics) {
        if (remaining <= 0) {
          break;
        }
        canvas.drawPath(
          metric.extractPath(0, math.min(remaining, metric.length)),
          line,
        );
        remaining -= metric.length;
      }
    }
    canvas.restore();
  }

  /// Indique si les données du dessin diffèrent du peintre précédent.
  @override
  bool shouldRepaint(covariant _SymbolPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.progress != progress;
}
