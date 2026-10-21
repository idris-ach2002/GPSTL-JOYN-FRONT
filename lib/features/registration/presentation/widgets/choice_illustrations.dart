import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/components/joyn_score_ring.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../../../design_system/tokens/app_gradients.dart';

const _cardShadow = [
  BoxShadow(color: Color(0x240E1F2A), blurRadius: 36, offset: Offset(0, 18)),
];

/// Illustration de la carte « Étudiant·e » : une offre compatible à swiper.
class StudentChoiceIllustration extends StatelessWidget {
  const StudentChoiceIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.studentCard),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final centerX = constraints.maxWidth / 2;
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.hardEdge,
              children: [
                const Positioned(
                  top: -90,
                  right: -40,
                  width: 300,
                  height: 300,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppGradients.heroBlueGlow,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-54, 10),
                  child: Transform.rotate(
                    angle: -9 * math.pi / 180,
                    child: Container(
                      width: 200,
                      height: 132,
                      decoration: BoxDecoration(
                        color: const Color(0x99FFFFFF),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-18, 0),
                  child: Transform.rotate(
                    angle: 3 * math.pi / 180,
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _MiniOfferCard(),
                    ),
                  ),
                ),
                Positioned(
                  left: centerX + 96,
                  bottom: 18,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.orangeLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x73FF8559),
                          blurRadius: 22,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MiniOfferCard extends StatelessWidget {
  const _MiniOfferCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 236,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'N',
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nébula Pay',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Paris 9e · 35 min',
                      style: TextStyle(fontSize: 11, color: AppColors.slate),
                    ),
                  ],
                ),
              ),
              const JoynScoreRing(score: 92),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Développeuse·eur Full-Stack',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 17,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              _Tag('React', AppColors.skyTint, AppColors.navy),
              _Tag('Node.js', AppColors.skyTint, AppColors.navy),
              _Tag(
                '3 sem / 1 sem',
                AppColors.successTint,
                AppColors.successDeep,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

/// Illustration de la carte « Entreprise » : des profils compatibles.
class CompanyChoiceIllustration extends StatelessWidget {
  const CompanyChoiceIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.companyCard),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned(
              top: -120,
              right: -60,
              width: 320,
              height: 320,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.heroOrangeGlow,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 60, 0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 272),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CandidateRow(
                        initials: 'YK',
                        name: 'Yasmine K.',
                        detail: 'M1 Informatique · cooptée',
                        score: 92,
                        avatarColor: AppColors.cyanBlue,
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 28),
                        child: _CandidateRow(
                          initials: 'HL',
                          name: 'Hugo L.',
                          detail: 'BUT Informatique',
                          score: 88,
                          avatarColor: AppColors.orangeLight,
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: _NewProfilesBadge(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({
    required this.initials,
    required this.name,
    required this.detail,
    required this.score,
    required this.avatarColor,
  });

  final String initials;
  final String name;
  final String detail;
  final int score;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: avatarColor,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  detail,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.slate),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.skyTint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$score%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewProfilesBadge extends StatelessWidget {
  const _NewProfilesBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xBFFFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.orangeLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Flexible(
            child: Text(
              '5 nouveaux profils compatibles',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.orangeDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
