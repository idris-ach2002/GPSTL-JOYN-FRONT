import 'package:flutter/material.dart';

import '../tokens/app_fonts.dart';

/// Pastille arrondie : statut, catégorie, badge.
class JoynPill extends StatelessWidget {
  const JoynPill({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.borderColor,
    this.fontSize = 13,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    super.key,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final Color? borderColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: fontSize + 3, color: foreground),
              const SizedBox(width: 7),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
