import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routing/app_routes.dart';
import '../../../core/network/api_client.dart';
import '../../recruiter_workspace/data/recruiter_workspace_repository.dart';
import '../../recruiter_workspace/presentation/candidate_dossier.dart';
import 'interview_dialog.dart';

class InterviewAgenda extends StatefulWidget {
  const InterviewAgenda({
    super.key,
    required this.api,
    this.recruiter = false,
    this.query = '',
    this.onChanged,
  });

  final ApiClient api;
  final bool recruiter;
  final String query;
  final VoidCallback? onChanged;

  @override
  State<InterviewAgenda> createState() => _InterviewAgendaState();
}

class _InterviewAgendaState extends State<InterviewAgenda> {
  late Future<List<Map<String, dynamic>>> _items;
  final _busy = <int>{};
  bool _history = false;

  @override
  void initState() {
    super.initState();
    _items = _fetch();
  }

  Future<List<Map<String, dynamic>>> _fetch() async {
    final interviews = <Map<String, dynamic>>[];
    for (var page = 1; ; page++) {
      final result = apiObject(
        await widget.api.getJson(
          '/api/v1/interviews',
          query: {'page': '$page', 'limit': '100'},
        ),
      );
      interviews.addAll(apiList(result));
      if (result['hasNext'] != true) return interviews;
    }
  }

  void _reload() => setState(() => _items = _fetch());

  Future<void> _decide(int id, String status) async {
    if (_busy.contains(id)) return;
    setState(() => _busy.add(id));
    try {
      await widget.api.patchJson(
        '/api/v1/interviews/$id/status',
        body: {'status': status},
      );
      if (!mounted) return;
      _reload();
      widget.onChanged?.call();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de mettre à jour cet entretien.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (widget.recruiter)
            FilledButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final sent = await showInterviewProposal(context, widget.api);
                if (!mounted || sent != true) return;
                _reload();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Entretien enregistré et invitation envoyée.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Proposer un entretien'),
            ),
          FilterChip(
            label: const Text('Historique'),
            selected: _history,
            onSelected: (value) => setState(() => _history = value),
          ),
          IconButton(
            tooltip: 'Actualiser les entretiens',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      FutureBuilder(
        future: _items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          }
          if (snapshot.hasError) {
            return TextButton(
              onPressed: _reload,
              child: const Text('Agenda indisponible · Réessayer'),
            );
          }
          final visible = (snapshot.data ?? []).where((item) {
            final date = DateTime.tryParse('${item['scheduledAt']}');
            final upcoming =
                date != null &&
                date.isAfter(DateTime.now()) &&
                const ['PROPOSED', 'CONFIRMED'].contains(item['status']);
            final searchable =
                '${item['jobTitle']} ${item['companyName']} ${item['firstName']} ${item['lastName']} ${item['title']}';
            return upcoming != _history &&
                searchable.toLowerCase().contains(widget.query);
          });
          if (visible.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                _history
                    ? 'Aucun entretien dans l’historique.'
                    : 'Aucun entretien à venir.',
              ),
            );
          }
          return Column(
            children: [
              for (final interview
                  in _history ? visible.toList().reversed : visible)
                _card(interview),
            ],
          );
        },
      ),
    ],
  );

  Widget _card(Map<String, dynamic> item) {
    final id = item['id'] as int;
    final status = item['status'];
    final date = DateTime.tryParse('${item['scheduledAt']}')?.toLocal();
    final localizations = MaterialLocalizations.of(context);
    final dateLabel = date == null
        ? ''
        : '${localizations.formatCompactDate(date)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
    final statusLabel = switch (status) {
      'PROPOSED' => 'Proposé',
      'CONFIRMED' => 'Confirmé',
      'CANCELLED' => 'Annulé',
      'DECLINED' => 'Refusé',
      'DONE' => 'Terminé',
      _ => 'À vérifier',
    };
    final format = switch (item['mode']) {
      'VIDEO' => 'Visioconférence',
      'PHONE' => 'Téléphone',
      _ => 'Sur place',
    };
    final person = widget.recruiter
        ? [item['firstName'], item['lastName']].whereType<String>().join(' ')
        : '${item['companyName']}';
    final enabled = !_busy.contains(id);
    final applicationId = '${item['applicationId']}';
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item['title'] ?? item['jobTitle']}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (item['title'] != item['jobTitle']) Text('${item['jobTitle']}'),
            Text('$person · $statusLabel'),
            Text('$dateLabel · ${item['durationMinutes']} min · $format'),
            if ('${item['locationOrLink'] ?? ''}'.isNotEmpty)
              SelectableText('${item['locationOrLink']}'),
            Wrap(
              spacing: 8,
              children: [
                if (widget.recruiter)
                  TextButton(
                    onPressed: () => showCandidateDossier(
                      context,
                      widget.api,
                      applicationId,
                    ),
                    child: const Text('Voir le dossier'),
                  ),
                if (widget.recruiter)
                  TextButton(
                    onPressed: () => context.go(
                      Uri(
                        path: AppRoutes.recruiterMessages,
                        queryParameters: {
                          'applicationId': applicationId,
                          'name': person,
                        },
                      ).toString(),
                    ),
                    child: const Text('Conversation'),
                  ),
                if (!widget.recruiter && status == 'PROPOSED' && !_history) ...[
                  FilledButton(
                    onPressed: enabled ? () => _decide(id, 'CONFIRMED') : null,
                    child: const Text('Confirmer'),
                  ),
                  TextButton(
                    onPressed: enabled ? () => _decide(id, 'DECLINED') : null,
                    child: const Text('Décliner'),
                  ),
                ],
                if (widget.recruiter &&
                    !_history &&
                    (status == 'PROPOSED' || status == 'CONFIRMED'))
                  TextButton(
                    onPressed: enabled ? () => _decide(id, 'CANCELLED') : null,
                    child: const Text('Annuler le créneau'),
                  ),
                if (widget.recruiter && _history && status == 'CONFIRMED')
                  TextButton(
                    onPressed: enabled ? () => _decide(id, 'DONE') : null,
                    child: const Text('Marquer terminé'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
