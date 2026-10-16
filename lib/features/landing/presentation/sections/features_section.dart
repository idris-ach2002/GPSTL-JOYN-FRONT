import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../widgets/landing_motion.dart';
import '../widgets/landing_product_mockups.dart';

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
      'Pourquoi cette offre te correspond — sans boîte noire.',
      Icons.track_changes_rounded,
    ),
    _FeatureData(
      'Skill Gap',
      'Ce qui te manque pour viser plus haut, rendu visible.',
      Icons.tune_rounded,
    ),
    _FeatureData(
      'Candidature express',
      'Ton CV et ton message partent sans tout ressaisir.',
      Icons.send_rounded,
    ),
    _FeatureData(
      'Suivi clair',
      'Match, réponse, entretien : tout reste au même endroit.',
      Icons.view_list_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF061F34),
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LandingReveal(child: _FeaturesIntro()),
              const SizedBox(height: 52),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 850;
                  final selector = Column(
                    children: [
                      for (var index = 0; index < items.length; index++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
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
                    offset: const Offset(30, 0),
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
                      const SizedBox(width: 44),
                      Expanded(flex: 6, child: preview),
                    ],
                  );
                },
              ),
              const SizedBox(height: 56),
              LayoutBuilder(
                builder: (context, constraints) {
                  final count = constraints.maxWidth >= 980
                      ? 4
                      : constraints.maxWidth >= 760
                      ? 2
                      : 1;
                  final width =
                      (constraints.maxWidth - (count - 1) * 12) / count;
                  const mini = [
                    (
                      'Alertes utiles',
                      'Seulement quand une offre mérite ton attention.',
                      Icons.notifications_none_rounded,
                    ),
                    (
                      'Favoris comparables',
                      'Garde les offres et reviens-y sans perdre le contexte.',
                      Icons.bookmark_border_rounded,
                    ),
                    (
                      'Stats lisibles',
                      'Vues, matchs et réponses — pas un tableau incompréhensible.',
                      Icons.analytics_outlined,
                    ),
                    (
                      'Rythme & trajet',
                      'Élimine les offres incompatibles avant même le swipe.',
                      Icons.route_outlined,
                    ),
                  ];
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (var i = 0; i < mini.length; i++)
                        SizedBox(
                          width: width,
                          child: LandingReveal(
                            delay: Duration(milliseconds: 65 * i),
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

class _FeaturesIntro extends StatelessWidget {
  const _FeaturesIntro();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LE MOTEUR JOYN',
            style: TextStyle(
              color: AppColors.orangeLight,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Simple à utiliser. Pas simpliste.',
            style: TextStyle(
              color: AppColors.white,
              fontSize: mobile ? 38 : 54,
              height: 1.02,
              fontWeight: FontWeight.w900,
              letterSpacing: mobile ? -1 : -1.7,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Clique sur une fonctionnalité : le produit change, pas juste le texte.',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: .60),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
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

class _FeatureSelector extends StatefulWidget {
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
  State<_FeatureSelector> createState() => _FeatureSelectorState();
}

class _FeatureSelectorState extends State<_FeatureSelector> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || hovered;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: active
                ? AppColors.white.withValues(alpha: widget.selected ? .11 : .07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.selected
                  ? AppColors.orange.withValues(alpha: .55)
                  : AppColors.white.withValues(alpha: .08),
            ),
          ),
          child: Row(
            children: [
              Text(
                widget.number,
                style: TextStyle(
                  color: widget.selected
                      ? AppColors.orangeLight
                      : AppColors.white.withValues(alpha: .34),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.orange.withValues(alpha: .15)
                      : AppColors.white.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.data.icon,
                  color: active
                      ? AppColors.orangeLight
                      : AppColors.white.withValues(alpha: .54),
                  size: 19,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data.title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.data.description,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: .48),
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                duration: const Duration(milliseconds: 220),
                turns: widget.selected ? 0 : -.08,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.selected
                      ? AppColors.orangeLight
                      : AppColors.white.withValues(alpha: .24),
                  size: 18,
                ),
              ),
            ],
          ),
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
      constraints: const BoxConstraints(minHeight: 430),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E3857), Color(0xFF09263E)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.white.withValues(alpha: .10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .20),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 360),
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
    return LandingHoverLift(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.white.withValues(alpha: .08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.orangeLight, size: 21),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: .48),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
