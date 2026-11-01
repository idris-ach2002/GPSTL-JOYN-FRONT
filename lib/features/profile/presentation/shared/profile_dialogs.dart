import 'package:flutter/material.dart';

import '../../domain/student_profile.dart';

/// Demande confirmation avant de quitter avec des modifications non
/// enregistrées. Renvoie `true` pour quitter sans enregistrer.
Future<bool> confirmDiscardChanges(BuildContext context) async {
  final leave = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Theme(
      data: Theme.of(context),
      child: AlertDialog(
        title: const Text('Quitter sans enregistrer ?'),
        content: const Text(
          'Tes modifications non enregistrées seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Continuer à modifier'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    ),
  );
  return leave ?? false;
}

/// Saisie d'une nouvelle formation. Renvoie `null` si annulé.
Future<ProfileEducation?> showAddEducationDialog(BuildContext context) {
  return showDialog<ProfileEducation>(
    context: context,
    builder: (dialogContext) =>
        Theme(data: Theme.of(context), child: const _AddEducationDialog()),
  );
}

class _AddEducationDialog extends StatefulWidget {
  const _AddEducationDialog();

  @override
  State<_AddEducationDialog> createState() => _AddEducationDialogState();
}

class _AddEducationDialogState extends State<_AddEducationDialog> {
  final _title = TextEditingController();
  final _school = TextEditingController();
  final _period = TextEditingController();
  bool _attempted = false;

  @override
  void dispose() {
    _title.dispose();
    _school.dispose();
    _period.dispose();
    super.dispose();
  }

  void _submit() {
    if (_title.text.trim().isEmpty) {
      setState(() => _attempted = true);
      return;
    }
    Navigator.of(context).pop(
      ProfileEducation(
        title: _title.text.trim(),
        school: _school.text.trim(),
        period: _period.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une formation'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Diplôme',
                hintText: 'Master Informatique · M1',
                errorText: _attempted && _title.text.trim().isEmpty
                    ? 'Indique le diplôme.'
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _school,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'École ou université',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _period,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Années',
                hintText: '2026 – 2028',
              ),
            ),
          ],
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
