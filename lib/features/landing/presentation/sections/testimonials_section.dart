import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../widgets/landing_motion.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 108),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LandingReveal(child: _ProofIntro()),
              const SizedBox(height: 48),
              LayoutBuilder(
                builder: (context, constraints) {
                  final count = constraints.maxWidth >= 940
                      ? 3
                      : constraints.maxWidth >= 760
                      ? 2
                      : 1;
                  final width =
                      (constraints.maxWidth - (count - 1) * 16) / count;
                  const cards = [
                    _ProofCard(
                      icon: Icons.person_search_outlined,
                      eyebrow: 'CÔTÉ CANDIDAT',
                      title: 'Moins de candidatures à l’aveugle.',
                      text: 'La bêta doit mesurer si le score expliqué aide réellement à choisir avant de postuler.',
                      signal: 'Pertinence perçue',
                    ),
                    _ProofCard(
                      icon: Icons.domain_outlined,
                      eyebrow: 'CÔTÉ RECRUTEUR',
                      title: 'Moins de volume inutile.',
                      text: 'L’objectif est de vérifier si un profil contextualisé vaut mieux qu’une pile de CV non qualifiés.',
                      signal: 'Qualité du signal',
                    ),
                    _ProofCard(
                      icon: Icons.speed_rounded,
                      eyebrow: 'CÔTÉ PRODUIT',
                      title: 'Moins de friction entre intérêt et échange.',
                      text: 'Le parcours doit raccourcir le chemin entre “cette offre me plaît” et une vraie conversation.',
                      signal: 'Temps jusqu’au contact',
                    ),
                  ];
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (var i = 0; i < cards.length; i++)
                        SizedBox(
                          width: width,
                          child: LandingReveal(
                            delay: Duration(milliseconds: i * 90),
                            child: cards[i],
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              LandingReveal(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8FA),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E9EF)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: AppColors.cyanBlue,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pas de faux témoignages ici : les retours utilisateurs réels remplaceront ces objectifs dès que la bêta en produira.',
                          style: TextStyle(
                            color: Color(0xFF60768A),
                            fontSize: 12,
                            height: 1.45,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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

class _ProofIntro extends StatelessWidget {
  const _ProofIntro();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 790),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PREUVES, PAS PROMESSES',
            style: TextStyle(
              color: AppColors.orange,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Ce que la bêta doit prouver.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: mobile ? 38 : 54,
              height: 1.02,
              fontWeight: FontWeight.w900,
              letterSpacing: mobile ? -1 : -1.7,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'JOYN sera crédible quand les usages confirmeront la promesse. Voilà les trois signaux à mesurer en priorité.',
            style: TextStyle(
              color: Color(0xFF6B8094),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofCard extends StatelessWidget {
  const _ProofCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.text,
    required this.signal,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String text;
  final String signal;

  @override
  Widget build(BuildContext context) {
    return LandingHoverLift(
      child: Container(
        constraints: const BoxConstraints(minHeight: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE1E8EE)),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: .06),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6FC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.cyanBlue, size: 21),
            ),
            const SizedBox(height: 20),
            Text(
              eyebrow,
              style: const TextStyle(
                color: AppColors.orange,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 21,
                height: 1.12,
                fontWeight: FontWeight.w900,
                letterSpacing: -.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF6B8094),
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7F9),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                signal,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
