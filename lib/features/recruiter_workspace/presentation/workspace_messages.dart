import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'workspace_controller.dart';
import 'workspace_screen.dart';

class WorkspaceMessages extends StatefulWidget {
  const WorkspaceMessages({super.key, this.candidateId, this.candidateName});
  final String? candidateId;
  final String? candidateName;
  @override
  State<WorkspaceMessages> createState() => _WorkspaceMessagesState();
}

class _WorkspaceMessagesState extends State<WorkspaceMessages>
    with WidgetsBindingObserver {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  final Map<String, String> _drafts = {};
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _selected;
  String _search = '';
  String? _error;
  bool _loading = false;
  bool _sending = false;
  bool _active = true;
  int _request = 0;
  Timer? _timer;
  final Map<String, String> _retryIds = {};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final c = context.read<WorkspaceController>();
      if (widget.candidateId != null) {
        try {
          final conversation = await c.repository.startConversation(
            widget.candidateId!,
            widget.candidateName ?? 'Candidat',
          );
          if (mounted) {
            await _open(conversation);
            await c.load('messages');
          }
        } catch (_) {
          if (mounted)
            setState(
              () => _error = 'Impossible de démarrer cette conversation.',
            );
        }
      }
      _timer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (mounted &&
            _active &&
            !_loading &&
            !_sending &&
            !c.repository.isMock)
          _refresh();
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    _request++;
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _open(Map<String, dynamic> conversation) async {
    if (_sending) return;
    if (_selected != null) _drafts['${_selected!['id']}'] = _text.text;
    setState(() {
      _selected = conversation;
      _messages = [];
      _text.text = _drafts['${conversation['id']}'] ?? '';
    });
    await _refresh();
  }

  Future<void> _refresh() async {
    final selected = _selected;
    final ticket = ++_request;
    if (selected == null) {
      await context.read<WorkspaceController>().load('messages');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final c = context.read<WorkspaceController>();
    final wasAtBottom =
        !_scroll.hasClients ||
        _scroll.position.maxScrollExtent - _scroll.offset < 100;
    try {
      final items = await c.repository.messages('${selected['id']}');
      await c.repository.readConversation('${selected['id']}');
      if (!mounted || ticket != _request) return;
      setState(() {
        _messages = items;
        selected['unread'] = 0;
      });
      await c.load('messages');
      if (wasAtBottom) _bottom();
    } catch (_) {
      if (mounted && ticket == _request)
        setState(
          () => _error = 'Impossible d’actualiser les messages. Réessayez.',
        );
    } finally {
      if (mounted && ticket == _request) setState(() => _loading = false);
    }
  }

  void _bottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients)
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
    });
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (_selected == null || text.isEmpty || _sending || text.length > 4000)
      return;
    final selected = _selected!;
    final conversationId = '${selected['id']}';
    final key = '$conversationId\u0000$text';
    final clientId = _retryIds.putIfAbsent(
      key,
      () => 'web-${DateTime.now().microsecondsSinceEpoch}',
    );
    setState(() {
      _sending = true;
      _error = null;
    });
    final c = context.read<WorkspaceController>();
    try {
      final item = await c.repository.send(conversationId, text, clientId);
      if (!mounted) return;
      setState(() {
        if (!_messages.any((m) => m['id'] == item['id'])) _messages.add(item);
        _text.clear();
        _drafts.remove(conversationId);
        _retryIds.remove(key);
      });
      _bottom();
      await c.load('messages');
    } catch (_) {
      if (mounted)
        setState(
          () => _error = 'Envoi non confirmé. Votre texte est conservé. Réessayez avec le bouton Envoyer.',
        );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<WorkspaceController>();
    return LayoutBuilder(
      builder: (context, box) {
        final narrow = box.maxWidth < 800;
        final list = Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Rechercher un candidat ou une offre',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) =>
                    setState(() => _search = v.toLowerCase().trim()),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await c.load('messages');
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    if (c.conversations.isEmpty && !c.busy)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Aucune conversation. Contactez un talent depuis sa fiche candidat.',
                        ),
                      ),
                    for (final item in c.conversations.where(
                      (v) => '${v['name']} ${v['offerTitle'] ?? ''}'
                          .toLowerCase()
                          .contains(_search),
                    ))
                      ListTile(
                        selected: _selected?['id'] == item['id'],
                        selectedTileColor: const Color(0xFFEAF2F9),
                        leading: CircleAvatar(
                          child: Text(
                            '${item['name'] ?? '?'}'.characters.first,
                          ),
                        ),
                        title: Text(
                          '${item['name']}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${item['lastMessage'] ?? ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: (item['unread'] as num? ?? 0) > 0
                            ? Badge(label: Text('${item['unread']}'))
                            : null,
                        onTap: _sending ? null : () => _open(item),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
        final chat = _selected == null
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        size: 56,
                        color: workspaceNavy,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Chaque échange commence par une rencontre.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Sélectionnez une conversation pour échanger avec un candidat.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        if (narrow)
                          IconButton(
                            tooltip: 'Conversations',
                            onPressed: _sending
                                ? null
                                : () {
                                    _drafts['${_selected!['id']}'] = _text.text;
                                    _request++;
                                    setState(() {
                                      _selected = null;
                                      _loading = false;
                                    });
                                  },
                            icon: const Icon(Icons.arrow_back),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_selected!['name']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (_selected!['offerTitle'] != null)
                                Text(
                                  '${_selected!['offerTitle']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Actualiser les messages',
                          onPressed: _loading ? null : _refresh,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  ),
                  if (_loading) const LinearProgressIndicator(minHeight: 2),
                  Expanded(
                    child: _messages.isEmpty && !_loading
                        ? const Center(
                            child: Text(
                              'Présentez-vous pour commencer la conversation.',
                            ),
                          )
                        : ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final m = _messages[index];
                              final mine = m['fromMe'] == true;
                              final date = DateTime.tryParse(
                                '${m['createdAt']}',
                              )?.toLocal();
                              return Align(
                                alignment: mine
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: narrow
                                        ? box.maxWidth * .82
                                        : (box.maxWidth - 340) * .78,
                                  ),
                                  padding: const EdgeInsets.all(14),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: mine ? workspaceNavy : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(
                                        '${m['text']}',
                                        style: TextStyle(
                                          color: mine
                                              ? Colors.white
                                              : workspaceNavy,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        date == null
                                            ? ''
                                            : '${date.day}/${date.month} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}${mine ? ' · Envoyé' : ''}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: mine
                                              ? Colors.white70
                                              : Colors.blueGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _text,
                            enabled: !_sending,
                            minLines: 1,
                            maxLines: 5,
                            maxLength: 4000,
                            decoration: const InputDecoration(
                              hintText: 'Votre message…',
                              border: OutlineInputBorder(),
                              counterText: '',
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          tooltip: 'Envoyer le message',
                          onPressed: _sending || _text.text.trim().isEmpty
                              ? null
                              : _send,
                          icon: _sending
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ],
              );
        return Padding(
          padding: EdgeInsets.all(narrow ? 0 : 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(narrow ? 0 : 20),
            child: ColoredBox(
              color: const Color(0xFFEDF2F6),
              child: narrow
                  ? (_selected == null
                        ? Column(
                            children: [
                              if (_error != null)
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(_error!),
                                ),
                              Expanded(child: list),
                            ],
                          )
                        : chat)
                  : Row(
                      children: [
                        SizedBox(
                          width: 330,
                          child: ColoredBox(color: Colors.white, child: list),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(child: chat),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
