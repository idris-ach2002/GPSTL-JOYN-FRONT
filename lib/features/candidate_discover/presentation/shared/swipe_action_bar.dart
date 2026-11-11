import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_shadows.dart';
import '../../domain/recommended_offer.dart';

/// Boutons sous la pile : annuler, passer (✕), sauvegarder, postuler (♥).
///
/// Ils offrent la même chose que le glissement, pour la souris, le clavier et
/// les lecteurs d'écran.
class SwipeActionBar extends StatelessWidget {
  const SwipeActionBar({
    super.key,
    required this.onDecision,
    this.onUndo,
    this.enabled = true,
    this.scale = 1,
  });

  final ValueChanged<SwipeDecision>? onDecision;

  /// `null` quand il n'y a rien à annuler.
  final VoidCallback? onUndo;
  final bool enabled;
  final double scale;

  @override
  Widget build(BuildContext context) {
    void Function()? action(SwipeDecision decision) =>
        enabled && onDecision != null ? () => onDecision!(decision) : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundAction(
          tooltip: 'Annuler le dernier choix',
          icon: Icons.undo_rounded,
          size: 40 * scale,
          iconColor: AppColors.slate,
          onPressed: onUndo,
        ),
        SizedBox(width: 14 * scale),
        _RoundAction(
          tooltip: 'Passer',
          icon: Icons.close_rounded,
          size: 60 * scale,
          iconColor: AppColors.slate,
          onPressed: action(SwipeDecision.skip),
        ),
        SizedBox(width: 14 * scale),
        _RoundAction(
          tooltip: 'Sauvegarder',
          icon: Icons.bookmark_border_rounded,
          size: 46 * scale,
          iconColor: AppColors.slate,
          onPressed: action(SwipeDecision.save),
        ),
        SizedBox(width: 14 * scale),
        _RoundAction(
          tooltip: 'Intéressé',
          icon: Icons.favorite_rounded,
          size: 64 * scale,
          background: AppColors.orangeLight,
          iconColor: AppColors.navy,
          onPressed: action(SwipeDecision.interested),
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.tooltip,
    required this.icon,
    required this.size,
    required this.iconColor,
    required this.onPressed,
    this.background = AppColors.white,
  });

  final String tooltip;
  final IconData icon;
  final double size;
  final Color iconColor;
  final Color background;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: AnimatedOpacity(
          opacity: disabled ? 0.45 : 1,
          duration: const Duration(milliseconds: 150),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppShadows.card,
            ),
            child: Material(
              color: background,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPressed,
                child: SizedBox.square(
                  dimension: size,
                  child: Icon(icon, size: size * 0.42, color: iconColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
