import 'package:flutter/material.dart';

import '../../core/responsive/app_breakpoints.dart';

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final columns = switch (width) {
      < AppBreakpoints.mobile => 1,
      < AppBreakpoints.tablet => 2,
      _ => 3,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = spacing * (columns - 1);

        final itemWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
