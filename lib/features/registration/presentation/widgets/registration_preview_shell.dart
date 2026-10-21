import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/components/joyn_pill.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../../../design_system/tokens/app_gradients.dart';
import 'dot_grid.dart';

/// Panneau bleu nuit « Aperçu en direct » des écrans d'inscription.
///
/// Fournit le fond (dégradé, halos, trame, anneaux), l'introduction et la
/// mise en page verticale ; le contenu de la carte et du pied de panneau
/// dépend du type de compte.
class RegistrationPreviewShell extends StatelessWidget {
  const RegistrationPreviewShell({
    required this.title,
    required this.subtitle,
    required this.card,
    required this.footer,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget card;
  final Widget footer;

  /// Largeur maximale du texte et des cartes, comme sur la maquette.
  static const double _maxContentWidth = 470;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.hero),
        child: Stack(
          children: [
            const Positioned(
              top: -260,
              right: -260,
              width: 720,
              height: 720,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppGradients.heroBlueGlow),
                ),
              ),
            ),
            const Positioned(
              bottom: -220,
              left: -200,
              width: 560,
              height: 560,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppGradients.heroOrangeGlow,
                  ),
                ),
              ),
            ),
            const Positioned.fill(child: DotGrid(opacity: 0.55)),
            const Positioned(
              right: -170,
              bottom: -120,
              width: 520,
              height: 364,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.13,
                  child: CustomPaint(painter: _RingsPainter()),
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                const padding = 44.0;
                // Largeur réelle du contenu, fixée AVANT IntrinsicHeight :
                // la hauteur est ainsi mesurée à la bonne largeur (sinon le
                // texte replié sur plus de lignes déborde).
                final contentWidth = math.max(
                  0.0,
                  math.min(_maxContentWidth, constraints.maxWidth - padding * 2),
                );
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(padding),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: contentWidth,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: math.max(
                            0.0,
                            constraints.maxHeight - padding * 2,
                          ),
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _Intro(title: title, subtitle: subtitle),
                              const SizedBox(height: 30),
                              card,
                              const SizedBox(height: 30),
                              footer,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const JoynPill(
          label: 'Aperçu en direct',
          icon: Icons.auto_awesome_outlined,
          background: Color(0x1FFFFFFF),
          foreground: AppColors.white,
          borderColor: Color(0x38FFFFFF),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        ),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            text: title,
            children: const [
              TextSpan(
                text: '.',
                style: TextStyle(color: AppColors.orangeLight),
              ),
            ],
          ),
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: (MediaQuery.sizeOf(context).width * 0.032)
                .clamp(34.0, 48.0)
                .toDouble(),
            height: 1.02,
            letterSpacing: -2,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            height: 1.55,
            color: AppColors.skyMist,
          ),
        ),
      ],
    );
  }
}

/// Carte blanche de l'aperçu, avec une vignette flottante facultative
/// en haut à droite.
class PreviewCard extends StatelessWidget {
  const PreviewCard({required this.children, this.floating, super.key});

  final Widget? floating;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59030E16),
            blurRadius: 60,
            offset: Offset(0, 30),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );

    final chip = floating;
    if (chip == null) return card;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(padding: const EdgeInsets.only(top: 20), child: card),
        Positioned(top: -8, right: -10, child: chip),
      ],
    );
  }
}

/// Vignette flottante : un visuel à gauche, deux lignes de texte.
class PreviewFloatingChip extends StatelessWidget {
  const PreviewFloatingChip({
    required this.leading,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final Widget leading;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D030E16),
            blurRadius: 36,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.slate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bloc « Juste après » : séparateur, titre et 3 prochaines étapes.
class PreviewNextSteps extends StatelessWidget {
  const PreviewNextSteps({required this.steps, super.key});

  final List<PreviewStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, thickness: 1, color: AppColors.lineSoft),
        const SizedBox(height: 16),
        const Text(
          'JUSTE APRÈS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.72,
            color: AppColors.slate,
          ),
        ),
        for (final step in steps) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: step.accent ? AppColors.orangeTint : AppColors.skyTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  step.icon,
                  size: 18,
                  color: step.accent ? AppColors.orangeDeep : AppColors.navy,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      step.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Une prochaine étape de [PreviewNextSteps].
class PreviewStep {
  const PreviewStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// Affiche l'étape en orange (la plus engageante, en dernier).
  final bool accent;
}

/// Une personne ou une entreprise dans le pied de panneau.
class PreviewBadge {
  const PreviewBadge(this.initials, this.name, this.background, this.foreground);

  final String initials;
  final String name;
  final Color background;
  final Color foreground;
}

/// Pied de panneau : titre, pastilles et phrase de réassurance.
class PreviewFooter extends StatelessWidget {
  const PreviewFooter({
    required this.title,
    required this.badges,
    required this.icon,
    required this.note,
    this.roundAvatars = false,
    super.key,
  });

  final String title;
  final List<PreviewBadge> badges;
  final IconData icon;
  final String note;

  /// Avatars ronds (personnes) plutôt que carrés (entreprises).
  final bool roundAvatars;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.72,
            color: AppColors.skyMist,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final badge in badges)
              Container(
                padding: const EdgeInsets.fromLTRB(6, 6, 13, 6),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x2EFFFFFF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badge.background,
                        shape: roundAvatars
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        borderRadius: roundAvatars
                            ? null
                            : BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x40FFFFFF)),
                      ),
                      child: Text(
                        badge.initials,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: badge.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      badge.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, size: 18, color: AppColors.skyMist),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                note,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.skyMist,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RingsPainter extends CustomPainter {
  const _RingsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Reprise du pictogramme Joyn en très grand, dans une grille de 40 × 28.
    final s = size.width / 40;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * s;
    canvas.drawCircle(
      Offset(14 * s, 14 * s),
      10 * s,
      paint..color = AppColors.white,
    );
    canvas.drawCircle(
      Offset(26 * s, 14 * s),
      10 * s,
      paint..color = AppColors.orangeLight,
    );
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) => false;
}
