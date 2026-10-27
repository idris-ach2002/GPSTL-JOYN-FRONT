import 'package:flutter/material.dart';

import 'package:joyn_front/core/widgets/brand_logo.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';

/// Boutons « Google » et « LinkedIn ».
class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({
    required this.onGoogle,
    required this.onLinkedIn,
    super.key,
  });

  final VoidCallback onGoogle;
  final VoidCallback onLinkedIn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            semanticsLabel: 'Continuer avec Google',
            badge: const BrandLogo.google(),
            onTap: onGoogle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialButton(
            label: 'LinkedIn',
            semanticsLabel: 'Continuer avec LinkedIn',
            badge: const BrandLogo.linkedIn(),
            onTap: onLinkedIn,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.semanticsLabel,
    required this.badge,
    required this.onTap,
  });

  final String label;
  final String semanticsLabel;
  final Widget badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                badge,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
