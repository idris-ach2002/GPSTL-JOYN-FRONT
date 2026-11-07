import 'package:flutter/material.dart';

class StudioFormField {
  const StudioFormField(
    this.keyName,
    this.label, {
    this.lines = 1,
    this.limit = 200,
    this.required = true,
  });
  final String keyName, label;
  final int lines, limit;
  final bool required;
}

/// Les contrôleurs appartiennent au dialogue jusqu'à son démontage effectif.
class StudioFormDialog extends StatefulWidget {
  const StudioFormDialog({
    super.key,
    required this.title,
    required this.fields,
    this.initial = const {},
    this.action = 'Enregistrer',
  });
  final String title, action;
  final List<StudioFormField> fields;
  final Map<String, String> initial;
  @override
  State<StudioFormDialog> createState() => _StudioFormDialogState();
}

class _StudioFormDialogState extends State<StudioFormDialog> {
  final _form = GlobalKey<FormState>();
  late final _controllers = {
    for (final f in widget.fields)
      f.keyName: TextEditingController(text: widget.initial[f.keyName] ?? ''),
  };
  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final f in widget.fields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _controllers[f.keyName],
                    autofocus: widget.fields.first == f,
                    decoration: InputDecoration(labelText: f.label),
                    maxLines: f.lines,
                    maxLength: f.limit,
                    validator: (v) => f.required && (v ?? '').trim().isEmpty
                        ? 'Champ obligatoire'
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, {
              for (final e in _controllers.entries) e.key: e.value.text.trim(),
            });
          }
        },
        child: Text(widget.action),
      ),
    ],
  );
}
