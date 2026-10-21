import 'package:flutter/material.dart';

import '../../../../core/feedback/coming_soon.dart';
import '../../../../design_system/components/joyn_button.dart';
import '../../../../design_system/components/joyn_pill.dart';
import '../../../../design_system/components/joyn_removable_chip.dart';
import '../../../../design_system/components/joyn_text_field.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../domain/cv_extraction.dart';
import '../controllers/cv_import_controller.dart';
import 'add_item_dialog.dart';
import 'cv_upload_panel.dart';

/// Colonne de droite : informations extraites du CV, modifiables.
class ExtractedInfoPanel extends StatelessWidget {
  const ExtractedInfoPanel({
    required this.cv,
    required this.compact,
    required this.onCompletePreferences,
    required this.onValidate,
    required this.isValidating,
    super.key,
  });

  final CvImportController cv;
  final bool compact;
  final VoidCallback onCompletePreferences;
  final VoidCallback onValidate;
  final bool isValidating;

  @override
  Widget build(BuildContext context) {
    final extraction = cv.extraction;

    final Widget content;
    if (cv.isAnalyzing) {
      content = const _AnalyzingState();
    } else if (cv.hasResult && extraction != null) {
      content = _ExtractedContent(
        // Recréé à chaque nouvelle analyse pour réinitialiser les champs.
        key: ValueKey(cv.analysisCount),
        cv: cv,
        extraction: extraction,
      );
    } else {
      content = const _EmptyState();
    }

    return Container(
      padding: EdgeInsets.all(compact ? 20 : 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lineSoft),
      ),
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
                child: const Text(
                  'Informations extraites',
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (cv.hasResult)
                const JoynPill(
                  label: 'Modifiable',
                  background: AppColors.skyTint,
                  foreground: AppColors.navy,
                  fontSize: 12,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
            ],
          ),
          const SizedBox(height: 28),
          content,
          if (cv.hasResult) ...[
            const SizedBox(height: 28),
            const Divider(height: 1, thickness: 1, color: AppColors.track),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 12,
              children: [
                JoynButton(
                  label: 'Compléter les préférences',
                  variant: JoynButtonVariant.outline,
                  height: 48,
                  fontSize: 15,
                  borderRadius: 12,
                  onPressed: isValidating ? null : onCompletePreferences,
                ),
                JoynButton(
                  key: const ValueKey('cv-validate'),
                  label: 'Valider mon profil',
                  height: 48,
                  fontSize: 15,
                  borderRadius: 12,
                  isLoading: isValidating,
                  onPressed: onValidate,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.description_outlined, size: 36, color: AppColors.slate),
          SizedBox(height: 12),
          Text(
            'Rien à vérifier pour l’instant',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Importe ton CV : ta formation, tes expériences et tes compétences apparaîtront ici, prêtes à être corrigées.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.slate),
          ),
        ],
      ),
    );
  }
}

class _AnalyzingState extends StatelessWidget {
  const _AnalyzingState();

  @override
  Widget build(BuildContext context) {
    Widget bar(double widthFactor, [double height = 14]) {
      return FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widthFactor,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.track,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    return Semantics(
      label: 'Lecture du CV en cours',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bar(0.25),
          const SizedBox(height: 14),
          bar(1, 44),
          const SizedBox(height: 28),
          bar(0.3),
          const SizedBox(height: 14),
          bar(1, 68),
          const SizedBox(height: 10),
          bar(1, 68),
          const SizedBox(height: 28),
          bar(0.4),
          const SizedBox(height: 14),
          bar(0.8, 32),
        ],
      ),
    );
  }
}

class _ExtractedContent extends StatefulWidget {
  const _ExtractedContent({
    required this.cv,
    required this.extraction,
    super.key,
  });

  final CvImportController cv;
  final CvExtraction extraction;

  @override
  State<_ExtractedContent> createState() => _ExtractedContentState();
}

class _ExtractedContentState extends State<_ExtractedContent> {
  late final _fullName = TextEditingController(
    text: widget.extraction.fullName,
  );
  late final _email = TextEditingController(text: widget.extraction.email);
  late final _city = TextEditingController(text: widget.extraction.city);

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _addSkill() async {
    final value = await showAddItemDialog(
      context,
      title: 'Ajouter une compétence',
      label: 'Compétence',
      hintText: 'Ex. Flutter, Kotlin…',
    );
    if (value != null) widget.cv.addSkill(value);
  }

  @override
  Widget build(BuildContext context) {
    final cv = widget.cv;
    final extraction = widget.extraction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (extraction.isSample) ...[
          const _SampleNotice(),
          const SizedBox(height: 24),
        ],
        const _SectionTitle('Identité'),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 640
                ? 3
                : constraints.maxWidth >= 420
                ? 2
                : 1;
            const spacing = 12.0;
            final fieldWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: fieldWidth,
                  child: JoynTextField(
                    label: 'Nom complet',
                    controller: _fullName,
                    onChanged: cv.updateFullName,
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: JoynTextField(
                    label: 'E-mail',
                    controller: _email,
                    onChanged: cv.updateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: JoynTextField(
                    label: 'Ville',
                    controller: _city,
                    onChanged: cv.updateCity,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        const _SectionTitle('Formation'),
        const SizedBox(height: 14),
        for (final education in extraction.educations)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ExtractedItem(
              letter: education.title.isEmpty ? '?' : education.title[0],
              title: education.title,
              subtitle: '${education.school} · ${education.period}',
              tint: AppColors.skyTint,
              foreground: AppColors.navy,
              onEdit: () => showComingSoon(context, 'La modification'),
            ),
          ),
        const SizedBox(height: 18),
        const _SectionTitle('Expériences'),
        const SizedBox(height: 14),
        for (final experience in extraction.experiences)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ExtractedItem(
              letter: experience.title.isEmpty ? '?' : experience.title[0],
              title: experience.title,
              subtitle: '${experience.company} · ${experience.period}',
              description: experience.summary,
              tint: AppColors.orangeTint,
              foreground: AppColors.orangeDeep,
              onEdit: () => showComingSoon(context, 'La modification'),
            ),
          ),
        const SizedBox(height: 4),
        CvAddButton(
          label: 'Ajouter une expérience',
          onTap: () => showComingSoon(context, "L'ajout d'expérience"),
        ),
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(child: _SectionTitle('Compétences détectées')),
            Text(
              '${extraction.skills.length} compétences',
              style: const TextStyle(fontSize: 13, color: AppColors.slate),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final skill in extraction.skills)
              JoynRemovableChip(
                label: skill,
                onRemove: () => cv.removeSkill(skill),
              ),
            CvAddButton(label: 'Ajouter', height: 36, onTap: _addSkill),
          ],
        ),
        if (extraction.languages.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'Langues : ${extraction.languages}',
            style: const TextStyle(fontSize: 13, color: AppColors.slate),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
          color: AppColors.slateDark,
        ),
      ),
    );
  }
}

class _ExtractedItem extends StatelessWidget {
  const _ExtractedItem({
    required this.letter,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.foreground,
    required this.onEdit,
    this.description,
  });

  final String letter;
  final String title;
  final String subtitle;
  final String? description;
  final Color tint;
  final Color foreground;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: description == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              letter.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.w700, color: foreground),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: AppColors.slate),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.slateDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Modifier',
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }
}

/// Prévient que la lecture automatique du CV n'est pas encore branchée.
class _SampleNotice extends StatelessWidget {
  const _SampleNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.warningDeep,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'La lecture automatique du CV arrive bientôt. En attendant, '
              'les informations ci-dessous sont un exemple : corrige-les avec les tiennes.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: AppColors.warningDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
