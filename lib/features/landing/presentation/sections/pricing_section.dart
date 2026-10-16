import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../widgets/landing_motion.dart';

class PricingSection extends StatefulWidget {
  const PricingSection({super.key});

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> {
  bool recruiter = false;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF2F6F9),
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 110),
          child: Column(
            children: [
              const LandingReveal(
                child: Column(
                  children: [
                    Text(
                      'TARIFS · HYPOTHÈSES PRODUIT',
                      style: TextStyle(
                        color: Color(0xFF4F6680),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.35,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Une grille simple à tester en bêta.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 48,
                        height: 1.02,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Ces montants illustrent une proposition de pricing à valider avant lancement. Ils ne constituent pas une offre commerciale publiée.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF72879A),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              LandingReveal(
                delay: const Duration(milliseconds: 80),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Segment(
                        label: 'Étudiants',
                        icon: Icons.school_outlined,
                        selected: !recruiter,
                        onTap: () => setState(() => recruiter = false),
                      ),
                      _Segment(
                        label: 'Recruteur',
                        icon: Icons.apartment_rounded,
                        selected: recruiter,
                        onTap: () => setState(() => recruiter = true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 52),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 380),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, .03),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: recruiter
                    ? const _RecruiterPricing(key: ValueKey('recruiter'))
                    : const _StudentPricing(key: ValueKey('student')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('pricing-segment-$label'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.white : const Color(0xFF71869B),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.white : const Color(0xFF71869B),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentPricing extends StatelessWidget {
  const _StudentPricing({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 850;
        const cards = [
          _PriceCard(
            name: 'joyn',
            subtitle: 'Tout l’essentiel pour décrocher ton alternance.',
            price: '0 €',
            period: 'Base gratuite',
            description: 'Hypothèse de lancement à valider en bêta.',
            features: [
              '10 × Intéressé par jour',
              'Score de compatibilité expliqué',
              'Skill Gap et formations conseillées',
              'Messagerie dès le match',
              'Suivi de tes candidatures',
              'Offres Remplace-moi',
            ],
            cta: 'Créer mon profil gratuit',
          ),
          _PriceCard(
            name: 'joyn+',
            subtitle: 'Plus de « Intéressé », plus de visibilité, plus vite en entretien.',
            price: '15,99 €',
            period: '/ Mois',
            description: 'Hypothèse d’abonnement premium.',
            features: [
              '« Intéressé » illimités',
              'Profil mis en avant chaque semaine',
              'Voir quelles entreprises ont consulté ton profil',
            ],
            cta: 'Essayer JOYN+ 7 jours',
            highlighted: true,
            badge: '7 jours offerts',
          ),
          _PriceCard(
            name: 'Boost 48 h',
            subtitle: 'Ton profil en tête des recommandations recruteurs pendant 48 h.',
            price: '4,99 €',
            period: 'Pour 48h.',
            description: 'Hypothèse d’achat ponctuel.',
            features: [
              'Profil remonté en tête',
              'Priorité temporaire côté recruteur',
              'Idéal avant une période de candidatures',
            ],
            cta: 'Booster mon profil',
          ),
        ];

        if (stacked) {
          return Column(
            children: [
              LandingReveal(child: cards[0]),
              SizedBox(height: 18),
              LandingReveal(delay: Duration(milliseconds: 90), child: cards[1]),
              SizedBox(height: 18),
              LandingReveal(
                delay: Duration(milliseconds: 180),
                child: cards[2],
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: LandingReveal(child: cards[0])),
            SizedBox(width: 18),
            Expanded(
              child: LandingReveal(
                delay: Duration(milliseconds: 90),
                child: cards[1],
              ),
            ),
            SizedBox(width: 18),
            Expanded(
              child: LandingReveal(
                delay: Duration(milliseconds: 180),
                child: cards[2],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecruiterPricing extends StatelessWidget {
  const _RecruiterPricing({super.key});

  @override
  Widget build(BuildContext context) {
    return LandingReveal(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE1E9EF)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 720;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recrutement à l’annonce',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.7,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pas d’abonnement à empiler. Publiez quand vous recrutez, puis laissez JOYN faire remonter les profils compatibles.',
                  style: TextStyle(
                    color: Color(0xFF6B8094),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _RecruiterChip(label: 'Matching expliqué'),
                    _RecruiterChip(label: 'Profils compatibles'),
                    _RecruiterChip(label: 'Messagerie contextualisée'),
                    _RecruiterChip(label: 'Remplace-moi'),
                  ],
                ),
              ],
            );
            final action = Column(
              crossAxisAlignment: stacked
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                const Text(
                  'Sans abonnement',
                  style: TextStyle(
                    color: AppColors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .9,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'À l’annonce',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Parler à JOYN'),
                ),
              ],
            );
            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [copy, const SizedBox(height: 30), action],
              );
            }
            return Row(
              children: [
                Expanded(child: copy),
                const SizedBox(width: 50),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecruiterChip extends StatelessWidget {
  const _RecruiterChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6F9),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF62778C),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PriceCard extends StatefulWidget {
  const _PriceCard({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
    required this.cta,
    this.highlighted = false,
    this.badge,
  });

  final String name;
  final String subtitle;
  final String price;
  final String period;
  final String description;
  final List<String> features;
  final String cta;
  final bool highlighted;
  final String? badge;

  @override
  State<_PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<_PriceCard> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) {
    final dark = widget.highlighted;
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 190),
        scale: hovered ? 1.015 : 1,
        child: Container(
          constraints: const BoxConstraints(minHeight: 490),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF0F304F) : AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: dark ? AppColors.cyanBlue : const Color(0xFFE3EAF0),
            ),
            boxShadow: dark
                ? [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: .25),
                      blurRadius: 44,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: .05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        color: dark ? AppColors.white : AppColors.navy,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (widget.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        widget.badge!,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.subtitle,
                style: TextStyle(
                  color: dark
                      ? AppColors.white.withValues(alpha: .7)
                      : const Color(0xFF72879A),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 8,
                children: [
                  Text(
                    widget.price,
                    style: TextStyle(
                      color: dark ? AppColors.white : AppColors.navy,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      widget.period,
                      style: TextStyle(
                        color: dark
                            ? AppColors.white.withValues(alpha: .7)
                            : const Color(0xFF72879A),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                widget.description,
                style: TextStyle(
                  color: dark
                      ? AppColors.white.withValues(alpha: .62)
                      : const Color(0xFF72879A),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 18),
              Divider(color: dark ? Colors.white12 : const Color(0xFFE8EEF2)),
              const SizedBox(height: 12),
              for (final feature in widget.features)
                Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: dark
                              ? AppColors.orange
                              : const Color(0xFFD9EEF8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: dark ? AppColors.white : AppColors.cyanBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            color: dark
                                ? AppColors.white.withValues(alpha: .78)
                                : const Color(0xFF6B8094),
                            fontSize: 10,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: dark ? AppColors.orange : AppColors.navy,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    widget.cta,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
