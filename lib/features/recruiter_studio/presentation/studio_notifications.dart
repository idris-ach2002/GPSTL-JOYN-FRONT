import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routing/app_routes.dart';
import '../../recruiter_workspace/presentation/workspace_controller.dart';
import 'studio_controller.dart';
import 'studio_components.dart';

class StudioNotifications extends StatefulWidget {
  const StudioNotifications({super.key});
  @override
  State<StudioNotifications> createState() => _StudioNotificationsState();
}

class _StudioNotificationsState extends State<StudioNotifications> {
  String _view = 'inbox', _kind = 'all', _search = '';
  final Set<String> _selected = {};
  Timer? _clock;
  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  bool _snoozed(StudioController c, String id) =>
      DateTime.tryParse('${c.object('snoozedNotifications')[id]}')
          ?.isAfter(DateTime.now()) ??
      false;
  @override
  Widget build(BuildContext context) {
    final c = context.watch<WorkspaceController>();
    final studio = context.watch<StudioController>();
    final archived = List<String>.from(
      studio.data['archivedNotifications'] as List? ?? [],
    );
    final now = DateTime.now();
    final items =
        c.notifications.where((n) {
          final id = '${n['id']}';
          final isArchived = archived.contains(id);
          final snoozed = _snoozed(studio, id);
          if (_view == 'archived'
              ? !isArchived
              : _view == 'snoozed'
              ? !snoozed || isArchived
              : isArchived || snoozed) {
            return false;
          }
          if (_view == 'unread' && n['read'] == true) return false;
          if (_view == 'pinned' &&
              !studio.contains('pinnedNotifications', id)) {
            return false;
          }
          if (_kind != 'all' && n['kind'] != _kind) return false;
          return '${n['title']} ${n['body'] ?? ''}'.toLowerCase().contains(
            _search,
          );
        }).toList()..sort((a, b) {
          final pin =
              (studio.contains('pinnedNotifications', '${b['id']}') ? 1 : 0) -
              (studio.contains('pinnedNotifications', '${a['id']}') ? 1 : 0);
          return pin != 0
              ? pin
              : '${b['createdAt']}'.compareTo('${a['createdAt']}');
        });
    final ids = items.map((n) => '${n['id']}').toSet();
    final selectedVisible = _selected.intersection(ids);
    final unreads = c.notifications
        .where(
          (n) =>
              n['read'] != true &&
              !archived.contains('${n['id']}') &&
              !_snoozed(studio, '${n['id']}'),
        )
        .length;
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth > 1000;
        final sidebar = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'VOTRE ACTIVITÉ',
              style: TextStyle(
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            for (final item in [
              ('inbox', 'Boîte de réception', Icons.inbox_outlined),
              ('unread', 'Non lues', Icons.mark_email_unread_outlined),
              ('pinned', 'Épinglées', Icons.push_pin_outlined),
              ('snoozed', 'Reportées', Icons.snooze_outlined),
              ('archived', 'Archives', Icons.archive_outlined),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  selected: _view == item.$1,
                  selectedTileColor: Theme.of(context).colorScheme.primary
                      .withValues(alpha: .12),
                  leading: Icon(item.$3),
                  title: Text(item.$2),
                  trailing: item.$1 == 'unread' && unreads > 0
                      ? Badge(label: Text('$unreads'))
                      : null,
                  onTap: () => setState(() {
                    _view = item.$1;
                    _selected.clear();
                  }),
                ),
              ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.recruiterSettings),
              icon: const Icon(Icons.tune),
              label: const Text('Mes préférences'),
            ),
          ],
        );
        final list = RefreshIndicator(
          onRefresh: () async {
            await c.load('notifications');
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              StudioCard(
                accent: true,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary
                            .withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.bolt_rounded,
                        size: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unreads == 0
                                ? 'Vous êtes à jour.'
                                : '$unreads ${unreads == 1 ? 'actualité à découvrir' : 'actualités à découvrir'}',
                            style: const TextStyle(
                              fontFamily: 'BricolageGrotesque',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Gardez le fil de vos rencontres et de vos recrutements.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (!wide)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final item in {
                        'inbox': 'Tout',
                        'unread': 'Non lues',
                        'pinned': 'Épinglées',
                        'snoozed': 'Reportées',
                        'archived': 'Archives',
                      }.entries)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(item.value),
                            selected: _view == item.key,
                            onSelected: (_) => setState(() {
                              _view = item.key;
                              _selected.clear();
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              const StudioLoadNotice(),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Rechercher dans les notifications',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) =>
                    setState(() => _search = v.toLowerCase().trim()),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in {
                    'all': 'Tous les événements',
                    'message': 'Messages',
                    'match': 'Matches',
                    'application': 'Candidatures',
                    'offer': 'Offres',
                  }.entries)
                    FilterChip(
                      label: Text(type.value),
                      selected: _kind == type.key,
                      onSelected: (_) => setState(() {
                        _kind = type.key;
                        _selected.clear();
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Checkbox(
                    value:
                        ids.isNotEmpty && selectedVisible.length == ids.length,
                    onChanged: ids.isEmpty
                        ? null
                        : (v) => setState(() {
                            if (v == true) {
                              _selected.addAll(ids);
                            } else {
                              _selected.removeAll(ids);
                            }
                          }),
                  ),
                  Text(
                    selectedVisible.isEmpty
                        ? '${items.length} notification${items.length > 1 ? 's' : ''}'
                        : '${selectedVisible.length} sélectionnée(s)',
                  ),
                  if (selectedVisible.isNotEmpty) ...[
                    TextButton.icon(
                      onPressed: c.busy
                          ? null
                          : () async {
                              await c.setRead(selectedVisible, true);
                              if (mounted) setState(_selected.clear);
                            },
                      icon: const Icon(Icons.done_all),
                      label: const Text('Marquer lues'),
                    ),
                    TextButton.icon(
                      onPressed: studio.saving
                          ? null
                          : () => _archive(
                              studio,
                              selectedVisible,
                              _view != 'archived',
                            ),
                      icon: Icon(
                        _view == 'archived'
                            ? Icons.unarchive_outlined
                            : Icons.archive_outlined,
                      ),
                      label: Text(
                        _view == 'archived' ? 'Restaurer' : 'Archiver',
                      ),
                    ),
                  ] else
                    TextButton.icon(
                      onPressed: c.busy || unreads == 0 ? null : c.readAll,
                      icon: const Icon(Icons.done_all),
                      label: const Text('Tout marquer comme lu'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty && !c.busy)
                StudioEmpty(
                  title: 'Rien à signaler ici',
                  message: _search.isNotEmpty
                      ? 'Essayez un autre mot ou un autre filtre.'
                      : 'Vos prochaines notifications apparaîtront dans cette rubrique.',
                  icon: Icons.notifications_paused_outlined,
                ),
              for (var index = 0; index < items.length; index++) ...[
                if (index == 0 ||
                    _group(items[index]['createdAt'], now) !=
                        _group(items[index - 1]['createdAt'], now))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _group(items[index]['createdAt'], now),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _notification(context, c, studio, items[index]),
                ),
              ],
            ],
          ),
        );
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 270,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: sidebar,
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  Expanded(child: list),
                ],
              )
            : list;
      },
    );
  }

  Widget _notification(
    BuildContext context,
    WorkspaceController c,
    StudioController studio,
    Map<String, dynamic> n,
  ) {
    final id = '${n['id']}';
    final unread = n['read'] != true;
    final icon = switch (n['kind']) {
      'message' => Icons.forum_outlined,
      'match' => Icons.handshake_outlined,
      'offer' => Icons.work_outline,
      _ => Icons.person_add_alt_outlined,
    };
    return StudioCard(
      accent: unread,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _selected.contains(id),
            onChanged: (v) => setState(() {
              v == true ? _selected.add(id) : _selected.remove(id);
            }),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${n['title']}',
                        style: TextStyle(
                          fontWeight: unread
                              ? FontWeight.w800
                              : FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (studio.contains('pinnedNotifications', id))
                      const Icon(Icons.push_pin, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  studio.preferences['notificationPreview'] == false &&
                          n['kind'] == 'message'
                      ? 'Le contenu de ce message est masqué par vos préférences.'
                      : '${n['body'] ?? ''}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    Text(
                      studioDate(n['createdAt']),
                      style: const TextStyle(fontSize: 11),
                    ),
                    TextButton(
                      onPressed: c.busy
                          ? null
                          : () async {
                              final ok = await c.readNotification(id);
                              if (!context.mounted || !ok) return;
                              final target = '${n['target']}';
                              if ({
                                AppRoutes.recruiterMessages,
                                AppRoutes.recruiterCandidates,
                                AppRoutes.recruiterJobs,
                                AppRoutes.recruiterProfile,
                                AppRoutes.recruiterDashboard,
                              }.contains(target)) {
                                context.go(target);
                              }
                            },
                      child: const Text('Consulter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Actions de notification',
            enabled: !c.busy && !studio.saving,
            onSelected: (v) async {
              switch (v) {
                case 'read':
                  await c.setRead([id], unread);
                case 'pin':
                  await studio.toggle('pinnedNotifications', id);
                case 'archive':
                  await _archive(studio, {id}, _view != 'archived');
                case 'snooze':
                  final values = studio.object('snoozedNotifications');
                  values[id] = DateTime.now()
                      .add(const Duration(hours: 24))
                      .toUtc()
                      .toIso8601String();
                  await studio.save('snoozedNotifications', values);
                case 'wake':
                  final values = studio.object('snoozedNotifications')
                    ..remove(id);
                  await studio.save('snoozedNotifications', values);
                case 'delete':
                  if (await studioConfirm(
                        context,
                        'Supprimer définitivement ?',
                        'Cette notification sera retirée de votre compte.',
                        action: 'Supprimer',
                      ) &&
                      context.mounted) {
                    await c.deleteNotification(id);
                  }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'read',
                child: Text(
                  unread ? 'Marquer comme lue' : 'Marquer comme non lue',
                ),
              ),
              PopupMenuItem(
                value: 'pin',
                child: Text(
                  studio.contains('pinnedNotifications', id)
                      ? 'Désépingler'
                      : 'Épingler',
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                child: Text(_view == 'archived' ? 'Restaurer' : 'Archiver'),
              ),
              PopupMenuItem(
                value: _view == 'snoozed' ? 'wake' : 'snooze',
                child: Text(
                  _view == 'snoozed'
                      ? 'Réafficher maintenant'
                      : 'Reporter de 24 h',
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Supprimer définitivement'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _archive(
    StudioController c,
    Set<String> ids,
    bool archive,
  ) async {
    final before = List<String>.from(
      c.data['archivedNotifications'] as List? ?? [],
    );
    final values = before.toSet();
    archive ? values.addAll(ids) : values.removeAll(ids);
    final ok = await c.save('archivedNotifications', values.toList());
    if (!mounted) return;
    if (ok) {
      setState(_selected.clear);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            archive ? 'Notifications archivées.' : 'Notifications restaurées.',
          ),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () => c.save('archivedNotifications', before),
          ),
        ),
      );
    } else {
      studioToast(context, 'Modification impossible. Réessayez.');
    }
  }

  String _group(Object? value, DateTime now) {
    final date = DateTime.tryParse('$value')?.toLocal();
    if (date == null) return 'Autres';
    final day = DateTime(now.year, now.month, now.day);
    final n = day.difference(DateTime(date.year, date.month, date.day)).inDays;
    return n <= 0
        ? 'Aujourd’hui'
        : n == 1
        ? 'Hier'
        : 'Plus tôt';
  }
}
