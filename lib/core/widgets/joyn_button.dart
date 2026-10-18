import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

enum JoynButtonVariant {
  /// Pilule bleu nuit en dégradé, pour l'action principale d'un écran.
  primary,

  /// Pilule blanche avec bordure, pour les actions secondaires.
  secondary,
}

/// Bouton en forme de pilule, aux couleurs de Joyn.
///
/// - [onPressed] à `null` : bouton désactivé (grisé).
/// - [isLoading] à `true` : affiche un indicateur et bloque les clics.
class JoynButton extends StatelessWidget {
  const JoynButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = JoynButtonVariant.primary,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Icône optionnelle affichée après le libellé (ex. une flèche).
  final IconData? icon;
  final bool isLoading;
  final JoynButtonVariant variant;

  /// Si `true`, le bouton prend toute la largeur disponible.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == JoynButtonVariant.primary;
    final isEnabled = onPressed != null && !isLoading;
    final foreground = isPrimary ? Colors.white : AppColors.ink;
    final radius = BorderRadius.circular(AppRadius.pill);

    final Widget content = isLoading
        ? SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(icon, size: 20, color: foreground),
              ],
            ],
          );

    return Semantics(
      button: true,
      enabled: isEnabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onPressed == null && !isLoading ? 0.5 : 1,
        child: SizedBox(
          width: expand ? double.infinity : null,
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: isPrimary ? AppColors.primaryButtonGradient : null,
              color: isPrimary ? null : AppColors.surface,
              borderRadius: radius,
              border: isPrimary ? null : Border.all(color: AppColors.border),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: isEnabled ? onPressed : null,
                borderRadius: radius,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Center(widthFactor: 1, child: content),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
