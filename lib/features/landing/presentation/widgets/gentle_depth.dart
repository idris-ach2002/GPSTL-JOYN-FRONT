import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';

/// Bounded pointer depth, only for the hero; never changes the hit target size.
class GentleDepth extends StatefulWidget {
  const GentleDepth({super.key, required this.child});
  final Widget child;
  @override
  State<GentleDepth> createState() => _GentleDepthState();
}

class _GentleDepthState extends State<GentleDepth> {
  Offset target = Offset.zero;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.sizeOf(context).width < JoynTokens.tablet) {
      return widget.child;
    }
    return LayoutBuilder(
      builder: (context, constraints) => MouseRegion(
        onHover: (event) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null || box.size.height == 0 || box.size.width == 0) {
            return;
          }
          final x = (event.localPosition.dx / box.size.width * 2 - 1)
              .clamp(-1.0, 1.0)
              .toDouble();
          final y = (event.localPosition.dy / box.size.height * 2 - 1)
              .clamp(-1.0, 1.0)
              .toDouble();
          setState(
            () => target = Offset(
              x * JoynTokens.parallaxTravel,
              y * JoynTokens.parallaxTravel,
            ),
          );
        },
        onExit: (_) => setState(() => target = Offset.zero),
        child: TweenAnimationBuilder<Offset>(
          tween: Tween(begin: Offset.zero, end: target),
          duration: JoynTokens.menuDuration,
          curve: Curves.easeOutCubic,
          builder: (context, offset, child) =>
              Transform.translate(offset: offset, child: child),
          child: widget.child,
        ),
      ),
    );
  }
}
