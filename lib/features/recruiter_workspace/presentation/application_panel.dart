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
    this.embedded = false,
    this.onChanged,
  });
  final RecruiterWorkspaceRepository repository;
  final int jobId;
  final bool embedded;
  final VoidCallback? onChanged;
  @override
  State<ApplicationPanel> createState() => _ApplicationPanelState();
}

class _ApplicationPanelState extends State<ApplicationPanel> {
  List<Map<String, dynamic>>? _items;
  bool _busy = true;
  String? _error;
  String _query = '';
  String _filter = 'ALL';
  String _status(Object? value) => switch ('$value') {
    'PENDING' || 'NEW' => 'À examiner',
    'IN_REVIEW' => 'En cours',
    'INTERVIEW' => 'Entretien',
    'ACCEPTED' || 'HIRED' => 'Acceptée',
    'REJECTED' => 'Refusée',
    _ => 'Statut non renseigné',
  };

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
      if (mounted) widget.onChanged?.call();
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
          trailing: widget.embedded
              ? null
              : IconButton(
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
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: TextField(
            onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
            decoration: const InputDecoration(
              hintText: 'Rechercher un candidat ou une compétence',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final stage in [
                'ALL',
                'PENDING',
                'IN_REVIEW',
                'INTERVIEW',
                'REJECTED',
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 12),
                  child: ChoiceChip(
                    label: Text(
                      stage == 'ALL'
                          ? 'Tous (${_items?.length ?? 0})'
                          : _status(stage),
                    ),
                    selected: _filter == stage,
                    onSelected: (_) => setState(() => _filter = stage),
                  ),
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
              for (final item in (_items ?? <Map<String, dynamic>>[]).where(
                (item) =>
                    (_filter == 'ALL' ||
                        item['stage'] == _filter ||
                        (_filter == 'PENDING' && item['stage'] == 'NEW')) &&
                    '${item['name']} ${item['education']} ${item['skills']}'
                        .toLowerCase()
                        .contains(_query),
              ))
                _CandidateCard(
                  key: ValueKey(item['id']),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.all(18),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFFE8F2FF),
                      child: Text(
                        ('${item['name'] ?? ''}'.trim().isEmpty
                                ? '?'
                                : '${item['name']}'
                                      .trim()
                                      .split(RegExp(r'\s+'))
                                      .take(2)
                                      .map((s) => s[0])
                                      .join())
                            .toUpperCase(),
                      ),
                    ),
                    title: Text(
                      '${item['name']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ('${item['education'] ?? ''}'.isNotEmpty)
                            Text('${item['education']}'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Chip(
                                label: Text(_status(item['stage'])),
                                backgroundColor: const Color(0xFFE8F2FF),
                              ),
                              if (item['score'] != null)
                                Chip(
                                  label: Text(
                                    '${item['score']} % d’adéquation',
                                  ),
                                ),
                              if ('${item['location'] ?? ''}'.isNotEmpty)
                                Chip(
                                  avatar: const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                  ),
                                  label: Text('${item['location']}'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Voir le profil et les compétences',
                            style: TextStyle(
                              color: Color(0xFF1675D1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      enabled: !_busy,
                      tooltip: 'Actions candidat',
                      onSelected: (v) {
                        if (v == 'contact' || v == 'invite') {
                          final router = GoRouter.of(context);
                          if (!widget.embedded) Navigator.pop(context);
                          router.go(
                            Uri(
                              path: AppRoutes.recruiterMessages,
                              queryParameters: {
                                (widget.repository.isMock
                                        ? 'candidateId'
                                        : 'profileId'):
                                    '${item['candidateId']}',
                                'name': '${item['name']}',
                                if (!widget.repository.isMock)
                                  'applicationId': '${item['id']}',
                              },
                            ).toString(),
                            extra: v == 'invite'
                                ? 'Bonjour ${item['name']}, je vous propose un entretien concernant l’offre n°${widget.jobId}. Quels créneaux vous conviendraient ?'
                                : null,
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
                          child: Text('Passer au statut Entretien'),
                        ),
                        PopupMenuItem(
                          value: 'REJECTED',
                          child: Text('Refuser'),
                        ),
                        if (item['candidateId'] != null)
                          const PopupMenuItem(
                            value: 'invite',
                            child: Text('Proposer un entretien dans JOYN'),
                          ),
                        if (item['candidateId'] != null)
                          PopupMenuItem(
                            value: 'contact',
                            child: Text('Contacter'),
                          ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (item['location'] != null)
                              Text('Localisation : ${item['location']}'),
                            if (item['experience'] != null)
                              Text('Expérience : ${item['experience']} an(s)'),
                            if (item['appliedAt'] != null)
                              Text(
                                'Candidature : ${item['appliedAt'].toString().split('T').first}',
                              ),
                            if ('${item['bio'] ?? ''}'.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: SelectableText('${item['bio']}'),
                              ),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final skill
                                    in item['skills'] as List? ?? const [])
                                  Chip(label: Text('$skill')),
                              ],
                            ),
                          ],
                        ),
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

/// Hover and entrance transitions respect the user's reduced-motion setting.
class _CandidateCard extends StatefulWidget {
  const _CandidateCard({super.key, required this.child});
  final Widget child;
  @override
  State<_CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends State<_CandidateCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 220);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: child,
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: duration,
          margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hover ? const Color(0xFF2D8CFF) : const Color(0xFFDCE5EF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hover ? 0.08 : 0.03),
                blurRadius: _hover ? 18 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(color: Colors.transparent, child: widget.child),
        ),
      ),
    );
  }
}
