import 'package:flutter/material.dart';

/// Entrée douce des écrans natifs JOYN après le splash ou une navigation auth.
class MobileEntryTransition extends StatelessWidget {
  const MobileEntryTransition({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 760),
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: Transform.scale(
              scale: .985 + (.015 * value),
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
