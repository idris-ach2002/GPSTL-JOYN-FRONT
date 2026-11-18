import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../candidate_applications/data/candidate_applications_repository.dart';
import '../../../candidate_applications/domain/candidate_application.dart';
import '../../../messaging/data/messaging_repository.dart';
import '../../../messaging/domain/conversation.dart';

/// Ce que le candidat peut faire dans un fil.
enum ThreadState {
  /// Conversation ouverte : on peut écrire.
  open,

  /// Entretien proposé mais pas encore de conversation : on peut la démarrer.
  startable,

  /// Candidature envoyée, l'entreprise n'a pas encore répondu : verrouillé.
  locked,
}

/// Une ligne de la liste « Messages » (conversation ou candidature en attente).
class MessageThread {
  const MessageThread({
    required this.id,
    required this.state,
    required this.companyName,
    required this.offerTitle,
    this.preview = '',
    this.at,
    this.unread = 0,
    this.conversation,
    this.application,
  });

  final String id;
  final ThreadState state;
  final String companyName;
  final String offerTitle;
  final String preview;
  final DateTime? at;
  final int unread;
  final Conversation? conversation;
  final CandidateApplication? application;

  MessageThread withUnread(int value) => MessageThread(
    id: id,
    state: state,
    companyName: companyName,
    offerTitle: offerTitle,
    preview: preview,
    at: at,
    unread: value,
    conversation: conversation,
    application: application,
  );
}

enum MessagesStatus { loading, ready, error }

/// État de la page « Messages » du candidat, partagé Web / Mobile.
///
/// Le back pousse aussi les nouveaux messages en temps réel (SSE), mais ce flux
/// exige l'en-tête `Authorization`, qu'un navigateur ne sait pas joindre à un
/// `EventSource`. En attendant, la page se rafraîchit toutes les
/// [pollInterval].
class CandidateMessagesController extends ChangeNotifier {
  CandidateMessagesController(
    this._messaging, {
    this.applicationsRepository,
    this.pollInterval = const Duration(seconds: 15),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final MessagingRepository _messaging;

  /// Candidatures, pour lister celles en attente de réponse ou d'entretien.
  final CandidateApplicationsRepository? applicationsRepository;
  final DateTime Function() _clock;

  /// `null` désactive le rafraîchissement automatique (tests).
  final Duration? pollInterval;
  Timer? _timer;
  bool _disposed = false;
  int _clientSeq = 0;
  int _selectionEpoch = 0;
  bool _refreshing = false;
  int _sending = 0;

  MessagesStatus _status = MessagesStatus.loading;
  MessagesStatus get status => _status;

  String? _error;
  String? get error => _error;

  List<MessageThread> _threads = const [];
  String _query = '';
  String get query => _query;
  bool _unreadOnly = false;
  bool get unreadOnly => _unreadOnly;

  void filterUnread(bool value) {
    _unreadOnly = value;
    notifyListeners();
  }

  /// Fils visibles, filtrés par la recherche.
  List<MessageThread> get threads {
    final q = _query.trim().toLowerCase();
    final eligible = _unreadOnly
        ? _threads.where((thread) => thread.unread > 0)
        : _threads;
    if (q.isEmpty) return eligible.toList();
    return eligible
        .where(
          (t) =>
              t.companyName.toLowerCase().contains(q) ||
              t.offerTitle.toLowerCase().contains(q) ||
              t.preview.toLowerCase().contains(q),
        )
        .toList();
  }

  int get totalUnread => _threads.fold(0, (sum, t) => sum + t.unread);

  String? _selectedId;
  MessageThread? get selected =>
      _threads.where((t) => t.id == _selectedId).firstOrNull;

  List<ChatMessage> _messages = const [];
  List<ChatMessage> get messages => _messages;

  bool _loadingMessages = false;
  bool get loadingMessages => _loadingMessages;

  bool _hasOlder = false;
  bool get hasOlder => _hasOlder;
  String? _cursor;

  bool _busy = false;

  /// Ouverture d'une conversation en cours.
  bool get busy => _busy;

  /// Message ponctuel à afficher (erreur d'ouverture, d'envoi…).
  String? notice;

  Future<void> load({String? select}) async {
    _status = MessagesStatus.loading;
    _error = null;
    _notify();
    try {
      await _reloadThreads();
      _status = MessagesStatus.ready;
      _startPolling();
    } catch (_) {
      _status = MessagesStatus.error;
      _error = 'Impossible de charger tes messages. Réessaie plus tard.';
    }
    _notify();
    final target = select ?? _selectedId;
    if (target != null && _status == MessagesStatus.ready) {
      await this.select(target);
    }
  }

  void search(String value) {
    _query = value;
    _notify();
  }

  /// Sélectionne un fil : id de conversation, de fil, ou de candidature.
  Future<void> select(String id) async {
    final thread = _threads
        .where(
          (t) =>
              t.id == id || t.conversation?.id == id || t.application?.id == id,
        )
        .firstOrNull;
    if (thread == null) return;
    _selectionEpoch++;
    _selectedId = thread.id;
    _messages = const [];
    _hasOlder = false;
    _loadingMessages = false;
    _cursor = null;
    _notify();
    if (thread.state == ThreadState.open) await _openMessages(thread);
  }

  /// Revient à la liste (Mobile).
  void unselect() {
    _selectionEpoch++;
    _selectedId = null;
    _loadingMessages = false;
    _messages = const [];
    _notify();
  }

  Future<void> _openMessages(MessageThread thread) async {
    final epoch = _selectionEpoch;
    final conversationId = thread.conversation!.id;
    _loadingMessages = true;
    _notify();
    try {
      final page = await _messaging.fetchMessages(conversationId);
      if (_disposed || epoch != _selectionEpoch || _selectedId != thread.id) {
        return;
      }
      _messages = page.messages;
      _hasOlder = page.hasMore;
      _cursor = page.nextCursor;
      if (thread.unread > 0) {
        await _messaging.markRead(conversationId);
        if (_disposed || epoch != _selectionEpoch) return;
        _replaceThread(thread.withUnread(0));
      }
    } catch (_) {
      if (!_disposed && epoch == _selectionEpoch) {
        notice = 'Impossible de charger cette conversation.';
      }
    } finally {
      if (epoch == _selectionEpoch) _loadingMessages = false;
      _notify();
    }
  }

  /// Charge les messages plus anciens du fil sélectionné.
  Future<void> loadOlder() async {
    final epoch = _selectionEpoch;
    final conversation = selected?.conversation;
    if (conversation == null || !_hasOlder || _loadingMessages) return;
    _loadingMessages = true;
    _notify();
    try {
      final page = await _messaging.fetchMessages(
        conversation.id,
        before: _cursor,
      );
      if (_disposed || epoch != _selectionEpoch) return;
      _messages = [...page.messages, ..._messages];
      _hasOlder = page.hasMore;
      _cursor = page.nextCursor;
    } catch (_) {
      if (!_disposed && epoch == _selectionEpoch) {
        notice = 'Impossible de charger les messages précédents.';
      }
    } finally {
      if (epoch == _selectionEpoch) _loadingMessages = false;
      _notify();
    }
  }

  /// Démarre la conversation d'une candidature au stade entretien.
  Future<void> start(MessageThread thread) async {
    final application = thread.application;
    if (application == null || _busy) return;
    final epoch = _selectionEpoch;
    _busy = true;
    _notify();
    try {
      final conversation = await _messaging.openForApplication(application.id);
      if (_disposed) return;
      final opened = _fromConversation(conversation, application);
      _threads = [
        opened,
        for (final t in _threads)
          if (t.id != thread.id) t,
      ];
      if (epoch != _selectionEpoch) return;
      _selectionEpoch++;
      _selectedId = opened.id;
      _messages = const [];
      await _openMessages(opened);
    } on MessagingException catch (e) {
      notice = e.message;
    } catch (_) {
      notice = 'Impossible d’ouvrir la conversation. Réessaie plus tard.';
    } finally {
      _busy = false;
      _notify();
    }
  }

  /// Envoie [text] dans le fil sélectionné (affichage immédiat).
  Future<void> send(String text) async {
    final trimmed = text.trim();
    final thread = selected;
    if (trimmed.isEmpty || thread?.state != ThreadState.open) return;
    final clientId = 'tmp-${_clock().microsecondsSinceEpoch}-${_clientSeq++}';
    final pending = ChatMessage(
      id: clientId,
      text: trimmed,
      fromMe: true,
      createdAt: _clock(),
      clientId: clientId,
      delivery: MessageDelivery.sending,
    );
    _messages = [..._messages, pending];
    _notify();
    await _deliver(thread!, pending);
  }

  /// Renvoie un message dont l'envoi a échoué.
  Future<void> retry(ChatMessage message) async {
    final thread = selected;
    if (thread == null || message.delivery != MessageDelivery.failed) return;
    _swap(
      message.clientId,
      message.copyWith(delivery: MessageDelivery.sending),
    );
    await _deliver(thread, message);
  }

  Future<void> _deliver(MessageThread thread, ChatMessage pending) async {
    _sending++;
    try {
      final saved = await _messaging.send(
        thread.conversation!.id,
        pending.text,
        clientId: pending.clientId!,
      );
      if (_disposed) return;
      if (_selectedId == thread.id) _swap(pending.clientId, saved);
      _replaceThread(
        MessageThread(
          id: thread.id,
          state: thread.state,
          companyName: thread.companyName,
          offerTitle: thread.offerTitle,
          preview: saved.text,
          at: saved.createdAt,
          conversation: thread.conversation,
          application: thread.application,
        ),
        moveToTop: true,
      );
    } catch (_) {
      if (_selectedId == thread.id) {
        _swap(
          pending.clientId,
          pending.copyWith(delivery: MessageDelivery.failed),
        );
      }
      notice = 'Envoi non confirmé. Vérifie le fil avant de renvoyer : un doublon est possible.';
    } finally {
      _sending--;
    }
    _notify();
  }

  /// Rafraîchit la liste et le fil ouvert sans écran de chargement.
  Future<void> refresh() async {
    if (_status != MessagesStatus.ready ||
        _busy ||
        _refreshing ||
        _sending > 0 ||
        _disposed) {
      return;
    }
    _refreshing = true;
    final epoch = _selectionEpoch;
    try {
      await _reloadThreads();
      if (_disposed || epoch != _selectionEpoch) return;
      final thread = selected;
      if (thread?.state == ThreadState.open && !_loadingMessages) {
        final page = await _messaging.fetchMessages(thread!.conversation!.id);
        if (_disposed || epoch != _selectionEpoch || _sending > 0) return;
        final pending = _messages.where(
          (m) => m.delivery != MessageDelivery.sent,
        );
        final known = {for (final m in _messages) m.id};
        final fresh = page.messages.where((m) => !known.contains(m.id));
        // Les messages déjà affichés sont remplacés par la version du back :
        // c'est ainsi que l'accusé « Lu » (readAt) apparaît sans recharger.
        final server = {for (final m in page.messages) m.id: m};
        final sent = _messages
            .where((m) => m.delivery == MessageDelivery.sent)
            .toList();
        final updated = [for (final m in sent) server[m.id] ?? m];
        final readChanged = updated.indexed.any(
          (e) => e.$2.readAt != sent[e.$1].readAt,
        );
        if (fresh.isNotEmpty || readChanged) {
          _messages = [...updated, ...fresh, ...pending];
        }
        if (thread.unread > 0 || fresh.any((m) => !m.fromMe)) {
          await _messaging.markRead(thread.conversation!.id);
          if (_disposed || epoch != _selectionEpoch) return;
          _replaceThread(thread.withUnread(0));
        }
      }
      _notify();
    } catch (_) {
      // Keep the last confirmed state while offline.
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _reloadThreads() async {
    final results = await Future.wait([
      _messaging.fetchConversations(),
      _loadApplications(),
    ]);
    final conversations = (results[0] as ConversationList).items;
    final applications = results[1] as List<CandidateApplication>;

    final byApplication = {for (final a in applications) a.id: a};
    final open = <MessageThread>[
      for (final c in conversations)
        _fromConversation(
          c,
          c.applicationId == null ? null : byApplication[c.applicationId],
        ),
    ];
    final withConversation = {
      for (final c in conversations)
        if (c.applicationId != null) c.applicationId,
      for (final a in applications)
        if (a.hasConversation &&
            conversations.any((c) => c.id == a.conversationId))
          a.id,
    };
    final pending =
        <MessageThread>[
          for (final a in applications)
            if (!withConversation.contains(a.id) &&
                (a.status == ApplicationStatus.interview ||
                    a.status == ApplicationStatus.sent))
              MessageThread(
                id: 'app-${a.id}',
                state: a.status == ApplicationStatus.interview
                    ? ThreadState.startable
                    : ThreadState.locked,
                companyName: a.companyName ?? 'Entreprise',
                offerTitle: a.jobTitle ?? '',
                preview: a.status == ApplicationStatus.interview
                    ? 'Entretien proposé · démarre la conversation'
                    : 'En attente de réponse',
                at: a.appliedAt,
                application: a,
              ),
        ]..sort((x, y) {
          // Les entretiens à démarrer d'abord, puis les plus récents.
          final byState = x.state.index.compareTo(y.state.index);
          if (byState != 0) return byState;
          return (y.at ?? DateTime(0)).compareTo(x.at ?? DateTime(0));
        });

    if (!_disposed) _threads = [...open, ...pending];
  }

  Future<List<CandidateApplication>> _loadApplications() async {
    final repository = applicationsRepository;
    if (repository == null) return const [];
    try {
      final items = <CandidateApplication>[];
      for (var number = 1; ; number++) {
        final page = await repository.fetchApplications(
          page: number,
          pageSize: 50,
        );
        items.addAll(page.items);
        if (!page.hasMore || page.items.isEmpty) break;
      }
      return items;
    } catch (_) {
      // Sans candidatures, la messagerie reste utilisable.
      return const [];
    }
  }

  MessageThread _fromConversation(
    Conversation c,
    CandidateApplication? application,
  ) {
    return MessageThread(
      id: c.id,
      state: ThreadState.open,
      companyName: c.companyName.isNotEmpty
          ? c.companyName
          : (application?.companyName ?? 'Entreprise'),
      offerTitle: c.offerTitle.isNotEmpty
          ? c.offerTitle
          : (application?.jobTitle ?? ''),
      preview: c.lastMessage.isEmpty
          ? 'Conversation ouverte · écris le premier message'
          : c.lastMessage,
      at: c.lastMessageAt,
      unread: c.unread,
      conversation: c,
      application: application,
    );
  }

  void _replaceThread(MessageThread updated, {bool moveToTop = false}) {
    final others = [
      for (final t in _threads)
        if (t.id != updated.id) t,
    ];
    if (moveToTop) {
      _threads = [updated, ...others];
    } else {
      _threads = [for (final t in _threads) t.id == updated.id ? updated : t];
    }
  }

  void _swap(String? clientId, ChatMessage replacement) {
    _messages = [
      for (final m in _messages)
        m.clientId != null && m.clientId == clientId ? replacement : m,
    ];
  }

  void _startPolling() {
    final interval = pollInterval;
    if (interval == null || _timer != null) return;
    _timer = Timer.periodic(interval, (_) => refresh());
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _selectionEpoch++;
    _timer?.cancel();
    super.dispose();
  }
}
