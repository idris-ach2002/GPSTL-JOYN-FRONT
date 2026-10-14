import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../widgets/landing_motion.dart';
import '../widgets/landing_product_mockups.dart';
import '../widgets/section_header.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: SectionHeader(
                      eyebrow: 'Comment ça marche',
                      title: 'Du profil au premier entretien, en trois gestes.',
                      description: 'Un parcours court, visuel et réciproque : tu comprends l’offre avant d’envoyer ton CV et la conversation démarre seulement quand les deux côtés sont intéressés.',
                    ),
                  ),
                  if (MediaQuery.sizeOf(context).width >= 880) ...[
                    const SizedBox(width: 24),
                    LandingReveal(
                      delay: const Duration(milliseconds: 160),
                      offset: const Offset(24, 0),
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 17,
                          ),
                        ),
                        child: const Text(
                          'Créer mon profil',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 58),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 820;
                  const cards = [
                    _StepCard(
                      number: '1',
                      title: 'Glisse ton CV',
                      description: 'Formation, compétences et expériences sont extraites automatiquement. Tu ajustes tes informations librement.',
                      visual: MiniCvMockup(),
                    ),
                    _StepCard(
                      number: '2',
                      title: 'Swipe tes offres',
                      description: 'Chaque offre arrive avec son score de compatibilité expliqué. Un “Intéressé” envoie ton message et ton CV automatiquement.',
                      visual: _MiniSwipeMockup(),
                    ),
                    _StepCard(
                      number: '3',
                      title: 'Matche et discute',
                      description: 'Dès que l’entreprise te répond, le chat s’ouvre. Tu échanges avec le recruteur et tu suis tout jusqu’à la signature.',
                      visual: _MiniChatMockup(),
                    ),
                  ];

                  if (stacked) {
                    return Column(
                      children: [
                        LandingReveal(child: cards[0]),
                        SizedBox(height: 18),
                        LandingReveal(
                          delay: Duration(milliseconds: 100),
                          child: cards[1],
                        ),
                        SizedBox(height: 18),
                        LandingReveal(
                          delay: Duration(milliseconds: 200),
                          child: cards[2],
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: LandingReveal(child: cards[0])),
                      SizedBox(width: 18),
                      Expanded(
                        child: LandingReveal(
                          delay: Duration(milliseconds: 100),
                          child: cards[1],
                        ),
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: LandingReveal(
                          delay: Duration(milliseconds: 200),
                          child: cards[2],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatefulWidget {
  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.visual,
  });

  final String number;
  final String title;
  final String description;
  final Widget visual;

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 190),
        scale: hovered ? 1.012 : 1,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE3EBF1)),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: hovered ? .13 : .08),
                blurRadius: hovered ? 36 : 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEAF6FC), Color(0xFFF8FCFE)],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(child: widget.visual),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: .65),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.number,
                          style: const TextStyle(
                            color: Color(0xFFCAE0EC),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        color: Color(0xFF6B8094),
                        fontSize: 13,
                        height: 1.48,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniSwipeMockup extends StatelessWidget {
  const _MiniSwipeMockup();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 98,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -.10,
            child: Container(
              width: 125,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFDDECF4),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Container(
            width: 132,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: .1),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.navy,
                      child: Text(
                        'N',
                        style: TextStyle(color: Colors.white, fontSize: 7),
                      ),
                    ),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Nxt pay',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '94%',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Dév. Full-Stack',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 4,
            right: 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 11,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChatMockup extends StatelessWidget {
  const _MiniChatMockup();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text(
              'Ton profil nous plaît ! Dispo jeudi ?',
              style: TextStyle(color: AppColors.navy, fontSize: 9),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text(
              'Avec plaisir, à jeudi !',
              style: TextStyle(color: AppColors.white, fontSize: 9),
            ),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFDFF5E5),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Text(
                '🔓 Chat débloqué',
                style: TextStyle(
                  color: Color(0xFF3B8E54),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
