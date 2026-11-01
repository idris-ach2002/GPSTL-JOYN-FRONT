import 'package:flutter/material.dart';

import '../../../../design_system/material/joyn_chip_group.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/tokens/app_colors.dart';

/// Haut des écrans d'inscription mobiles : retour + logo, puis puce d'étape,
/// titre et phrase d'introduction.
class MobileRegisterHeader extends StatelessWidget {
  const MobileRegisterHeader({
    required this.onBack,
    required this.title,
    required this.subtitle,
    this.stepLabel,
    this.stepColor = AppColors.skyTint,
    super.key,
  });

  final VoidCallback onBack;
  final String title;
  final String subtitle;
  final String? stepLabel;
  final Color stepColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stepLabel = this.stepLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              tooltip: 'Retour',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Spacer(),
            const MobileBrandMark(compact: true),
          ],
        ),
        const SizedBox(height: 28),
        if (stepLabel != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: JoynInfoChip(
              label: stepLabel,
              background: stepColor,
              foreground: AppColors.navy,
              small: true,
            ),
          ),
          const SizedBox(height: 14),
        ],
        Semantics(
          header: true,
          child: Text(
            title,
            style: textTheme.headlineMedium?.copyWith(color: AppColors.navy),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
        ),
      ],
    );
  }
}
