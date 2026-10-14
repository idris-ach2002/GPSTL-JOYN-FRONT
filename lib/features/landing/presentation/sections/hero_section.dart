import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../widgets/hero_background.dart';
import '../widgets/hero_match_preview.dart';
import '../widgets/landing_navbar.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return HeroBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1000;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LandingNavbar(),

              ContentContainer(
                maxWidth: 1440,
                child: isDesktop
                    ? const SizedBox(height: 680, child: _DesktopHeroContent())
                    : const _MobileHeroContent(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DesktopHeroContent extends StatelessWidget {
  const _DesktopHeroContent();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80, bottom: 90),
      child: Row(
        children: [
          Expanded(flex: 11, child: _HeroCopy()),

          SizedBox(width: 80),

          Expanded(flex: 9, child: Center(child: HeroMatchPreview())),
        ],
      ),
    );
  }
}

class _MobileHeroContent extends StatelessWidget {
  const _MobileHeroContent();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 52, bottom: 76),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroCopy(),

          SizedBox(height: 64),

          Center(
            child: FittedBox(fit: BoxFit.scaleDown, child: HeroMatchPreview()),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final isMobile = screenWidth < 700;

    final titleSize = isMobile ? 52.0 : 74.0;
    final joySize = isMobile ? 74.0 : 102.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.18)),
          ),
          child: Text(
            'Trouve l’opportunité qui te correspond.',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Text(
          'Joyn a job,',
          style: TextStyle(
            color: AppColors.white,
            fontSize: titleSize,
            height: 0.98,
            fontWeight: FontWeight.w700,
            letterSpacing: isMobile ? -2 : -3,
          ),
        ),

        const SizedBox(height: 2),

        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'With ',
              style: TextStyle(
                color: AppColors.white,
                fontSize: titleSize,
                height: 0.98,
                fontWeight: FontWeight.w700,
                letterSpacing: isMobile ? -2 : -3,
              ),
            ),

            Transform.translate(
              offset: Offset(0, isMobile ? 8 : 11),
              child: Text(
                'joy.',
                style: TextStyle(
                  fontFamily: 'GreatVibes',
                  color: AppColors.orangeLight,
                  fontSize: joySize,
                  height: 0.78,
                  fontWeight: FontWeight.w400,
                  shadows: [
                    Shadow(
                      color: AppColors.orange.withValues(alpha: 0.55),
                      blurRadius: 16,
                    ),
                    Shadow(
                      color: AppColors.orangeLight.withValues(alpha: 0.24),
                      blurRadius: 30,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 42),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.82),
                fontSize: isMobile ? 16 : 18,
                height: 1.6,
              ),
              children: const [
                TextSpan(text: 'Fini les candidatures à l’aveugle ! Découvre '),
                TextSpan(
                  text: 'des offres adaptées à tes compétences',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: ', à ta formation et à tes ambitions. '),
                TextSpan(
                  text: 'Swipe sur celles qui t’intéressent',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ', matche avec les entreprises et commence à échanger dès que l’intérêt est réciproque.',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            FilledButton.icon(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text(
                'Trouver des offres',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),

            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                side: BorderSide(
                  color: AppColors.white.withValues(alpha: 0.25),
                ),
              ),
              child: const Text(
                'Je recrute',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
