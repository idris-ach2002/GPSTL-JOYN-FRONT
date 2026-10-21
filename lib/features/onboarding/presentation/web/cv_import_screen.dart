import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/components/joyn_text_link.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_fonts.dart';
import 'package:joyn_front/features/onboarding/presentation/onboarding_scope.dart';
import 'package:joyn_front/features/onboarding/presentation/widgets/cv_upload_panel.dart';
import 'package:joyn_front/features/onboarding/presentation/widgets/extracted_info_panel.dart';
import 'package:joyn_front/features/onboarding/presentation/widgets/onboarding_top_bar.dart';

/// Écran 04 — Importe ton CV, on s'occupe du reste.
class CvImportScreen extends StatelessWidget {
  const CvImportScreen({super.key});

  /// Largeur à partir de laquelle les deux colonnes sont côte à côte.
  static const double _twoColumnsBreakpoint = 960;

  @override
  Widget build(BuildContext context) {
    final cv = OnboardingScope.cvImportOf(context);
    final onboarding = OnboardingScope.onboardingOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 640;
    final twoColumns = width >= _twoColumnsBreakpoint;
    final titleSize = (width * 0.034).clamp(28.0, 40.0).toDouble();

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
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Profil enregistré. La découverte des offres arrive bientôt.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    final upload = CvUploadPanel(cv: cv);
    final info = ExtractedInfoPanel(
      cv: cv,
      compact: compact,
      isValidating: onboarding.isSaving,
      onCompletePreferences: completePreferences,
      onValidate: validate,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingTopBar(
              maxWidth: 1200,
              trailing: JoynTextLink(
                label: 'Remplir à la main plutôt',
                color: AppColors.slate,
                onTap: () => context.go(AppRoutes.candidateOnboarding),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: compact
                          ? const EdgeInsets.fromLTRB(16, 24, 16, 40)
                          : const EdgeInsets.fromLTRB(24, 40, 24, 64),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  header: true,
                                  child: Text(
                                    "Importe ton CV, on s'occupe du reste.",
                                    style: TextStyle(
                                      fontFamily: AppFonts.display,
                                      fontSize: titleSize,
                                      height: 1.08,
                                      letterSpacing: -titleSize * 0.03,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Vérifie ce qu'on a extrait, corrige si besoin : ton profil sera prêt en un clic.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: AppColors.slate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (twoColumns)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: upload),
                                const SizedBox(width: 24),
                                Expanded(flex: 2, child: info),
                              ],
                            )
                          else ...[
                            upload,
                            const SizedBox(height: 24),
                            info,
                          ],
                        ],
                      ),
                    ),
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
