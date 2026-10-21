import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/layout/content_container.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_radius.dart';
import 'package:joyn_front/design_system/tokens/app_spacing.dart';
import 'package:joyn_front/features/landing/presentation/navigation/landing_section.dart';
import 'package:joyn_front/features/landing/presentation/widgets/hero_background.dart';
import 'package:joyn_front/features/landing/presentation/widgets/hero_match_preview.dart';
import 'package:joyn_front/features/landing/presentation/widgets/landing_motion.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({required this.onNavigate, super.key});

  final LandingNavigate onNavigate;

  @override
  Widget build(BuildContext context) {
    return HeroBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1000;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // La navbar est désormais flottante dans LandingScreen. Ce
              // dégagement conserve la respiration de la maquette originale.
              SizedBox(height: constraints.maxWidth < 690 ? 132 : 96),
              ContentContainer(
                maxWidth: 1440,
                child: isDesktop
                    ? ConstrainedBox(
                        // Le Hero a une taille minimale,
                        // mais peut grandir selon son contenu.
                        constraints: const BoxConstraints(minHeight: 620),
                        child: _DesktopHeroContent(onNavigate: onNavigate),
                      )
                    : _MobileHeroContent(onNavigate: onNavigate),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================================
// DESKTOP
// =============================================================================

class _DesktopHeroContent extends StatelessWidget {
  const _DesktopHeroContent({required this.onNavigate});

  final LandingNavigate onNavigate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 66, bottom: 72),
      child: Row(
        children: [
          Expanded(
            flex: 11,
            child: LandingReveal(
              offset: const Offset(-28, 0),
              child: _HeroCopy(onNavigate: onNavigate),
            ),
          ),
          const SizedBox(width: 56),
          const Expanded(
            flex: 9,
            child: LandingReveal(
              delay: Duration(milliseconds: 140),
              offset: Offset(34, 0),
              child: Center(child: HeroMatchPreview()),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MOBILE / TABLET
// =============================================================================

class _MobileHeroContent extends StatelessWidget {
  const _MobileHeroContent({required this.onNavigate});

  final LandingNavigate onNavigate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 52, bottom: 76),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LandingReveal(
            offset: const Offset(-18, 0),
            child: _HeroCopy(onNavigate: onNavigate),
          ),
          const SizedBox(height: 56),
          const LandingReveal(
            delay: Duration(milliseconds: 120),
            child: Center(child: HeroMatchPreview()),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HERO COPY
// =============================================================================

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onNavigate});

  final LandingNavigate onNavigate;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final isMobile = screenWidth < 700;

    final titleSize = isMobile ? 50.0 : 68.0;
    final joySize = isMobile ? 72.0 : 96.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
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
              color: AppColors.white.withValues(alpha: 0.90),
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
                fontSize: isMobile ? 15 : 17,
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

        const SizedBox(height: 24),

        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _HeroProof(
              icon: Icons.auto_awesome_rounded,
              label: 'Score expliqué',
            ),
            _HeroProof(
              icon: Icons.favorite_outline_rounded,
              label: 'Match réciproque',
            ),
            _HeroProof(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chat au bon moment',
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            FilledButton.icon(
              onPressed: () {
                onNavigate(LandingSection.features);
              },
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
              onPressed: () {
                onNavigate(LandingSection.companies);
              },
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

class _HeroProof extends StatelessWidget {
  const _HeroProof({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.orangeLight),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: .68),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
