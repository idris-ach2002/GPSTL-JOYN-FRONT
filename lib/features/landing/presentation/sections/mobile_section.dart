import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../widgets/landing_motion.dart';
import '../widgets/landing_product_mockups.dart';

class MobileSection extends StatelessWidget {
  const MobileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 92),
          child: LandingReveal(
            child: Container(
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 36),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF062A43), Color(0xFF0C5A7E)],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 780;
                  const visual = SizedBox(
                    width: double.infinity,
                    height: 250,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: PhoneStackMockup(),
                    ),
                  );
                  const copy = _MobileCopy();
                  if (stacked) {
                    return Column(
                      children: [visual, SizedBox(height: 22), copy],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: visual),
                      SizedBox(width: 36),
                      Expanded(child: copy),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileCopy extends StatelessWidget {
  const _MobileCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: const Text(
            'WEB · iOS · ANDROID',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'JOYN dans ta poche.',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Swipe dans le métro, réponds au recruteur entre deux cours. Ton profil, tes matchs et tes messages te suivent partout.',
          style: TextStyle(
            color: AppColors.white.withValues(alpha: .72),
            fontSize: 14,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: AppColors.orangeLight,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Expérience mobile pensée pour les gestes rapides.',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: .7),
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
