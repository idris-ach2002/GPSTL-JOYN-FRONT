import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import 'joyn_mark.dart';

/// Reveals its child the first time it enters the viewport.
///
/// The animation is deliberately limited to opacity + transform so it stays
/// cheap on Flutter Web. When reduced motion is requested, content is rendered
/// immediately.
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

    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }

    final nextPosition = Scrollable.maybeOf(context)?.position;
    if (_position != nextPosition) {
      _position?.removeListener(_checkVisibility);
      _position = nextPosition;
      _position?.addListener(_checkVisibility);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (!mounted || _controller.value > 0 || _scheduled) {
      return;
    }
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final top = renderObject.localToGlobal(Offset.zero).dy;
    final viewportHeight = MediaQuery.sizeOf(context).height;
    if (top < viewportHeight * .9) {
      _scheduled = true;
      Future<void>.delayed(widget.delay, () {
        if (!mounted) {
          return;
        }
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
      child: RepaintBoundary(child: widget.child),
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

/// Small reusable hover treatment for premium product surfaces.
class LandingHoverLift extends StatefulWidget {
  const LandingHoverLift({
    required this.child,
    this.enabled = true,
    this.lift = 7,
    this.scale = 1.012,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final double lift;
  final double scale;

  @override
  State<LandingHoverLift> createState() => _LandingHoverLiftState();
}

class _LandingHoverLiftState extends State<LandingHoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final canAnimate =
        widget.enabled && !MediaQuery.disableAnimationsOf(context);
    final active = canAnimate && _hovered;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOutCubic,
        scale: active ? widget.scale : 1,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 190),
          curve: Curves.easeOutCubic,
          offset: Offset(0, active ? -.018 * widget.lift / 7 : 0),
          child: widget.child,
        ),
      ),
    );
  }
}

typedef LandingScrollSceneBuilder = Widget Function(
  BuildContext context,
  double progress,
  double pinOffset,
  double viewportHeight,
);

/// Reports progress while a tall storytelling scene crosses the viewport.
///
/// The widget is intentionally dependency-free. It is used by the two major
/// universe transitions and by the sticky "How it works" story.
class LandingScrollScene extends StatefulWidget {
  const LandingScrollScene({
    required this.height,
    required this.builder,
    this.topInset = 88,
    super.key,
  });

  final double height;
  final double topInset;
  final LandingScrollSceneBuilder builder;

  @override
  State<LandingScrollScene> createState() => _LandingScrollSceneState();
}

class _LandingScrollSceneState extends State<LandingScrollScene> {
  ScrollPosition? _position;
  double _progress = 0;
  double _pinOffset = 0;
  double _viewportHeight = 800;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextPosition = Scrollable.maybeOf(context)?.position;
    if (_position != nextPosition) {
      _position?.removeListener(_updateMetrics);
      _position = nextPosition;
      _position?.addListener(_updateMetrics);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateMetrics());
  }

  void _updateMetrics() {
    if (!mounted) {
      return;
    }
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final viewportHeight = MediaQuery.sizeOf(context).height;
    final top = renderObject.localToGlobal(Offset.zero).dy;
    final travel = math.max(1.0, widget.height + viewportHeight * .25);
    final progress = ((viewportHeight * .78 - top) / travel)
        .clamp(0.0, 1.0)
        .toDouble();
    final stageHeight = math.min(viewportHeight * .82, 760.0);
    final maxPin = math.max(0.0, widget.height - stageHeight);
    final pin = (-top + widget.topInset).clamp(0.0, maxPin).toDouble();

    if ((progress - _progress).abs() > .002 ||
        (pin - _pinOffset).abs() > .5 ||
        (viewportHeight - _viewportHeight).abs() > .5) {
      setState(() {
        _progress = progress;
        _pinOffset = pin;
        _viewportHeight = viewportHeight;
      });
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_updateMetrics);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: widget.builder(context, _progress, _pinOffset, _viewportHeight),
    );
  }
}

/// Candidate universe -> matching engine.
///
/// Cards converge towards JOYN, a match score takes over, then an orange
/// "flood" fills the scene before revealing the navy matching universe.
class MatchPortalTransition extends StatelessWidget {
  const MatchPortalTransition({super.key});

  double _segment(double value, double start, double end) {
    return ((value - start) / (end - start)).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;
    final height = mobile ? 520.0 : 690.0;

    return LandingScrollScene(
      height: height,
      topInset: mobile ? 28 : 72,
      builder: (context, progress, pinOffset, viewportHeight) {
        final reduceMotion = MediaQuery.disableAnimationsOf(context);
        final t = reduceMotion ? 1.0 : progress;
        final converge = Curves.easeInOutCubic.transform(_segment(t, .05, .48));
        final scoreIn = Curves.easeOutBack.transform(_segment(t, .32, .62));
        final flood = Curves.easeInOutCubic.transform(_segment(t, .52, .86));
        final reveal = Curves.easeOutCubic.transform(_segment(t, .78, 1));
        final bg = Color.lerp(
          AppColors.white,
          const Color(0xFF061F34),
          reveal,
        )!;

        return RepaintBoundary(
          child: ColoredBox(
            color: bg,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _PortalFieldPainter(progress: t),
                    ),
                  ),
                ),
                Positioned(
                  top: pinOffset,
                  left: 0,
                  right: 0,
                  height: math.min(viewportHeight * .78, mobile ? 460 : 610),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(
                          (mobile ? -92 : -250) * (1 - converge),
                          (mobile ? -80 : -120) * (1 - converge),
                        ),
                        child: Opacity(
                          opacity: (1 - flood * .9).clamp(0.0, 1.0).toDouble(),
                          child: const _PortalCard(
                            icon: Icons.person_outline_rounded,
                            label: 'TON PROFIL',
                            detail: 'Compétences · rythme · ambitions',
                            accent: AppColors.cyanBlue,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(
                          (mobile ? 92 : 250) * (1 - converge),
                          (mobile ? 72 : 105) * (1 - converge),
                        ),
                        child: Opacity(
                          opacity: (1 - flood * .9).clamp(0.0, 1.0).toDouble(),
                          child: const _PortalCard(
                            icon: Icons.work_outline_rounded,
                            label: 'L’OFFRE',
                            detail: 'Mission · équipe · localisation',
                            accent: AppColors.orange,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: .7 + scoreIn * .3,
                        child: Opacity(
                          opacity: scoreIn.clamp(0.0, 1.0).toDouble(),
                          child: _PortalScore(progress: scoreIn),
                        ),
                      ),
                      IgnorePointer(
                        child: Transform.scale(
                          scale: .05 + flood * (mobile ? 8 : 12),
                          child: Opacity(
                            opacity:
                                (flood * 1.2).clamp(0.0, 1.0).toDouble() *
                                (1 - reveal),
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: const BoxDecoration(
                                color: AppColors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: mobile ? 42 : 54,
                        child: Opacity(
                          opacity: reveal,
                          child: Transform.translate(
                            offset: Offset(0, 26 * (1 - reveal)),
                            child: Column(
                              children: [
                                const Text(
                                  'LE BRUIT DISPARAÎT.',
                                  style: TextStyle(
                                    color: AppColors.orangeLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.8,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Place au match qui a du sens.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: mobile ? 30 : 48,
                                    height: 1,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: mobile ? -1 : -1.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PortalCard extends StatelessWidget {
  const _PortalCard({
    required this.icon,
    required this.label,
    required this.detail,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 900;
    return Container(
      width: mobile ? 190 : 260,
      padding: EdgeInsets.all(mobile ? 16 : 22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: .24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: .12),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: accent, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Color(0xFF75899B),
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalScore extends StatelessWidget {
  const _PortalScore({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final score = (74 + 20 * progress).round();
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF061F34),
        border: Border.all(color: AppColors.orangeLight, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withValues(alpha: .34),
            blurRadius: 46,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$score%',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 38,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'MATCH',
            style: TextStyle(
              color: AppColors.orangeLight,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalFieldPainter extends CustomPainter {
  const _PortalFieldPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      paint.color = Color.lerp(
        AppColors.cyanBlue.withValues(alpha: .10),
        AppColors.white.withValues(alpha: .07),
        progress,
      )!;
      final radius = 90.0 + i * 74 + math.sin(progress * math.pi * 2 + i) * 10;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PortalFieldPainter oldDelegate) =>
      (oldDelegate.progress - progress).abs() > .002;
}

/// Matching engine -> recruiter universe.
///
/// The viewport splits into two worlds, JOYN joins them, then the recruiter
/// side takes over. This deliberately uses a different motion language than
/// the match portal so the second chapter change does not feel repetitive.
class TwoWorldsTransition extends StatelessWidget {
  const TwoWorldsTransition({super.key});

  double _segment(double value, double start, double end) {
    return ((value - start) / (end - start)).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 900;
    final height = mobile ? 500.0 : 640.0;

    return LandingScrollScene(
      height: height,
      topInset: mobile ? 24 : 72,
      builder: (context, progress, pinOffset, viewportHeight) {
        final reduceMotion = MediaQuery.disableAnimationsOf(context);
        final t = reduceMotion ? 1.0 : progress;
        final join = Curves.easeInOutCubic.transform(_segment(t, .12, .58));
        final takeover = Curves.easeInOutCubic.transform(_segment(t, .56, 1));

        return ColoredBox(
          color: const Color(0xFF061F34),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: pinOffset,
                left: 0,
                right: 0,
                height: math.min(viewportHeight * .78, mobile ? 440 : 560),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final half = constraints.maxWidth / 2;
                    return Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: half * (1 - takeover * .88),
                          child: Container(
                            color: Color.lerp(
                              const Color(0xFF0C5A7E),
                              const Color(0xFFE9F1F6),
                              takeover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          width: half + constraints.maxWidth * .5 * takeover,
                          child: Container(color: const Color(0xFFF2F6F9)),
                        ),
                        Positioned(
                          left: mobile ? 18 : 58,
                          top: mobile ? 74 : 120,
                          child: Opacity(
                            opacity: (1 - takeover).clamp(0.0, 1.0).toDouble(),
                            child: Transform.translate(
                              offset: Offset(70 * join, 0),
                              child: const _WorldBadge(
                                icon: Icons.person_outline_rounded,
                                title: 'CANDIDAT',
                                detail: 'Je cherche le bon environnement.',
                                dark: true,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: mobile ? 18 : 58,
                          bottom: mobile ? 72 : 116,
                          child: Transform.translate(
                            offset: Offset(-70 * join, 0),
                            child: _WorldBadge(
                              icon: Icons.domain_rounded,
                              title: 'ENTREPRISE',
                              detail: 'Je cherche le bon potentiel.',
                              dark: takeover < .45,
                            ),
                          ),
                        ),
                        Center(
                          child: Transform.scale(
                            scale: .82 + join * .18,
                            child: Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.orange.withValues(
                                      alpha: .28,
                                    ),
                                    blurRadius: 40,
                                  ),
                                ],
                              ),
                              child: const Center(child: JoynMark(size: 62)),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 22,
                          child: Opacity(
                            opacity: takeover,
                            child: Text(
                              'Deux besoins. Un même match.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: mobile ? 26 : 42,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorldBadge extends StatelessWidget {
  const _WorldBadge({
    required this.icon,
    required this.title,
    required this.detail,
    required this.dark,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? AppColors.white : AppColors.navy;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 230),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: dark
                  ? AppColors.white.withValues(alpha: .12)
                  : AppColors.navy.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: foreground, size: 23),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: TextStyle(
                    color: foreground.withValues(alpha: .65),
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
