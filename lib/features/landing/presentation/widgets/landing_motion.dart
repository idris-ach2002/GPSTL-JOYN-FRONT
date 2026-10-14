import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';

/// Reveals its child the first time it enters the viewport.
///
/// This intentionally avoids a third-party visibility dependency: the widget
/// listens to the closest scroll position and checks its own global position.
class LandingReveal extends StatefulWidget {
  const LandingReveal({
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 34),
    this.duration = const Duration(milliseconds: 650),
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;
  final Duration duration;

  @override
  State<LandingReveal> createState() => _LandingRevealState();
}

class _LandingRevealState extends State<LandingReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  ScrollPosition? _position;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextPosition = Scrollable.maybeOf(context)?.position;
    if (_position != nextPosition) {
      _position?.removeListener(_checkVisibility);
      _position = nextPosition;
      _position?.addListener(_checkVisibility);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (!mounted || _controller.value > 0 || _scheduled) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final top = renderObject.localToGlobal(Offset.zero).dy;
    final viewportHeight = MediaQuery.sizeOf(context).height;
    if (top < viewportHeight * 0.9) {
      _scheduled = true;
      Future<void>.delayed(widget.delay, () {
        if (!mounted) return;
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_checkVisibility);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final value = Curves.easeOutCubic.transform(_controller.value);
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(
              widget.offset.dx * (1 - value),
              widget.offset.dy * (1 - value),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Animated visual bridge between two landing universes.
///
/// It gives the page a deliberate "chapter change" instead of a hard color cut.
class UniverseTransition extends StatefulWidget {
  const UniverseTransition({
    required this.from,
    required this.to,
    this.label,
    this.height = 150,
    super.key,
  });

  final Color from;
  final Color to;
  final String? label;
  final double height;

  @override
  State<UniverseTransition> createState() => _UniverseTransitionState();
}

class _UniverseTransitionState extends State<UniverseTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final dx = math.sin(t * math.pi * 2) * 0.12;
          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [widget.from, widget.to],
                    stops: const [0, 1],
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _TransitionGridPainter(
                      progress: t,
                      light: widget.to.computeLuminance() < 0.35,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(dx, 0.1),
                child: Container(
                  width: 320,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: RadialGradient(
                      colors: [
                        AppColors.orange.withValues(alpha: 0.26),
                        AppColors.blue.withValues(alpha: 0.13),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.label != null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: widget.to.computeLuminance() < 0.35
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: widget.to.computeLuminance() < 0.35
                            ? Colors.white.withValues(alpha: 0.16)
                            : AppColors.navy.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Text(
                      widget.label!,
                      style: TextStyle(
                        color: widget.to.computeLuminance() < 0.35
                            ? AppColors.white
                            : AppColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TransitionGridPainter extends CustomPainter {
  const _TransitionGridPainter({required this.progress, required this.light});

  final double progress;
  final bool light;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (light ? Colors.white : AppColors.navy).withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const spacing = 44.0;
    final drift = progress * spacing;
    for (double x = -spacing + drift; x < size.width + spacing; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TransitionGridPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.light != light;
}
