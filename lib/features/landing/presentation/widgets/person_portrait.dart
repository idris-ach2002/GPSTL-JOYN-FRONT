// Dessine les portraits illustrés utilisés dans les aperçus.
//
// Référence : doc/landing/fichiers/person_portrait.md.

import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';

/// Portrait vectoriel de candidat ou de recruteur.
class PersonPortrait extends StatelessWidget {
  /// Initialise les paramètres de PersonPortrait ; les valeurs par défaut figurent dans la signature.
  const PersonPortrait({
    super.key,
    this.recruiter = false,
    this.size = JoynTokens.portrait,
  });

  /// Sélectionne le rôle recruteur ou son portrait selon le composant.
  final bool recruiter;

  /// Taille demandée pour le dessin ou dimensions du canevas.
  final double size;

  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(JoynTokens.radius),
        child: CustomPaint(painter: _PersonPainter(recruiter)),
      ),
    ),
  );
}

/// Dessin du portrait selon le rôle représenté.
class _PersonPainter extends CustomPainter {
  /// Initialise les paramètres de _PersonPainter ; les valeurs par défaut figurent dans la signature.
  const _PersonPainter(this.recruiter);

  /// Sélectionne le rôle recruteur ou son portrait selon le composant.
  final bool recruiter;

  /// Dessine la géométrie dans le repère du canevas fourni.
  @override
  void paint(Canvas canvas, Size size) {
    // Largeur du canevas utilisée comme base des proportions du portrait.
    final w = size.width;
    // Hauteur du canevas utilisée comme base des proportions du portrait.
    final h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = recruiter ? JoynTokens.cyan : JoynTokens.blue,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * .12, h * .65, w * .78, h * .8),
      Paint()..color = JoynTokens.ink,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * .43, h * .53, w * .14, h * .23),
      Paint()..color = JoynTokens.orangeLight,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * .27, h * .12, w * .46, h * .53),
      Paint()..color = JoynTokens.ink,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * .31, h * .22, w * .38, h * .43),
      Paint()..color = JoynTokens.orangeLight,
    );
    // Style de dessin des cheveux du portrait.
    final hair = Path()
      ..moveTo(w * .28, h * .35)
      ..quadraticBezierTo(w * .24, h * .08, w * .50, h * .11)
      ..quadraticBezierTo(w * .79, h * .10, w * .72, h * .37)
      ..lineTo(w * .57, h * .23)
      ..lineTo(w * .30, h * .36)
      ..close();
    canvas.drawPath(hair, Paint()..color = JoynTokens.ink);
    // Style de dessin du visage du portrait.
    final face = Paint()
      ..color = JoynTokens.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .018;
    canvas.drawLine(Offset(w * .40, h * .40), Offset(w * .43, h * .40), face);
    canvas.drawLine(Offset(w * .57, h * .40), Offset(w * .60, h * .40), face);
    // Style du trait de la bouche.
    final smile = Path()
      ..moveTo(w * .44, h * .51)
      ..quadraticBezierTo(w * .50, h * .56, w * .57, h * .51);
    canvas.drawPath(smile, face);
    if (recruiter) {
      canvas.drawOval(Rect.fromLTWH(w * .35, h * .35, w * .13, h * .10), face);
      canvas.drawOval(Rect.fromLTWH(w * .53, h * .35, w * .13, h * .10), face);
      canvas.drawLine(Offset(w * .48, h * .39), Offset(w * .53, h * .39), face);
    }
    // Style de dessin du vêtement du portrait.
    final shirt = Path()
      ..moveTo(w * .36, h * .70)
      ..lineTo(w * .50, h * .86)
      ..lineTo(w * .64, h * .70)
      ..close();
    canvas.drawPath(shirt, Paint()..color = JoynTokens.paper);
  }

  /// Indique si les données du dessin diffèrent du peintre précédent.
  @override
  bool shouldRepaint(covariant _PersonPainter oldDelegate) =>
      oldDelegate.recruiter != recruiter;
}
