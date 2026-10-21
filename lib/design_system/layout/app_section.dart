import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';
import 'content_container.dart';

class AppSection extends StatelessWidget {
  const AppSection({
    required this.child,
    this.backgroundColor,
    this.verticalPadding = AppSpacing.section,
    super.key,
  });

  final Widget child;
  final Color? backgroundColor;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: ContentContainer(child: child),
      ),
    );
  }
}
