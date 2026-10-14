import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../widgets/landing_motion.dart';
import '../widgets/landing_product_mockups.dart';
import '../widgets/section_header.dart';

class FeaturesSection extends StatefulWidget {
  const FeaturesSection({super.key});

  @override
  State<FeaturesSection> createState() => _FeaturesSectionState();
}

class _FeaturesSectionState extends State<FeaturesSection> {
  int selected = 0;

  static const items = [
    _FeatureData(
      'Score détaillé',
      'Chaque offre affiche un score expliqué : compétence, formation, rythme et trajet.',
      Icons.track_changes_rounded,
    ),
    _FeatureData(
      'Skill Gap',
      'Tu vois ce qu’il te manque pour viser plus haut, avec des pistes concrètes de progression.',
      Icons.tune_rounded,
    ),
    _FeatureData(
      'Candidature en un geste',
      'Ton CV et ton message partent sans ressaisie quand une offre t’intéresse.',
      Icons.send_rounded,
    ),
    _FeatureData(
      'Suivi des candidatures',
      'Matchs, réponses et prochaines étapes restent visibles au même endroit.',
      Icons.view_list_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 112),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: SectionHeader(
                  eyebrow: 'Fonctionnalités',
                  title: "Tout ce qu'il faut pour décrocher ta place.",
                  description: 'Le produit reste simple en surface, mais chaque interaction donne du contexte : pourquoi cette offre, quoi améliorer, où en est ta candidature.',
                ),
              ),
              const SizedBox(height: 54),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 850;
                  final selector = Column(
                    children: [
                      for (var index = 0; index < items.length; index++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _FeatureSelector(
                            data: items[index],
                            number: '${index + 1}'.padLeft(2, '0'),
                            selected: index == selected,
                            onTap: () => setState(() => selected = index),
                          ),
                        ),
                    ],
                  );

                  final preview = LandingReveal(
                    delay: const Duration(milliseconds: 100),
                    offset: const Offset(32, 0),
                    child: _FeaturePreview(index: selected),
                  );

                  if (stacked) {
                    return Column(
                      children: [selector, const SizedBox(height: 28), preview],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 5, child: selector),
                      const SizedBox(width: 42),
                      Expanded(flex: 6, child: preview),
                    ],
                  );
                },
              ),
              const SizedBox(height: 58),
              LayoutBuilder(
                builder: (context, constraints) {
                  final count = constraints.maxWidth >= 1000
                      ? 4
                      : constraints.maxWidth >= 600
                      ? 2
                      : 1;
                  final width =
                      (constraints.maxWidth - (count - 1) * 14) / count;
                  const mini = [
                    (
                      'Alertes sur mesure',
                      'Une notification dès qu’une offre dépasse ton seuil de compatibilité.',
                      Icons.notifications_none_rounded,
                    ),
                    (
                      'Favoris',
                      'Garde les offres qui te plaisent et compare-les quand tu veux.',
                      Icons.bookmark_border_rounded,
                    ),
                    (
                      'Tes stats en direct',
                      'Vues, matchs et réponses : ta semaine en un coup d’œil.',
                      Icons.analytics_outlined,
                    ),
                    (
                      'Filtres rythme & trajet',
                      'Ne vois que les offres qui collent à ton rythme d’école et à ton trajet.',
                      Icons.tune_rounded,
                    ),
                  ];
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      for (var i = 0; i < mini.length; i++)
                        SizedBox(
                          width: width,
                          child: LandingReveal(
                            delay: Duration(milliseconds: 70 * i),
                            child: _MiniFeatureCard(
                              title: mini[i].$1,
                              text: mini[i].$2,
                              icon: mini[i].$3,
                            ),
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

class _FeatureData {
  const _FeatureData(this.title, this.description, this.icon);
  final String title;
  final String description;
  final IconData icon;
}

class _FeatureSelector extends StatelessWidget {
  const _FeatureSelector({
    required this.data,
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final _FeatureData data;
  final String number;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE7EDF1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected ? AppColors.navy : const Color(0xFFF0F4F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                data.icon,
                size: 19,
                color: selected ? AppColors.white : AppColors.navy,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(height: 6),
                    Text(
                      data.description,
                      style: const TextStyle(
                        color: Color(0xFF6B8094),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              number,
              style: TextStyle(
                color: selected ? AppColors.orange : const Color(0xFFD8E1E7),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePreview extends StatelessWidget {
  const _FeaturePreview({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 370,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF062A43), Color(0xFF0A5576)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _DotGridPainter()),
            ),
          ),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween(begin: .97, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
              child: switch (index) {
                0 => ConstrainedBox(
                  key: const ValueKey(0),
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: const MatchScoreMockup(),
                ),
                1 => const _SkillGapMockup(key: ValueKey(1)),
                2 => const _ApplyMockup(key: ValueKey(2)),
                _ => const _TrackingMockup(key: ValueKey(3)),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillGapMockup extends StatelessWidget {
  const _SkillGapMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skill Gap',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '3 compétences à renforcer pour passer au-dessus de 95 %.',
            style: TextStyle(color: AppColors.grey, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),
          for (final item in const [
            ('Docker', .62),
            ('CI/CD', .46),
            ('Tests', .78),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 12,
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
                        backgroundColor: const Color(0xFFE8EEF2),
                        color: AppColors.orange,
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

class _ApplyMockup extends StatelessWidget {
  const _ApplyMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                child: Text('N'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Nébula Pay · Flutter Developer',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F6F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Ton CV + ton message sont prêts. Rien à ressaisir.',
              style: TextStyle(color: Color(0xFF647A8F), fontSize: 12),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: null,
            style: FilledButton.styleFrom(
              disabledBackgroundColor: AppColors.orange,
              disabledForegroundColor: Colors.white,
            ),
            icon: const Icon(Icons.send_rounded, size: 17),
            label: const Text('Envoyer ma candidature'),
          ),
        ],
      ),
    );
  }
}

class _TrackingMockup extends StatelessWidget {
  const _TrackingMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suivi des candidatures',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          for (final item in const [
            ('Nébula Pay', 'Entretien jeudi', AppColors.success),
            ('Nova Studio', 'Match réciproque', AppColors.orange),
            ('North Data', 'CV consulté', AppColors.cyanBlue),
          ])
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.$3,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    item.$2,
                    style: const TextStyle(color: AppColors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniFeatureCard extends StatelessWidget {
  const _MiniFeatureCard({
    required this.title,
    required this.text,
    required this.icon,
  });
  final String title;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EBF0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: .07),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6FC),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: AppColors.cyanBlue, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF72879A),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .07);
    for (double x = 8; x < size.width; x += 18) {
      for (double y = 8; y < size.height; y += 18) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
