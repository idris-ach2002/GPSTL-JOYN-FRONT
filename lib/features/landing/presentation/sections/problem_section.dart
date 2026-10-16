import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../widgets/landing_motion.dart';

class ProblemSection extends StatelessWidget {
  const ProblemSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF2F6F9),
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 108),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 900;
                  final copy = LandingReveal(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 660),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LE CONSTAT',
                            style: TextStyle(
                              color: AppColors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Chercher ne devrait pas devenir ton deuxième job.',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: constraints.maxWidth < 520 ? 38 : 54,
                              height: 1.02,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.7,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'JOYN part d’un problème simple : trop de volume, trop peu de contexte, et beaucoup trop de candidatures envoyées sans savoir si le poste colle vraiment.',
                            style: TextStyle(
                              color: Color(0xFF6B8094),
                              fontSize: 15,
                              height: 1.52,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  const frictions = Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _FrictionCard(
                        icon: Icons.layers_outlined,
                        title: 'Trop de bruit',
                        text: 'Des dizaines d’offres et de CV, mais peu de signal utile pour décider.',
                        dark: false,
                      ),
                      _FrictionCard(
                        icon: Icons.help_outline_rounded,
                        title: 'Peu de contexte',
                        text: 'Rythme, trajet, attentes et compatibilité arrivent souvent trop tard.',
                        dark: true,
                      ),
                    ],
                  );

                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        copy,
                        const SizedBox(height: 42),
                        const LandingReveal(
                          delay: Duration(milliseconds: 90),
                          child: frictions,
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 6, child: copy),
                      const SizedBox(width: 54),
                      const Expanded(
                        flex: 4,
                        child: LandingReveal(
                          delay: Duration(milliseconds: 100),
                          offset: Offset(34, 0),
                          child: frictions,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 84),
              const LandingReveal(
                child: Text(
                  'AVANT / APRÈS',
                  style: TextStyle(
                    color: AppColors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const LandingReveal(
                child: Text(
                  'Même recherche.\nMoins de friction.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 46,
                    height: 1.04,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.4,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 780;
                  const without = _ComparePanel(
                    label: 'Sans JOYN',
                    dark: false,
                    lines: [
                      'Tu parcours les mêmes annonces que tout le monde.',
                      'Tu adaptes ton CV sans savoir ce qui fera la différence.',
                      'Tu découvres parfois trop tard que le rythme ou le trajet ne colle pas.',
                    ],
                  );
                  const withJoyn = _ComparePanel(
                    label: 'Avec JOYN',
                    dark: true,
                    lines: [
                      'Les opportunités les plus compatibles remontent en premier.',
                      'Le score explique pourquoi le poste colle à ton profil.',
                      'Le contexte utile est visible avant la candidature.',
                    ],
                  );

                  if (stacked) {
                    return const Column(
                      children: [
                        LandingReveal(child: without),
                        SizedBox(height: 16),
                        LandingReveal(
                          delay: Duration(milliseconds: 100),
                          child: withJoyn,
                        ),
                      ],
                    );
                  }

                  return const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: LandingReveal(child: without)),
                      SizedBox(width: 16),
                      Expanded(
                        child: LandingReveal(
                          delay: Duration(milliseconds: 100),
                          child: withJoyn,
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

class _FrictionCard extends StatelessWidget {
  const _FrictionCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.dark,
  });

  final IconData icon;
  final String title;
  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return LandingHoverLift(
      child: Container(
        width: 205,
        constraints: const BoxConstraints(minHeight: 210),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF0F304F) : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: .08),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: dark ? AppColors.orangeLight : AppColors.cyanBlue,
              size: 27,
            ),
            const SizedBox(height: 30),
            Text(
              title,
              style: TextStyle(
                color: dark ? AppColors.white : AppColors.navy,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                color: dark
                    ? AppColors.white.withValues(alpha: .58)
                    : const Color(0xFF71869A),
                fontSize: 11,
                height: 1.42,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparePanel extends StatelessWidget {
  const _ComparePanel({
    required this.label,
    required this.dark,
    required this.lines,
  });

  final String label;
  final bool dark;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? AppColors.white : const Color(0xFF62778C);
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0F304F) : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark
              ? AppColors.cyanBlue.withValues(alpha: .24)
              : const Color(0xFFE2E9EF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: dark
                  ? AppColors.orange.withValues(alpha: .16)
                  : const Color(0xFFF2F6F9),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: dark ? AppColors.orangeLight : AppColors.navy,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 20),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    dark
                        ? Icons.check_circle_rounded
                        : Icons.remove_circle_outline,
                    size: 17,
                    color: dark ? AppColors.success : const Color(0xFF9AA8B4),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      line,
                      style: TextStyle(
                        color: foreground.withValues(alpha: dark ? .72 : .90),
                        fontSize: 12,
                        height: 1.45,
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
