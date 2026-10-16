import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../widgets/landing_motion.dart';
import '../widgets/landing_product_mockups.dart';

class CompaniesSection extends StatelessWidget {
  const CompaniesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF2F6F9),
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 900;
                  final copy = LandingReveal(
                    child: _CompanyCopy(compact: constraints.maxWidth < 520),
                  );
                  final visual = const LandingReveal(
                    delay: Duration(milliseconds: 120),
                    offset: Offset(36, 0),
                    child: _RecruiterWorkspace(),
                  );

                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [copy, const SizedBox(height: 46), visual],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 5, child: copy),
                      const SizedBox(width: 60),
                      Expanded(flex: 6, child: visual),
                    ],
                  );
                },
              ),
              const SizedBox(height: 64),
              LayoutBuilder(
                builder: (context, constraints) {
                  final count = constraints.maxWidth >= 900
                      ? 3
                      : constraints.maxWidth >= 760
                      ? 2
                      : 1;
                  final width =
                      (constraints.maxWidth - (count - 1) * 14) / count;
                  const benefits = [
                    _CompanyBenefit(
                      icon: Icons.filter_alt_outlined,
                      title: 'Moins de bruit',
                      text: 'Les profils arrivent déjà contextualisés par rapport au poste.',
                    ),
                    _CompanyBenefit(
                      icon: Icons.forum_outlined,
                      title: 'Échange au bon moment',
                      text: 'La conversation s’ouvre quand l’intérêt devient réellement réciproque.',
                    ),
                    _CompanyBenefit(
                      icon: Icons.timeline_rounded,
                      title: 'Pipeline lisible',
                      text: 'Compatibilité, message, entretien : une vue claire du recrutement.',
                    ),
                  ];
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      for (var i = 0; i < benefits.length; i++)
                        SizedBox(
                          width: width,
                          child: LandingReveal(
                            delay: Duration(milliseconds: i * 70),
                            child: benefits[i],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanyCopy extends StatelessWidget {
  const _CompanyCopy({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.navy.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: const Text(
            'UNIVERS ENTREPRISE',
            style: TextStyle(
              color: AppColors.cyanBlue,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Recrute moins au volume. Plus au signal.',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: compact ? 38 : 52,
            height: 1.02,
            fontWeight: FontWeight.w900,
            letterSpacing: compact ? -1 : -1.7,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'JOYN ne promet pas plus de CV. Il veut rendre chaque profil plus lisible avant même le premier message.',
          style: TextStyle(color: Color(0xFF687E91), fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: const Text(
            'Découvrir le côté recruteur',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _RecruiterWorkspace extends StatelessWidget {
  const _RecruiterWorkspace();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE0E8EE)),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: .10),
                blurRadius: 42,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Poste · Flutter Developer',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF6FC),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Text(
                      'DÉMO',
                      style: TextStyle(
                        color: AppColors.cyanBlue,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const CandidateListMockup(),
            ],
          ),
        ),
        Positioned(
          right: -10,
          top: -18,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: .18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.orangeLight,
                  size: 15,
                ),
                SizedBox(width: 7),
                Text(
                  'Signal avant volume',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompanyBenefit extends StatelessWidget {
  const _CompanyBenefit({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return LandingHoverLift(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E9EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6FC),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: AppColors.cyanBlue, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF6C8194),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
