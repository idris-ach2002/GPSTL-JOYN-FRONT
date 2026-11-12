import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../recruiter_candidates/domain/recruiter_candidate_models.dart';
import '../../recruiter_candidates/presentation/recruiter_candidate_controller.dart';
import '../../recruiter_offers/presentation/web/recruiter_offers_top_bar.dart';
import 'studio_actions.dart';
import 'studio_components.dart';
import 'studio_controller.dart';

Map<String, dynamic> studioCandidateSnapshot(
  RecruiterCandidateRecommendation c,
) => {
  'id': c.id,
  'profileId': c.profileId,
  'name': c.fullName,
  'title': c.jobTitle,
  'location': c.location,
  'education': c.education,
  'experienceYears': c.experienceYears,
  'availability': c.availability,
  'contract': c.contractPreference,
  'remote': c.remotePreference,
  'skills': c.skills,
  'score': c.compatibilityScore,
  'strengths': c.strengths,
  'warnings': c.warnings,
};

class CandidateStudioPanel extends StatelessWidget {
  const CandidateStudioPanel({super.key, required this.candidate});
  final RecruiterCandidateRecommendation candidate;
  @override
  Widget build(BuildContext context) {
    final c = context.watch<StudioController?>();
    if (c == null) return const SizedBox.shrink();
    final stage = c
        .list('pipeline')
        .where((v) => v['id'] == candidate.id)
        .firstOrNull;
    final notes = c
        .list('notes')
        .where((v) => v['candidateId'] == candidate.id)
        .toList();
    final compared = c.list('comparison').any((v) => v['id'] == candidate.id);
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: StudioCard(
        accent: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StudioLoadNotice(),
            const StudioSectionTitle(
              'Mon suivi recruteur',
              subtitle:
                  'Notes privées, prochaines étapes et comparaison structurée.',
            ),
            DropdownButtonFormField<String>(
              isExpanded: true,
              key: ValueKey('${candidate.id}-${stage?['stage']}'),
              initialValue: '${stage?['stage'] ?? 'none'}',
              decoration: const InputDecoration(
                labelText: 'Étape dans mon pipeline',
              ),
              items: [
                for (final e in {
                  'none': 'Pas encore suivi',
                  'review': 'À examiner',
                  'contact': 'À contacter',
                  'interview': 'Entretien',
                  'decision': 'Décision',
                  'closed': 'Clôturé',
                }.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: c.saving || c.loading || c.error != null
                  ? null
                  : (v) {
                      if (v == 'none') {
                        c.remove('pipeline', candidate.id);
                      } else {
                        c.upsert('pipeline', {
                          ...studioCandidateSnapshot(candidate),
                          'stage': v,
                        });
                      }
                    },
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: c.saving
                      ? null
                      : () => studioAddNote(
                          context,
                          candidate.id,
                          candidate.fullName,
                        ),
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text('Note privée'),
                ),
                OutlinedButton.icon(
                  onPressed: c.saving
                      ? null
                      : () => studioEditTask(
                          context,
                          candidateId: candidate.id,
                          candidateName: candidate.fullName,
                        ),
                  icon: const Icon(Icons.task_alt),
                  label: const Text('Relance'),
                ),
                OutlinedButton.icon(
                  onPressed: c.saving
                      ? null
                      : () => studioEditInterview(
                          context,
                          profileId: candidate.profileId,
                          applicationId: candidate.profileId == null ? null : candidate.id,
                          candidateId: candidate.id,
                          candidateName: candidate.fullName,
                        ),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Entretien'),
                ),
                FilledButton.tonalIcon(
                  onPressed: c.saving
                      ? null
                      : () async {
                          if (compared) {
                            await c.remove('comparison', candidate.id);
                          } else if (c.list('comparison').length >= 3) {
                            studioToast(
                              context,
                              'Vous pouvez comparer trois talents. Retirez-en un dans le comparateur.',
                            );
                          } else {
                            await c.upsert(
                              'comparison',
                              studioCandidateSnapshot(candidate),
                            );
                          }
                        },
                  icon: Icon(compared ? Icons.check : Icons.compare_arrows),
                  label: Text(compared ? 'Dans le comparateur' : 'Comparer'),
                ),
              ],
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text(
                'Mes dernières observations',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              for (final note in notes.take(3))
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        '${note['text']}',
                        style: const TextStyle(height: 1.5),
                      ),
                      Text(
                        studioDate(note['createdAt']),
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class TalentStudioToolbar extends StatelessWidget {
  const TalentStudioToolbar({super.key});
  @override
  Widget build(BuildContext context) {
    final studio = context.watch<StudioController?>();
    if (studio == null) return const SizedBox.shrink();
    final controller = context.watch<RecruiterCandidateController>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: StudioCard(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: controller.isLoading || studio.saving
                  ? null
                  : () => _saveView(context, studio, controller),
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('Enregistrer ma recherche'),
            ),
            PopupMenuButton<String>(
              tooltip: 'Recherches enregistrées',
              enabled: studio.list('candidateViews').isNotEmpty,
              onSelected: (id) {
                final view = studio
                    .list('candidateViews')
                    .firstWhere((v) => v['id'] == id);
                controller.restoreView(
                  Map<String, dynamic>.from(view['query'] as Map),
                );
              },
              itemBuilder: (_) => [
                for (final view in studio.list('candidateViews'))
                  PopupMenuItem(
                    value: '${view['id']}',
                    child: Text('${view['name']}'),
                  ),
              ],
              child: Chip(
                avatar: const Icon(Icons.history, size: 16),
                label: Text(
                  '${studio.list('candidateViews').length} recherche(s)',
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => context.go('/recruiter/compare'),
              icon: const Icon(Icons.compare_arrows),
              label: Text('Comparer (${studio.list('comparison').length}/3)'),
            ),
            TextButton.icon(
              onPressed: () => context.go('/recruiter/planner?tab=2'),
              icon: const Icon(Icons.view_kanban_outlined),
              label: const Text('Pipeline'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveView(
    BuildContext context,
    StudioController studio,
    RecruiterCandidateController controller,
  ) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => const _NameViewDialog(),
    );
    if (value == null) return;
    final ok = await studio.upsert('candidateViews', {
      'id': StudioController.newId(),
      'name': value,
      'query': controller.query.toQueryParameters(),
    });
    if (context.mounted) {
      studioToast(
        context,
        ok
            ? 'Recherche enregistrée.'
            : 'Impossible d’enregistrer la recherche.',
      );
    }
  }
}

class _NameViewDialog extends StatefulWidget {
  const _NameViewDialog();
  @override
  State<_NameViewDialog> createState() => _NameViewDialogState();
}

class _NameViewDialogState extends State<_NameViewDialog> {
  final _text = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Enregistrer cette recherche'),
    content: Form(
      key: _form,
      child: TextFormField(
        controller: _text,
        autofocus: true,
        maxLength: 80,
        decoration: const InputDecoration(
          labelText: 'Un nom pour la retrouver',
        ),
        validator: (v) => (v ?? '').trim().isEmpty ? 'Ajoutez un nom' : null,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, _text.text.trim());
          }
        },
        child: const Text('Enregistrer'),
      ),
    ],
  );
}

class StudioComparison extends StatelessWidget {
  const StudioComparison({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.watch<StudioController>();
    final values = c.list('comparison');
    final narrow = MediaQuery.sizeOf(context).width < 800;
    const rows = {
      'title': 'Profil',
      'location': 'Localisation',
      'education': 'Formation',
      'experienceYears': 'Années d’expérience',
      'availability': 'Disponibilité',
      'contract': 'Contrat recherché',
      'remote': 'Organisation du travail',
      'skills': 'Compétences',
      'strengths': 'Points de correspondance',
      'warnings': 'Points à approfondir',
    };
    return Scaffold(
      appBar: narrow
          ? AppBar(
              title: const Text('Comparer les talents'),
              leading: IconButton(
                onPressed: () => context.go('/recruiter/candidates'),
                icon: const Icon(Icons.arrow_back),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (!narrow)
              Container(
                color: const Color(0xFF001E3B),
                padding: const EdgeInsets.all(22),
                child: const RecruiterOffersTopBar(
                  active: RecruiterTopTab.candidates,
                ),
              ),
            const StudioLoadNotice(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  const StudioSectionTitle(
                    'Trois profils. Une lecture plus claire.',
                    subtitle: 'Comparez les informations utiles au poste. Les scores de correspondance ne remplacent pas votre appréciation.',
                  ),
                  if (values.isEmpty)
                    StudioEmpty(
                      title: 'Ajoutez vos premiers profils.',
                      message:
                          'Ouvrez une fiche talent et choisissez Comparer.',
                      icon: Icons.compare_arrows,
                      action: FilledButton(
                        onPressed: () => context.go('/recruiter/candidates'),
                        child: const Text('Découvrir les talents'),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: StudioCard(
                        padding: EdgeInsets.zero,
                        child: DataTable(
                          columnSpacing: 24,
                          dataRowMinHeight: 56,
                          dataRowMaxHeight: 160,
                          columns: [
                            const DataColumn(
                              label: SizedBox(
                                width: 155,
                                child: Text('Critères liés au poste'),
                              ),
                            ),
                            for (final v in values)
                              DataColumn(
                                label: SizedBox(
                                  width: 230,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${v['name']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Retirer de la comparaison',
                                        onPressed: c.saving
                                            ? null
                                            : () => c.remove(
                                                'comparison',
                                                '${v['id']}',
                                              ),
                                        icon: const Icon(Icons.close, size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                          rows: [
                            for (final row in rows.entries)
                              DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      row.value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  for (final v in values)
                                    DataCell(
                                      SizedBox(
                                        width: 230,
                                        child: Text(
                                          v[row.key] is List
                                              ? (v[row.key] as List).join(' · ')
                                              : '${v[row.key] ?? 'Non renseigné'}',
                                          maxLines: 6,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            DataRow(
                              cells: [
                                const DataCell(Text('Prochaine étape')),
                                for (final v in values)
                                  DataCell(
                                    OutlinedButton(
                                      onPressed: () => studioEditInterview(
                                        context,
                                        profileId: v['profileId']?.toString(),
                                        applicationId: v['profileId'] == null ? null : v['id']?.toString(),
                                        candidateId: '${v['id']}',
                                        candidateName: '${v['name']}',
                                      ),
                                      child: const Text(
                                        'Préparer un entretien',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
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
