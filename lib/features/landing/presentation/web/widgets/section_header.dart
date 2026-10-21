import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_spacing.dart';
import 'package:joyn_front/features/landing/presentation/widgets/landing_motion.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.description,
    this.dark = false,
    this.centered = false,
    this.maxWidth = 760,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String description;
  final bool dark;
  final bool centered;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width < 520
        ? 34.0
        : width < 900
        ? 44.0
        : 52.0;
    final titleColor = dark ? AppColors.white : AppColors.navy;
    final bodyColor = dark
        ? AppColors.white.withValues(alpha: 0.68)
        : const Color(0xFF62778C);

    return LandingReveal(
      child: Align(
        alignment: centered ? Alignment.center : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: centered
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                textAlign: centered ? TextAlign.center : TextAlign.start,
                style: const TextStyle(
                  color: AppColors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: centered ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  color: titleColor,
                  fontSize: titleSize,
                  height: 1.03,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.7,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                description,
                textAlign: centered ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  color: bodyColor,
                  fontSize: width < 520 ? 15 : 17,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
