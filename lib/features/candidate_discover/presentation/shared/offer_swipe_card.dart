import 'package:flutter/material.dart';

import '../../../../design_system/components/joyn_score_ring.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../../../design_system/tokens/app_shadows.dart';
import '../../domain/recommended_offer.dart';
import 'discover_formatters.dart';

/// Carte d'une offre recommandée, posée dans la [SwipeDeck].
///
/// [compact] resserre la mise en page pour le mobile : description plus
/// courte et en-tête plus petit.
class OfferSwipeCard extends StatelessWidget {
  const OfferSwipeCard({
    super.key,
    required this.offer,
    this.onViewDetails,
    this.compact = false,
  });

  final RecommendedOffer offer;
  final VoidCallback? onViewDetails;
  final bool compact;

  static const Color cardColor = AppColors.skyTint;

  @override
  Widget build(BuildContext context) {
    final padding = compact ? 18.0 : 24.0;
    final radius = BorderRadius.circular(compact ? 24 : 28);
    // La couleur est portée par la décoration : sans fond, l'ombre serait
    // peinte sous toute la carte et la griserait.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
        boxShadow: AppShadows.floating,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(offer: offer, compact: compact),
              SizedBox(height: compact ? 12 : 16),
              Text(
                offer.title,
                maxLines: compact ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  color: AppColors.textPrimary,
                  fontSize: compact ? 22 : 28,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: compact ? 12 : 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (icon, label) in offerFacts(offer))
                    _FactChip(icon: icon, label: label),
                  if (offer.monthlySalary != null)
                    _FactChip(
                      label: formatSalary(offer.monthlySalary!),
                      highlighted: true,
                    ),
                ],
              ),
              SizedBox(height: compact ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        offer.description,
                        maxLines: compact ? 3 : 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFonts.body,
                          color: AppColors.slate,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final skill in offer.skills)
                          OfferSkillChip(skill: skill),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 24, color: AppColors.skyMist),
              _Footer(offer: offer, onViewDetails: onViewDetails),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.offer, required this.compact});

  final RecommendedOffer offer;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final logo = compact ? 40.0 : 48.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: logo,
          height: logo,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            offer.company.initial,
            style: TextStyle(
              fontFamily: AppFonts.display,
              color: AppColors.white,
              fontSize: logo * 0.42,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.company.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  offer.company.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    color: AppColors.slate,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            JoynScoreRing(score: offer.compatibility, size: compact ? 52 : 64),
            const SizedBox(height: 6),
            const Text(
              'COMPATIBILITÉ',
              style: TextStyle(
                fontFamily: AppFonts.body,
                color: AppColors.slate,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.label, this.icon, this.highlighted = false});

  final IconData? icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final foreground = highlighted ? AppColors.successDeep : AppColors.slate;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted ? AppColors.successTint : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: highlighted ? AppColors.successLine : AppColors.line,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.body,
                color: foreground,
                fontSize: 12,
                fontWeight: highlighted ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compétence de l'offre : ✓ si le candidat l'a, ✕ sinon.
class OfferSkillChip extends StatelessWidget {
  const OfferSkillChip({super.key, required this.skill});

  final OfferSkill skill;

  @override
  Widget build(BuildContext context) {
    final matched = skill.matched;
    final color = matched ? AppColors.navy : AppColors.errorDeep;
    return Semantics(
      label: '${skill.name}, ${matched ? 'acquise' : 'à acquérir'}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: matched ? AppColors.skyMist : AppColors.errorTint,
          borderRadius: BorderRadius.circular(6),
          border: matched
              ? null
              : Border.all(color: AppColors.error.withValues(alpha: 0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                matched ? Icons.check_rounded : Icons.close_rounded,
                size: 13,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                skill.name,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.offer, required this.onViewDetails});

  final RecommendedOffer offer;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (offer.alumniCount > 0) ...[
          _AlumniAvatars(count: offer.alumniCount),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              alumniLabel(offer.alumniCount),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                color: AppColors.slate,
                fontSize: 12,
              ),
            ),
          ),
        ] else
          const Spacer(),
        TextButton(
          onPressed: onViewDetails,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.navy,
            textStyle: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text("Voir l'offre complète →"),
        ),
      ],
    );
  }
}

class _AlumniAvatars extends StatelessWidget {
  const _AlumniAvatars({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    const colors = [AppColors.orangeLight, AppColors.blue, AppColors.cyanBlue];
    final shown = count.clamp(1, 3);
    return SizedBox(
      width: 22.0 + (shown - 1) * 14,
      height: 22,
      child: Stack(
        children: [
          for (var i = 0; i < shown; i++)
            Positioned(
              left: i * 14.0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: colors[i % colors.length],
                  shape: BoxShape.circle,
                  border: Border.all(color: OfferSwipeCard.cardColor, width: 2),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 11,
                  color: AppColors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
