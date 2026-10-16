import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../navigation/landing_section.dart';
import '../widgets/hero_background.dart';
import '../widgets/hero_match_preview.dart';
import '../widgets/landing_navbar.dart';
import '../widgets/landing_motion.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    required this.onNavigate,
    this.showNavbar = true,
    super.key,
  });

  final LandingNavigate onNavigate;
  final bool showNavbar;

  @override
  Widget build(BuildContext context) {
    return HeroBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1000;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showNavbar)
                LandingNavbar(onNavigate: onNavigate)
              else
                const SizedBox(height: 104),
              ContentContainer(
                maxWidth: 1440,
                child: isDesktop
                    ? ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 650),
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

class _DesktopHeroContent extends StatelessWidget {
  const _DesktopHeroContent({required this.onNavigate});

  final LandingNavigate onNavigate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48, bottom: 74),
      child: Row(
        children: [
          Expanded(
            flex: 11,
            child: LandingReveal(
              offset: const Offset(-28, 0),
              child: _HeroCopy(onNavigate: onNavigate),
            ),
          ),
          const SizedBox(width: 44),
          const Expanded(
            flex: 10,
            child: LandingReveal(
              delay: Duration(milliseconds: 120),
              offset: Offset(34, 0),
              child: _HeroLiveDemo(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileHeroContent extends StatelessWidget {
  const _MobileHeroContent({required this.onNavigate});

  final LandingNavigate onNavigate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 34, bottom: 68),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LandingReveal(
            offset: const Offset(-18, 0),
            child: _HeroCopy(onNavigate: onNavigate),
          ),
          const SizedBox(height: 46),
          const LandingReveal(
            delay: Duration(milliseconds: 100),
            child: _HeroLiveDemo(),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onNavigate});

  final LandingNavigate onNavigate;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 900;
    final titleSize = isMobile ? 49.0 : 68.0;
    final joySize = isMobile ? 72.0 : 96.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.white.withValues(alpha: .18)),
          ),
          child: const Text(
            'LE MATCH AVANT LA CANDIDATURE',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.15,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Joyn a job,',
          style: TextStyle(
            color: AppColors.white,
            fontSize: titleSize,
            height: .98,
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
                height: .98,
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
                  height: .78,
                  fontWeight: FontWeight.w400,
                  shadows: [
                    Shadow(
                      color: AppColors.orange.withValues(alpha: .55),
                      blurRadius: 16,
                    ),
                    Shadow(
                      color: AppColors.orangeLight.withValues(alpha: .24),
                      blurRadius: 30,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 34),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 610),
          child: Text(
            'Ton profil entre. Les bonnes offres remontent. JOYN explique le match avant que tu envoies quoi que ce soit.',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: .80),
              fontSize: isMobile ? 15 : 17,
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _HeroPrimaryAction(
              label: 'Voir mes opportunités',
              onPressed: () => onNavigate(LandingSection.opportunities),
            ),
            OutlinedButton.icon(
              onPressed: () => onNavigate(LandingSection.howItWorks),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                side: BorderSide(color: AppColors.white.withValues(alpha: .24)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 17,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
              label: const Text(
                'Voir comment ça marche',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: const [
            _HeroProof(icon: Icons.bolt_rounded, text: 'CV en un geste'),
            _HeroProof(
              icon: Icons.track_changes_rounded,
              text: 'Score expliqué',
            ),
            _HeroProof(icon: Icons.forum_outlined, text: 'Échange réciproque'),
          ],
        ),
      ],
    );
  }
}

class _HeroPrimaryAction extends StatefulWidget {
  const _HeroPrimaryAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_HeroPrimaryAction> createState() => _HeroPrimaryActionState();
}

class _HeroPrimaryActionState extends State<_HeroPrimaryAction> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: hovered && !MediaQuery.disableAnimationsOf(context) ? 1.025 : 1,
        child: FilledButton.icon(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.orange,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _HeroProof extends StatelessWidget {
  const _HeroProof({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.orangeLight),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: .62),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HeroLiveDemo extends StatefulWidget {
  const _HeroLiveDemo();

  @override
  State<_HeroLiveDemo> createState() => _HeroLiveDemoState();
}

class _HeroLiveDemoState extends State<_HeroLiveDemo> {
  Timer? _timer;
  int phase = 0;

  static const labels = [
    ('Profil analysé', Icons.person_search_rounded),
    ('Offre compatible', Icons.work_history_outlined),
    ('Match réciproque', Icons.favorite_rounded),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _timer?.cancel();
      phase = 2;
      return;
    }
    _timer ??= Timer.periodic(const Duration(milliseconds: 2100), (_) {
      if (!mounted) {
        return;
      }
      setState(() => phase = (phase + 1) % labels.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 900;
    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            scale: phase == 2 ? 1.015 : 1,
            child: const HeroMatchPreview(),
          ),
          Positioned(
            left: mobile ? 8 : 26,
            top: mobile ? -18 : 10,
            child: _LiveStatus(data: labels[phase], active: true),
          ),
          if (!mobile)
            Positioned(
              right: 8,
              bottom: 26,
              child: _LiveStatus(
                data: labels[(phase + 1) % labels.length],
                active: false,
              ),
            ),
        ],
      ),
    );
  }
}

class _LiveStatus extends StatelessWidget {
  const _LiveStatus({required this.data, required this.active});

  final (String, IconData) data;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: active ? AppColors.white : const Color(0xFF0B2F4B),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: active
              ? AppColors.orange.withValues(alpha: .25)
              : AppColors.white.withValues(alpha: .12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            data.$2,
            size: 15,
            color: active ? AppColors.orange : AppColors.orangeLight,
          ),
          const SizedBox(width: 7),
          Text(
            data.$1,
            style: TextStyle(
              color: active ? AppColors.navy : AppColors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
