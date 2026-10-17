import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_fonts.dart';

/// Lien textuel cliquable (accessible au clavier).
class JoynTextLink extends StatelessWidget {
  const JoynTextLink({
    required this.label,
    required this.onTap,
    this.fontSize = 14,
    this.color = AppColors.navy,
    this.leadingIcon,
    this.underline = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final double fontSize;
  final Color color;
  final IconData? leadingIcon;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: fontSize + 2, color: color),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: color,
                  decoration: underline ? TextDecoration.underline : null,
                  decorationColor: color.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
