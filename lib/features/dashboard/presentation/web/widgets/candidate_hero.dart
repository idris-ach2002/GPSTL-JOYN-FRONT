import 'package:flutter/material.dart';

import 'package:joyn_front/core/theme/app_colors.dart';
import 'package:joyn_front/core/theme/app_dimens.dart';
import 'package:joyn_front/core/utils/placeholders.dart';
import 'package:joyn_front/core/widgets/coming_soon.dart';
import 'package:joyn_front/features/dashboard/domain/candidate_profile.dart';

/// En-tête du profil : avatar, score de match, nom, accroche et actions.
class CandidateHero extends StatelessWidget {
  const CandidateHero({super.key, required this.profile, required this.isWide});

  final CandidateProfile profile;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      profile.headline,
      profile.school,
      profile.location,
    ].map(Placeholders.text).join(' · ');

    final identity = Row(
      children: [
        _Avatar(initials: profile.initials, size: isWide ? 120 : 76),
        SizedBox(width: isWide ? AppSpacing.lg : AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MatchBadge(score: profile.matchScore),
              const SizedBox(height: AppSpacing.sm),
              Text(
                Placeholders.text(profile.fullName),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWide ? 36 : 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: isWide ? 17 : 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    const actions = _HeroActions();

    if (isWide) {
      return Row(
        children: [
          Expanded(child: identity),
          const SizedBox(width: AppSpacing.lg),
          actions,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        identity,
        const SizedBox(height: AppSpacing.lg),
        actions,
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, required this.size});

  final String? initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.sky,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: initials == null
          ? Icon(
              Icons.person_outline_rounded,
              size: size * 0.45,
              color: AppColors.navy,
            )
          : Text(
              initials!,
              style: TextStyle(
                fontSize: size * 0.3,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
    );
  }
}

/// Badge « 92 % Match ».
class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.score});

  final int? score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '${Placeholders.percent(score)} Match',
        style: const TextStyle(
          color: AppColors.successSoft,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions();

  @override
  Widget build(BuildContext context) {
    // TODO(backend): brancher la messagerie et la prise de rendez-vous.
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        OutlinedButton(
          onPressed: () => showComingSoon(context, 'Messagerie'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            side: const BorderSide(color: Colors.white),
            minimumSize: const Size(0, 42),
            shape: const StadiumBorder(),
          ),
          child: const Text('Envoyer un message'),
        ),
        FilledButton(
          onPressed: () => showComingSoon(context, 'Proposer un entretien'),
          style: FilledButton.styleFrom(
            foregroundColor: AppColors.ink,
            backgroundColor: AppColors.surface,
            minimumSize: const Size(0, 42),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Proposer un entretien'),
        ),
      ],
    );
  }
}
