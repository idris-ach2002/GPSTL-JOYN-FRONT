import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/material/joyn_chip_group.dart';
import 'package:joyn_front/design_system/theme/joyn_material_theme.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/onboarding/presentation/controllers/cv_import_controller.dart';
import 'package:joyn_front/features/onboarding/presentation/onboarding_scope.dart';
import 'package:joyn_front/features/onboarding/presentation/shared/cv_extracted_content.dart';
import 'package:joyn_front/features/onboarding/presentation/shared/cv_upload_card.dart';
import 'package:joyn_front/features/onboarding/presentation/web/widgets/onboarding_top_bar.dart';

/// Écran 04 — Importe ton CV, on s'occupe du reste (web).
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

    final upload = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CvUploadCard(cv: cv),
        const SizedBox(height: 14),
        const _PrivacyCard(),
      ],
    );
    final info = _ExtractedInfoCard(
      cv: cv,
      compact: compact,
      actions: CvImportActions(
        isValidating: onboarding.isSaving,
        stacked: compact,
        onCompletePreferences: completePreferences,
        onValidate: validate,
      ),
    );

    return JoynMaterialScope(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              OnboardingTopBar(
                maxWidth: 1200,
                trailing: TextButton(
                  onPressed: () => context.go(AppRoutes.candidateOnboarding),
                  child: const Text('Remplir à la main plutôt'),
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
                            const _Heading(),
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
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleSize = (MediaQuery.sizeOf(context).width * 0.034)
        .clamp(28.0, 40.0)
        .toDouble();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              "Importe ton CV, on s'occupe du reste.",
              style: textTheme.displaySmall?.copyWith(
                fontSize: titleSize,
                letterSpacing: -titleSize * 0.03,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Vérifie ce qu'on a extrait, corrige si besoin : ton profil sera prêt en un clic.",
            style: textTheme.bodyLarge?.copyWith(color: AppColors.slate),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: AppColors.textPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.lock_outline_rounded, color: AppColors.white),
        title: Text(
          "Ce qu'on en fait",
          style: textTheme.titleSmall?.copyWith(color: AppColors.white),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            "Ton CV sert à pré-remplir ton profil et calculer tes scores. Il n'est transmis à une entreprise que si tu le décides, après un match.",
            style: textTheme.bodySmall?.copyWith(color: AppColors.skyMist),
          ),
        ),
      ),
    );
  }
}

/// Colonne de droite : informations extraites, dans une [Card].
class _ExtractedInfoCard extends StatelessWidget {
  const _ExtractedInfoCard({
    required this.cv,
    required this.compact,
    required this.actions,
  });

  final CvImportController cv;
  final bool compact;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final extraction = cv.extraction;

    final Widget content;
    if (cv.isAnalyzing) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const LinearProgressIndicator(semanticsLabel: 'Lecture du CV'),
          const SizedBox(height: 12),
          Text('On lit ton CV…', style: textTheme.bodySmall),
        ],
      );
    } else if (cv.hasResult && extraction != null) {
      content = CvExtractedContent(
        key: ValueKey(cv.analysisCount),
        cv: cv,
        extraction: extraction,
      );
    } else {
      content = Card(
        color: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
          child: Column(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 36,
                color: AppColors.slate,
              ),
              const SizedBox(height: 12),
              Text(
                'Rien à vérifier pour l’instant',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Importe ton CV : ta formation, tes expériences et tes compétences apparaîtront ici, prêtes à être corrigées.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 20 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Informations extraites',
                    style: textTheme.titleLarge,
                  ),
                ),
                if (cv.hasResult)
                  const JoynInfoChip(
                    label: 'Modifiable',
                    background: AppColors.skyTint,
                    foreground: AppColors.navy,
                    small: true,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            content,
            if (cv.hasResult) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 20),
              actions,
            ],
          ],
        ),
      ),
    );
  }
}
