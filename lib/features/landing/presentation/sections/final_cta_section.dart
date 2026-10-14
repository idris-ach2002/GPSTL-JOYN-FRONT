import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../widgets/landing_motion.dart';

class FinalCtaSection extends StatelessWidget {
  const FinalCtaSection({
    required this.onCandidate,
    required this.onCompany,
    super.key,
  });

  final VoidCallback onCandidate;
  final VoidCallback onCompany;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 96),
          child: LandingReveal(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 72),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF061F34), Color(0xFF0C4C70)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -80,
                    top: -110,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.blue.withValues(alpha: .13),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const Text(
                        'Ton prochain match\ncommence peut-être ici.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 48,
                          height: 1.03,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Un profil clair. Des opportunités expliquées. Une conversation quand l’intérêt est réciproque.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: .68),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: onCandidate,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.orange,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                            ),
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Trouver mon opportunité',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: onCompany,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.white,
                              side: BorderSide(
                                color: AppColors.white.withValues(alpha: .24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Je recrute',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
