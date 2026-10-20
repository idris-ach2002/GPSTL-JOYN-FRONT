import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_shadows.dart';
import '../../../../design_system/tokens/app_spacing.dart';

/// Démonstration visuelle du matching JOYN.
///
/// Deux compositions sont volontairement utilisées :
///
/// Desktop:
/// - grande interface
/// - cartes flottantes
/// - composition marketing plus spectaculaire
///
/// Tablet / mobile:
/// - aucune carte ne dépasse du viewport
/// - toutes les informations font partie du flux normal
/// - boutons capables de revenir à la ligne
class HeroMatchPreview extends StatelessWidget {
  const HeroMatchPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Semantics(
      label: 'Illustration fictive du matching',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (screenWidth < 1180)
            const _CompactMatchPreview()
          else
            const _DesktopMatchPreview(),
          const SizedBox(height: 12),
          const Text(
            'Aperçu illustratif',
            style: TextStyle(color: AppColors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DESKTOP
// =============================================================================

class _DesktopMatchPreview extends StatelessWidget {
  const _DesktopMatchPreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 520,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: SizedBox(
          width: 680,
          height: 540,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ----------------------------------------------------------------
              // Carte principale
              // ----------------------------------------------------------------
              const Positioned(
                left: 105,
                top: 34,
                width: 470,
                child: _MainMatchCard(),
              ),

              // ----------------------------------------------------------------
              // Compatibilité
              //
              // Contrairement à l'ancienne version, cette carte fait maintenant
              // partie des 680 px du canvas complet.
              // ----------------------------------------------------------------
              const Positioned(
                right: 0,
                top: 105,
                child: _DesktopCompatibilityCard(),
              ),

              // ----------------------------------------------------------------
              // Entretien
              // ----------------------------------------------------------------
              const Positioned(
                left: 0,
                bottom: 8,
                child: _DesktopInterviewCard(),
              ),

              // ----------------------------------------------------------------
              // Notification
              // ----------------------------------------------------------------
              const Positioned(left: 80, top: 70, child: _NotificationCard()),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// TABLET / MOBILE
// =============================================================================

class _CompactMatchPreview extends StatelessWidget {
  const _CompactMatchPreview();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final requestedWidth = math.min(math.max(screenWidth - 40, 280), 560);

    return SizedBox(
      width: requestedWidth.toDouble(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.36)),
          boxShadow: AppShadows.floating,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ----------------------------------------------------------------
            // Avatars
            // ----------------------------------------------------------------
            const _MatchedProfiles(compact: true),

            const SizedBox(height: AppSpacing.lg),

            // ----------------------------------------------------------------
            // Match
            // ----------------------------------------------------------------
            const _MatchTitle(compact: true),

            const SizedBox(height: AppSpacing.sm),

            Text(
              'Cette entreprise est aussi intéressée par ton profil.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.75),
                fontSize: 14,
                height: 1.45,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ----------------------------------------------------------------
            // Compatibilité intégrée
            // ----------------------------------------------------------------
            const _CompactCompatibilityCard(),

            const SizedBox(height: AppSpacing.md),

            // ----------------------------------------------------------------
            // Entretien intégré
            // ----------------------------------------------------------------
            const _CompactInterviewCard(),

            const SizedBox(height: AppSpacing.lg),

            // ----------------------------------------------------------------
            // Actions
            // ----------------------------------------------------------------
            const _MatchActions(),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// MAIN DESKTOP CARD
// =============================================================================

class _MainMatchCard extends StatelessWidget {
  const _MainMatchCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.42)),
        boxShadow: AppShadows.floating,
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _MatchedProfiles(),

          SizedBox(height: AppSpacing.lg),

          _MatchTitle(),

          SizedBox(height: AppSpacing.sm),

          Text(
            'Cette entreprise est aussi intéressée par ton profil.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xBFFFFFFF),
              fontSize: 14,
              height: 1.4,
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          _MatchActions(),
        ],
      ),
    );
  }
}

// =============================================================================
// MATCHED PROFILES
// =============================================================================

class _MatchedProfiles extends StatelessWidget {
  const _MatchedProfiles({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 76.0 : 88.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _AvatarCircle(
          label: 'YK',
          size: size,
          backgroundColor: AppColors.cyanBlue.withValues(alpha: 0.86),
          borderColor: AppColors.white,
        ),
        Transform.translate(
          offset: Offset(compact ? -10 : -12, 0),
          child: _AvatarCircle(
            label: 'N',
            size: size,
            backgroundColor: AppColors.navy,
            borderColor: AppColors.orange,
          ),
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.label,
    required this.size,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String label;
  final double size;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(width: 2, color: borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.35),
            blurRadius: 24,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.white,
          fontSize: size * 0.25,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =============================================================================
// TITLE
// =============================================================================

class _MatchTitle extends StatelessWidget {
  const _MatchTitle({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: AppColors.white,
          fontSize: compact ? 26 : 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        children: const [
          TextSpan(text: 'C’est un match'),
          TextSpan(
            text: '.',
            style: TextStyle(color: AppColors.orange),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ACTIONS
// =============================================================================

class _MatchActions extends StatelessWidget {
  const _MatchActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        FilledButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/connexion'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.navy,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
          label: const Text(
            'Écrire au recruteur',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pushNamed(context, '/connexion'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            side: BorderSide(color: AppColors.white.withValues(alpha: 0.32)),
          ),
          child: const Text(
            'Continuer',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// DESKTOP FLOATING CARDS
// =============================================================================

class _DesktopCompatibilityCard extends StatelessWidget {
  const _DesktopCompatibilityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F7),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.orange,
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                '94%',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Très compatible',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Technos, rythme et trajet',
            style: TextStyle(color: AppColors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DesktopInterviewCard extends StatelessWidget {
  const _DesktopInterviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
      ),
      child: const _InterviewContent(),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
      ),
      child: const Icon(
        Icons.notifications_none_rounded,
        color: AppColors.blue,
      ),
    );
  }
}

// =============================================================================
// MOBILE / TABLET CARDS
// =============================================================================

class _CompactCompatibilityCard extends StatelessWidget {
  const _CompactCompatibilityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F7),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Row(
        children: [
          ContainerIcon(
            icon: Icons.auto_awesome_rounded,
            color: AppColors.orange,
          ),

          SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Très compatible',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Technos, rythme et trajet',
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          SizedBox(width: AppSpacing.sm),

          Text(
            '94%',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactInterviewCard extends StatelessWidget {
  const _CompactInterviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const _InterviewContent(),
    );
  }
}

class _InterviewContent extends StatelessWidget {
  const _InterviewContent();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        ContainerIcon(
          icon: Icons.event_available_rounded,
          color: AppColors.success,
        ),

        SizedBox(width: AppSpacing.sm),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entretien confirmé',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Jeudi · 14:00 · Visio',
                style: TextStyle(color: AppColors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// SMALL ICON
// =============================================================================

class ContainerIcon extends StatelessWidget {
  const ContainerIcon({required this.icon, required this.color, super.key});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }
}
