import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../recruiter_workspace/presentation/candidate_email.dart';
import '../../recruiter_workspace/presentation/workspace_controller.dart';
import '../../recruiter_workspace/data/recruiter_workspace_repository.dart';
import 'studio_controller.dart';
import 'studio_components.dart';

Future<void> studioEditTask(
  BuildContext context, {
  Map<String, dynamic>? task,
  String? candidateId,
  String? candidateName,
}) async {
  final c = context.read<StudioController>();
  final value = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => _TaskDialog(
      task: task,
      candidateId: candidateId,
      candidateName: candidateName,
    ),
  );
  if (value == null) return;
  final ok = await c.upsert('tasks', value);
  if (context.mounted) {
    studioToast(
      context,
      ok ? 'Action enregistrée.' : 'Impossible d’enregistrer l’action.',
    );
  }
}

Future<void> studioEditInterview(
  BuildContext context, {
  Map<String, dynamic>? event,
  String? profileId,
  String? applicationId,
  String? candidateId,
  String? candidateName,
}) async {
  final c = context.read<StudioController>();
  final value = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => _InterviewDialog(
      event: event,
      candidateId: candidateId,
      candidateName: candidateName,
    ),
  );
  if (value == null || !context.mounted) return;
  final start = DateTime.parse('${value['start']}');
  final end = start.add(Duration(minutes: value['duration'] as int));
  final overlaps = c.list('interviews').where((e) {
    if (e['id'] == value['id'] || e['status'] == 'cancelled') return false;
    final s = DateTime.tryParse('${e['start']}');
    if (s == null) return false;
    return s.isBefore(end) &&
        s
            .add(Duration(minutes: (e['duration'] as num? ?? 30).toInt()))
            .isAfter(start);
  }).isNotEmpty;
  if (overlaps &&
      !await studioConfirm(
        context,
        'Un créneau se chevauche',
        'Un autre entretien est prévu à cet horaire. Enregistrer quand même ?',
      )) {
    return;
  }
  final record = {
    ...?event,
    ...value,
    'profileId': ?profileId,
    'applicationId': ?applicationId,
  };
  final ok = await c.upsert('interviews', record);
  if (context.mounted) {
    studioToast(
      context,
      ok
          ? 'Entretien enregistré dans votre agenda. Aucune invitation n’a été envoyée.'
          : 'Impossible d’enregistrer le créneau.',
    );
  }
  if (!ok || !context.mounted || record['profileId'] == null) return;
  final address = record['profileId'].toString();
  final repo = context.read<WorkspaceController>().repository;
  if (repo is! ApiRecruiterWorkspaceRepository) return;
  if (record['applicationId'] != null &&
      event == null &&
      await studioConfirm(
        context,
        'Passer la candidature en entretien ?',
        'Le nouveau statut sera visible dans le suivi de la candidature.',
        action: 'Mettre à jour',
      )) {
    try {
      await repo.api.patchJson(
        '/api/v1/applications/${record['applicationId']}/status',
        body: {'status': 'INTERVIEW'},
      );
    } catch (_) {
      if (context.mounted) {
        studioToast(
          context,
          'Créneau enregistré. La mise à jour du statut a échoué.',
        );
      }
    }
  }
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Invitation à l’entretien'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Fermer'),
        ),
      ],
      content: SizedBox(
        width: 520,
        height: 380,
        child: CandidateEmail(
          api: repo.api,
          profileId: address,
          interview: record,
        ),
      ),
    ),
  );
}

Future<void> studioAddNote(
  BuildContext context,
  String candidateId,
  String name,
) async {
  final c = context.read<StudioController>();
  final text = await showDialog<String>(
    context: context,
    builder: (_) => _NoteDialog(name: name),
  );
  if (text == null) return;
  final ok = await c.upsert('notes', {
    'id': StudioController.newId(),
    'candidateId': candidateId,
    'candidateName': name,
    'text': text,
    'createdAt': DateTime.now().toUtc().toIso8601String(),
  });
  if (context.mounted) {
    studioToast(
      context,
      ok ? 'Note privée enregistrée.' : 'Impossible d’enregistrer la note.',
    );
  }
}

class _TaskDialog extends StatefulWidget {
  const _TaskDialog({this.task, this.candidateId, this.candidateName});
  final Map<String, dynamic>? task;
  final String? candidateId, candidateName;
  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(
    text: '${widget.task?['title'] ?? ''}',
  );
  late DateTime? _due = DateTime.tryParse('${widget.task?['due']}');
  late String _priority = '${widget.task?['priority'] ?? 'normal'}';
  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.task == null ? 'Nouvelle action' : 'Modifier l’action'),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                autofocus: true,
                maxLength: 160,
                decoration: const InputDecoration(
                  labelText: 'Que souhaitez-vous faire ?',
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Ajoutez un titre' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Priorité'),
                items: const [
                  DropdownMenuItem(value: 'normal', child: Text('Normale')),
                  DropdownMenuItem(value: 'high', child: Text('Prioritaire')),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _due ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null && mounted) setState(() => _due = date);
                },
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  _due == null
                      ? 'Ajouter une échéance'
                      : studioDate(_due!.toIso8601String()),
                ),
              ),
              if (_due != null)
                TextButton(
                  onPressed: () => setState(() => _due = null),
                  child: const Text('Sans échéance'),
                ),
              if (widget.candidateName != null)
                Text('Talent · ${widget.candidateName}'),
            ],
          ),
        ),
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
            Navigator.pop(context, {
              ...?widget.task,
              'id': widget.task?['id'] ?? StudioController.newId(),
              'title': _title.text.trim(),
              'due': _due?.toIso8601String(),
              'priority': _priority,
              'done': widget.task?['done'] ?? false,
              'candidateId': widget.candidateId ?? widget.task?['candidateId'],
              'candidateName':
                  widget.candidateName ?? widget.task?['candidateName'],
            });
          }
        },
        child: const Text('Enregistrer'),
      ),
    ],
  );
}

class _InterviewDialog extends StatefulWidget {
  const _InterviewDialog({this.event, this.candidateId, this.candidateName});
  final Map<String, dynamic>? event;
  final String? candidateId, candidateName;
  @override
  State<_InterviewDialog> createState() => _InterviewDialogState();
}

class _InterviewDialogState extends State<_InterviewDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: '${widget.candidateName ?? widget.event?['name'] ?? ''}',
  );
  late final _title = TextEditingController(
    text: '${widget.event?['title'] ?? 'Premier échange'}',
  );
  late final _location = TextEditingController(
    text: '${widget.event?['location'] ?? ''}',
  );
  late DateTime _start =
      DateTime.tryParse('${widget.event?['start']}')?.toLocal() ??
      DateTime.now().add(const Duration(days: 1));
  late int _duration = (widget.event?['duration'] as num? ?? 30).toInt();
  @override
  void dispose() {
    _name.dispose();
    _title.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Préparer un entretien'),
    content: SizedBox(
      width: 500,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                maxLength: 120,
                decoration: const InputDecoration(labelText: 'Candidat'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Précisez le candidat' : null,
              ),
              TextFormField(
                controller: _title,
                maxLength: 140,
                decoration: const InputDecoration(
                  labelText: 'Objet de l’entretien',
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Ajoutez un objet' : null,
              ),
              TextFormField(
                controller: _location,
                maxLength: 300,
                decoration: const InputDecoration(
                  labelText: 'Lieu ou lien de visioconférence',
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _start,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(
                          const Duration(days: 3650),
                        ),
                      );
                      if (d != null && mounted) {
                        setState(
                          () => _start = DateTime(
                            d.year,
                            d.month,
                            d.day,
                            _start.hour,
                            _start.minute,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(studioDate(_start.toIso8601String())),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_start),
                      );
                      if (t != null && mounted) {
                        setState(
                          () => _start = DateTime(
                            _start.year,
                            _start.month,
                            _start.day,
                            t.hour,
                            t.minute,
                          ),
                        );
                      }
                    },
                    child: Text(
                      '${_start.hour.toString().padLeft(2, '0')}:${_start.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: [15, 30, 45, 60, 90].contains(_duration)
                    ? _duration
                    : 30,
                decoration: const InputDecoration(labelText: 'Durée'),
                items: [
                  for (final minutes in [15, 30, 45, 60, 90])
                    DropdownMenuItem(
                      value: minutes,
                      child: Text('$minutes minutes'),
                    ),
                ],
                onChanged: (v) => setState(() => _duration = v!),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ce créneau organise votre agenda personnel. Confirmez l’horaire avec le candidat par message.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
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
            Navigator.pop(context, {
              ...?widget.event,
              'id': widget.event?['id'] ?? StudioController.newId(),
              'candidateId': widget.candidateId ?? widget.event?['candidateId'],
              'name': _name.text.trim(),
              'title': _title.text.trim(),
              'location': _location.text.trim(),
              'start': _start.toUtc().toIso8601String(),
              'duration': _duration,
              'status': widget.event?['status'] ?? 'planned',
            });
          }
        },
        child: const Text('Enregistrer le créneau'),
      ),
    ],
  );
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.name});
  final String name;
  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  final _text = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Note privée · ${widget.name}'),
    content: SizedBox(
      width: 500,
      child: Form(
        key: _form,
        child: TextFormField(
          controller: _text,
          autofocus: true,
          maxLines: 6,
          maxLength: 3000,
          decoration: const InputDecoration(
            hintText:
                'Points à approfondir, retour d’entretien, prochaine étape…',
          ),
          validator: (v) =>
              (v ?? '').trim().isEmpty ? 'Saisissez une note' : null,
        ),
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
        child: const Text('Enregistrer la note'),
      ),
    ],
  );
}
