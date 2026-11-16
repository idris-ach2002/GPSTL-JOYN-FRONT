import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../domain/app_notification.dart';
import '../notifications_controller.dart';

/// Page de l'espace candidat vers laquelle mène une notification.
String? candidateRouteFor(NotificationKind kind) => switch (kind) {
  NotificationKind.newMessage => AppRoutes.candidateMessages,
  NotificationKind.interview ||
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
    final route = candidateRouteFor(n.kind);
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
          child: SizedBox(width: 400, height: 520, child: panel(ctx)),
        ),
      ),
    ),
  );
}

/// Liste des notifications avec actions « Tout marquer comme lu ».
class NotificationsPanel extends StatelessWidget {
  const NotificationsPanel({super.key, required this.onOpen});

  final ValueChanged<AppNotification> onOpen;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationsController>();
    final items = controller.items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.unreadCount == 0
                    ? null
                    : controller.markAllRead,
                child: const Text('Tout marquer comme lu'),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.lineSoft),
        Expanded(
          child: controller.loading && items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      controller.error ?? 'Aucune notification pour l’instant.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        color: AppColors.slate,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, i) => NotificationTile(
                    notification: items[i],
                    onTap: () => onOpen(items[i]),
                    onDelete: () => controller.delete(items[i]),
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
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

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
            IconButton(
              tooltip: 'Supprimer',
              onPressed: onDelete,
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppColors.slate,
            ),
          ],
        ),
      ),
    );
  }
}
