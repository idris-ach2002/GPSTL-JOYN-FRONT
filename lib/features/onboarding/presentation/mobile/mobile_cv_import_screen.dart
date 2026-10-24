import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../onboarding_scope.dart';
import '../shared/cv_extracted_content.dart';
import '../shared/cv_upload_card.dart';

/// Import du CV (mobile).
class MobileCvImportScreen extends StatelessWidget {
  const MobileCvImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = OnboardingScope.cvImportOf(context);
    final onboarding = OnboardingScope.onboardingOf(context);
    final textTheme = Theme.of(context).textTheme;
    final extraction = cv.extraction;

    void completePreferences() {
      final extraction = cv.extraction;
      if (extraction == null) return;
      onboarding
        ..applyCv(extraction)
        ..goToStep(2);
      context.go(AppRoutes.candidateOnboarding);
    }

    Future<void> validate() async {
      final extraction = cv.extraction;
      if (extraction == null) return;
      onboarding.applyCv(extraction);
      final saved = await onboarding.finish();
      if (!context.mounted || !saved) return;
      context.go(AppRoutes.dashboard);
    }

    return JoynMaterialScope(
      child: MobileAppSurface(
        backgroundColor: const Color(0xFFF7F8F2),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: "Retour à l'onboarding",
                    onPressed: () => context.go(AppRoutes.candidateOnboarding),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  const MobileBrandMark(compact: true),
                ],
              ),
              const SizedBox(height: 28),
              Semantics(
                header: true,
                child: Text(
                  'Ton CV fait le premier pas.',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Importe ton CV. JOYN pré-remplit ton profil, tu gardes le contrôle sur tout.',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
              ),
              const SizedBox(height: 24),
              CvUploadCard(cv: cv),
              if (cv.isAnalyzing) ...[
                const SizedBox(height: 20),
                Text('On lit ton CV…', style: textTheme.bodySmall),
              ],
              if (cv.hasResult && extraction != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: CvExtractedContent(
                      key: ValueKey(cv.analysisCount),
                      cv: cv,
                      extraction: extraction,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CvImportActions(
                  stacked: true,
                  isValidating: onboarding.isSaving,
                  onCompletePreferences: completePreferences,
                  onValidate: validate,
                ),
              ],
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.candidateOnboarding),
                  child: const Text('Remplir à la main plutôt'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
