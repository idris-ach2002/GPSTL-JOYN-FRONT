import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/components/joyn_dashed_button.dart';
import 'package:joyn_front/design_system/components/joyn_field_message.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_durations.dart';
import 'package:joyn_front/design_system/tokens/app_fonts.dart';
import 'package:joyn_front/features/onboarding/domain/cv_extraction.dart';
import 'package:joyn_front/features/onboarding/presentation/controllers/cv_import_controller.dart';

/// Colonne de gauche : zone d'import, fichier en cours, explication.
class CvUploadPanel extends StatelessWidget {
  const CvUploadPanel({required this.cv, super.key});

  final CvImportController cv;

  @override
  Widget build(BuildContext context) {
    final file = cv.file;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DropZone(
          busy: cv.isAnalyzing,
          hasFile: file != null,
          onTap: cv.pickAndAnalyze,
        ),
        if (cv.pickError != null) ...[
          const SizedBox(height: 10),
          JoynFieldMessage.error(cv.pickError!),
        ],
        if (file != null) ...[
          const SizedBox(height: 16),
          _FileCard(cv: cv, file: file),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ce qu'on en fait",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Ton CV sert à pré-remplir ton profil et calculer tes scores. Il n'est transmis à une entreprise que si tu le décides, après un match.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: AppColors.skyMist,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DropZone extends StatelessWidget {
  const _DropZone({
    required this.busy,
    required this.hasFile,
    required this.onTap,
  });

  final bool busy;
  final bool hasFile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !busy,
      label: hasFile ? 'Importer un autre CV' : 'Importer mon CV',
      excludeSemantics: true,
      child: CustomPaint(
        foregroundPainter: const DashedBorderPainter(
          color: Color(0x99489EC9),
          radius: 24,
          strokeWidth: 2,
          dash: 8,
          gap: 6,
        ),
        child: Material(
          color: AppColors.skyTint,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: busy ? null : onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 240),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.upload_file_rounded,
                        color: AppColors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hasFile ? 'Importer un autre CV' : 'Importe ton CV',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text.rich(
                      TextSpan(
                        text: 'Clique pour ',
                        children: [
                          TextSpan(
                            text: 'parcourir tes fichiers',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: ' · PDF, DOCX · 5 Mo max'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.slate),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  const _FileCard({required this.cv, required this.file});

  final CvImportController cv;
  final PickedCv file;

  @override
  Widget build(BuildContext context) {
    final failed = cv.status == CvImportStatus.failed;
    final done = cv.hasResult;
    final barColor = failed ? AppColors.error : AppColors.successDeep;

    final Widget status;
    if (failed) {
      status = Text(
        cv.error ?? "L'analyse a échoué. Réessaie avec un autre fichier.",
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.errorDeep,
        ),
      );
    } else if (done) {
      status = Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: AppColors.successDeep,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Analyse terminée · ${cv.extraction!.extractedCount} éléments extraits',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.successDeep,
              ),
            ),
          ),
        ],
      );
    } else {
      status = Text(
        'Analyse en cours… ${(cv.progress * 100).round()} %',
        style: const TextStyle(fontSize: 13, color: AppColors.slate),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lineSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.orangeTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              file.extension,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.orangeDeep,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      file.readableSize,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Progression de l’analyse',
                  value: '${(cv.progress * 100).round()} %',
                  excludeSemantics: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: Stack(
                      children: [
                        Container(height: 6, color: AppColors.successTint),
                        AnimatedFractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          duration: AppDurations.normal,
                          widthFactor: failed ? 1 : cv.progress,
                          child: Container(height: 6, color: barColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                status,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton « + Ajouter … » réutilisé dans le panneau des informations.
class CvAddButton extends StatelessWidget {
  const CvAddButton({
    required this.label,
    required this.onTap,
    this.height = 44,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: JoynDashedButton(
        label: label,
        height: height,
        borderRadius: height == 44 ? 10 : null,
        onTap: onTap,
      ),
    );
  }
}
