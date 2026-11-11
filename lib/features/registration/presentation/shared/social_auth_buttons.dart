import 'package:flutter/material.dart';

import '../../../../design_system/components/joyn_brand_logos.dart';

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
            icon: const GoogleLogo(),
            label: const Text('Google'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            style: style,
            onPressed: onLinkedIn,
            icon: const LinkedInLogo(),
            label: const Text('LinkedIn'),
          ),
        ),
      ],
    );
  }
}
