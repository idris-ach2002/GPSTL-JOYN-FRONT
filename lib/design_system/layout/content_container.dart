import 'package:flutter/material.dart';

import '../../core/responsive/app_breakpoints.dart';

class ContentContainer extends StatelessWidget {
  const ContentContainer({
    required this.child,
    this.maxWidth = 1200,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final horizontalPadding = switch (width) {
      < AppBreakpoints.mobile => 20.0,
      < AppBreakpoints.tablet => 32.0,
      _ => 48.0,
    };

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}
