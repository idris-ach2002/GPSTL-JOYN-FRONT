import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../widgets/landing_motion.dart';
import '../widgets/landing_product_mockups.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  static const _steps = [
    _StoryStepData(
      number: '01',
      title: 'Ton profil entre.',
      description: 'CV, formation, rythme et compétences deviennent un profil clair que tu peux corriger à tout moment.',
      icon: Icons.file_upload_outlined,
    ),
    _StoryStepData(
      number: '02',
      title: 'JOYN trie le bruit.',
      description: 'Les offres remontent avec un score expliqué. Tu vois tout de suite ce qui colle — et ce qui manque.',
      icon: Icons.auto_awesome_rounded,
    ),
    _StoryStepData(
      number: '03',
      title: 'Le match ouvre la discussion.',
      description: 'Quand l’intérêt est réciproque, la conversation démarre. Plus de candidature envoyée dans le vide.',
      icon: Icons.forum_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF061F34),
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 96),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 820;
              if (mobile) {
                return const _MobileStory(steps: _steps);
              }
              return const _DesktopStory(steps: _steps);
            },
          ),
        ),
      ),
    );
  }
}

class _DesktopStory extends StatelessWidget {
  const _DesktopStory({required this.steps});

  final List<_StoryStepData> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LandingReveal(child: _DarkSectionIntro()),
        const SizedBox(height: 36),
        LandingScrollScene(
          height: 1500,
          topInset: 106,
          builder: (context, progress, pinOffset, viewportHeight) {
            final selected = progress < .33
                ? 0
                : progress < .67
                ? 1
                : 2;
            final stageHeight = (viewportHeight * .76)
                .clamp(560.0, 690.0)
                .toDouble();
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  top: pinOffset,
                  left: 0,
                  right: 0,
                  height: stageHeight,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: _StorySelector(steps: steps, selected: selected),
                      ),
                      const SizedBox(width: 54),
                      Expanded(
                        flex: 6,
                        child: _StoryVisual(selected: selected),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MobileStory extends StatelessWidget {
  const _MobileStory({required this.steps});

  final List<_StoryStepData> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DarkSectionIntro(),
        const SizedBox(height: 42),
        for (var i = 0; i < steps.length; i++) ...[
          LandingReveal(
            delay: Duration(milliseconds: i * 80),
            child: _MobileStepCard(data: steps[i], index: i),
          ),
          if (i != steps.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _DarkSectionIntro extends StatelessWidget {
  const _DarkSectionIntro();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMMENT ÇA MARCHE',
            style: TextStyle(
              color: AppColors.orangeLight,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Trois gestes. Pas trois formulaires.',
            style: TextStyle(
              color: AppColors.white,
              fontSize: mobile ? 38 : 56,
              height: 1.02,
              fontWeight: FontWeight.w900,
              letterSpacing: mobile ? -1.1 : -1.9,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Le même écran se transforme à mesure que tu avances : profil, recommandation, match.',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: .62),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryStepData {
  const _StoryStepData({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String number;
  final String title;
  final String description;
  final IconData icon;
}

class _StorySelector extends StatelessWidget {
  const _StorySelector({required this.steps, required this.selected});

  final List<_StoryStepData> steps;
  final int selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < steps.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: i == selected
                  ? AppColors.white.withValues(alpha: .11)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: i == selected
                    ? AppColors.orange.withValues(alpha: .55)
                    : AppColors.white.withValues(alpha: .08),
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: i == selected
                        ? AppColors.orange
                        : AppColors.white.withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(steps[i].icon, color: AppColors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${steps[i].number} · ${steps[i].title}',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: i == selected
                              ? FontWeight.w900
                              : FontWeight.w700,
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        child: i == selected
                            ? Padding(
                                padding: const EdgeInsets.only(top: 7),
                                child: Text(
                                  steps[i].description,
                                  style: TextStyle(
                                    color: AppColors.white.withValues(
                                      alpha: .58,
                                    ),
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StoryVisual extends StatelessWidget {
  const _StoryVisual({required this.selected});

  final int selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2F4B),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.white.withValues(alpha: .10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .22),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'JOYN · PARCOURS EN DIRECT',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: .48),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '${((selected + 1) / 3 * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.orangeLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: (selected + 1) / 3,
              minHeight: 5,
              backgroundColor: Colors.white10,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween(begin: .97, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
              child: switch (selected) {
                0 => const _ProfileStoryMockup(key: ValueKey('profile')),
                1 => const _RecommendationStoryMockup(key: ValueKey('feed')),
                _ => const _ConversationStoryMockup(key: ValueKey('chat')),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStoryMockup extends StatelessWidget {
  const _ProfileStoryMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MiniCvMockup(),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: const [
                _StoryChip('Flutter'),
                _StoryChip('Bac +5'),
                _StoryChip('3 sem. / 1 sem.'),
                _StoryChip('Paris'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationStoryMockup extends StatelessWidget {
  const _RecommendationStoryMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.navy,
                    foregroundColor: AppColors.white,
                    child: Text('N'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Flutter Developer',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '94%',
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              for (final item in const [
                ('Compétences', .96),
                ('Rythme', 1.0),
                ('Trajet', .88),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 86,
                        child: Text(
                          item.$1,
                          style: const TextStyle(
                            color: Color(0xFF6F8496),
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
                            minHeight: 7,
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
        ),
      ),
    );
  }
}

class _ConversationStoryMockup extends StatelessWidget {
  const _ConversationStoryMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _ChatBubble(
                text: 'Ton profil nous plaît. Tu es dispo jeudi ?',
                mine: false,
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: _ChatBubble(text: 'Oui, avec plaisir 👋', mine: true),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: const Text(
                  'MATCH RÉCIPROQUE · CHAT OUVERT',
                  style: TextStyle(
                    color: AppColors.orangeLight,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.mine});

  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 310),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: mine ? AppColors.orange : AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: mine ? AppColors.white : AppColors.navy,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StoryChip extends StatelessWidget {
  const _StoryChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.white.withValues(alpha: .08)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.white.withValues(alpha: .72),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MobileStepCard extends StatelessWidget {
  const _MobileStepCard({required this.data, required this.index});

  final _StoryStepData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.white.withValues(alpha: .09)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(data.icon, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                data.number,
                style: const TextStyle(
                  color: AppColors.orangeLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            data.title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -.6,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            data.description,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: .60),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Center(
              child: switch (index) {
                0 => const MiniCvMockup(),
                1 => const _RecommendationStoryMockup(),
                _ => const _ConversationStoryMockup(),
              },
            ),
          ),
        ],
      ),
    );
  }
}
