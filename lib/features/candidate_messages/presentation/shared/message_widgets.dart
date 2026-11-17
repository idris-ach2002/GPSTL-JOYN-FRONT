import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../../messaging/domain/conversation.dart';
import '../controllers/candidate_messages_controller.dart';

/// Libellés de date compacts : « 14:32 », « hier », « 09/10 ».
abstract final class MessageDates {
  static String short(DateTime? date, DateTime now) {
    if (date == null) return '';
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return time(date);
    if (diff == 1) return 'hier';
    return '${_two(date.day)}/${_two(date.month)}';
  }

  static String time(DateTime date) =>
      '${_two(date.hour)}:${_two(date.minute)}';

  static String day(DateTime date, DateTime now) {
    final diff = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;
    if (diff == 0) return 'Aujourd’hui';
    if (diff == 1) return 'Hier';
    return '${_two(date.day)}/${_two(date.month)}/${date.year}';
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}

/// Pastille carrée avec l'initiale de l'entreprise.
class CompanyBadge extends StatelessWidget {
  const CompanyBadge({
    super.key,
    required this.name,
    this.size = 44,
    this.locked = false,
    this.dot = false,
  });

  final String name;
  final double size;
  final bool locked;

  /// Point orange : messages non lus.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return SizedBox.square(
      dimension: size + 4,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: locked ? AppColors.slate : AppColors.navy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              initial,
              style: TextStyle(
                fontFamily: AppFonts.display,
                color: AppColors.white,
                fontSize: size * 0.42,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (locked)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.warningTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 11,
                  color: AppColors.warningDeep,
                ),
              ),
            ),
          if (dot)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ligne de la liste des conversations.
class ThreadTile extends StatelessWidget {
  const ThreadTile({
    super.key,
    required this.thread,
    required this.now,
    required this.selected,
    required this.onTap,
  });

  final MessageThread thread;
  final DateTime now;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = thread.unread > 0;
    final previewColor = switch (thread.state) {
      ThreadState.locked => AppColors.warningDeep,
      ThreadState.startable => AppColors.successDeep,
      ThreadState.open => AppColors.slate,
    };
    return Material(
      color: selected ? AppColors.skyTint : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CompanyBadge(
                name: thread.companyName,
                locked: thread.state == ThreadState.locked,
                dot: unread,
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
                            thread.companyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: unread
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          MessageDates.short(thread.at, now),
                          style: const TextStyle(
                            fontFamily: AppFonts.body,
                            color: AppColors.slate,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      thread.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        color: unread ? AppColors.textPrimary : previewColor,
                        fontSize: 13,
                        fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pastille d'état dans l'en-tête du fil.
class ThreadStatusChip extends StatelessWidget {
  const ThreadStatusChip({super.key, required this.state});

  final ThreadState state;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (state) {
      ThreadState.locked => (
        'En attente de réponse',
        AppColors.warningTint,
        AppColors.warningDeep,
      ),
      ThreadState.startable => (
        'Entretien proposé',
        AppColors.successTint,
        AppColors.successDeep,
      ),
      ThreadState.open => (
        'Conversation ouverte',
        AppColors.skyTint,
        AppColors.navy,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.body,
            color: fg,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Bulle de message.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, this.onRetry});

  final ChatMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final mine = message.fromMe;
    final status = switch (message.delivery) {
      MessageDelivery.sending => 'Envoi…',
      MessageDelivery.failed => 'Échec de l’envoi',
      MessageDelivery.sent =>
        mine ? (message.readAt != null ? 'Lu' : 'Envoyé') : '',
    };
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          crossAxisAlignment: mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!mine && message.senderName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 4),
                child: Text(
                  message.senderName,
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    color: AppColors.slate,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Opacity(
              opacity: message.delivery == MessageDelivery.sending ? 0.7 : 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: mine ? AppColors.navy : AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(mine ? 20 : 6),
                    bottomRight: Radius.circular(mine ? 6 : 20),
                  ),
                  border: mine ? null : Border.all(color: AppColors.lineSoft),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      color: mine ? AppColors.white : AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    [
                      MessageDates.time(message.createdAt),
                      if (status.isNotEmpty) status,
                    ].join(' · '),
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      color: message.delivery == MessageDelivery.failed
                          ? AppColors.errorDeep
                          : AppColors.slate,
                      fontSize: 11,
                    ),
                  ),
                  if (message.delivery == MessageDelivery.failed &&
                      onRetry != null)
                    TextButton(
                      onPressed: onRetry,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: AppColors.errorDeep,
                      ),
                      child: const Text('Réessayer'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Séparateur de jour (« Aujourd’hui », « Hier », date).
class DayDivider extends StatelessWidget {
  const DayDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.skyTint,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Zone de saisie, ou bandeau expliquant pourquoi on ne peut pas écrire.
class ConversationFooter extends StatefulWidget {
  const ConversationFooter({
    super.key,
    required this.thread,
    required this.busy,
    required this.onSend,
    required this.onStart,
  });

  final MessageThread thread;
  final bool busy;
  final ValueChanged<String> onSend;
  final VoidCallback onStart;

  @override
  State<ConversationFooter> createState() => _ConversationFooterState();
}

class _ConversationFooterState extends State<ConversationFooter> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.thread.state) {
      case ThreadState.locked:
        return _InfoBanner(
          icon: Icons.lock_rounded,
          title: 'Ta candidature et ton CV sont bien partis',
          body:
              'Tu pourras écrire à ${widget.thread.companyName} dès que '
              'l’entreprise t’aura proposé un entretien.',
        );
      case ThreadState.startable:
        return _InfoBanner(
          icon: Icons.event_available_rounded,
          title: '${widget.thread.companyName} t’a proposé un entretien',
          body: 'Démarre la conversation pour échanger avec le recruteur.',
          action: FilledButton.icon(
            onPressed: widget.busy ? null : widget.onStart,
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text('Démarrer la conversation'),
          ),
        );
      case ThreadState.open:
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                maxLength: 2000,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  hintText: 'Écris ton message…',
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              tooltip: 'Envoyer',
              onPressed: _submit,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
                minimumSize: const Size.square(48),
              ),
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        );
    }
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.skyTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      color: AppColors.slate,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (action != null) ...[const SizedBox(width: 12), action!],
          ],
        ),
      ),
    );
  }
}

/// Fil complet : en-tête, messages, pied (saisie ou bandeau).
class ConversationPane extends StatelessWidget {
  const ConversationPane({
    super.key,
    required this.controller,
    required this.thread,
    required this.now,
    this.onBack,
    this.onViewOffer,
    this.compact = false,
  });

  final CandidateMessagesController controller;
  final MessageThread thread;
  final DateTime now;
  final VoidCallback? onBack;
  final VoidCallback? onViewOffer;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final messages = controller.messages;
    final items = <Widget>[];
    DateTime? lastDay;
    for (final m in messages) {
      final day = DateTime(
        m.createdAt.year,
        m.createdAt.month,
        m.createdAt.day,
      );
      if (lastDay != day) {
        items.add(DayDivider(label: MessageDates.day(m.createdAt, now)));
        lastDay = day;
      }
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: MessageBubble(message: m, onRetry: () => controller.retry(m)),
        ),
      );
    }

    final application = thread.application;
    final header = Padding(
      padding: EdgeInsets.fromLTRB(compact ? 8 : 22, 14, compact ? 14 : 22, 14),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              tooltip: 'Retour',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          CompanyBadge(name: thread.companyName, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.display,
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  thread.offerTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    color: AppColors.slate,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!compact) ...[
            ThreadStatusChip(state: thread.state),
            if (onViewOffer != null) ...[
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onViewOffer,
                child: const Text('Mes candidatures'),
              ),
            ],
          ],
        ],
      ),
    );

    final body = switch (thread.state) {
      ThreadState.open when controller.loadingMessages && messages.isEmpty =>
        const Center(child: CircularProgressIndicator()),
      ThreadState.open when messages.isEmpty => const _EmptyThread(
        text:
            'La conversation est ouverte. Présente-toi et demande les '
            'prochaines étapes à l’entreprise.',
      ),
      ThreadState.open => ListView(
        reverse: true,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        children: [
          ...items.reversed,
          if (controller.hasOlder)
            Center(
              child: TextButton(
                onPressed: controller.loadOlder,
                child: const Text('Messages précédents'),
              ),
            ),
        ],
      ),
      _ => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (application?.appliedAt != null)
            DayDivider(
              label:
                  'Candidature envoyée le '
                  '${MessageDates.day(application!.appliedAt!, now).toLowerCase()}',
            ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Ton message et ton CV ont été transmis avec la candidature.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.body,
                color: AppColors.slate,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    };

    return Column(
      children: [
        header,
        const Divider(height: 1, color: AppColors.lineSoft),
        Expanded(
          child: ColoredBox(color: AppColors.surfaceSubtle, child: body),
        ),
        const Divider(height: 1, color: AppColors.lineSoft),
        Padding(
          padding: EdgeInsets.all(compact ? 12 : 18),
          child: ConversationFooter(
            key: ValueKey('footer-${thread.id}'),
            thread: thread,
            busy: controller.busy,
            onSend: controller.send,
            onStart: () => controller.start(thread),
          ),
        ),
      ],
    );
  }
}

class _EmptyThread extends StatelessWidget {
  const _EmptyThread({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppFonts.body,
            color: AppColors.slate,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

/// Liste des fils avec recherche.
class ThreadList extends StatelessWidget {
  const ThreadList({
    super.key,
    required this.controller,
    required this.now,
    required this.onOpen,
  });

  final CandidateMessagesController controller;
  final DateTime now;
  final ValueChanged<MessageThread> onOpen;

  @override
  Widget build(BuildContext context) {
    final threads = controller.threads;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
          child: TextField(
            onChanged: controller.search,
            decoration: const InputDecoration(
              hintText: 'Rechercher une entreprise ou une offre',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        Expanded(
          child: threads.isEmpty
              ? const _EmptyThread(
                  text:
                      'Aucune conversation pour l’instant. Elles apparaissent '
                      'ici dès que tu postules.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                  itemCount: threads.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, i) => ThreadTile(
                    thread: threads[i],
                    now: now,
                    selected: controller.selected?.id == threads[i].id,
                    onTap: () => onOpen(threads[i]),
                  ),
                ),
        ),
      ],
    );
  }
}
