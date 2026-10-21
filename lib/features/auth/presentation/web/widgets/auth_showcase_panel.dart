import 'package:flutter/material.dart';

import 'package:joyn_front/core/theme/app_colors.dart';
import 'package:joyn_front/core/theme/app_dimens.dart';

/// Panneau bleu nuit illustré, affiché à droite du formulaire sur grand écran.
///
/// Contenu purement décoratif (profils fictifs) qui présente le principe du
/// « match des deux côtés ».
class AuthShowcasePanel extends StatelessWidget {
  const AuthShowcasePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);

    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.navy, borderRadius: radius),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          painter: const _GridPainter(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LE MATCH SE FAIT\nDES DEUX CÔTÉS.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Text(
                    'Étudiants et recruteurs se connectent au même endroit. '
                    'Chacun retrouve ensuite son espace : offres et '
                    'candidatures d’un côté, candidats et pipeline de l’autre.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                // L'illustration rétrécit si la fenêtre manque de place.
                const Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _MatchIllustration(),
                    ),
                  ),
                ),
                Text(
                  'Joyn a job, with joy.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Deux cartes de profil (étudiante / entreprise) reliées par le logo du match.
class _MatchIllustration extends StatelessWidget {
  const _MatchIllustration();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 470,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                top: 24,
                child: Transform.rotate(
                  angle: -0.06,
                  child: _ProfileCard(
                    badge: 'Étudiante',
                    badgeColor: AppColors.skySoft,
                    badgeTextColor: AppColors.navy,
                    avatar: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5BA4D9),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        'YK',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    name: 'Yasmine K.',
                    subtitle: 'M1 Informatique',
                    tags: const ['React', 'Node.js'],
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 8,
                child: Transform.rotate(
                  angle: 0.06,
                  child: _ProfileCard(
                    badge: 'Entreprise',
                    badgeColor: AppColors.coralSoft,
                    badgeTextColor: AppColors.coral,
                    avatar: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF15181D),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'N',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    name: 'Nébula Pay',
                    subtitle: 'Fintech · Paris 9e',
                    tags: const ['Full-Stack', '3 sem / 1 sem'],
                  ),
                ),
              ),
              const _MatchRings(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            const _Pill(
              label: '92 % compatible',
              background: AppColors.coral,
              foreground: Colors.white,
            ),
            _Pill(
              label: '✦  C’est un match, des deux côtés',
              background: Colors.white.withValues(alpha: 0.08),
              foreground: Colors.white,
              border: Colors.white.withValues(alpha: 0.25),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.avatar,
    required this.name,
    required this.subtitle,
    required this.tags,
  });

  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final Widget avatar;
  final String name;
  final String subtitle;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Tag(
            label: badge,
            background: badgeColor,
            foreground: badgeTextColor,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              avatar,
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in tags)
                _Tag(
                  label: tag,
                  background: AppColors.skySoft,
                  foreground: AppColors.navy,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
    this.border,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: border == null ? null : Border.all(color: border!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Pastille blanche centrale avec deux anneaux entrelacés (bleu + corail).
class _MatchRings extends StatelessWidget {
  const _MatchRings();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: 42,
          height: 28,
          child: CustomPaint(painter: _RingsPainter()),
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  const _RingsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height / 2 - 2;
    final center = size.center(Offset.zero);
    Paint ring(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawCircle(
      center.translate(-radius * 0.55, 0),
      radius,
      ring(AppColors.navy),
    );
    canvas.drawCircle(
      center.translate(radius * 0.55, 0),
      radius,
      ring(AppColors.coral),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Quadrillage discret en fond du panneau.
class _GridPainter extends CustomPainter {
  const _GridPainter();

  static const double _step = 36;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double x = _step; x < size.width; x += _step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = _step; y < size.height; y += _step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
