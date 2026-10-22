import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fond procédural du header "Mes offres".
///
/// Le motif n'utilise aucun asset bitmap : les plans 3D, grilles, points et
/// traits sont dessinés par Flutter et restent nets quelle que soit la taille.
class RecruiterOfferHeaderArt extends StatefulWidget {
  const RecruiterOfferHeaderArt({super.key, this.animate = true});

  final bool animate;

  @override
  State<RecruiterOfferHeaderArt> createState() =>
      _RecruiterOfferHeaderArtState();
}

class _RecruiterOfferHeaderArtState extends State<RecruiterOfferHeaderArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 28),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant RecruiterOfferHeaderArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) _controller.repeat();
    if (!widget.animate && _controller.isAnimating) _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _RecruiterOfferHeaderPainter(
          phase: widget.animate ? _controller.value : .28,
        ),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _RecruiterOfferHeaderPainter extends CustomPainter {
  const _RecruiterOfferHeaderPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;

    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF061F3A), Color(0xFF0C3155), Color(0xFF234B70)],
        stops: [0, .56, 1],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    // Halos bleus/gris pour retrouver le contraste doux de la maquette.
    _radial(
      canvas,
      center: Offset(size.width * .72, size.height * .48),
      radius: size.width * .34,
      colors: const [Color(0x3D80ACDC), Color(0x1594BCE5), Color(0x00061F3A)],
    );
    _radial(
      canvas,
      center: Offset(size.width * .43, size.height * .88),
      radius: size.width * .28,
      colors: const [Color(0x2B4779A6), Color(0x00061F3A)],
    );

    final drift = math.sin(phase * math.pi * 2) * size.width * .004;

    // Plans translucides imbriqués : projection isométrique simplifiée.
    final faces = <_Face>[
      _Face(.42, .16, .17, .46, .10, const Color(0x163A79A8)),
      _Face(.51, .30, .18, .54, .14, const Color(0x1D5B93C3)),
      _Face(.63, .07, .18, .48, .12, const Color(0x225F9DCA)),
      _Face(.70, .30, .14, .44, .11, const Color(0x1C2F6D9C)),
      _Face(.80, .13, .13, .40, .095, const Color(0x205C91B8)),
      _Face(.88, .35, .12, .38, .09, const Color(0x19396F98)),
      _Face(.33, .38, .13, .40, .10, const Color(0x15588AB2)),
    ];
    for (var i = 0; i < faces.length; i++) {
      _drawPrism(canvas, size, faces[i], drift * (i.isEven ? 1 : -1));
    }

    // Matrices de points : discrètes, pas de look "néon IA".
    _dotMatrix(canvas, size, .60, .50, 12, 6, const Color(0x436AA0CD));
    _dotMatrix(canvas, size, .78, .60, 10, 5, const Color(0x526E9EC4));
    _dotMatrix(canvas, size, .36, .18, 8, 4, const Color(0x284F82AA));

    // Traits de perspective très fins.
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .75
      ..color = const Color(0x4A86B6DD);
    for (var i = 0; i < 8; i++) {
      final y = size.height * (.12 + i * .105);
      canvas.drawLine(
        Offset(size.width * .30, y),
        Offset(size.width * (.94 - i * .012), y - size.height * .26),
        line,
      );
    }

    // Micro-cubes flottants pour renforcer la profondeur sans surcharger.
    _smallCube(canvas, size, const Offset(.48, .27), 13);
    _smallCube(canvas, size, const Offset(.72, .20), 9);
    _smallCube(canvas, size, const Offset(.86, .58), 11);
  }

  void _drawPrism(Canvas canvas, Size size, _Face f, double drift) {
    final x = size.width * f.x + drift;
    final y = size.height * f.y;
    final w = size.width * f.w;
    final h = size.height * f.h;
    final depth = size.width * f.depth;

    final front = Path()
      ..moveTo(x, y)
      ..lineTo(x + w, y - h * .12)
      ..lineTo(x + w, y + h * .74)
      ..lineTo(x, y + h)
      ..close();
    canvas.drawPath(front, Paint()..color = f.color);
    canvas.drawPath(
      front,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .9
        ..color = const Color(0x5279A8CD),
    );

    final side = Path()
      ..moveTo(x + w, y - h * .12)
      ..lineTo(x + w + depth, y + h * .10)
      ..lineTo(x + w + depth, y + h * .62)
      ..lineTo(x + w, y + h * .74)
      ..close();
    canvas.drawPath(side, Paint()..color = f.color.withValues(alpha: .52));
    canvas.drawPath(
      side,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7
        ..color = const Color(0x3E8AB8D9),
    );
  }

  void _dotMatrix(
    Canvas canvas,
    Size size,
    double nx,
    double ny,
    int columns,
    int rows,
    Color color,
  ) {
    final paint = Paint()..color = color;
    final dx = math.max(6.0, size.width * .0068);
    final dy = math.max(6.0, size.height * .038);
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        canvas.drawCircle(
          Offset(size.width * nx + col * dx, size.height * ny + row * dy),
          1.05,
          paint,
        );
      }
    }
  }

  void _smallCube(Canvas canvas, Size size, Offset n, double side) {
    final center = Offset(size.width * n.dx, size.height * n.dy);
    final front = Rect.fromCenter(center: center, width: side, height: side);
    canvas.drawRect(front, Paint()..color = const Color(0x315F9DC9));
    canvas.drawRect(
      front,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8
        ..color = const Color(0x657EB0D6),
    );
  }

  void _radial(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required List<Color> colors,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(colors: colors)
          .createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RecruiterOfferHeaderPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _Face {
  const _Face(this.x, this.y, this.w, this.h, this.depth, this.color);
  final double x;
  final double y;
  final double w;
  final double h;
  final double depth;
  final Color color;
}
