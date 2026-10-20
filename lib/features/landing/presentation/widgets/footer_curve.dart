import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';

/// Fil lumineux autonome du footer.
///
/// Une boucle lente déplace le dégradé du bleu vers l'orange le long de la
/// courbe. L'animation ne dépend plus du scroll. La préférence système
/// « réduire les animations » fige le rendu et évite tout ticker répétitif.
class FooterCurve extends StatefulWidget {
  const FooterCurve({super.key});

  @override
  State<FooterCurve> createState() => _FooterCurveState();
}

class _FooterCurveState extends State<FooterCurve>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );
  bool? _reduced;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced == reduced) return;
    _reduced = reduced;
    if (reduced) {
      _controller
        ..stop()
        ..value = .52;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: SizedBox(
        height: 74,
        width: double.infinity,
        child: CustomPaint(
          painter: _CurvePainter(
            _controller,
            reduced: MediaQuery.disableAnimationsOf(context),
          ),
        ),
      ),
    ),
  );
}

class _CurvePainter extends CustomPainter {
  _CurvePainter(this.animation, {required this.reduced})
    : super(repaint: animation);

  final Animation<double> animation;
  final bool reduced;

  Path _path(Size size) {
    final path = Path();
    for (var x = -20.0; x <= size.width + 20; x += 2) {
      final normalized = x / math.max(1, size.width);
      final y =
          size.height * .54 +
          math.sin(normalized * math.pi * 2.15 - .45) * 12 +
          math.sin(normalized * math.pi * 4.3 + .9) * 3;
      if (x <= -19) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path;
  }

  ui.Gradient _shader(Size size, double phase) {
    final travel = size.width * 1.8;
    final start = -size.width * .8 + travel * phase;
    return ui.Gradient.linear(
      Offset(start, 0),
      Offset(start + size.width * .95, 0),
      [
        AppColors.blue.withValues(alpha: .02),
        AppColors.blue,
        AppColors.orangeLight,
        AppColors.orange,
        AppColors.orange.withValues(alpha: .02),
      ],
      const [0, .22, .5, .76, 1],
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;
    final phase = reduced ? .52 : animation.value;
    final path = _path(size);
    final shader = _shader(size, phase);

    canvas.drawPath(
      path,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 14
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 14),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.2,
    );
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) =>
      oldDelegate.animation != animation || oldDelegate.reduced != reduced;
}
