import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/navigation/candidate_entrance.dart';
import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../domain/app_notification.dart';
import '../notifications_controller.dart';

/// Page de l'espace candidat vers laquelle mène une notification.
String? candidateRouteFor(NotificationKind kind) => switch (kind) {
  NotificationKind.newMessage => AppRoutes.candidateMessages,
  NotificationKind.interview => AppRoutes.dashboard,
  NotificationKind.applicationUpdate => AppRoutes.candidateApplications,
  NotificationKind.newMatch ||
  NotificationKind.newOffer ||
  NotificationKind.recommendation => AppRoutes.candidateDiscover,
  _ => null,
};

/// Ouvre les notifications : panneau à droite (Web) ou feuille (Mobile).
Future<void> showNotificationsPanel(
  BuildContext context, {
  required bool asSheet,
}) {
  final controller = context.read<NotificationsController>();
  controller.load(silent: controller.items.isNotEmpty);
  final router = GoRouter.of(context);

  void open(AppNotification n, BuildContext sheetContext) {
    controller.markRead(n);
    final conversation = n.kind == NotificationKind.newMessage
        ? RegExp(r'^/conversations/(\d+)$').firstMatch(n.link ?? '')?.group(1)
        : null;
    final route = conversation == null
        ? candidateRouteFor(n.kind)
        : Uri(
            path: AppRoutes.candidateMessages,
            queryParameters: {'conversation': conversation},
          ).toString();
    Navigator.of(sheetContext).pop();
    if (route != null) router.go(route);
  }

  Widget panel(BuildContext ctx) => ChangeNotifierProvider.value(
    value: controller,
    child: JoynMaterialScope(
      child: NotificationsPanel(onOpen: (n) => open(n, ctx)),
    ),
  );

  if (asSheet) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) =>
          FractionallySizedBox(heightFactor: 0.8, child: panel(ctx)),
    );
  }
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black12,
    builder: (ctx) => Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 72, 32, 16),
        child: Material(
          color: AppColors.surface,
          elevation: 8,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: 520,
            height: 655,
            child: CandidateEntrance(child: panel(ctx)),
          ),
        ),
      ),
    ),
  );
}

/// Liste des notifications avec actions « Tout marquer comme lu ».
class NotificationsPanel extends StatefulWidget {
  const NotificationsPanel({super.key, required this.onOpen});

  final ValueChanged<AppNotification> onOpen;

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  bool _unreadOnly = false;
  NotificationKind? _kind;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationsController>();
    final items = controller.items
        .where(
          (item) =>
              (!_unreadOnly || !item.isRead) &&
              (_kind == null || _kind == item.kind) &&
              '${item.title} ${item.message}'.toLowerCase().contains(_query),
        )
        .toList();
    final colors = Theme.of(context).colorScheme;
    final today = DateUtils.dateOnly(DateTime.now());
    String group(DateTime date) {
      final day = DateUtils.dateOnly(date.toLocal());
      if (day == today) return 'Aujourd’hui';
      if (day == DateTime(today.year, today.month, today.day - 1)) {
        return 'Hier';
      }
      return 'Plus anciennes';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 10, 10),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                child: const Icon(Icons.notifications_active_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Centre de notifications',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${controller.unreadCount} non lue(s)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Gérer les notifications',
                onSelected: (action) async {
                  if (action == 'read') await controller.markAllRead();
                  if (action == 'refresh') await controller.load();
                  if (action == 'clear' && context.mounted) {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialog) => AlertDialog(
                        title: const Text('Supprimer les notifications lues ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialog, false),
                            child: const Text('Annuler'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(dialog, true),
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      try {
                        await controller.deleteRead();
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Suppression indisponible.'),
                            ),
                          );
                        }
                      }
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'read',
                    child: Text('Tout marquer comme lu'),
                  ),
                  PopupMenuItem(
                    value: 'clear',
                    child: Text('Supprimer les notifications lues'),
                  ),
                  PopupMenuItem(value: 'refresh', child: Text('Actualiser')),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                tooltip: 'Fermer',
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (value) =>
                setState(() => _query = value.toLowerCase().trim()),
            decoration: const InputDecoration(
              hintText: 'Rechercher une notification',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Non lues'),
                selected: _unreadOnly,
                onSelected: (value) => setState(() => _unreadOnly = value),
              ),
              for (final (kind, label) in [
                (NotificationKind.interview, 'Entretiens'),
                (NotificationKind.newMessage, 'Messages'),
                (NotificationKind.applicationUpdate, 'Candidatures'),
                (NotificationKind.newOffer, 'Offres'),
              ])
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: _kind == kind,
                    onSelected: (value) =>
                        setState(() => _kind = value ? kind : null),
                  ),
                ),
            ],
          ),
        ),
        if (controller.error != null)
          TextButton(
            onPressed: controller.load,
            child: Text(controller.error!),
          ),
        Expanded(
          child: CandidateEntrance(
            key: ValueKey((_kind, _unreadOnly)),
            child: controller.loading && items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aucune notification à afficher.'),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final header = group(item.createdAt);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (i == 0 || group(items[i - 1].createdAt) != header)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                              child: Text(
                                header,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                          Card(
                            color: item.isRead
                                ? colors.surface
                                : colors.primaryContainer.withValues(
                                    alpha: .36,
                                  ),
                            child: NotificationTile(
                              notification: item,
                              onTap: () => widget.onOpen(item),
                              onDelete: () => controller.delete(item),
                              onToggleRead: () => item.isRead
                                  ? controller.markUnread(item)
                                  : controller.markRead(item),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

/// Une notification : icône selon le type, titre, texte, ancienneté.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
    required this.onToggleRead,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleRead;

  static (IconData, Color, Color) _style(NotificationKind kind) =>
      switch (kind) {
        NotificationKind.newMessage => (
          Icons.chat_bubble_rounded,
          AppColors.skyTint,
          AppColors.navy,
        ),
        NotificationKind.interview => (
          Icons.event_available_rounded,
          AppColors.successTint,
          AppColors.successDeep,
        ),
        NotificationKind.newMatch ||
        NotificationKind.recommendation ||
        NotificationKind.newOffer => (
          Icons.favorite_rounded,
          AppColors.orangeTint,
          AppColors.orange,
        ),
        NotificationKind.applicationUpdate || NotificationKind.newApplication =>
          (Icons.article_rounded, AppColors.warningTint, AppColors.warningDeep),
        NotificationKind.system => (
          Icons.info_rounded,
          AppColors.skyTint,
          AppColors.slate,
        ),
      };

  static String ago(DateTime date, DateTime now) {
    final d = now.difference(date);
    if (d.inMinutes < 1) return 'à l’instant';
    if (d.inMinutes < 60) return 'il y a ${d.inMinutes} min';
    if (d.inHours < 24) return 'il y a ${d.inHours} h';
    if (d.inDays == 1) return 'hier';
    return 'il y a ${d.inDays} j';
  }

  @override
  Widget build(BuildContext context) {
    final (icon, bg, fg) = _style(notification.kind);
    final unread = !notification.isRead;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: bg,
              child: Icon(icon, size: 18, color: fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: unread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (notification.message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        color: AppColors.slate,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    ago(notification.createdAt, DateTime.now()),
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      color: AppColors.placeholder,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Actions de la notification',
              onSelected: (value) =>
                  value == 'delete' ? onDelete() : onToggleRead(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'read',
                  child: Text(
                    unread ? 'Marquer comme lue' : 'Marquer comme non lue',
                  ),
                ),
                const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
