import 'package:flutter/material.dart';

import '../../../../design_system/material/joyn_notice.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/cv_extraction.dart';
import '../controllers/cv_import_controller.dart';

/// Zone d'import du CV, puis fichier choisi et avancement de l'analyse.
class CvUploadCard extends StatelessWidget {
  const CvUploadCard({required this.cv, super.key});

  final CvImportController cv;

  @override
  Widget build(BuildContext context) {
    final file = cv.file;
    final pickError = cv.pickError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DropZone(
          busy: cv.isAnalyzing,
          hasFile: file != null,
          onPick: cv.pickAndAnalyze,
        ),
        if (pickError != null) ...[
          const SizedBox(height: 10),
          JoynNotice(tone: JoynNoticeTone.error, message: pickError),
        ],
        if (file != null) ...[
          const SizedBox(height: 14),
          _FileCard(cv: cv, file: file),
        ],
      ],
    );
  }
}

class _DropZone extends StatelessWidget {
  const _DropZone({
    required this.busy,
    required this.hasFile,
    required this.onPick,
  });

  final bool busy;
  final bool hasFile;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: AppColors.skyTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0x99489EC9), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.navy,
              child: Icon(
                Icons.upload_file_rounded,
                color: AppColors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasFile ? 'Importer un autre CV' : 'Importe ton CV',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'PDF ou DOCX · 5 Mo maximum',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('cv-pick'),
              onPressed: busy ? null : onPick,
              icon: const Icon(Icons.folder_open_rounded),
              label: Text(
                hasFile ? 'Choisir un autre fichier' : 'Choisir un fichier',
              ),
            ),
          ],
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
    final textTheme = Theme.of(context).textTheme;
    final failed = cv.status == CvImportStatus.failed;
    final extraction = cv.extraction;

    final Widget status;
    if (failed) {
      status = Text(
        cv.error ?? "L'analyse a échoué. Réessaie avec un autre fichier.",
        style: textTheme.bodySmall?.copyWith(
          color: AppColors.errorDeep,
          fontWeight: FontWeight.w600,
        ),
      );
    } else if (cv.hasResult && extraction != null) {
      status = Text(
        'Analyse terminée · ${extraction.extractedCount} éléments extraits',
        style: textTheme.bodySmall?.copyWith(
          color: AppColors.successDeep,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      status = Text(
        'Analyse en cours… ${(cv.progress * 100).round()} %',
        style: textTheme.bodySmall,
      );
    }

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 8, 16, 8),
        leading: Container(
          width: 44,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.orangeTint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            file.extension,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.orangeDeep,
              letterSpacing: 0,
            ),
          ),
        ),
        title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(file.readableSize, style: textTheme.bodySmall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: failed ? 1 : cv.progress,
              color: failed ? AppColors.error : AppColors.successDeep,
              backgroundColor: AppColors.successTint,
              borderRadius: BorderRadius.circular(99),
              semanticsLabel: 'Progression de l’analyse',
            ),
            const SizedBox(height: 8),
            status,
          ],
        ),
      ),
    );
  }
}

/// Boutons de fin d'import : compléter les préférences ou valider.
class CvImportActions extends StatelessWidget {
  const CvImportActions({
    required this.onCompletePreferences,
    required this.onValidate,
    required this.isValidating,
    this.stacked = false,
    super.key,
  });

  final VoidCallback onCompletePreferences;
  final VoidCallback onValidate;
  final bool isValidating;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final complete = OutlinedButton(
      style: JoynButtonStyles.rounded,
      onPressed: isValidating ? null : onCompletePreferences,
      child: const Text('Compléter les préférences'),
    );
    final validate = FilledButton(
      key: const ValueKey('cv-validate'),
      style: JoynButtonStyles.rounded,
      onPressed: isValidating ? null : onValidate,
      child: isValidating
          ? const ButtonProgress()
          : const Text('Valider mon profil'),
    );

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [validate, const SizedBox(height: 10), complete],
      );
    }
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 12,
      runSpacing: 12,
      children: [complete, validate],
    );
  }
}
