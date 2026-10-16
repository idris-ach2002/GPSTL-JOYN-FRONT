import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../widgets/landing_motion.dart';

class MatchingDemoSection extends StatefulWidget {
  const MatchingDemoSection({super.key});

  @override
  State<MatchingDemoSection> createState() => _MatchingDemoSectionState();
}

class _MatchingDemoSectionState extends State<MatchingDemoSection> {
  int selected = 0;

  static const offers = [
    _DemoOffer(
      company: 'Nébula Pay',
      title: 'Flutter Developer',
      location: 'Paris · hybride',
      score: 94,
      skills: [
        ('Flutter', .98),
        ('Produit', .91),
        ('Rythme', 1.0),
        ('Trajet', .87),
      ],
      gap: 'Docker',
    ),
    _DemoOffer(
      company: 'Nova Studio',
      title: 'Product Designer',
      location: 'Lyon · hybride',
      score: 82,
      skills: [
        ('Produit', .96),
        ('Figma', .84),
        ('Rythme', .78),
        ('Trajet', .70),
      ],
      gap: 'Design systems',
    ),
    _DemoOffer(
      company: 'North Data',
      title: 'Data Analyst',
      location: 'Lille · remote',
      score: 67,
      skills: [('Python', .72), ('SQL', .76), ('Rythme', .92), ('Trajet', 1.0)],
      gap: 'Power BI',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final offer = offers[selected];
    return ColoredBox(
      color: const Color(0xFF061F34),
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LandingReveal(child: _MatchingIntro()),
              const SizedBox(height: 48),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 900;
                  final selector = _OfferSelector(
                    selected: selected,
                    offers: offers,
                    onSelected: (value) => setState(() => selected = value),
                  );
                  final lab = _MatchLab(offer: offer);

                  if (stacked) {
                    return Column(
                      children: [selector, const SizedBox(height: 22), lab],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 330, child: selector),
                      const SizedBox(width: 30),
                      Expanded(child: lab),
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

class _MatchingIntro extends StatelessWidget {
  const _MatchingIntro();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: const Text(
                  'MATCHING LAB · DÉMO ILLUSTRATIVE',
                  style: TextStyle(
                    color: AppColors.orangeLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Change d’offre. Regarde le match bouger.',
            style: TextStyle(
              color: AppColors.white,
              fontSize: mobile ? 38 : 54,
              height: 1.02,
              fontWeight: FontWeight.w900,
              letterSpacing: mobile ? -1.1 : -1.7,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Les scores ci-dessous servent à démontrer l’interface : JOYN explique ce qui rapproche un profil d’une opportunité — et ce qui manque encore.',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: .58),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoOffer {
  const _DemoOffer({
    required this.company,
    required this.title,
    required this.location,
    required this.score,
    required this.skills,
    required this.gap,
  });

  final String company;
  final String title;
  final String location;
  final int score;
  final List<(String, double)> skills;
  final String gap;
}

class _OfferSelector extends StatelessWidget {
  const _OfferSelector({
    required this.selected,
    required this.offers,
    required this.onSelected,
  });

  final int selected;
  final List<_DemoOffer> offers;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < offers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              key: ValueKey('match-offer-$i'),
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: i == selected
                      ? AppColors.white.withValues(alpha: .11)
                      : AppColors.white.withValues(alpha: .045),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: i == selected
                        ? AppColors.orange.withValues(alpha: .62)
                        : AppColors.white.withValues(alpha: .07),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: i == selected
                            ? AppColors.orange
                            : AppColors.white.withValues(alpha: .07),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        offers[i].company.substring(0, 1),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offers[i].title,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            offers[i].company,
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: .46),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${offers[i].score}%',
                      style: TextStyle(
                        color: i == selected
                            ? AppColors.orangeLight
                            : AppColors.white.withValues(alpha: .38),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MatchLab extends StatelessWidget {
  const _MatchLab({required this.offer});

  final _DemoOffer offer;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .22),
            blurRadius: 44,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 620;
          final score = _ScorePanel(offer: offer);
          final detail = _DetailPanel(offer: offer);

          if (stacked) {
            return Column(
              children: [score, const SizedBox(height: 24), detail],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 210, child: score),
              const SizedBox(width: 28),
              Expanded(child: detail),
            ],
          );
        },
      ),
    );
  }
}

class _ScorePanel extends StatelessWidget {
  const _ScorePanel({required this.offer});

  final _DemoOffer offer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          key: ValueKey('score-${offer.score}'),
          tween: Tween(begin: 0, end: offer.score / 100),
          duration: const Duration(milliseconds: 780),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 11,
                  backgroundColor: const Color(0xFFE9EEF2),
                  color: AppColors.orange,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(value * 100).round()}%',
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 34,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'MATCH',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          offer.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          offer.location,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.grey, fontSize: 10),
        ),
      ],
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.offer});

  final _DemoOffer offer;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      child: Column(
        key: ValueKey(offer.title),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pourquoi ce score ?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          for (final item in offer.skills)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 86,
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        color: Color(0xFF667C8F),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: item.$2,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE7EDF2),
                        color: item.$2 >= .9
                            ? AppColors.success
                            : item.$2 >= .75
                            ? AppColors.cyanBlue
                            : AppColors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${(item.$2 * 100).round()}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3ED),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.orange,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Skill Gap : ${offer.gap}',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
