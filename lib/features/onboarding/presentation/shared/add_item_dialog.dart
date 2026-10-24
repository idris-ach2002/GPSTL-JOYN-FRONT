import 'package:flutter/material.dart';

import '../../../../design_system/theme/joyn_material_theme.dart';

/// Demande un texte court dans un [AlertDialog] (compétence, soft skill…).
/// Renvoie `null` si l'utilisateur annule.
Future<String?> showAddItemDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String hintText,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => JoynMaterialScope(
      child: _AddItemDialog(title: title, label: label, hintText: hintText),
    ),
  );
}

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog({
    required this.title,
    required this.label,
    required this.hintText,
  });

  final String title;
  final String label;
  final String hintText;

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 380,
        child: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Ajouter')),
      ],
    );
  }
}
