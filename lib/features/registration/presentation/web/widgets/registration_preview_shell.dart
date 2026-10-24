import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_fonts.dart';
import 'package:joyn_front/design_system/tokens/app_gradients.dart';
import 'package:joyn_front/features/registration/presentation/web/widgets/dot_grid.dart';

/// Panneau bleu nuit « Aperçu en direct » des écrans d'inscription.
///
/// Fournit le fond (dégradé, halos, trame, anneaux), le titre et la mise en
/// page ; la carte d'aperçu dépend du type de compte. Le contenu est réduit
/// si besoin pour toujours tenir dans la hauteur, sans défilement.
class RegistrationPreviewShell extends StatelessWidget {
  const RegistrationPreviewShell({
    required this.title,
    required this.subtitle,
    required this.card,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget card;

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
                  decoration: BoxDecoration(
                    gradient: AppGradients.heroBlueGlow,
                  ),
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
                final contentWidth = math.max(
                  0.0,
                  math.min(
                    _maxContentWidth,
                    constraints.maxWidth - padding * 2,
                  ),
                );
                // Pas de défilement : si la fenêtre est trop basse, le
                // contenu est réduit proportionnellement (scaleDown).
                return Padding(
                  padding: const EdgeInsets.all(padding),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: contentWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Intro(title: title, subtitle: subtitle),
                            const SizedBox(height: 32),
                            card,
                          ],
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
    final card = Card(
      elevation: 18,
      shadowColor: const Color(0x99030E16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
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
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 12,
      shadowColor: const Color(0x80030E16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: textTheme.titleSmall),
                Text(subtitle, style: textTheme.bodySmall),
              ],
            ),
          ],
        ),
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Text('JUSTE APRÈS', style: textTheme.labelSmall),
        const SizedBox(height: 4),
        for (final step in steps)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: CircleAvatar(
              radius: 19,
              backgroundColor: step.accent
                  ? AppColors.orangeTint
                  : AppColors.skyTint,
              child: Icon(
                step.icon,
                size: 18,
                color: step.accent ? AppColors.orangeDeep : AppColors.navy,
              ),
            ),
            title: Text(step.title),
            subtitle: Text(step.subtitle),
          ),
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
