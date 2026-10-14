import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../widgets/landing_motion.dart';
import '../widgets/landing_product_mockups.dart';

class CompaniesSection extends StatelessWidget {
  const CompaniesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF061F34),
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 112),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 900;
              final copy = LandingReveal(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cyanBlue.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Text(
                        'POUR LES ENTREPRISES',
                        style: TextStyle(
                          color: Color(0xFFA8DDF2),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Moins de CV à trier.\nPlus de candidats motivés.',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: constraints.maxWidth < 520 ? 38 : 52,
                        height: 1.02,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.7,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _Benefit(
                      text: 'Des profils triés par compatibilité avec votre poste, votre rythme et votre localisation.',
                    ),
                    const SizedBox(height: 14),
                    const _Benefit(
                      text: 'Vos alternants en fin de contrat peuvent signaler leur poste avant sa publication avec Remplace-moi.',
                    ),
                    const SizedBox(height: 14),
                    const _Benefit(
                      text: 'Vous écrivez le premier message : seuls les candidats retenus entrent dans la conversation.',
                    ),
                    const SizedBox(height: 30),
                    FilledButton.icon(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text(
                        'Créer un compte recruteur',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              );

              final visual = LandingReveal(
                delay: const Duration(milliseconds: 140),
                offset: const Offset(40, 0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CandidateListMockup(),
                    Positioned(
                      right: -12,
                      top: -18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .16),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.orange,
                              size: 15,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Trié par compatibilité',
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [copy, const SizedBox(height: 52), visual],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 6, child: copy),
                  const SizedBox(width: 72),
                  Expanded(flex: 5, child: visual),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.orange,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.white,
            size: 17,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: .72),
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
