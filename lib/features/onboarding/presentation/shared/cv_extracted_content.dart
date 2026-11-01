import 'package:flutter/material.dart';

import '../../../../core/feedback/coming_soon.dart';
import '../../../../design_system/material/joyn_notice.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/cv_extraction.dart';
import '../controllers/cv_import_controller.dart';
import 'add_item_dialog.dart';

/// Informations extraites du CV, modifiables (identité, formation,
/// expériences, compétences, langues).
///
/// Donner `ValueKey(cv.analysisCount)` comme clé : les champs sont alors
/// réinitialisés à chaque nouvelle analyse.
class CvExtractedContent extends StatefulWidget {
  const CvExtractedContent({
    required this.cv,
    required this.extraction,
    super.key,
  });

  final CvImportController cv;
  final CvExtraction extraction;

  @override
  State<CvExtractedContent> createState() => _CvExtractedContentState();
}

class _CvExtractedContentState extends State<CvExtractedContent> {
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (extraction.isSample) ...[
          const JoynNotice(
            tone: JoynNoticeTone.warning,
            message:
                'La lecture automatique du CV arrive bientôt. En attendant, '
                'les informations ci-dessous sont un exemple : corrige-les avec les tiennes.',
          ),
          const SizedBox(height: 24),
        ],
        const _SectionTitle('Identité'),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 640
                ? 3
                : constraints.maxWidth >= 420
                ? 2
                : 1;
            const spacing = 12.0;
            final width =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: width,
                  child: TextField(
                    controller: _fullName,
                    onChanged: cv.updateFullName,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Nom complet'),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: TextField(
                    controller: _email,
                    onChanged: cv.updateEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: TextField(
                    controller: _city,
                    onChanged: cv.updateCity,
                    decoration: const InputDecoration(labelText: 'Ville'),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Formation'),
        for (final education in extraction.educations)
          _ExtractedItem(
            title: education.title,
            subtitle: '${education.school} · ${education.period}',
            tint: AppColors.skyTint,
            foreground: AppColors.navy,
            onEdit: () => showComingSoon(context, 'La modification'),
          ),
        const SizedBox(height: 14),
        const _SectionTitle('Expériences'),
        for (final experience in extraction.experiences)
          _ExtractedItem(
            title: experience.title,
            subtitle: '${experience.company} · ${experience.period}',
            description: experience.summary,
            tint: AppColors.orangeTint,
            foreground: AppColors.orangeDeep,
            onEdit: () => showComingSoon(context, 'La modification'),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => showComingSoon(context, "L'ajout d'expérience"),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter une expérience'),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(child: _SectionTitle('Compétences détectées')),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${extraction.skills.length} compétences',
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final skill in extraction.skills)
              InputChip(
                label: Text(skill),
                labelStyle: textTheme.labelMedium?.copyWith(
                  color: AppColors.navy,
                ),
                backgroundColor: AppColors.skyTint,
                side: BorderSide.none,
                deleteIconColor: AppColors.navy,
                deleteButtonTooltipMessage: 'Retirer $skill',
                onDeleted: () => cv.removeSkill(skill),
              ),
            ActionChip(
              avatar: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter'),
              onPressed: _addSkill,
            ),
          ],
        ),
        if (extraction.languages.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text('Langues : ${extraction.languages}', style: textTheme.bodySmall),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 13,
            letterSpacing: 0.9,
            color: AppColors.slateDark,
          ),
        ),
      ),
    );
  }
}

/// Une formation ou une expérience extraite ([ListTile] dans une [Card]).
class _ExtractedItem extends StatelessWidget {
  const _ExtractedItem({
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.foreground,
    required this.onEdit,
    this.description,
  });

  final String title;
  final String subtitle;
  final String? description;
  final Color tint;
  final Color foreground;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          isThreeLine: description != null,
          leading: CircleAvatar(
            backgroundColor: tint,
            child: Text(
              title.isEmpty ? '?' : title[0].toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.w700, color: foreground),
            ),
          ),
          title: Text(title),
          subtitle: Text(
            description == null ? subtitle : '$subtitle\n$description',
          ),
          trailing: IconButton(
            tooltip: 'Modifier',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
        ),
      ),
    );
  }
}
