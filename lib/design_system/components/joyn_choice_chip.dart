import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_durations.dart';
import '../tokens/app_fonts.dart';

enum JoynChipTone {
  /// Sélection en bleu nuit (cas général).
  navy,

  /// Sélection en orange (choix principal d'un écran).
  orange,
}

/// Pastille sélectionnable, pour les choix uniques ou multiples.
class JoynChoiceChip extends StatelessWidget {
  const JoynChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.tone = JoynChipTone.navy,
    this.showCheck = false,
    this.borderRadius = 999,
    this.height = 44,
    super.key,
  });

  final String label;
  final bool selected;

  /// `null` désactive la pastille (par exemple, limite de sélection atteinte).
  final VoidCallback? onTap;
  final JoynChipTone tone;

  /// Affiche une coche devant le libellé quand la pastille est sélectionnée.
  final bool showCheck;
  final double borderRadius;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final (background, foreground) = switch ((selected, tone)) {
      (true, JoynChipTone.navy) => (AppColors.navy, AppColors.white),
      (true, JoynChipTone.orange) => (
        AppColors.orangeLight,
        AppColors.textPrimary,
      ),
      (false, _) => (AppColors.surface, AppColors.slateDark),
    };
    final borderColor = selected ? background : AppColors.line;

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: Opacity(
        opacity: enabled || selected ? 1 : 0.45,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: AnimatedContainer(
              duration: AppDurations.fast,
              constraints: BoxConstraints(minHeight: height),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showCheck && selected) ...[
                    Icon(Icons.check_rounded, size: 16, color: foreground),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 14,
                      fontWeight: selected && tone == JoynChipTone.orange
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
