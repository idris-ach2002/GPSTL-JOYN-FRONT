import 'student_activity_charts.dart';
import '../../candidate_applications/data/api_candidate_applications_repository.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _stats = _loadStats();
    _profileCompletion = _loadProfileCompletion();
  }

  Future<int> _loadProfileCompletion() async {
    final profile = await context.read<ProfileRepository>().fetchProfile();
    return ProfileCompletion.of(profile).percent;
  }

  Future<Map<String, dynamic>> _loadStats() async {
    final api = context.read<ApiClient?>();
    final repository = context.read<CandidateApplicationsRepository>();
    if (api != null) {
      final stats = Map<String, dynamic>.from(
        await api.getJson(
          '/api/v1/candidates/dashboard',
          query: {'period': _period},
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
      Duration(days: _period == '7d' ? 7 : 30),
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
          (_period != 'all' && (item.appliedAt?.isBefore(threshold) ?? true))) {
        continue;
      }
      final date = item.appliedAt?.toLocal();
      if (date != null) {
        final bucket = DateTime(
          date.year,
          date.month,
          _period == 'all' ? 1 : date.day,
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
                        Container(
                          padding: EdgeInsets.all(width < 600 ? 22 : 34),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF052A4D), Color(0xFF1C6280)],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Suivi de mes candidatures',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 6),

                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                children: [
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
                                      side: const BorderSide(
                                        color: Colors.white54,
                                      ),
                                    ),
                                    onPressed: () => context.go(
                                      AppRoutes.candidateApplications,
                                    ),
                                    child: const Text('Mes candidatures'),
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
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Mes entretiens'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const LinearProgressIndicator();
                            }
                            if (!snapshot.hasData) {
                              return TextButton(
                                onPressed: _refresh,
                                child: const Text(
                                  'Statistiques indisponibles · Réessayer',
                                ),
                              );
                            }
                            return _statistics(
                              snapshot.data!,
                              notifications.unreadMessages,
                            );
                          },
                        ),
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
                                    LinearProgressIndicator(
                                      value: percent / 100,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      TextButton(
                                        onPressed: () => context.go(
                                          AppRoutes.candidateProfile,
                                        ),
                                        child: const Text('Voir mon profil'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () => context.go(
                                          AppRoutes.candidateProfileEdit,
                                        ),
                                        icon: const Icon(Icons.edit_outlined),
                                        label: const Text(
                                          'Modifier mon profil',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        if (api != null)
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

  Widget _statistics(Map<String, dynamic> data, int unread) {
    final applications = data['applications'] as Map? ?? const {};
    final interviews = data['interviews'] as Map? ?? const {};
    final pipeline = data['pipeline'] as Map? ?? const {};
    final messages = data['conversations'] as Map? ?? const {};
    final activity = data['recent_activities'] as List? ?? const [];
    final stages = [
      ('Intéressé', pipeline['interested'] as int? ?? 0),
      ('Envoyée', pipeline['sent'] as int? ?? 0),
      ('En cours', pipeline['viewed'] as int? ?? 0),
      ('Entretien', pipeline['interview'] as int? ?? 0),
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
                for (final (label, count, icon, destination) in [
                  (
                    'Candidatures envoyées',
                    applications['total'],
                    Icons.send_outlined,
                    AppRoutes.candidateApplications,
                  ),
                  (
                    'Entretiens à venir',
                    interviews['upcoming'],
                    Icons.calendar_today_outlined,
                    null,
                  ),
                  (
                    'Messages non lus',
                    messages['unread_messages'] ?? unread,
                    Icons.chat_bubble_outline,
                    AppRoutes.candidateMessages,
                  ),
                  (
                    'Nouvelles offres',
                    data['new_offers_count'],
                    Icons.work_outline,
                    AppRoutes.candidateDiscover,
                  ),
                ])
                  SizedBox(
                    width: tileWidth,
                    child: Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          if (destination != null) {
                            context.go(destination);
                          } else if (_agenda.currentContext
                              case final anchor?) {
                            Scrollable.ensureVisible(
                              anchor,
                              duration: const Duration(milliseconds: 250),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                icon,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Text(
                                '${count ?? '—'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
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
                  Scrollable.ensureVisible(
                    anchor,
                    duration: const Duration(milliseconds: 250),
                  );
                }
              },
            ),
          ),
        const SizedBox(height: 12),
        StudentActivityCharts(
          trend: (data['trend'] as List? ?? const []).whereType<Map>().toList(),
          stages: stages,
          period: _period,
        ),
        if (activity.isNotEmpty)
          _section(
            'Activité récente',
            Column(
              children: [
                for (final item in activity.whereType<Map>().take(5))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history),
                    title: Text(switch (item['type']) {
                      'APPLICATION_SENT' => 'Candidature envoyée',
                      'APPLICATION_VIEWED' => 'Candidature consultée',
                      'OFFER_LIKED' => 'Offre repérée',
                      'MATCH' => 'Nouveau match',
                      'MESSAGE_RECEIVED' => 'Message reçu',
                      'INTERVIEW_PLANNED' => 'Entretien proposé',
                      _ => 'Mise à jour',
                    }),
                    subtitle: Text(
                      [
                        item['job_title'],
                        item['company_name'],
                      ].whereType<String>().join(' · '),
                    ),
                  ),
              ],
            ),
          ),
      ],
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
