import 'package:flutter/services.dart';

import '../../recruiter_studio/presentation/studio_controller.dart';
import '../../recruiter_studio/presentation/studio_actions.dart';
import '../../recruiter_studio/presentation/studio_components.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'workspace_controller.dart';

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
  String _filter = 'inbox', _messageSearch = '';
  bool _showMessageSearch = false;
  StudioController? _studio;
  String? _draftUserId;
  Timer? _draftTimer;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _studio = context.read<StudioController>();
    _draftUserId ??= _studio!.userId;
  }

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
          if (mounted) {
            setState(
              () => _error = 'Impossible de démarrer cette conversation.',
            );
          }
        }
      }
      _timer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (mounted &&
            _active &&
            !_loading &&
            !_sending &&
            !c.repository.isMock) {
          _refresh();
        }
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
    _draftTimer?.cancel();
    _persistDraft();
    WidgetsBinding.instance.removeObserver(this);
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _open(Map<String, dynamic> conversation) async {
    if (_sending) return;
    _draftTimer?.cancel();
    _persistDraft();
    if (_selected != null) _drafts['${_selected!['id']}'] = _text.text;
    setState(() {
      _selected = conversation;
      _messages = [];
      _text.text =
          _drafts['${conversation['id']}'] ??
          '${_studio?.object('drafts')['${conversation['id']}'] ?? ''}';
      _messageSearch = '';
    });
    await _refresh();
  }

  Future<void> _refresh() async {
    if (_sending) return;
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
      if (wasAtBottom && _studio?.preferences['scrollToLatest'] != false) {
        _bottom();
      }
    } catch (_) {
      if (mounted && ticket == _request) {
        setState(
          () => _error = 'Impossible d’actualiser les messages. Réessayez.',
        );
      }
    } finally {
      if (mounted && ticket == _request) setState(() => _loading = false);
    }
  }

  void _bottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _composedText;
    if (_selected == null || text.isEmpty || _sending || text.length > 4000) {
      return;
    }
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
      _persistDraft();
      _bottom();
      await c.load('messages');
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Envoi non confirmé. Votre texte est conservé. Réessayez avec le bouton Envoyer.',
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<WorkspaceController>();
    final studio = context.watch<StudioController>();
    final colors = Theme.of(context).colorScheme;
    final conversations =
        c.conversations.where((v) {
          final id = '${v['id']}';
          final archived = studio.contains('archivedConversations', id);
          if (_filter == 'archived' ? !archived : archived) return false;
          if (_filter == 'unread' && (v['unread'] as num? ?? 0) == 0) {
            return false;
          }
          if (_filter == 'pinned' &&
              !studio.contains('pinnedConversations', id)) {
            return false;
          }
          return '${v['name']} ${v['offerTitle'] ?? ''}'.toLowerCase().contains(
            _search,
          );
        }).toList()..sort(
          (a, b) =>
              (studio.contains('pinnedConversations', '${b['id']}') ? 1 : 0) -
              (studio.contains('pinnedConversations', '${a['id']}') ? 1 : 0),
        );
    final visibleMessages = _messages
        .where((m) => '${m['text']}'.toLowerCase().contains(_messageSearch))
        .toList();
    return LayoutBuilder(
      builder: (context, box) {
        final narrow = box.maxWidth < 800;
        final list = Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Conversations',
                          style: TextStyle(
                            fontFamily: 'BricolageGrotesque',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Badge(label: Text('${c.conversations.length}')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un candidat ou une offre',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) =>
                        setState(() => _search = v.toLowerCase().trim()),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final f in {
                          'inbox': 'Tout',
                          'unread': 'Non lues',
                          'pinned': 'Prioritaires',
                          'archived': 'Archives',
                        }.entries)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(f.value),
                              selected: _filter == f.key,
                              onSelected: (_) =>
                                  setState(() => _filter = f.key),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
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
                    if (conversations.isEmpty && !c.busy)
                      const StudioEmpty(
                        title: 'Aucune conversation ici',
                        message: 'Contactez un talent depuis son profil ou modifiez vos filtres.',
                        icon: Icons.forum_outlined,
                      ),
                    for (final item in conversations)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          selected: _selected?['id'] == item['id'],
                          selectedTileColor: colors.primary.withValues(
                            alpha: .12,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: colors.primary.withValues(
                              alpha: .14,
                            ),
                            child: Text(
                              ('${item['name'] ?? '?'}'.trim().isEmpty
                                      ? '?'
                                      : '${item['name']}')
                                  .characters
                                  .first
                                  .toUpperCase(),
                            ),
                          ),
                          title: Text(
                            '${item['name']}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            '${item['lastMessage'] ?? 'Commencer la conversation'}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: (item['unread'] as num? ?? 0) > 0
                              ? Badge(label: Text('${item['unread']}'))
                              : studio.contains(
                                  'pinnedConversations',
                                  '${item['id']}',
                                )
                              ? const Icon(Icons.push_pin, size: 16)
                              : null,
                          onTap: _sending ? null : () => _open(item),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
        final chat = _selected == null
            ? const Center(
                child: StudioEmpty(
                  title: 'La bonne rencontre commence ici.',
                  message: 'Sélectionnez un échange. Vos modèles et prochaines actions restent à portée de main.',
                  icon: Icons.mark_chat_unread_outlined,
                ),
              )
            : Column(
                children: [
                  Material(
                    color: colors.surface,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
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
                                      _persistDraft();
                                      _request++;
                                      setState(() {
                                        _selected = null;
                                        _loading = false;
                                      });
                                    },
                              icon: const Icon(Icons.arrow_back),
                            ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: colors.primary.withValues(
                              alpha: .15,
                            ),
                            child: Text(
                              ('${_selected!['name']}'.trim().isEmpty
                                      ? '?'
                                      : '${_selected!['name']}')
                                  .characters
                                  .first,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_selected!['name']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  '${_selected!['offerTitle'] ?? 'Échange direct'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Rechercher dans cet échange',
                            onPressed: () => setState(
                              () => _showMessageSearch = !_showMessageSearch,
                            ),
                            icon: const Icon(Icons.search),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Actions de conversation',
                            enabled: !_sending && !studio.saving,
                            onSelected: (v) async {
                              final id = '${_selected!['id']}';
                              final candidate = '${_selected!['candidateId']}';
                              final name = '${_selected!['name']}';
                              switch (v) {
                                case 'pin':
                                  await studio.toggle(
                                    'pinnedConversations',
                                    id,
                                  );
                                case 'archive':
                                  _persistDraft();
                                  final ok = await studio.toggle(
                                    'archivedConversations',
                                    id,
                                  );
                                  if (ok && mounted) {
                                    setState(() => _selected = null);
                                  }
                                case 'note':
                                  await studioAddNote(context, candidate, name);
                                case 'task':
                                  await studioEditTask(
                                    context,
                                    candidateId: candidate,
                                    candidateName: name,
                                  );
                                case 'interview':
                                  await studioEditInterview(
                                    context,
                                    candidateId: candidate,
                                    candidateName: name,
                                  );
                                case 'refresh':
                                  await _refresh();
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'pin',
                                child: Text(
                                  studio.contains(
                                        'pinnedConversations',
                                        '${_selected!['id']}',
                                      )
                                      ? 'Retirer des prioritaires'
                                      : 'Épingler la conversation',
                                ),
                              ),
                              PopupMenuItem(
                                value: 'archive',
                                child: Text(
                                  _filter == 'archived'
                                      ? 'Restaurer la conversation'
                                      : 'Archiver la conversation',
                                ),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem(
                                value: 'note',
                                child: Text('Ajouter une note privée'),
                              ),
                              const PopupMenuItem(
                                value: 'task',
                                child: Text('Préparer une relance'),
                              ),
                              const PopupMenuItem(
                                value: 'interview',
                                child: Text('Préparer un entretien'),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem(
                                value: 'refresh',
                                child: Text('Actualiser les messages'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showMessageSearch)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher dans les messages',
                          prefixIcon: const Icon(Icons.search),
                          suffixText: '${visibleMessages.length} résultat(s)',
                        ),
                        onChanged: (v) => setState(
                          () => _messageSearch = v.toLowerCase().trim(),
                        ),
                      ),
                    ),
                  if (_loading) const LinearProgressIndicator(minHeight: 2),
                  Expanded(
                    child: visibleMessages.isEmpty && !_loading
                        ? StudioEmpty(
                            title: _messageSearch.isEmpty
                                ? 'À vous de faire le premier pas.'
                                : 'Aucun message trouvé',
                            message: _messageSearch.isEmpty
                                ? 'Présentez l’opportunité ou utilisez une réponse enregistrée.'
                                : 'Essayez une autre recherche.',
                            icon: Icons.chat_bubble_outline,
                          )
                        : ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.all(18),
                            itemCount: visibleMessages.length,
                            itemBuilder: (context, index) {
                              final m = visibleMessages[index];
                              final mine = m['fromMe'] == true;
                              final date = DateTime.tryParse(
                                '${m['createdAt']}',
                              )?.toLocal();
                              return Column(
                                children: [
                                  if (index == 0 ||
                                      studioDate(m['createdAt']) !=
                                          studioDate(
                                            visibleMessages[index -
                                                1]['createdAt'],
                                          ))
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      child: Text(
                                        studioDate(m['createdAt']),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  Align(
                                    alignment: mine
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: narrow
                                            ? box.maxWidth * .84
                                            : (box.maxWidth - 360) * .83,
                                      ),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        12,
                                        10,
                                        8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: mine
                                            ? const Color(0xFF133554)
                                            : colors.surface,
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(18),
                                          topRight: const Radius.circular(18),
                                          bottomLeft: Radius.circular(
                                            mine ? 18 : 4,
                                          ),
                                          bottomRight: Radius.circular(
                                            mine ? 4 : 18,
                                          ),
                                        ),
                                        border: mine
                                            ? null
                                            : Border.all(
                                                color: colors.outlineVariant,
                                              ),
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
                                                  : colors.onSurface,
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                date == null
                                                    ? ''
                                                    : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}${mine ? ' · Envoyé' : ''}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: mine
                                                      ? Colors.white70
                                                      : colors.onSurfaceVariant,
                                                ),
                                              ),
                                              PopupMenuButton<String>(
                                                tooltip: 'Actions du message',
                                                icon: Icon(
                                                  Icons.more_horiz,
                                                  size: 16,
                                                  color: mine
                                                      ? Colors.white70
                                                      : colors.onSurfaceVariant,
                                                ),
                                                onSelected: (v) async {
                                                  if (v == 'copy') {
                                                    await Clipboard.setData(
                                                      ClipboardData(
                                                        text: '${m['text']}',
                                                      ),
                                                    );
                                                    if (context.mounted) {
                                                      studioToast(
                                                        context,
                                                        'Message copié.',
                                                      );
                                                    }
                                                  } else {
                                                    await studioEditTask(
                                                      context,
                                                      task: {
                                                        'title':
                                                            'Relancer ${_selected!['name']}',
                                                      },
                                                      candidateId:
                                                          '${_selected!['candidateId']}',
                                                      candidateName:
                                                          '${_selected!['name']}',
                                                    );
                                                  }
                                                },
                                                itemBuilder: (_) => const [
                                                  PopupMenuItem(
                                                    value: 'copy',
                                                    child: Text(
                                                      'Copier le message',
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'task',
                                                    child: Text(
                                                      'Créer une prochaine action',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _error!,
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                  Material(
                    color: colors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: _sending
                                    ? null
                                    : () => _chooseTemplate(studio),
                                icon: const Icon(
                                  Icons.auto_awesome_outlined,
                                  size: 16,
                                ),
                                label: const Text('Réponses'),
                              ),
                              const Spacer(),
                              Text(
                                '${_composedText.length}/4000',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _composedText.length > 4000
                                      ? colors.error
                                      : colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          if (studio.preferences['useSignature'] == true &&
                              '${studio.data['signature'] ?? ''}'.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Signature · ${studio.data['signature']}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: CallbackShortcuts(
                                  bindings: {
                                    const SingleActivator(
                                      LogicalKeyboardKey.enter,
                                      control: true,
                                    ): _send,
                                    const SingleActivator(
                                      LogicalKeyboardKey.enter,
                                      meta: true,
                                    ): _send,
                                  },
                                  child: TextField(
                                    controller: _text,
                                    enabled: !_sending,
                                    minLines: 1,
                                    maxLines: 4,
                                    maxLength: 4000,
                                    decoration: const InputDecoration(
                                      hintText: 'Votre message…',
                                      counterText: '',
                                    ),
                                    onChanged: (_) {
                                      setState(() {});
                                      _draftTimer?.cancel();
                                      _draftTimer = Timer(
                                        const Duration(milliseconds: 650),
                                        _persistDraft,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                tooltip: 'Envoyer le message',
                                onPressed:
                                    _sending ||
                                        _text.text.trim().isEmpty ||
                                        _composedText.length > 4000
                                    ? null
                                    : _send,
                                icon: _sending
                                    ? const SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.arrow_upward_rounded),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
        return Padding(
          padding: EdgeInsets.all(narrow ? 0 : 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(narrow ? 0 : 24),
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: narrow
                  ? (_selected == null ? list : chat)
                  : Row(
                      children: [
                        SizedBox(
                          width: 340,
                          child: Material(color: colors.surface, child: list),
                        ),
                        VerticalDivider(width: 1, color: colors.outlineVariant),
                        Expanded(child: chat),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  String get _composedText {
    final raw = _text.text.trim();
    final signature = '${_studio?.data['signature'] ?? ''}'.trim();
    return raw.isNotEmpty &&
            _studio?.preferences['useSignature'] == true &&
            signature.isNotEmpty &&
            !raw.endsWith(signature)
        ? '$raw\n\n$signature'
        : raw;
  }

  void _persistDraft() {
    if (_studio == null ||
        _selected == null ||
        _studio!.userId != _draftUserId) {
      return;
    }
    final id = '${_selected!['id']}';
    final value = _text.text;
    _drafts[id] = value;
    _studio!.change('drafts', () {
      final drafts = _studio!.object('drafts');
      if (value.trim().isEmpty) {
        drafts.remove(id);
      } else {
        drafts[id] = value;
      }
      return drafts;
    });
  }

  Future<void> _chooseTemplate(StudioController c) async {
    final templates = [
      ...c.list('templates'),
      {
        'title': 'Premier contact',
        'text': 'Bonjour {prenom}, votre profil a retenu mon attention. Seriez-vous disponible pour échanger sur notre opportunité ?',
      },
      {
        'title': 'Proposer un entretien',
        'text': 'Bonjour {prenom}, je vous propose un premier échange. Quels créneaux vous conviendraient cette semaine ?',
      },
      {
        'title': 'Relancer avec attention',
        'text': 'Bonjour {prenom}, je reviens vers vous concernant notre précédent échange. L’opportunité vous intéresse-t-elle toujours ?',
      },
    ];
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.sizeOf(ctx).height * .6,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Réponses enregistrées',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final t in templates)
                    ListTile(
                      title: Text('${t['title']}'),
                      subtitle: Text(
                        '${t['text']}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.pop(ctx, '${t['text']}'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (text != null && mounted) {
      if (_text.text.trim().isNotEmpty &&
          !await studioConfirm(
            context,
            'Remplacer le brouillon ?',
            'Votre texte actuel sera remplacé par cette réponse.',
          )) {
        return;
      }
      if (!mounted) return;
      setState(
        () => _text.text = text.replaceAll(
          '{prenom}',
          '${_selected?['name'] ?? ''}'.split(' ').first,
        ),
      );
      _persistDraft();
    }
  }
}
