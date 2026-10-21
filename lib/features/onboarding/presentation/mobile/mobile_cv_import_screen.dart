import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../controllers/cv_import_controller.dart';
import '../onboarding_scope.dart';

class MobileCvImportScreen extends StatelessWidget {
  const MobileCvImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = OnboardingScope.cvImportOf(context);
    final onboarding = OnboardingScope.onboardingOf(context);

    Future<void> continueWithCv() async {
      final extraction = cv.extraction;
      if (extraction == null) return;
      onboarding.applyCv(extraction);
      onboarding.goToStep(2);
      if (context.mounted) context.go(AppRoutes.candidateOnboarding);
    }

    return MobileAppSurface(
      backgroundColor: const Color(0xFFF7F8F2),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () => context.go(AppRoutes.candidateOnboarding),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Spacer(),
                const MobileBrandMark(compact: true),
              ],
            ),
            const SizedBox(height: 34),
            const Text(
              'Ton CV fait le premier pas.',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 31,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Importe ton CV. JOYN pré-remplit ton profil, tu gardes le contrôle sur tout.',
              style: TextStyle(
                color: AppColors.slate,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            AnimatedBuilder(
              animation: cv,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFE1E7E1)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFE9E1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.description_rounded,
                            color: AppColors.orange,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          cv.file?.name ?? 'PDF ou document CV',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Le document est analysé localement dans cette démo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.slate,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        if (cv.isAnalyzing) ...[
                          const SizedBox(height: 18),
                          LinearProgressIndicator(
                            value: cv.progress,
                            backgroundColor: const Color(0xFFE7EBE7),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.orange,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        MobilePrimaryButton(
                          label: cv.hasResult
                              ? 'Choisir un autre CV'
                              : 'Importer mon CV',
                          loading: cv.isAnalyzing,
                          backgroundColor: AppColors.orange,
                          onPressed: cv.pickAndAnalyze,
                        ),
                      ],
                    ),
                  ),
                  if (cv.pickError != null || cv.error != null) ...[
                    const SizedBox(height: 12),
                    _MessageCard(
                      message: cv.pickError ?? cv.error!,
                      error: true,
                    ),
                  ],
                  if (cv.hasResult) ...[
                    const SizedBox(height: 18),
                    _ResultCard(cv: cv),
                    const SizedBox(height: 18),
                    MobilePrimaryButton(
                      label: 'Continuer avec ces informations',
                      onPressed: continueWithCv,
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.candidateOnboarding),
                    child: const Text(
                      'Je préfère remplir mon profil à la main',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.cv});
  final CvImportController cv;
  @override
  Widget build(BuildContext context) {
    final extraction = cv.extraction!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.orangeLight,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Profil détecté',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            extraction.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${extraction.city} · ${extraction.skills.take(3).join(' · ')}',
            style: const TextStyle(
              color: Color(0xFFBDD2E3),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.error});
  final String message;
  final bool error;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: error ? const Color(0xFFFFEEEE) : const Color(0xFFEAF6EF),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      message,
      style: TextStyle(
        color: error ? AppColors.error : AppColors.success,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
