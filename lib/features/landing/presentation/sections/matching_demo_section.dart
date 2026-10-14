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
  bool analyzed = false;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFF7446),
      child: ContentContainer(
        maxWidth: 1160,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 104),
          child: Column(
            children: [
              const LandingReveal(
                child: Column(
                  children: [
                    Text(
                      'TESTE LE MATCHING',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Un score utile doit être explicable.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 48,
                        height: 1.02,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Clique sur “Analyser” : JOYN compare le profil et l’offre, puis détaille ce qui fait réellement le match.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 780;
                  final profile = const _InputCard(
                    icon: Icons.person_outline_rounded,
                    title: 'Ton profil',
                    chips: ['Flutter · Dart', 'Bac +5', 'Paris', 'Alternance'],
                  );
                  final offer = const _InputCard(
                    icon: Icons.work_outline_rounded,
                    title: 'L’offre',
                    chips: [
                      'Flutter Developer',
                      'Paris',
                      'Alternance',
                      'Équipe produit',
                    ],
                  );

                  if (stacked) {
                    return Column(
                      children: [
                        LandingReveal(child: profile),
                        const SizedBox(height: 16),
                        LandingReveal(
                          delay: const Duration(milliseconds: 80),
                          child: offer,
                        ),
                        const SizedBox(height: 20),
                        _AnalyzePanel(
                          analyzed: analyzed,
                          onTap: () => setState(() => analyzed = true),
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: LandingReveal(child: profile)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: LandingReveal(
                          delay: const Duration(milliseconds: 80),
                          child: offer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 250,
                        child: _AnalyzePanel(
                          analyzed: analyzed,
                          onTap: () => setState(() => analyzed = true),
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

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.icon,
    required this.title,
    required this.chips,
  });
  final IconData icon;
  final String title;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.navy, size: 21),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final chip in chips)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7FA),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    chip,
                    style: const TextStyle(
                      color: Color(0xFF5F7589),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyzePanel extends StatelessWidget {
  const _AnalyzePanel({required this.analyzed, required this.onTap});
  final bool analyzed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LandingReveal(
      delay: const Duration(milliseconds: 160),
      offset: const Offset(24, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: analyzed ? const Color(0xFF0F304F) : AppColors.navy,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: .18),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 360),
          child: analyzed
              ? Column(
                  key: const ValueKey('result'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: .92),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => SizedBox(
                        width: 92,
                        height: 92,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: value,
                              strokeWidth: 8,
                              backgroundColor: Colors.white12,
                              color: AppColors.orangeLight,
                            ),
                            Center(
                              child: Text(
                                '${(value * 100).round()}%',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Très compatible',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Formation 100% · Rythme 100% · Trajet 90%',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: .62),
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ],
                )
              : Column(
                  key: const ValueKey('button'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.orangeLight,
                      size: 34,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Prêt à comparer ?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Analyser'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
