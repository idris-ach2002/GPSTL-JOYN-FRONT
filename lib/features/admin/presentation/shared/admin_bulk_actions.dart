import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../recruiter_studio/data/studio_export.dart';
import '../../../recruiter_studio/presentation/studio_export_dialog.dart';

mixin AdminSelection on ChangeNotifier {
  final _selected = <String>{};
  Set<String> get selectedIds => Set.unmodifiable(_selected);
  bool selected(String id) => _selected.contains(id);

  void select(String id, bool selected) {
    if (selected && _selected.length >= 100) return;
    final changed = selected ? _selected.add(id) : _selected.remove(id);
    if (changed) notifyListeners();
  }

  void selectVisible(Iterable<String> ids) {
    final before = _selected.length;
    _selected.addAll(
      ids.where((id) => !_selected.contains(id)).take(100 - before).toList(),
    );
    if (_selected.length != before) notifyListeners();
  }

  void clearSelection() {
    if (_selected.isEmpty) return;
    _selected.clear();
    notifyListeners();
  }
}

class AdminBulkActions extends StatelessWidget {
  const AdminBulkActions({
    super.key,
    required this.kind,
    required this.selection,
    required this.export,
    required this.reload,
    this.visibleIds,
  });

  final String kind;
  final AdminSelection selection;
  final Future<List<List<Object?>>> Function() export;
  final Future<void> Function() reload;
  final List<String>? visibleIds;

  @override
  Widget build(BuildContext context) {
    final count = selection.selectedIds.length;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (visibleIds case final ids?)
          AdminSelectionCheckbox(selection: selection, visibleIds: ids),
        OutlinedButton.icon(
          onPressed: () async {
            try {
              final rows = await export();
              if (context.mounted) {
                await studioExport(
                  context,
                  name: 'joyn-$kind.csv',
                  text: studioCsv(rows),
                  extension: 'csv',
                );
              }
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Impossible d’exporter la liste.'),
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.download_outlined),
          label: const Text('Exporter en CSV'),
        ),
        OutlinedButton.icon(
          onPressed: count == 0
              ? null
              : () async {
                  final removed = await confirmAdminRemoval(
                    context,
                    kind,
                    selection.selectedIds,
                  );
                  if (removed) {
                    selection.clearSelection();
                    await reload();
                  }
                },
          icon: const Icon(Icons.delete_outline),
          label: Text('Supprimer la sélection ($count)'),
        ),
      ],
    );
  }
}

class AdminSelectionCheckbox extends StatelessWidget {
  const AdminSelectionCheckbox({
    super.key,
    required this.selection,
    required this.visibleIds,
  });

  final AdminSelection selection;
  final List<String> visibleIds;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selection.selectedIds.isNotEmpty;
    final allVisibleSelected =
        visibleIds.isNotEmpty && visibleIds.every(selection.selected);
    return Tooltip(
      message: hasSelection
          ? 'Effacer la sélection sur toutes les pages'
          : 'Sélectionner les lignes affichées',
      child: Checkbox(
        tristate: true,
        value: hasSelection ? (allVisibleSelected ? true : null) : false,
        onChanged: hasSelection
            ? (_) => selection.clearSelection()
            : visibleIds.isEmpty
            ? null
            : (_) => selection.selectVisible(visibleIds),
      ),
    );
  }
}

Future<bool> confirmAdminRemoval(
  BuildContext context,
  String kind,
  Set<String> ids,
) async {
  final api = context.read<ApiClient?>();
  if (api == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La suppression sécurisée nécessite le mode API.'),
      ),
    );
    return false;
  }
  return await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (_) => _RemovalDialog(api: api, ids: ids, kind: kind),
      ) ??
      false;
}

class _RemovalDialog extends StatefulWidget {
  const _RemovalDialog({
    required this.api,
    required this.ids,
    required this.kind,
  });
  final ApiClient api;
  final Set<String> ids;
  final String kind;

  @override
  State<_RemovalDialog> createState() => _RemovalDialogState();
}

class _RemovalDialogState extends State<_RemovalDialog> {
  final _password = TextEditingController();
  final _code = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _code.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.api.postJson(
        '/api/v1/admin/${widget.kind}/bulk-delete',
        body: {
          'ids': widget.ids.map(int.parse).toList(),
          'password': _password.text,
          'code': _code.text,
          'confirmation': _confirm.text,
        },
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (ex) {
      if (mounted) {
        setState(
          () => _error = switch (ex.statusCode) {
            403 => 'Mot de passe ou code invalide. Vérifiez aussi que le code n’a pas déjà servi.',
            412 => 'La double authentification doit être configurée pour ce compte avant de supprimer des éléments.',
            429 => 'Trop de tentatives. Réessayez dans une minute.',
            404 || 409 => 'La sélection a changé. Actualisez la liste.',
            _ => 'La suppression n’a pas pu aboutir. Réessayez.',
          },
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final valid =
        _password.text.isNotEmpty &&
        RegExp(r'^\d{6}$').hasMatch(_code.text) &&
        _confirm.text == 'SUPPRIMER';
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: Text(
          'Supprimer ${widget.ids.length} ${widget.kind == 'users' ? 'compte(s)' : 'entreprise(s)'}',
        ),
        content: SizedBox(
          width: 510,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.kind == 'users'
                      ? 'Les comptes sélectionnés perdront leur accès à JOYN.'
                      : 'Les établissements sélectionnés seront retirés et leurs offres clôturées.',
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _password,
                  enabled: !_saving,
                  obscureText: true,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe JOYN',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ouvrez votre application d’authentification et utilisez le code affiché pour votre compte administrateur JOYN. Si ce compte n’y figure pas, demandez sa configuration à la personne qui gère le serveur JOYN.',
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _code,
                  enabled: !_saving,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Code temporaire à 6 chiffres',
                  ),
                ),
                TextField(
                  controller: _confirm,
                  enabled: !_saving,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Saisissez SUPPRIMER',
                  ),
                ),
                if (_saving) const LinearProgressIndicator(),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: _saving || !valid ? null : _delete,
            child: const Text('Confirmer la suppression'),
          ),
        ],
      ),
    );
  }
}
