import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/layout/content_container.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/landing/presentation/widgets/landing_motion.dart';

/// Constat national 2026 autour de la recherche d'alternance.
///
/// L'interface garde uniquement les indicateurs utiles au récit produit.
/// Les références utilisées pour valider les chiffres ne sont pas affichées
/// dans la landing afin de conserver une lecture simple et éditoriale.
class ConstatSection extends StatelessWidget {
  const ConstatSection({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.background,
    child: ContentContainer(
      maxWidth: 1240,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 104),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final copy = LandingReveal(
              offset: const Offset(-26, 0),
              child: const _ConstatCopy(),
            );
            final metrics = LandingReveal(
              delay: const Duration(milliseconds: 120),
              offset: const Offset(28, 0),
              child: const _MetricsPanel(),
            );

            if (constraints.maxWidth < 900) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [copy, const SizedBox(height: 44), metrics],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 11, child: copy),
                const SizedBox(width: 64),
                Expanded(flex: 10, child: metrics),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _ConstatCopy extends StatelessWidget {
  const _ConstatCopy();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'LE CONSTAT',
        style: TextStyle(
          color: AppColors.orange,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: .5,
        ),
      ),
      const SizedBox(height: 28),
      Text(
        'Chercher une alternance ne\ndevrait pas être un job à plein temps.',
        style: TextStyle(
          color: AppColors.navy,
          fontSize: MediaQuery.sizeOf(context).width < 600 ? 37 : 50,
          height: 1.08,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
        ),
      ),
      const SizedBox(height: 28),
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 610),
        child: Text(
          'En 2026, la demande reste forte alors que les opportunités se '
          'resserrent et que les budgets employeurs sont plus contraints. '
          'Le marché devient plus sélectif : trouver le bon match, au bon '
          'moment, fait la différence.',
          style: TextStyle(
            color: AppColors.blueGreyDark,
            fontSize: 16,
            height: 1.55,
          ),
        ),
      ),
    ],
  );
}

class _MetricsPanel extends StatelessWidget {
  const _MetricsPanel();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 520;
          final first = const _MetricCard(
            value: '207 000+',
            caption:
                'candidats engagés dans une recherche d’apprentissage post-bac '
                'en France en 2026',
            icon: Icons.groups_2_outlined,
          );
          final second = const _MetricCard(
            value: '44 %',
            caption:
                'des candidats rencontrent des difficultés à trouver une '
                'entreprise d’accueil',
            icon: Icons.near_me_outlined,
            dark: true,
          );
          if (narrow) {
            return Column(
              children: [first, const SizedBox(height: 18), second],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 18),
              Expanded(child: second),
            ],
          );
        },
      ),
    ],
  );
}

class _MetricCard extends StatefulWidget {
  const _MetricCard({
    required this.value,
    required this.caption,
    required this.icon,
    this.dark = false,
  });

  final String value;
  final String caption;
  final IconData icon;
  final bool dark;

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          _hovered && !reduceMotion ? -7 : 0,
          0,
        ),
        constraints: const BoxConstraints(minHeight: 250),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: widget.dark ? AppColors.navy : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.dark
                ? AppColors.white.withValues(alpha: .08)
                : AppColors.navy.withValues(alpha: .06),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: _hovered ? .16 : .10),
              blurRadius: _hovered ? 34 : 24,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: widget.dark
                    ? AppColors.orange.withValues(alpha: .16)
                    : AppColors.cyanBlue.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                color: widget.dark ? AppColors.orangeLight : AppColors.cyanBlue,
              ),
            ),
            const SizedBox(height: 42),
            Text(
              widget.value,
              style: TextStyle(
                color: widget.dark ? AppColors.white : AppColors.navy,
                fontSize: 46,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.6,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.caption,
              style: TextStyle(
                color: widget.dark
                    ? AppColors.white.withValues(alpha: .74)
                    : AppColors.blueGreyDark,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
