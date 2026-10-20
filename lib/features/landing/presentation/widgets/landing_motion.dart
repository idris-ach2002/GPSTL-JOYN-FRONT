import 'package:flutter/material.dart';

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
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
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
