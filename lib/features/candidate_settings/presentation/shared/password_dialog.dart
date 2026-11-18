import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';

Future<bool?> showPasswordDialog(BuildContext context, ApiClient api) =>
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PasswordDialog(api: api),
    );

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.api});
  final ApiClient api;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirmation = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final password = _new.text;
    final String? error;
    if (_current.text.isEmpty) {
      error = 'Saisissez votre mot de passe actuel.';
    } else if (password.length < 12 || utf8.encode(password).length > 72) {
      error = 'Utilisez au moins 12 caractères et 72 octets maximum.';
    } else if (_confirmation.text != password) {
      error = 'La confirmation doit correspondre au nouveau mot de passe.';
    } else {
      error = null;
    }
    setState(() => _error = error);
    if (error != null) return;

    setState(() => _saving = true);
    try {
      await widget.api.patchJson(
        '/api/v1/account/credentials',
        body: {'currentPassword': _current.text, 'newPassword': password},
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (ex) {
      if (mounted) {
        setState(
          () => _error = ex.statusCode == 403
              ? 'Le mot de passe actuel est incorrect.'
              : 'Impossible de modifier le mot de passe. Réessayez.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: const Text('Modifier mon mot de passe'),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(_current, 'Mot de passe actuel'),
              const SizedBox(height: 12),
              _field(_new, 'Nouveau mot de passe'),
              const SizedBox(height: 12),
              _field(_confirmation, 'Confirmer le nouveau mot de passe'),
              const SizedBox(height: 12),
              const Text(
                'Reconnectez-vous avec le nouveau mot de passe après avoir enregistré.',
              ),
              if (_saving) const LinearProgressIndicator(),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
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
          onPressed: _saving ? null : _save,
          child: const Text('Enregistrer'),
        ),
      ],
    ),
  );

  Widget _field(TextEditingController controller, String label) => TextField(
    controller: controller,
    obscureText: true,
    enabled: !_saving,
    enableSuggestions: false,
    autocorrect: false,
    decoration: InputDecoration(labelText: label),
  );
}
