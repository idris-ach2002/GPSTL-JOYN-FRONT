import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';

/// Boutons « Google » et « LinkedIn » ([OutlinedButton]).
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
    final style = OutlinedButton.styleFrom(
      minimumSize: const Size(64, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: style,
            onPressed: onGoogle,
            icon: const _Badge(label: 'G', round: true),
            label: const Text('Google'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            style: style,
            onPressed: onLinkedIn,
            icon: const _Badge(label: 'in', round: false),
            label: const Text('LinkedIn'),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.round});

  final String label;
  final bool round;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: round ? null : AppColors.navy,
        shape: round ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: round ? null : BorderRadius.circular(6),
        border: round
            ? Border.all(color: AppColors.textPrimary, width: 2)
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: round ? AppColors.textPrimary : AppColors.white,
        ),
      ),
    );
  }
}
