import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/core/theme/app_colors.dart';
import 'package:joyn_front/core/theme/app_dimens.dart';
import 'package:joyn_front/core/theme/app_text_styles.dart';
import 'package:joyn_front/core/widgets/joyn_button.dart';
import 'package:joyn_front/features/dashboard/domain/candidate_profile.dart';
import 'package:joyn_front/features/dashboard/presentation/dashboard_controller.dart';
import 'package:joyn_front/features/dashboard/presentation/widgets/candidate_hero.dart';
import 'package:joyn_front/features/dashboard/presentation/widgets/cv_card.dart';
import 'package:joyn_front/features/dashboard/presentation/widgets/dashboard_top_bar.dart';
import 'package:joyn_front/features/dashboard/presentation/widgets/experience_card.dart';
import 'package:joyn_front/features/dashboard/presentation/widgets/match_card.dart';
import 'package:joyn_front/features/dashboard/presentation/widgets/skills_card.dart';

/// Dashboard recruteur (route `/dashboard`) : fiche d'un candidat comparée
/// à une offre.
///
/// - Grand écran : deux colonnes (compétences + parcours | match + CV).
/// - Petit écran : une seule colonne.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  /// Largeur maximale du contenu sur très grand écran.
  static const double _maxContentWidth = 1200;

  /// Hauteur dont les cartes remontent sur le bandeau bleu.
  static const double _cardsOverlap = 40;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final profile = controller.profile ?? const CandidateProfile();
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;
    final gutter = isWide ? AppSpacing.xl : AppSpacing.md;

    Widget constrained(Widget child) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: child,
        ),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bandeau bleu : barre du haut + en-tête du candidat.
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: AppSpacing.xl + _cardsOverlap,
                  ),
                  child: constrained(
                    Column(
                      children: [
                        DashboardTopBar(isWide: isWide),
                        SizedBox(
                          height: isWide ? AppSpacing.xl : AppSpacing.lg,
                        ),
                        CandidateHero(profile: profile, isWide: isWide),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -_cardsOverlap),
              child: constrained(_Body(controller: controller, isWide: isWide)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contenu sous le bandeau : chargement, erreur ou cartes du profil.
class _Body extends StatelessWidget {
  const _Body({required this.controller, required this.isWide});

  final DashboardController controller;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final error = controller.errorMessage;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Text(error, style: AppTextStyles.muted),
            const SizedBox(height: AppSpacing.md),
            JoynButton(
              label: 'Réessayer',
              expand: false,
              onPressed: controller.load,
            ),
          ],
        ),
      );
    }

    final profile = controller.profile ?? const CandidateProfile();
    const gap = SizedBox(height: AppSpacing.md, width: AppSpacing.md);

    final skills = SkillsCard(
      skills: profile.skills,
      offerTitle: profile.offerTitle,
    );
    final experiences = ExperienceCard(experiences: profile.experiences);
    final match = MatchCard(
      score: profile.matchScore,
      label: profile.matchLabel,
      ranking: profile.ranking,
      highlights: profile.matchHighlights,
    );
    final cv = CvCard(cv: profile.cv);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(children: [skills, gap, experiences]),
                ),
                gap,
                Expanded(child: Column(children: [match, gap, cv])),
              ],
            )
          : Column(children: [match, gap, skills, gap, cv, gap, experiences]),
    );
  }
}
