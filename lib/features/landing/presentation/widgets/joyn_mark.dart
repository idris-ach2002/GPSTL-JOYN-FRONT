// Dessine le signe JOYN et sa rotation au changement d’état actif.
//
// Référence : doc/landing.md#joyn_markdart.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';

/// Signe vectoriel JOYN dont la taille est paramétrable.
class JoynMark extends StatelessWidget {
  /// Initialise les paramètres de JoynMark ; les valeurs par défaut figurent dans la signature.
  const JoynMark({this.size = JoynTokens.logo, super.key});

  /// Taille demandée pour le dessin ou dimensions du canevas.
  final double size;

  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [JoynTokens.orangeLight, JoynTokens.orange],
          ),
        ),
        child: CustomPaint(painter: const _JoynMarkPainter()),
      ),
    );
  }
}

/// Tracé du signe JOYN sur un canevas normalisé.
class _JoynMarkPainter extends CustomPainter {
  /// Initialise les paramètres de _JoynMarkPainter ; les valeurs par défaut figurent dans la signature.
  const _JoynMarkPainter();

  /// Dessine la géométrie dans le repère du canevas fourni.
  @override
  void paint(Canvas canvas, Size size) {
    // Épaisseur du trait employé pour le signe JOYN.
    final strokeWidth = size.width * 0.075;

    // Style du trait des deux boucles du signe JOYN.
    final linkPaint = Paint()
      ..color = JoynTokens.paper
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.save();

    canvas.translate(size.width / 2, size.height / 2);

    canvas.rotate(-math.pi / 5.5);

    // Tracé de la boucle gauche du signe.
    final leftLoop = Rect.fromCenter(
      center: Offset(-size.width * 0.10, 0),
      width: size.width * 0.31,
      height: size.height * 0.53,
    );

    // Tracé de la boucle droite du signe.
    final rightLoop = Rect.fromCenter(
      center: Offset(size.width * 0.10, 0),
      width: size.width * 0.31,
      height: size.height * 0.53,
    );

    canvas.drawOval(leftLoop, linkPaint);

    canvas.drawOval(rightLoop, linkPaint);

    canvas.restore();

    // Style des points de terminaison du signe.
    final dotPaint = Paint()
      ..color = JoynTokens.paper
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.69, size.height * 0.22),
      size.width * 0.045,
      dotPaint,
    );
  }

  /// Indique si les données du dessin diffèrent du peintre précédent.
  @override
  bool shouldRepaint(covariant _JoynMarkPainter oldDelegate) {
    return false;
  }
}

/// Rotation du signe JOYN selon l’état actif.
class AnimatedJoynMark extends StatelessWidget {
  /// Initialise les paramètres de AnimatedJoynMark ; les valeurs par défaut figurent dans la signature.
  const AnimatedJoynMark({super.key, this.active = false});

  /// Indice ou indicateur d’activation utilisé par cette composition.
  final bool active;

  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: active ? 1 : 0),
    duration: MediaQuery.disableAnimationsOf(context)
        ? JoynTokens.instant
        : JoynTokens.menuDuration,
    curve: Curves.easeOutCubic,
    builder: (context, progress, child) =>
        Transform.rotate(angle: progress * math.pi / 12, child: child),
    child: const JoynMark(),
  );
}
