import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_fonts.dart';

/// Pastille avec un bouton « retirer » (compétence, soft skill…).
class JoynRemovableChip extends StatelessWidget {
  const JoynRemovableChip({
    required this.label,
    required this.onRemove,
    this.background = AppColors.skyTint,
    this.foreground = AppColors.navy,
    super.key,
  });

  final String label;
  final VoidCallback onRemove;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
          const SizedBox(width: 2),
          IconButton(
            tooltip: 'Retirer $label',
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            iconSize: 16,
            icon: Icon(Icons.close_rounded, color: foreground),
          ),
        ],
      ),
    );
  }
}
