import 'package:flutter/material.dart';

import 'package:joyn_front/core/theme/app_dimens.dart';
import 'package:joyn_front/core/widgets/brand_logo.dart';

/// Boutons de connexion Google et LinkedIn.
///
/// TODO(auth): ces connexions ne sont pas encore disponibles côté backend.
class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({
    super.key,
    required this.onGoogle,
    required this.onLinkedIn,
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
            logo: const BrandLogo.google(),
            onPressed: onGoogle,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SocialButton(
            label: 'LinkedIn',
            logo: const BrandLogo.linkedIn(),
            onPressed: onLinkedIn,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.logo,
    required this.onPressed,
  });

  final String label;
  final Widget logo;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          const SizedBox(width: 10),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
