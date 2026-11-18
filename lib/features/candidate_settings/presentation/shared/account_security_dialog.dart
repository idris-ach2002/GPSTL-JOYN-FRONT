import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';

Future<bool?> showAccountSecurityDialog(
  BuildContext context,
  ApiClient api, {
  required bool updateEmail,
}) => showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (_) => _AccountSecurityDialog(api: api, updateEmail: updateEmail),
);

class _AccountSecurityDialog extends StatefulWidget {
  const _AccountSecurityDialog({required this.api, required this.updateEmail});
  final ApiClient api;
  final bool updateEmail;

  @override
  State<_AccountSecurityDialog> createState() => _AccountSecurityDialogState();
}

class _AccountSecurityDialogState extends State<_AccountSecurityDialog> {
  final _password = TextEditingController();
  final _email = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (_password.text.isEmpty ||
        (widget.updateEmail &&
            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email))) {
      setState(() => _error = 'Vérifiez les champs saisis.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (widget.updateEmail) {
        await widget.api.patchJson(
          '/api/v1/account/credentials',
          body: {'currentPassword': _password.text, 'email': email},
        );
      } else {
        await widget.api.postJson(
          '/api/v1/account/sessions/revoke',
          body: {'currentPassword': _password.text},
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(
          () => _error = switch (e.statusCode) {
            403 => 'Mot de passe incorrect.',
            409 => 'Cette adresse est déjà utilisée.',
            _ => 'Impossible d’enregistrer la modification.',
          },
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: Text(
        widget.updateEmail
            ? 'Modifier mon adresse e-mail'
            : 'Déconnecter tous mes appareils',
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Vous devrez vous reconnecter sur tous vos appareils.',
              ),
              const SizedBox(height: 12),
              if (widget.updateEmail) ...[
                TextField(
                  controller: _email,
                  enabled: !_busy,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Nouvelle adresse e-mail',
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _password,
                enabled: !_busy,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                ),
              ),
              if (_busy) const LinearProgressIndicator(),
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
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: const Text('Confirmer'),
        ),
      ],
    ),
  );
}

class AccountAlertPreferences extends StatefulWidget {
  const AccountAlertPreferences({super.key, required this.api});
  final ApiClient api;

  @override
  State<AccountAlertPreferences> createState() =>
      _AccountAlertPreferencesState();
}

class _AccountAlertPreferencesState extends State<AccountAlertPreferences> {
  static const _path = '/api/v1/account/notification-preferences';
  late Future<Map> _saved;
  bool _busy = false;

  Future<Map> _get() async => await widget.api.getJson(_path) as Map;

  @override
  void initState() {
    super.initState();
    _saved = _get();
  }

  Future<void> _change(Map current, String key, bool enabled) async {
    setState(() => _busy = true);
    try {
      final saved = await widget.api.putJson(
        _path,
        body: {
          'messageAlerts': current['messageAlerts'],
          'opportunityAlerts': current['opportunityAlerts'],
          key: enabled,
        },
      ) as Map;
      if (mounted) setState(() => _saved = Future.value(saved));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Préférences non enregistrées.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _saved,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return TextButton(
          onPressed: () => setState(() => _saved = _get()),
          child: const Text('Recharger les préférences de notification'),
        );
      }
      if (!snapshot.hasData) return const LinearProgressIndicator();
      final saved = snapshot.data!;
      return Column(
        children: [
          for (final (key, label) in [
            ('messageAlerts', 'Nouveaux messages'),
            ('opportunityAlerts', 'Offres, matchs et recommandations'),
          ])
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: saved[key] == true,
              title: Text(label),
              onChanged: _busy ? null : (value) => _change(saved, key, value),
            ),
          const Text(
            'Les alertes de suivi de candidature et d’entretien restent actives.',
          ),
        ],
      );
    },
  );
}
