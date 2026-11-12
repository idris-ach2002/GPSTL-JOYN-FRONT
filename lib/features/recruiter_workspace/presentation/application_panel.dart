import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routing/app_routes.dart';
import '../data/recruiter_workspace_repository.dart';

/// Le backend applique les autorisations et renvoie les candidatures de l'offre.
class ApplicationPanel extends StatefulWidget {
  const ApplicationPanel({
    super.key,
    required this.repository,
    required this.jobId,
  });
  final RecruiterWorkspaceRepository repository;
  final int jobId;
  @override
  State<ApplicationPanel> createState() => _ApplicationPanelState();
}

class _ApplicationPanelState extends State<ApplicationPanel> {
  List<Map<String, dynamic>>? _items;
  bool _busy = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final items = await widget.repository.applications(widget.jobId);
      if (mounted) setState(() => _items = items);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Impossible de charger les candidatures.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stage(Map<String, dynamic> item, String stage) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.repository.updateApplication(
        widget.jobId,
        '${item['id']}',
        stage,
      );
      await _load();
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Modification impossible. Réessayez.';
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        ListTile(
          title: const Text(
            'Candidatures à cette offre',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          trailing: IconButton(
            tooltip: 'Fermer',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(_error!),
                TextButton(
                  onPressed: _busy ? null : _load,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView(
            children: [
              if (_items?.isEmpty == true)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Aucune candidature reçue pour le moment.'),
                ),
              for (final item in _items ?? <Map<String, dynamic>>[])
                ListTile(
                  title: Text('${item['name']}'),
                  subtitle: Text(
                    '${item['education'] ?? ''} ${item['score'] == null ? '' : '· ${item['score']} %'}\n${item['stage'] ?? 'NEW'}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    enabled: !_busy,
                    tooltip: 'Actions candidat',
                    onSelected: (v) {
                      if (v == 'contact') {
                        final router = GoRouter.of(context);
                        Navigator.pop(context);
                        router.go(
                          Uri(
                            path: AppRoutes.recruiterMessages,
                            queryParameters: {
                              (widget.repository.isMock
                                      ? 'candidateId'
                                      : 'profileId'):
                                  '${item['candidateId']}',
                              'name': '${item['name']}',
                            },
                          ).toString(),
                        );
                      } else {
                        _stage(item, v);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'IN_REVIEW',
                        child: Text('En cours'),
                      ),
                      PopupMenuItem(
                        value: 'INTERVIEW',
                        child: Text('Entretien'),
                      ),
                      PopupMenuItem(value: 'REJECTED', child: Text('Refuser')),
                      if (item['candidateId'] != null)
                        PopupMenuItem(
                          value: 'contact',
                          child: Text('Contacter'),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
