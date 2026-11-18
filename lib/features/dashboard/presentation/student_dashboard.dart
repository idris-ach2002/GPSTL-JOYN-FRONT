import 'dart:convert';

import '../../candidate_workspace/presentation/candidate_workspace_dialog.dart';
import 'student_activity_charts.dart';
import 'student_dashboard_hero.dart';
import '../../candidate_applications/data/api_candidate_applications_repository.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/navigation/candidate_account_menu.dart';
import '../../../app/navigation/candidate_mobile_navigation.dart';
import '../../../app/routing/app_routes.dart';
import '../../../core/network/api_client.dart';
import '../../candidate_applications/data/candidate_applications_repository.dart';
import '../../candidate_applications/domain/candidate_application.dart';
import '../../interviews/presentation/interview_agenda.dart';
import '../../notifications/presentation/notifications_controller.dart';
import '../../notifications/presentation/shared/notifications_panel.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/profile_completion.dart';
import 'web/widgets/dashboard_top_bar.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key, required this.mobile});
  final bool mobile;

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String _period = '30d';
  late Future<Map<String, dynamic>> _stats;
  late Future<int> _profileCompletion;
  final _agenda = GlobalKey();
  Set<String> _hiddenDashboardWidgets = {};
  Map<String, dynamic>? _workspaceData;
  String? _workspaceError;

  @override
  void initState() {
    super.initState();
    _stats = _loadStats();
    _profileCompletion = _loadProfileCompletion();
    _loadWorkspaceSummary();
  }

  Future<void> _loadWorkspaceSummary() async {
    final api = context.read<ApiClient?>();
    if (api == null) return;
    try {
      final result = await api.getJson('/api/v1/candidates/workspace');
      final data = result is Map<String, dynamic>
          ? result
          : <String, dynamic>{};
      final prefs = data['preferences'] is Map
          ? data['preferences'] as Map
          : const <String, dynamic>{};
      final stored = prefs['hidden_widgets_json'];
      final decoded = stored is String ? jsonDecode(stored) : stored;
      final hidden = decoded is List
          ? decoded.whereType<String>().toSet()
          : <String>{};
      if (mounted) {
        setState(() {
          _workspaceData = data;
          _hiddenDashboardWidgets = hidden;
          _workspaceError = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _workspaceError = '$error');
    }
  }

  Future<void> _openWorkspace({int initialTab = 0}) async {
    await showCandidateWorkspace(context, initialTab: initialTab);
    if (mounted) await _loadWorkspaceSummary();
  }

  Future<void> _customizeDashboard() async {
    final api = context.read<ApiClient?>();
    if (api == null) return;
    final hidden = {..._hiddenDashboardWidgets};
    const choices = [
      ('actions', 'Mes prochaines actions'),
      ('activity', 'Mon activité et mes statistiques'),
      ('profile', 'Progression de mon profil'),
      ('interviews', 'Agenda des entretiens'),
    ];
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (dialog, update) => AlertDialog(
          title: const Text('Personnaliser mon dashboard'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (id, label) in choices)
                  SwitchListTile(
                    title: Text(label),
                    value: !hidden.contains(id),
                    onChanged: (show) =>
                        update(() => show ? hidden.remove(id) : hidden.add(id)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true) return;
    try {
      await api.putJson(
        '/api/v1/candidates/workspace/preferences',
        body: {'hidden_widgets': hidden.toList()},
      );
      await _loadWorkspaceSummary();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de sauvegarder les préférences : $error'),
          ),
        );
      }
    }
  }

  Widget _nextCandidateActions() {
    final data = _workspaceData;
    final bookmarks = (data?['bookmarks'] as List? ?? const [])
        .whereType<Map>()
        .where((entry) => entry['state'] == 'INTERESTED')
        .take(3)
        .toList();
    final notes = (data?['notes'] as List? ?? const [])
        .whereType<Map>()
        .where((entry) => entry['remind_at'] != null)
        .take(3)
        .toList();
    return _section(
      'Mes prochaines actions',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (data == null && _workspaceError == null)
            const LinearProgressIndicator()
          else if (_workspaceError != null)
            TextButton(
              onPressed: _loadWorkspaceSummary,
              child: const Text('Actualiser mes prochaines actions'),
            )
          else if (bookmarks.isEmpty && notes.isEmpty)
            const Text(
              'Aucune action en attente dans tes favoris ou tes rappels.',
            )
          else ...[
            for (final item in bookmarks)
              ListTile(
                dense: true,
                leading: const Icon(Icons.bookmark_added_outlined),
                title: Text('Préparer : ${item['title'] ?? 'candidature'}'),
                subtitle: Text('${item['company_name'] ?? ''}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openWorkspace(initialTab: 1),
              ),
            for (final item in notes)
              ListTile(
                dense: true,
                leading: const Icon(Icons.event_note_outlined),
                title: Text('Rappel : ${item['job_title'] ?? 'candidature'}'),
                subtitle: Text(
                  '${item['remind_at'] ?? ''}'.replaceFirst('T', ' '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openWorkspace(initialTab: 3),
              ),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _openWorkspace(initialTab: 1),
              icon: const Icon(Icons.folder_open_outlined),
              label: const Text('Organiser mes offres et candidatures'),
            ),
          ),
        ],
      ),
    );
  }

  Future<int> _loadProfileCompletion() async {
    final profile = await context.read<ProfileRepository>().fetchProfile();
    return ProfileCompletion.of(profile).percent;
  }

  Future<Map<String, dynamic>> _loadStats() async {
    final period = _period;
    final api = context.read<ApiClient?>();
    final repository = context.read<CandidateApplicationsRepository>();
    if (api != null) {
      final stats = Map<String, dynamic>.from(
        await api.getJson(
          '/api/v1/candidates/dashboard',
          query: {'period': period},
        ) as Map,
      );
      if (repository is ApiCandidateApplicationsRepository) {
        final pipeline = Map<String, dynamic>.from(stats['pipeline'] as Map);
        pipeline['interested'] =
            (pipeline['interested'] as int? ?? 0) +
            repository.interests.items.length;
        stats['pipeline'] = pipeline;
      }
      return stats;
    }

    final first = await repository.fetchApplications();
    final all = [
      ...first.items,
      for (var page = 2; page <= first.totalPages; page++)
        ...(await repository.fetchApplications(page: page)).items,
    ];
    final pipeline = <String, int>{
      'interested': 0,
      'sent': 0,
      'viewed': 0,
      'interview': 0,
    };
    final statuses = <String, int>{};
    final dates = <String, int>{};
    final threshold = DateTime.now().subtract(
      Duration(days: period == '7d' ? 7 : 30),
    );
    for (final item in all) {
      final step = switch (item.status.name) {
        'interested' => 'interested',
        'sent' => 'sent',
        'viewed' => 'viewed',
        'interview' => 'interview',
        _ => null,
      };
      if (step != null) pipeline.update(step, (value) => value + 1);
      if (item.status == ApplicationStatus.interested ||
          (period != 'all' && (item.appliedAt?.isBefore(threshold) ?? true))) {
        continue;
      }
      final date = item.appliedAt?.toLocal();
      if (date != null) {
        final bucket = DateTime(
          date.year,
          date.month,
          period == 'all' ? 1 : date.day,
        ).toIso8601String().split('T').first;
        dates.update(bucket, (n) => n + 1, ifAbsent: () => 1);
      }
      statuses.update(
        item.status.name.toUpperCase(),
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    return {
      'period': period,
      'pipeline': pipeline,
      'trend': [
        for (final day in dates.keys.toList()..sort())
          {'date': day, 'applications': dates[day], 'interviews': 0},
      ],
      'applications': {'total': statuses.values.fold<int>(0, (a, b) => a + b)},
      'interviews': {
        'upcoming': all
            .where((a) => a.interviewAt?.isAfter(DateTime.now()) ?? false)
            .length,
      },
    };
  }

  Future<void> _refresh() async {
    setState(() {
      _stats = _loadStats();
      _profileCompletion = _loadProfileCompletion();
    });
    await _loadWorkspaceSummary();
    await _stats.then<void>((_) {}, onError: (Object _) {});
  }

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiClient?>();
    final notifications = context.watch<NotificationsController>();
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: !widget.mobile
          ? null
          : AppBar(
              title: const Text('Tableau de bord'),
              actions: [
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () =>
                      showNotificationsPanel(context, asSheet: true),
                  icon: Badge(
                    isLabelVisible: notifications.unreadCount > 0,
                    label: Text('${notifications.unreadCount}'),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                ),
                IconButton(
                  tooltip: 'Paramètres',
                  onPressed: () => context.go(AppRoutes.candidateSettings),
                  icon: const Icon(Icons.settings_outlined),
                ),
                const CandidateAccountMenu(icon: Icon(Icons.person_outline)),
              ],
            ),
      bottomNavigationBar: !widget.mobile
          ? null
          : CandidateMobileNavigation(
              current: CandidateMobileTab.home,
              unreadMessages: notifications.unreadMessages,
            ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (!widget.mobile)
                ColoredBox(
                  color: const Color(0xFF001E3B),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width < 600 ? 12 : 28,
                      vertical: 14,
                    ),
                    child: DashboardTopBar(isWide: width >= 950),
                  ),
                ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: EdgeInsets.all(width < 600 ? 14 : 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        StudentDashboardHero(
                          actions: [
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8055),
                                foregroundColor: const Color(0xFF102E48),
                              ),
                              onPressed: () =>
                                  context.go(AppRoutes.candidateDiscover),
                              icon: const Icon(Icons.explore_outlined),
                              label: const Text('Explorer les offres'),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                              ),
                              onPressed: () =>
                                  context.go(AppRoutes.candidateApplications),
                              child: const Text('Mes candidatures'),
                            ),
                            if (api != null)
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white54),
                                ),
                                onPressed: () => _openWorkspace(),
                                icon: const Icon(Icons.bookmarks_outlined),
                                label: const Text('Explorer et organiser'),
                              ),
                            if (api != null)
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  final target = _agenda.currentContext;
                                  if (target != null) {
                                    Scrollable.ensureVisible(
                                      target,
                                      duration: _motion,
                                    );
                                  }
                                },
                                child: const Text('Mes entretiens'),
                              ),
                          ],
                        ),
                        if (api != null) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _customizeDashboard,
                              icon: const Icon(Icons.tune_outlined),
                              label: const Text('Personnaliser les widgets'),
                            ),
                          ),
                          if (!_hiddenDashboardWidgets.contains('actions')) ...[
                            const SizedBox(height: 12),
                            _nextCandidateActions(),
                          ],
                        ],
                        if (!_hiddenDashboardWidgets.contains('activity')) ...[
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Mon activité',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              for (final (id, title) in [
                                ('7d', '7 jours'),
                                ('30d', '30 jours'),
                                ('all', 'Tout'),
                              ])
                                ChoiceChip(
                                  label: Text(title),
                                  selected: _period == id,
                                  onSelected: (_) => setState(() {
                                    _period = id;
                                    _stats = _loadStats();
                                  }),
                                ),
                              IconButton(
                                tooltip: 'Actualiser les statistiques',
                                onPressed: _refresh,
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                          FutureBuilder(
                            future: _stats,
                            builder: (context, snapshot) {
                              final loading =
                                  snapshot.connectionState ==
                                  ConnectionState.waiting;
                              if (loading && !snapshot.hasData) {
                                return const LinearProgressIndicator();
                              }
                              if (snapshot.hasError || !snapshot.hasData) {
                                return TextButton(
                                  onPressed: _refresh,
                                  child: const Text(
                                    'Statistiques indisponibles · Réessayer',
                                  ),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    height: 4,
                                    child: loading
                                        ? const LinearProgressIndicator()
                                        : null,
                                  ),
                                  const SizedBox(height: 10),
                                  _statistics(
                                    snapshot.data!,
                                    notifications.unreadMessages,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                        if (!_hiddenDashboardWidgets.contains('profile')) ...[
                          const SizedBox(height: 14),
                          _section(
                            'Mon profil',
                            FutureBuilder(
                              future: _profileCompletion,
                              builder: (context, snapshot) {
                                final percent = snapshot.data;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (percent != null) ...[
                                      Text('Profil complété à $percent %'),
                                      const SizedBox(height: 8),
                                      TweenAnimationBuilder<double>(
                                        tween: Tween(
                                          begin: 0,
                                          end: percent / 100,
                                        ),
                                        duration: _motion,
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, _) =>
                                            LinearProgressIndicator(
                                              value: value,
                                              minHeight: 8,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: () => context.go(
                                        AppRoutes.candidateProfile,
                                      ),
                                      icon: const Icon(Icons.person_outline),
                                      label: const Text('Voir mon profil'),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                        if (api != null &&
                            !_hiddenDashboardWidgets.contains('interviews'))
                          KeyedSubtree(
                            key: _agenda,
                            child: _section(
                              'Mes entretiens',
                              InterviewAgenda(
                                api: api,
                                onChanged: () =>
                                    setState(() => _stats = _loadStats()),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Duration get _motion => MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 360);

  Widget _statistics(Map<String, dynamic> data, int unread) {
    final applications = data['applications'] as Map? ?? const {};
    final interviews = data['interviews'] as Map? ?? const {};
    final pipeline = data['pipeline'] as Map? ?? const {};
    final messages = data['conversations'] as Map? ?? const {};
    final activity = data['recent_activities'] as List? ?? const [];
    final matches = (data['recent_matches'] as List? ?? const [])
        .whereType<Map>();
    final colors = Theme.of(context).colorScheme;
    final stages = [
      ('Offres repérées', pipeline['interested'] as int? ?? 0),
      ('Envoyées', pipeline['sent'] as int? ?? 0),
      ('En cours', pipeline['viewed'] as int? ?? 0),
      ('Entretiens', pipeline['interview'] as int? ?? 0),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, limits) {
            final columns = limits.maxWidth >= 780 ? 4 : 2;
            final tileWidth = (limits.maxWidth - 10 * (columns - 1)) / columns;
            return Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                for (final (label, count, icon, accent, destination) in [
                  (
                    'Candidatures envoyées',
                    applications['total'],
                    Icons.send_outlined,
                    const Color(0xFF137DB8),
                    AppRoutes.candidateApplications,
                  ),
                  (
                    'Entretiens à venir',
                    interviews['upcoming'],
                    Icons.calendar_today_outlined,
                    const Color(0xFFC4542C),
                    null,
                  ),
                  (
                    'Messages non lus',
                    messages['unread_messages'] ?? unread,
                    Icons.chat_bubble_outline,
                    const Color(0xFF7457BD),
                    AppRoutes.candidateMessages,
                  ),
                  (
                    'Nouvelles offres',
                    data['new_offers_count'],
                    Icons.work_outline,
                    const Color(0xFF137D77),
                    AppRoutes.candidateDiscover,
                  ),
                ])
                  SizedBox(
                    width: tileWidth,
                    child: Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap:
                            destination == null &&
                                context.read<ApiClient?>() == null
                            ? null
                            : () {
                                if (destination != null) {
                                  context.go(destination);
                                } else if (_agenda.currentContext
                                    case final anchor?) {
                                  Scrollable.ensureVisible(
                                    anchor,
                                    duration: _motion,
                                  );
                                }
                              },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 17,
                                    backgroundColor: accent.withValues(
                                      alpha: .14,
                                    ),
                                    foregroundColor: accent,
                                    child: Icon(icon, size: 17),
                                  ),
                                  const Spacer(),
                                  if (destination != null ||
                                      context.read<ApiClient?>() != null)
                                    Icon(
                                      Icons.arrow_outward_rounded,
                                      size: 15,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TweenAnimationBuilder<int>(
                                tween: IntTween(
                                  begin: 0,
                                  end: (count as num?)?.toInt() ?? 0,
                                ),
                                duration: _motion,
                                curve: Curves.easeOutCubic,
                                builder: (context, number, _) => Text(
                                  count == null ? '—' : '$number',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ),
                              Text(label),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        if (interviews['next'] case final Map next)
          Card(
            child: ListTile(
              leading: const Icon(Icons.event_available_outlined),
              title: Text('${next['job_title'] ?? 'Prochain entretien'}'),
              subtitle: Text(
                [
                  'Prochain entretien',
                  if (next['company_name'] != null) '${next['company_name']}',
                  if (DateTime.tryParse('${next['scheduled_at']}')
                      case final date?)
                    MaterialLocalizations.of(context)
                        .formatShortDate(date.toLocal()),
                ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (_agenda.currentContext case final anchor?) {
                  Scrollable.ensureVisible(anchor, duration: _motion);
                }
              },
            ),
          ),
        const SizedBox(height: 12),
        StudentActivityCharts(
          trend: (data['trend'] as List? ?? const []).whereType<Map>().toList(),
          stages: stages,
          period: data['period'] as String? ?? _period,
        ),
        if (matches.isNotEmpty)
          _section(
            'Mes derniers matchs',
            Column(
              children: [
                for (final match in matches.take(3))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.onPrimaryContainer,
                      child: const Icon(Icons.handshake_outlined),
                    ),
                    title: Text('${match['job_title'] ?? 'Offre'}'),
                    subtitle: Text(
                      [
                        if (match['company_name'] case final String company)
                          company,
                        if (match['compatibility_score'] case final num score)
                          '${score.round()} % de compatibilité',
                      ].join(' · '),
                    ),
                    trailing: match['conversation_id'] == null
                        ? null
                        : IconButton(
                            tooltip: 'Ouvrir la discussion',
                            icon: const Icon(Icons.chat_bubble_outline),
                            onPressed: () => context.go(
                              AppRoutes.candidateConversation(
                                '${match['conversation_id']}',
                              ),
                            ),
                          ),
                  ),
              ],
            ),
          ),
        if (activity.isNotEmpty)
          _section(
            'Activité récente',
            Column(
              children: [
                for (final item in activity.whereType<Map>().take(5))
                  _activityEntry(item),
              ],
            ),
          ),
      ],
    );
  }

  Widget _activityEntry(Map item) {
    final (label, icon, route) = switch (item['type']) {
      'APPLICATION_SENT' => (
        'Candidature envoyée',
        Icons.send_outlined,
        AppRoutes.candidateApplications,
      ),
      'APPLICATION_VIEWED' => (
        'Candidature consultée',
        Icons.visibility_outlined,
        AppRoutes.candidateApplications,
      ),
      'OFFER_LIKED' => (
        'Offre repérée',
        Icons.bookmark_outline,
        AppRoutes.candidateDiscover,
      ),
      'MATCH' => (
        'Nouveau match',
        Icons.handshake_outlined,
        AppRoutes.candidateDiscover,
      ),
      'MESSAGE_RECEIVED' => (
        'Message reçu',
        Icons.chat_bubble_outline,
        AppRoutes.candidateMessages,
      ),
      'INTERVIEW_PLANNED' => (
        'Entretien proposé',
        Icons.event_available_outlined,
        null,
      ),
      _ => ('Mise à jour', Icons.history, null),
    };
    final colors = Theme.of(context).colorScheme;
    final date = DateTime.tryParse('${item['occurred_at']}')?.toLocal();
    final details = [
      item['job_title'],
      item['company_name'],
      if (date != null) MaterialLocalizations.of(context).formatShortDate(date),
    ].whereType<String>().join(' · ');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: colors.secondaryContainer,
        foregroundColor: colors.onSecondaryContainer,
        child: Icon(icon, size: 19),
      ),
      title: Text(label),
      subtitle: details.isEmpty ? null : Text(details),
      trailing: route != null ? const Icon(Icons.chevron_right_rounded) : null,
      onTap: route != null ? () => context.go(route) : null,
    );
  }

  Widget _section(String name, Widget content) => Card(
    margin: const EdgeInsets.only(top: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          content,
        ],
      ),
    ),
  );
}
