import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routing/app_routes.dart';
import '../../recruiter_offers/presentation/web/recruiter_offers_top_bar.dart';
import '../data/studio_export.dart';
import 'studio_export_dialog.dart';
import 'studio_actions.dart';
import 'studio_controller.dart';
import 'studio_components.dart';

class StudioPlanner extends StatefulWidget {
  const StudioPlanner({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<StudioPlanner> createState() => _StudioPlannerState();
}

class _StudioPlannerState extends State<StudioPlanner> {
  late int _tab = widget.initialTab;
  String _query = '',
      _taskView = 'open',
      _eventView = 'upcoming',
      _stage = 'review';
  DateTime? _day;
  @override
  void didUpdateWidget(covariant StudioPlanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<StudioController>();
    final compact = MediaQuery.sizeOf(context).width < 800;
    return Scaffold(
      appBar: compact
          ? AppBar(
              leading: IconButton(
                tooltip: 'Dashboard',
                onPressed: () => context.go(AppRoutes.recruiterDashboard),
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Centre de travail'),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (!compact)
              Container(
                color: const Color(0xFF001E3B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 18,
                ),
                child: const RecruiterOffersTopBar(
                  active: RecruiterTopTab.workspace,
                ),
              ),
            const StudioLoadNotice(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StudioSectionTitle(
                    'Le prochain pas, au bon moment.',
                    subtitle: 'Actions, entretiens et suivi des talents réunis dans un même espace.',
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final e in [
                          (0, 'Mes actions', Icons.task_alt),
                          (1, 'Entretiens', Icons.calendar_month_outlined),
                          (2, 'Pipeline', Icons.view_kanban_outlined),
                          (3, 'Notes privées', Icons.sticky_note_2_outlined),
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              avatar: Icon(e.$3, size: 16),
                              label: Text(e.$2),
                              selected: _tab == e.$1,
                              onSelected: (_) => setState(() => _tab = e.$1),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: c.retry,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Rechercher dans cette rubrique',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) =>
                          setState(() => _query = v.toLowerCase().trim()),
                    ),
                    const SizedBox(height: 16),
                    switch (_tab) {
                      0 => _tasks(c),
                      1 => _events(c),
                      2 => _pipeline(c),
                      _ => _notes(c),
                    },
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tasks(StudioController c) {
    final values =
        c
            .list('tasks')
            .where(
              (v) =>
                  ('${v['title']} ${v['candidateName'] ?? ''}')
                      .toLowerCase()
                      .contains(_query) &&
                  (_taskView == 'all' ||
                      _taskView == 'done' && v['done'] == true ||
                      _taskView == 'open' && v['done'] != true ||
                      _taskView == 'high' &&
                          v['priority'] == 'high' &&
                          v['done'] != true),
            )
            .toList()
          ..sort(
            (a, b) =>
                ('${a['due'] ?? '9999'}').compareTo('${b['due'] ?? '9999'}'),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 12,
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final e in {
                  'open': 'À faire',
                  'high': 'Prioritaires',
                  'done': 'Terminées',
                  'all': 'Toutes',
                }.entries)
                  FilterChip(
                    label: Text(e.value),
                    selected: _taskView == e.key,
                    onSelected: (_) => setState(() => _taskView = e.key),
                  ),
              ],
            ),
            FilledButton.icon(
              onPressed: c.loading || c.saving || c.error != null
                  ? null
                  : () => studioEditTask(context),
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle action'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (values.isEmpty)
          const StudioEmpty(
            title: 'Faites de la place à la prochaine étape.',
            message:
                'Ajoutez une relance, une lecture de CV ou un point de suivi.',
            icon: Icons.task_alt,
          ),
        for (final task in values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: StudioCard(
              padding: const EdgeInsets.all(12),
              child: CheckboxListTile(
                value: task['done'] == true,
                onChanged: c.saving
                    ? null
                    : (v) => c.upsert('tasks', {...task, 'done': v}),
                title: Text(
                  '${task['title']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: task['done'] == true
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Text(
                  [
                    if (task['candidateName'] != null)
                      '${task['candidateName']}',
                    if (task['due'] != null)
                      'Échéance ${studioDate(task['due'])}',
                    if (task['priority'] == 'high') 'Prioritaire',
                  ].join(' · '),
                  style: TextStyle(
                    color: _overdue(task)
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
                secondary: PopupMenuButton<String>(
                  tooltip: 'Actions de la tâche',
                  enabled: !c.saving,
                  onSelected: (v) async {
                    if (v == 'edit') {
                      await studioEditTask(context, task: task);
                    } else if (await studioConfirm(
                          context,
                          'Supprimer cette action ?',
                          'Cette action sera retirée de votre liste.',
                        ) &&
                        mounted) {
                      await c.remove('tasks', '${task['id']}');
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Modifier')),
                    PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _overdue(Map<String, dynamic> t) {
    final date = DateTime.tryParse('${t['due']}');
    final now = DateTime.now();
    return t['done'] != true &&
        date != null &&
        date.isBefore(DateTime(now.year, now.month, now.day));
  }

  Widget _events(StudioController c) {
    final all = c.list('interviews');
    final values = all.where((e) {
      final d = DateTime.tryParse('${e['start']}')?.toLocal();
      if (d == null) return false;
      final upcoming = d
          .add(Duration(minutes: (e['duration'] as num? ?? 30).toInt()))
          .isAfter(DateTime.now());
      return ('${e['name']} ${e['title']}').toLowerCase().contains(_query) &&
          (_eventView == 'all' ||
              _eventView == 'cancelled' && e['status'] == 'cancelled' ||
              _eventView == 'upcoming' &&
                  upcoming &&
                  e['status'] != 'cancelled') &&
          (_day == null || DateUtils.isSameDay(d, _day));
    }).toList()..sort((a, b) => '${a['start']}'.compareTo('${b['start']}'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: c.loading || c.saving || c.error != null
                  ? null
                  : () => studioEditInterview(context),
              icon: const Icon(Icons.add),
              label: const Text('Préparer un entretien'),
            ),
            OutlinedButton.icon(
              onPressed: values.isEmpty
                  ? null
                  : () => studioExport(
                      context,
                      name: 'joyn-entretiens.ics',
                      text: studioCalendar(values),
                      extension: 'ics',
                    ),
              icon: const Icon(Icons.calendar_today_outlined),
              label: const Text('Exporter le calendrier'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          children: [
            for (final e in {
              'upcoming': 'À venir',
              'all': 'Tous',
              'cancelled': 'Annulés',
            }.entries)
              ChoiceChip(
                label: Text(e.value),
                selected: _eventView == e.key,
                onSelected: (_) => setState(() => _eventView = e.key),
              ),
            if (_day != null)
              InputChip(
                label: Text(studioDate(_day!.toIso8601String())),
                onDeleted: () => setState(() => _day = null),
              ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 104 + (MediaQuery.textScalerOf(context).scale(1) - 1) * 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            separatorBuilder: (_, i) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final now = DateTime.now();
              final day = DateTime(now.year, now.month, now.day + i);
              final count = all
                  .where(
                    (e) =>
                        DateUtils.isSameDay(
                          DateTime.tryParse('${e['start']}')?.toLocal(),
                          day,
                        ) &&
                        e['status'] != 'cancelled',
                  )
                  .length;
              final selected = DateUtils.isSameDay(_day, day);
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _day = selected ? null : day),
                child: Container(
                  width: 88,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                              .withValues(alpha: .16)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        const [
                          'LUN',
                          'MAR',
                          'MER',
                          'JEU',
                          'VEN',
                          'SAM',
                          'DIM',
                        ][day.weekday - 1],
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${day.day}',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '$count prévu(s)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        if (values.isEmpty)
          const StudioEmpty(
            title: 'Un agenda prêt pour les bonnes rencontres.',
            message: 'Préparez un créneau, puis confirmez-le avec le candidat. Aucune invitation n’est envoyée automatiquement.',
            icon: Icons.calendar_month_outlined,
          ),
        for (final e in values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: StudioCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary
                          .withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${DateTime.parse('${e['start']}').toLocal().day}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${DateTime.parse('${e['start']}').toLocal().hour.toString().padLeft(2, '0')}:${DateTime.parse('${e['start']}').toLocal().minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${e['name']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text('${e['title']}'),
                        const SizedBox(height: 6),
                        Text(
                          '${studioDate(e['start'])} · ${e['duration']} min · ${e['status'] == 'cancelled' ? 'Annulé' : 'Prévu'}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        if ('${e['location'] ?? ''}'.isNotEmpty)
                          SelectableText(
                            '${e['location']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Actions de l’entretien',
                    enabled: !c.saving,
                    onSelected: (v) async {
                      if (v == 'edit') {
                        await studioEditInterview(context, event: e);
                      } else if (v == 'cancel') {
                        if (await studioConfirm(
                              context,
                              'Annuler ce créneau ?',
                              'Le candidat ne recevra aucune notification automatique.',
                            ) &&
                            mounted) {
                          await c.upsert('interviews', {
                            ...e,
                            'status': 'cancelled',
                          });
                        }
                      } else if (v == 'message' && e['candidateId'] != null) {
                        context.go(
                          Uri(
                            path: AppRoutes.recruiterMessages,
                            queryParameters: {
                              if (e['profileId'] != null)
                                'profileId': '${e['profileId']}'
                              else
                                'candidateId': '${e['candidateId']}',
                              'name': '${e['name']}',
                            },
                          ).toString(),
                        );
                      } else if (v == 'export') {
                        await studioExport(
                          context,
                          name: 'joyn-entretien.ics',
                          text: studioCalendar([e]),
                          extension: 'ics',
                        );
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Modifier le créneau'),
                      ),
                      if (e['candidateId'] != null)
                        const PopupMenuItem(
                          value: 'message',
                          child: Text('Contacter le candidat'),
                        ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Text('Exporter ce créneau'),
                      ),
                      if (e['status'] != 'cancelled')
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Text('Annuler le créneau'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static const stages = {
    'review': 'À examiner',
    'contact': 'À contacter',
    'interview': 'Entretien',
    'decision': 'Décision',
    'closed': 'Clôturé',
  };
  Widget _pipeline(StudioController c) {
    final candidates = c
        .list('pipeline')
        .where(
          (v) =>
              '${v['name']} ${v['title'] ?? ''}'.toLowerCase().contains(_query),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Un suivi personnel de vos talents. Changer une étape ne modifie pas leur candidature et n’envoie aucun message.',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final stage in stages.entries)
              ChoiceChip(
                label: Text(
                  '${stage.value} · ${candidates.where((v) => v['stage'] == stage.key).length}',
                ),
                selected: _stage == stage.key,
                onSelected: (_) => setState(() => _stage = stage.key),
              ),
          ],
        ),
        const SizedBox(height: 18),
        if (candidates.where((v) => v['stage'] == _stage).isEmpty)
          const StudioEmpty(
            title: 'Votre pipeline se construit avec vos rencontres.',
            message: 'Ajoutez un talent depuis sa fiche pour suivre la prochaine étape.',
            icon: Icons.view_kanban_outlined,
          ),
        for (final candidate in candidates.where((v) => v['stage'] == _stage))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: StudioCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${candidate['name']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text('${candidate['title'] ?? ''}'),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    key: ValueKey('${candidate['id']}-${candidate['stage']}'),
                    initialValue: stages.containsKey('${candidate['stage']}')
                        ? '${candidate['stage']}'
                        : 'review',
                    decoration: const InputDecoration(
                      labelText: 'Étape de suivi',
                    ),
                    items: [
                      for (final s in stages.entries)
                        DropdownMenuItem(value: s.key, child: Text(s.value)),
                    ],
                    onChanged: c.saving
                        ? null
                        : (v) =>
                              c.upsert('pipeline', {...candidate, 'stage': v}),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () => studioAddNote(
                          context,
                          '${candidate['id']}',
                          '${candidate['name']}',
                        ),
                        icon: const Icon(Icons.note_add_outlined),
                        label: const Text('Note'),
                      ),
                      TextButton.icon(
                        onPressed: () => studioEditTask(
                          context,
                          candidateId: '${candidate['id']}',
                          candidateName: '${candidate['name']}',
                        ),
                        icon: const Icon(Icons.task_alt),
                        label: const Text('Action'),
                      ),
                      TextButton.icon(
                        onPressed: () => context.go(
                          Uri(
                            path: AppRoutes.recruiterMessages,
                            queryParameters: {
                              if (candidate['profileId'] != null)
                                'profileId': '${candidate['profileId']}'
                              else
                                'candidateId': '${candidate['id']}',
                              'name': '${candidate['name']}',
                            },
                          ).toString(),
                        ),
                        icon: const Icon(Icons.chat_outlined),
                        label: const Text('Contacter'),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (await studioConfirm(
                                context,
                                'Retirer du pipeline ?',
                                'Les notes et la candidature restent disponibles.',
                              ) &&
                              mounted) {
                            await c.remove('pipeline', '${candidate['id']}');
                          }
                        },
                        child: const Text('Retirer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _notes(StudioController c) {
    final notes = c
        .list('notes')
        .where(
          (n) => '${n['text']} ${n['candidateName'] ?? ''}'
              .toLowerCase()
              .contains(_query),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (notes.isEmpty)
          const StudioEmpty(
            title: 'Vos observations, au même endroit.',
            message: 'Ajoutez une note depuis une fiche talent ou une conversation. Elle restera privée dans votre espace.',
            icon: Icons.sticky_note_2_outlined,
          ),
        for (final note in notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: StudioCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${note['candidateName'] ?? 'Note privée'}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Supprimer la note',
                        onPressed: c.saving
                            ? null
                            : () async {
                                if (await studioConfirm(
                                      context,
                                      'Supprimer cette note ?',
                                      'La suppression sera définitive.',
                                    ) &&
                                    mounted) {
                                  await c.remove('notes', '${note['id']}');
                                }
                              },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  SelectableText(
                    '${note['text']}',
                    style: const TextStyle(height: 1.6),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    studioDate(note['createdAt']),
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class StudioOverview extends StatelessWidget {
  const StudioOverview({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.watch<StudioController?>();
    if (c == null) return const SizedBox.shrink();
    final tasks = c.list('tasks').where((t) => t['done'] != true).toList();
    final events =
        c
            .list('interviews')
            .where(
              (e) =>
                  e['status'] != 'cancelled' &&
                  (DateTime.tryParse('${e['start']}')
                          ?.isAfter(DateTime.now()) ??
                      false),
            )
            .toList()
          ..sort((a, b) => '${a['start']}'.compareTo('${b['start']}'));
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: StudioCard(
        accent: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StudioSectionTitle(
              'Votre prochaine bonne décision.',
              subtitle:
                  'Un espace de travail qui relie vos talents à vos actions.',
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go('/recruiter/planner'),
                  icon: const Icon(Icons.task_alt),
                  label: Text('${tasks.length} action(s) à suivre'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/recruiter/planner?tab=1'),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text('${events.length} entretien(s) à venir'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/recruiter/planner?tab=2'),
                  icon: const Icon(Icons.view_kanban_outlined),
                  label: const Text('Mon pipeline'),
                ),
              ],
            ),
            if (events.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Prochain échange · ${events.first['name']} · ${studioDate(events.first['start'])}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
