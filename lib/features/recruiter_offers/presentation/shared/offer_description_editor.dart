import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/tokens/app_colors.dart';
import 'offer_ui.dart';

enum _DescriptionEditorMode { guided, advanced, preview }

class OfferDescriptionEditor extends StatefulWidget {
  const OfferDescriptionEditor({
    super.key,
    required this.controller,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.compact = false,
    this.maxLength = 5000,
  });

  final TextEditingController controller;
  final String value;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool compact;
  final int maxLength;

  @override
  State<OfferDescriptionEditor> createState() => _OfferDescriptionEditorState();
}

class _OfferDescriptionEditorState extends State<OfferDescriptionEditor> {
  final FocusNode _focusNode = FocusNode();
  final List<String> _history = <String>[];
  final TextEditingController _introController = TextEditingController();
  final TextEditingController _missionsController = TextEditingController();
  final TextEditingController _profileController = TextEditingController();
  final TextEditingController _benefitsController = TextEditingController();
  int _historyIndex = -1;
  Timer? _historyTimer;
  late _DescriptionEditorMode _mode;
  bool _expanded = false;
  bool _syncingGuided = false;

  @override
  void initState() {
    super.initState();
    _history.add(widget.controller.text);
    _historyIndex = 0;
    _mode = _containsAdvancedMarkup(widget.controller.text)
        ? _DescriptionEditorMode.advanced
        : _DescriptionEditorMode.guided;
    _syncGuidedFromMarkup(widget.controller.text);
    for (final controller in [
      _introController,
      _missionsController,
      _profileController,
      _benefitsController,
    ]) {
      controller.addListener(_handleGuidedChange);
    }
  }

  @override
  void didUpdateWidget(covariant OfferDescriptionEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value &&
        widget.value != widget.controller.text) {
      widget.controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
      _record(widget.value);
      _syncGuidedFromMarkup(widget.value);
    }
  }

  @override
  void dispose() {
    _historyTimer?.cancel();
    _focusNode.dispose();
    _introController.dispose();
    _missionsController.dispose();
    _profileController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editor = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.compact ? 16 : 18),
        border: Border.all(
          color: widget.errorText == null
              ? const Color(0xFFD8E4EC)
              : AppColors.error,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0A3152),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _modeBar(),
          if (_mode == _DescriptionEditorMode.guided) ...[
            _guidedEditor(),
            _guidedHelperBar(),
          ] else if (_mode == _DescriptionEditorMode.advanced) ...[
            _quickStructureBar(),
            _formatBar(),
            _textField(),
            _helperBar(),
          ] else
            _preview(),
        ],
      ),
    );

    if (_mode != _DescriptionEditorMode.advanced) return editor;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyB, meta: true): () =>
            _wrap('**', '**'),
        const SingleActivator(LogicalKeyboardKey.keyB, control: true): () =>
            _wrap('**', '**'),
        const SingleActivator(LogicalKeyboardKey.keyI, meta: true): () =>
            _wrap('*', '*'),
        const SingleActivator(LogicalKeyboardKey.keyI, control: true): () =>
            _wrap('*', '*'),
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): _undo,
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): _undo,
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true):
            _redo,
        const SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: true,
          shift: true,
        ): _redo,
      },
      child: editor,
    );
  }

  Widget _modeBar() => Container(
    padding: EdgeInsets.fromLTRB(
      widget.compact ? 10 : 12,
      widget.compact ? 8 : 10,
      widget.compact ? 10 : 12,
      widget.compact ? 8 : 10,
    ),
    decoration: const BoxDecoration(
      color: Color(0xFFFAFCFE),
      border: Border(bottom: BorderSide(color: AppColors.lineSoft)),
    ),
    child: Row(
      children: [
        _ModeButton(
          label: 'Guidé',
          icon: Icons.view_agenda_outlined,
          selected: _mode == _DescriptionEditorMode.guided,
          onTap: () => setState(() {
            _syncGuidedFromMarkup(widget.controller.text);
            _mode = _DescriptionEditorMode.guided;
          }),
        ),
        const SizedBox(width: 5),
        _ModeButton(
          label: widget.compact ? 'Texte' : 'Texte avancé',
          icon: Icons.code_rounded,
          selected: _mode == _DescriptionEditorMode.advanced,
          onTap: () => setState(() => _mode = _DescriptionEditorMode.advanced),
        ),
        const SizedBox(width: 5),
        _ModeButton(
          label: 'Aperçu',
          icon: Icons.visibility_outlined,
          selected: _mode == _DescriptionEditorMode.preview,
          onTap: () => setState(() => _mode = _DescriptionEditorMode.preview),
        ),
        const Spacer(),
        Text(
          '${widget.controller.text.length}/${widget.maxLength}',
          style: const TextStyle(
            color: AppColors.slate,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (!widget.compact && _mode == _DescriptionEditorMode.advanced) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: _expanded ? 'Réduire l’éditeur' : 'Agrandir l’éditeur',
            onPressed: () => setState(() => _expanded = !_expanded),
            visualDensity: VisualDensity.compact,
            icon: Icon(
              _expanded
                  ? Icons.close_fullscreen_rounded
                  : Icons.open_in_full_rounded,
              size: 18,
              color: AppColors.slateDark,
            ),
          ),
        ],
      ],
    ),
  );

  Widget _guidedEditor() => Padding(
    padding: EdgeInsets.all(widget.compact ? 10 : 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GuidedSectionField(
          icon: Icons.notes_rounded,
          title: 'Contexte du poste',
          helper:
              'Présentez l’équipe, le produit et l’objectif du recrutement.',
          controller: _introController,
          hint: 'Ex. Vous rejoignez l’équipe produit pour…',
          minLines: widget.compact ? 3 : 4,
        ),
        const SizedBox(height: 10),
        _GuidedSectionField(
          icon: Icons.checklist_rounded,
          title: 'Vos missions',
          helper:
              'Une mission par ligne — les puces sont créées automatiquement.',
          controller: _missionsController,
          hint: 'Développer de nouvelles fonctionnalités\nParticiper aux revues de code\nCollaborer avec l’équipe produit',
          minLines: widget.compact ? 4 : 5,
          listMode: true,
        ),
        const SizedBox(height: 10),
        _GuidedSectionField(
          icon: Icons.person_search_outlined,
          title: 'Profil recherché',
          helper:
              'Une attente par ligne : expérience, compétences ou qualités.',
          controller: _profileController,
          hint: 'Formation ou expérience attendue\nMaîtrise de…\nAutonomie et esprit d’équipe',
          minLines: widget.compact ? 4 : 5,
          listMode: true,
        ),
        const SizedBox(height: 10),
        _GuidedSectionField(
          icon: Icons.favorite_border_rounded,
          title: 'Pourquoi nous rejoindre',
          helper:
              'Ajoutez les éléments concrets qui rendent l’offre attractive.',
          controller: _benefitsController,
          hint: 'Équipe à taille humaine\nProjets à impact\nAccompagnement et montée en compétences',
          minLines: widget.compact ? 3 : 4,
          listMode: true,
        ),
      ],
    ),
  );

  Widget _guidedHelperBar() => Container(
    padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
    decoration: const BoxDecoration(
      color: Color(0xFFF4F9FD),
      border: Border(top: BorderSide(color: AppColors.lineSoft)),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.auto_awesome_outlined, size: 16, color: Color(0xFF1976D2)),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'La structure, les titres et les listes sont générés automatiquement. Passez en « Texte avancé » uniquement si vous voulez un contrôle précis.',
            style: TextStyle(
              color: AppColors.slateDark,
              fontSize: 10,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _quickStructureBar() => Container(
    padding: EdgeInsets.fromLTRB(
      widget.compact ? 8 : 12,
      widget.compact ? 8 : 10,
      widget.compact ? 8 : 12,
      widget.compact ? 8 : 10,
    ),
    color: const Color(0xFFFFFFFF),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StructureButton(
            label: 'Structure complète',
            icon: Icons.auto_awesome_outlined,
            emphasized: true,
            onTap: _insertStarterTemplate,
          ),
          const SizedBox(width: 7),
          _StructureButton(
            label: 'Présentation',
            icon: Icons.notes_rounded,
            onTap: () => _insertSection('À propos du poste'),
          ),
          const SizedBox(width: 7),
          _StructureButton(
            label: 'Missions',
            icon: Icons.checklist_rounded,
            onTap: () => _insertSection('Vos missions', bullets: true),
          ),
          const SizedBox(width: 7),
          _StructureButton(
            label: 'Profil',
            icon: Icons.person_search_outlined,
            onTap: () => _insertSection('Profil recherché', bullets: true),
          ),
          const SizedBox(width: 7),
          _StructureButton(
            label: 'Pourquoi nous rejoindre',
            icon: Icons.favorite_border_rounded,
            onTap: () =>
                _insertSection('Pourquoi nous rejoindre', bullets: true),
          ),
        ],
      ),
    ),
  );

  Widget _formatBar() => Container(
    constraints: BoxConstraints(minHeight: widget.compact ? 44 : 48),
    padding: EdgeInsets.symmetric(
      horizontal: widget.compact ? 7 : 10,
      vertical: 6,
    ),
    decoration: const BoxDecoration(
      color: Color(0xFFF7FAFC),
      border: Border(
        top: BorderSide(color: AppColors.lineSoft),
        bottom: BorderSide(color: AppColors.lineSoft),
      ),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          PopupMenuButton<String>(
            tooltip: 'Style du bloc',
            onSelected: (value) {
              if (value == 'paragraph') _clearBlockPrefix();
              if (value == 'h1') _prefixLines('# ');
              if (value == 'h2') _prefixLines('## ');
              if (value == 'quote') _prefixLines('> ');
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'paragraph', child: Text('Paragraphe')),
              PopupMenuItem(value: 'h1', child: Text('Titre principal')),
              PopupMenuItem(value: 'h2', child: Text('Sous-titre')),
              PopupMenuItem(value: 'quote', child: Text('Encadré / citation')),
            ],
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.lineSoft),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.text_fields_rounded, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Style',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.expand_more_rounded, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          _EditorToolButton(
            icon: Icons.format_bold_rounded,
            tooltip: 'Gras — ⌘/Ctrl+B',
            onTap: () => _wrap('**', '**'),
          ),
          _EditorToolButton(
            icon: Icons.format_italic_rounded,
            tooltip: 'Italique — ⌘/Ctrl+I',
            onTap: () => _wrap('*', '*'),
          ),
          _EditorToolButton(
            icon: Icons.format_list_bulleted_rounded,
            tooltip: 'Liste à puces',
            onTap: () => _prefixLines('- '),
          ),
          _EditorToolButton(
            icon: Icons.format_list_numbered_rounded,
            tooltip: 'Liste numérotée',
            onTap: _numberLines,
          ),
          _EditorToolButton(
            icon: Icons.format_quote_rounded,
            tooltip: 'Encadré',
            onTap: () => _prefixLines('> '),
          ),
          _EditorToolButton(
            icon: Icons.link_rounded,
            tooltip: 'Insérer un lien',
            onTap: _insertLink,
          ),
          _divider(),
          _EditorToolButton(
            icon: Icons.format_align_left_rounded,
            tooltip: 'Aligner à gauche',
            onTap: () => _alignLines('left'),
          ),
          _EditorToolButton(
            icon: Icons.format_align_center_rounded,
            tooltip: 'Centrer',
            onTap: () => _alignLines('center'),
          ),
          _EditorToolButton(
            icon: Icons.format_align_right_rounded,
            tooltip: 'Aligner à droite',
            onTap: () => _alignLines('right'),
          ),
          _divider(),
          _EditorToolButton(
            icon: Icons.format_clear_rounded,
            tooltip: 'Nettoyer la mise en forme de la sélection',
            onTap: _clearSelectionFormatting,
          ),
          _EditorToolButton(
            icon: Icons.undo_rounded,
            tooltip: 'Annuler',
            onTap: _historyIndex > 0 ? _undo : null,
          ),
          _EditorToolButton(
            icon: Icons.redo_rounded,
            tooltip: 'Rétablir',
            onTap: _historyIndex >= 0 && _historyIndex < _history.length - 1
                ? _redo
                : null,
          ),
        ],
      ),
    ),
  );

  Widget _divider() => Container(
    width: 1,
    height: 22,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    color: AppColors.lineSoft,
  );

  Widget _textField() => TextFormField(
    controller: widget.controller,
    focusNode: _focusNode,
    minLines: _expanded ? 18 : (widget.compact ? 11 : 9),
    maxLines: _expanded ? 28 : (widget.compact ? 18 : 17),
    maxLength: widget.maxLength,
    onChanged: _handleTyping,
    style: TextStyle(
      color: AppColors.navy,
      fontSize: widget.compact ? 12.5 : 13.5,
      height: 1.6,
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
      counterText: '',
      contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 18),
      hintText: 'Présentez le contexte du poste, les missions, le profil recherché et ce qui rend l’opportunité attractive…',
    ),
  );

  Widget _helperBar() => Container(
    padding: const EdgeInsets.fromLTRB(13, 9, 13, 9),
    decoration: const BoxDecoration(
      color: Color(0xFFFAFCFE),
      border: Border(top: BorderSide(color: AppColors.lineSoft)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.keyboard_command_key_rounded,
          size: 15,
          color: Color(0xFF54718A),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            widget.compact
                ? 'Utilisez les sections rapides et l’aperçu pour structurer l’offre sans saisir de syntaxe.'
                : 'Astuce : sélectionnez du texte puis utilisez la barre. ⌘/Ctrl+B pour le gras, ⌘/Ctrl+I pour l’italique.',
            style: const TextStyle(
              color: AppColors.slate,
              fontSize: 9.7,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _preview() => Container(
    constraints: BoxConstraints(minHeight: widget.compact ? 280 : 330),
    padding: EdgeInsets.all(widget.compact ? 14 : 18),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFF7FAFD)],
      ),
    ),
    child: widget.controller.text.trim().isEmpty
        ? const Center(
            child: Text(
              'Commencez à rédiger : l’aperçu formaté apparaîtra ici.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.slate,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          )
        : OfferRichText(
            value: widget.controller.text,
            baseStyle: TextStyle(
              color: AppColors.slateDark,
              fontSize: widget.compact ? 12 : 13,
              height: 1.55,
            ),
          ),
  );

  TextSelection _safeSelection() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    if (!selection.isValid) return TextSelection.collapsed(offset: text.length);
    return TextSelection(
      baseOffset: selection.start.clamp(0, text.length).toInt(),
      extentOffset: selection.end.clamp(0, text.length).toInt(),
    );
  }

  bool _containsAdvancedMarkup(String text) =>
      RegExp(r'(^|\n)(# |## |> |\[center\]|\[right\])|\*\*|\[[^\]]+\]\([^)]+\)')
          .hasMatch(text);

  void _syncGuidedFromMarkup(String text) {
    _syncingGuided = true;
    final sections = <String, List<String>>{
      'intro': <String>[],
      'missions': <String>[],
      'profile': <String>[],
      'benefits': <String>[],
    };
    var current = 'intro';
    for (final raw in text.replaceAll('\r\n', '\n').split('\n')) {
      final line = raw.trimRight();
      if (line.startsWith('## ')) {
        final heading = line.substring(3).toLowerCase();
        if (heading.contains('mission')) {
          current = 'missions';
        } else if (heading.contains('profil') || heading.contains('recherch')) {
          current = 'profile';
        } else if (heading.contains('pourquoi') ||
            heading.contains('rejoindre') ||
            heading.contains('avantage')) {
          current = 'benefits';
        } else {
          current = 'intro';
        }
        continue;
      }
      var clean = line
          .replaceFirst(RegExp(r'^\[(center|right)\]'), '')
          .replaceFirst(RegExp(r'^(# |> |\d+\. |- )'), '')
          .replaceAll('**', '')
          .replaceAll('*', '');
      clean = clean.replaceAllMapped(
        RegExp(r'\[([^\]]+)\]\([^)]+\)'),
        (match) => match.group(1) ?? '',
      );
      sections[current]!.add(clean);
    }

    String plain(String key, {bool list = false}) {
      final lines = sections[key]!
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      return lines.join(list ? '\n' : '\n');
    }

    _introController.text = plain('intro');
    _missionsController.text = plain('missions', list: true);
    _profileController.text = plain('profile', list: true);
    _benefitsController.text = plain('benefits', list: true);
    _syncingGuided = false;
  }

  void _handleGuidedChange() {
    if (_syncingGuided) return;

    List<String> lines(TextEditingController controller) => controller.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final parts = <String>[];
    final intro = _introController.text.trim();
    if (intro.isNotEmpty) parts.add(intro);

    void addListSection(String heading, TextEditingController controller) {
      final values = lines(controller);
      if (values.isEmpty) return;
      parts.add('## $heading\n${values.map((line) => '- $line').join('\n')}');
    }

    addListSection('Vos missions', _missionsController);
    addListSection('Profil recherché', _profileController);
    addListSection('Pourquoi nous rejoindre', _benefitsController);

    final composed = parts.join('\n\n');
    if (composed == widget.controller.text) return;
    widget.controller.value = TextEditingValue(
      text: composed,
      selection: TextSelection.collapsed(offset: composed.length),
    );
    widget.onChanged(composed);
    _historyTimer?.cancel();
    _historyTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      _record(composed);
      setState(() {});
    });
  }

  void _handleTyping(String text) {
    widget.onChanged(text);
    _historyTimer?.cancel();
    _historyTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      _record(text);
      setState(() {});
    });
    setState(() {});
  }

  void _commit(String text, int cursor, {bool record = true}) {
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: cursor.clamp(0, text.length).toInt(),
      ),
    );
    widget.onChanged(text);
    _syncGuidedFromMarkup(text);
    if (record) _record(text);
    setState(() {});
  }

  void _record(String text) {
    if (_historyIndex >= 0 && _history[_historyIndex] == text) return;
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(text);
    if (_history.length > 80) _history.removeAt(0);
    _historyIndex = _history.length - 1;
  }

  void _undo() {
    if (_historyIndex <= 0) return;
    _historyIndex -= 1;
    final text = _history[_historyIndex];
    _commit(text, text.length, record: false);
  }

  void _redo() {
    if (_historyIndex < 0 || _historyIndex >= _history.length - 1) return;
    _historyIndex += 1;
    final text = _history[_historyIndex];
    _commit(text, text.length, record: false);
  }

  void _wrap(String before, String after) {
    final text = widget.controller.text;
    final selection = _safeSelection();
    final selected = text.substring(selection.start, selection.end);
    final content = selected.isEmpty ? 'texte' : selected;
    final replacement = '$before$content$after';
    _commit(
      text.replaceRange(selection.start, selection.end, replacement),
      selection.start + replacement.length,
    );
  }

  void _prefixLines(String prefix) {
    final text = widget.controller.text;
    final selection = _safeSelection();
    final lineStart = selection.start == 0
        ? 0
        : text.lastIndexOf('\n', selection.start - 1) + 1;
    final nextBreak = text.indexOf('\n', selection.end);
    final lineEnd = nextBreak == -1 ? text.length : nextBreak;
    final block = text.substring(lineStart, lineEnd);
    final replacement = block
        .split('\n')
        .map((line) => line.startsWith(prefix) ? line : '$prefix$line')
        .join('\n');
    _commit(
      text.replaceRange(lineStart, lineEnd, replacement),
      lineStart + replacement.length,
    );
  }

  void _numberLines() {
    final text = widget.controller.text;
    final selection = _safeSelection();
    final lineStart = selection.start == 0
        ? 0
        : text.lastIndexOf('\n', selection.start - 1) + 1;
    final nextBreak = text.indexOf('\n', selection.end);
    final lineEnd = nextBreak == -1 ? text.length : nextBreak;
    final lines = text.substring(lineStart, lineEnd).split('\n');
    final replacement = [
      for (var i = 0; i < lines.length; i++) '${i + 1}. ${lines[i]}',
    ].join('\n');
    _commit(
      text.replaceRange(lineStart, lineEnd, replacement),
      lineStart + replacement.length,
    );
  }

  void _insertLink() {
    final text = widget.controller.text;
    final selection = _safeSelection();
    final selected = text.substring(selection.start, selection.end);
    final replacement =
        '[${selected.isEmpty ? 'texte du lien' : selected}](https://)';
    _commit(
      text.replaceRange(selection.start, selection.end, replacement),
      selection.start + replacement.length,
    );
  }

  void _alignLines(String alignment) {
    final text = widget.controller.text;
    final selection = _safeSelection();
    final lineStart = selection.start == 0
        ? 0
        : text.lastIndexOf('\n', selection.start - 1) + 1;
    final nextBreak = text.indexOf('\n', selection.end);
    final lineEnd = nextBreak == -1 ? text.length : nextBreak;
    final block = text.substring(lineStart, lineEnd);
    final replacement = block
        .split('\n')
        .map((line) {
          final clean = line.replaceFirst(RegExp(r'^\[(center|right)\]'), '');
          if (alignment == 'left') return clean;
          return '[$alignment]$clean';
        })
        .join('\n');
    _commit(
      text.replaceRange(lineStart, lineEnd, replacement),
      lineStart + replacement.length,
    );
  }

  void _clearBlockPrefix() {
    final text = widget.controller.text;
    final selection = _safeSelection();
    final lineStart = selection.start == 0
        ? 0
        : text.lastIndexOf('\n', selection.start - 1) + 1;
    final nextBreak = text.indexOf('\n', selection.end);
    final lineEnd = nextBreak == -1 ? text.length : nextBreak;
    final block = text.substring(lineStart, lineEnd);
    final replacement = block
        .split('\n')
        .map(
          (line) => line
              .replaceFirst(RegExp(r'^\[(center|right)\]'), '')
              .replaceFirst(RegExp(r'^(#{1,2} |> |\d+\. |- )'), ''),
        )
        .join('\n');
    _commit(
      text.replaceRange(lineStart, lineEnd, replacement),
      lineStart + replacement.length,
    );
  }

  void _clearSelectionFormatting() {
    final text = widget.controller.text;
    final selection = _safeSelection();
    if (selection.isCollapsed) {
      _clearBlockPrefix();
      return;
    }
    var selected = text.substring(selection.start, selection.end);
    selected = selected
        .replaceAllMapped(
          RegExp(r'\*\*([^*]+)\*\*'),
          (match) => match.group(1) ?? '',
        )
        .replaceAllMapped(
          RegExp(r'\*([^*]+)\*'),
          (match) => match.group(1) ?? '',
        )
        .replaceAllMapped(
          RegExp(r'\[([^\]]+)\]\([^)]+\)'),
          (match) => match.group(1) ?? '',
        )
        .split('\n')
        .map(
          (line) => line
              .replaceFirst(RegExp(r'^\[(center|right)\]'), '')
              .replaceFirst(RegExp(r'^(#{1,2} |> |\d+\. |- )'), ''),
        )
        .join('\n');
    _commit(
      text.replaceRange(selection.start, selection.end, selected),
      selection.start + selected.length,
    );
  }

  void _insertSection(String title, {bool bullets = false}) {
    final text = widget.controller.text;
    final selection = _safeSelection();
    final needsGap = text.isNotEmpty && selection.start > 0;
    final block = '${needsGap ? '\n\n' : ''}## $title\n${bullets ? '- ' : ''}';
    _commit(
      text.replaceRange(selection.start, selection.end, block),
      selection.start + block.length,
    );
    _focusNode.requestFocus();
  }

  Future<void> _insertStarterTemplate() async {
    const template = '''## À propos du poste
Présentez en quelques lignes l’équipe, le produit et l’objectif du recrutement.

## Vos missions
- Mission principale
- Deuxième mission
- Troisième mission

## Profil recherché
- Expérience ou formation attendue
- Compétences essentielles
- Qualités utiles pour réussir dans le poste

## Pourquoi nous rejoindre
- Un élément concret de votre environnement de travail
- Un avantage ou une opportunité de développement''';

    if (widget.controller.text.trim().isNotEmpty) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Utiliser la structure complète ?'),
          content: const Text(
            'Votre description actuelle sera remplacée par un modèle structuré que vous pourrez personnaliser.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Utiliser le modèle'),
            ),
          ],
        ),
      );
      if (replace != true || !mounted) return;
    }
    _commit(template, template.length);
    _syncGuidedFromMarkup(template);
    setState(() => _mode = _DescriptionEditorMode.guided);
  }
}

class _GuidedSectionField extends StatefulWidget {
  const _GuidedSectionField({
    required this.icon,
    required this.title,
    required this.helper,
    required this.controller,
    required this.hint,
    required this.minLines,
    this.listMode = false,
  });

  final IconData icon;
  final String title;
  final String helper;
  final TextEditingController controller;
  final String hint;
  final int minLines;
  final bool listMode;

  @override
  State<_GuidedSectionField> createState() => _GuidedSectionFieldState();
}

class _GuidedSectionFieldState extends State<_GuidedSectionField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) => Focus(
    onFocusChange: (value) => setState(() => _focused = value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _focused ? const Color(0xFFFBFDFF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused ? const Color(0xFFB9DDFB) : AppColors.lineSoft,
        ),
        boxShadow: _focused
            ? const [
                BoxShadow(
                  color: Color(0x0E1976D2),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ]
            : const [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon, size: 18, color: const Color(0xFF1976D2)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.helper,
                  style: const TextStyle(
                    color: AppColors.slate,
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: widget.controller,
                  minLines: widget.minLines,
                  maxLines: widget.minLines + 4,
                  maxLength: 1180,
                  inputFormatters: [LengthLimitingTextInputFormatter(1180)],
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    counterText: '',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9AABB8),
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: widget.listMode
                        ? const Padding(
                            padding: EdgeInsets.only(bottom: 44),
                            child: Icon(
                              Icons.format_list_bulleted_rounded,
                              size: 18,
                              color: Color(0xFF6A8398),
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: Color(0xFFE2EAF0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: Color(0xFF8CC8F5)),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(9),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEAF4FC) : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: selected ? const Color(0xFFB9DDFB) : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? const Color(0xFF1976D2) : AppColors.slate,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.navy : AppColors.slateDark,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}

class _StructureButton extends StatelessWidget {
  const _StructureButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: Icon(
      icon,
      size: 16,
      color: emphasized ? const Color(0xFF126DC1) : AppColors.slateDark,
    ),
    label: Text(label),
    onPressed: onTap,
    backgroundColor: emphasized
        ? const Color(0xFFEAF4FC)
        : const Color(0xFFF7F9FB),
    side: BorderSide(
      color: emphasized ? const Color(0xFFB9DDFB) : AppColors.lineSoft,
    ),
    labelStyle: TextStyle(
      color: emphasized ? const Color(0xFF126DC1) : AppColors.slateDark,
      fontSize: 10.2,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _EditorToolButton extends StatelessWidget {
  const _EditorToolButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onTap,
    visualDensity: VisualDensity.compact,
    constraints: const BoxConstraints(minWidth: 36, minHeight: 34),
    iconSize: 18,
    color: AppColors.slateDark,
    disabledColor: const Color(0xFFB9C5CE),
    icon: Icon(icon),
  );
}
