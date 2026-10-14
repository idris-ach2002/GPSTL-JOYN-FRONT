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
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LE CONSTAT',
                            style: TextStyle(
                              color: AppColors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chercher une alternance ne devrait pas être un job à plein temps.',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: constraints.maxWidth < 520 ? 38 : 54,
                              height: 1.02,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.8,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Candidatures sans réponse, peu de réseau au départ, offres qui ne collent pas au rythme de l’école. JOYN remet la compatibilité et la réciprocité au centre.',
                            style: TextStyle(
                              color: Color(0xFF6B8094),
                              fontSize: 16,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  final stats = Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: const [
                      _StatCard(
                        icon: Icons.groups_2_outlined,
                        value: '320 000',
                        label: "étudiants encore en recherche d'alternance",
                        dark: false,
                      ),
                      _StatCard(
                        icon: Icons.schedule_rounded,
                        value: '2 sur 3',
                        label:
                            'étudiants de M2 fins sans alternance à la rentrée',
                        dark: true,
                      ),
                    ],
                  );

                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        copy,
                        const SizedBox(height: 46),
                        LandingReveal(
                          delay: const Duration(milliseconds: 110),
                          child: stats,
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 6, child: copy),
                      const SizedBox(width: 56),
                      Expanded(
                        flex: 4,
                        child: LandingReveal(
                          delay: const Duration(milliseconds: 120),
                          offset: const Offset(34, 0),
                          child: stats,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 86),
              const LandingReveal(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVANT  /  APRÈS',
                      style: TextStyle(
                        color: AppColors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'La même recherche,\nsans la galère.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 46,
                        height: 1.04,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 780;
                  const without = _ComparePanel(
                    label: 'Sans JOYN',
                    dark: false,
                    lines: [
                      'Tu envoies le même CV à des dizaines d’offres.',
                      'Tu relances des entreprises qui ne répondent jamais.',
                      'Tu découvres en entretien que le rythme ne colle pas.',
                      'Tu cherches seul·e, sans réseau pour te recommander.',
                    ],
                  );
                  const withJoyn = _ComparePanel(
                    label: 'Avec JOYN',
                    dark: true,
                    lines: [
                      'Seulement des offres compatibles, avec un score expliqué.',
                      'Ton CV part en un geste, le chat s’ouvre dès que l’entreprise répond.',
                      'Rythme, trajet et formation vérifiés avant même de candidater.',
                    ],
                  );

                  if (stacked) {
                    return Column(
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

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: LandingReveal(child: without)),
                      SizedBox(width: 16),
                      Expanded(
                        child: LandingReveal(
                          delay: Duration(milliseconds: 110),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.dark,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      constraints: const BoxConstraints(minHeight: 230),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0F304F) : AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: .09),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: dark ? AppColors.orangeLight : AppColors.cyanBlue,
            size: 28,
          ),
          const SizedBox(height: 34),
          Text(
            value,
            style: TextStyle(
              color: dark ? AppColors.white : AppColors.navy,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: dark
                  ? AppColors.white.withValues(alpha: .66)
                  : const Color(0xFF72879A),
              fontSize: 10,
              height: 1.35,
            ),
          ),
        ],
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
        color: dark ? const Color(0xFF0F304F) : const Color(0xFFE7EFF5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: dark ? AppColors.orange : AppColors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 20),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dark
                          ? AppColors.orange
                          : AppColors.white.withValues(alpha: .92),
                    ),
                    child: Icon(
                      dark ? Icons.check_rounded : Icons.close_rounded,
                      size: 13,
                      color: dark ? AppColors.white : AppColors.grey,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      line,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: dark ? FontWeight.w600 : FontWeight.w500,
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
