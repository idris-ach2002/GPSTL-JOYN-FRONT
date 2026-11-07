import 'studio_form_dialog.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../recruiter_workspace/presentation/workspace_controller.dart';
import 'studio_components.dart';
import 'studio_controller.dart';

class StudioSettings extends StatefulWidget {
  const StudioSettings({super.key});
  @override
  State<StudioSettings> createState() => _StudioSettingsState();
}

class _StudioSettingsState extends State<StudioSettings> {
  String? _selected;
  String _search = '';
  static const categories = [
    (
      'appearance',
      Icons.palette_outlined,
      'Apparence et confort',
      'Thème, accent, densité et accessibilité',
      Color(0xFF8666D8),
    ),
    (
      'notifications',
      Icons.notifications_outlined,
      'Notifications',
      'Événements, résumés et horaires calmes',
      Color(0xFFE08335),
    ),
    (
      'recruitment',
      Icons.work_outline_rounded,
      'Recrutement',
      'Valeurs par défaut et organisation',
      Color(0xFF3381C8),
    ),
    (
      'messaging',
      Icons.forum_outlined,
      'Messagerie',
      'Signature, réponses et lecture',
      Color(0xFF158C78),
    ),
    (
      'privacy',
      Icons.shield_outlined,
      'Confidentialité',
      'Visibilité et aperçu des messages',
      Color(0xFF7562BE),
    ),
    (
      'account',
      Icons.manage_accounts_outlined,
      'Compte et sécurité',
      'Mot de passe, données et connexion',
      Color(0xFFB75D72),
    ),
    (
      'help',
      Icons.help_outline,
      'Aide et raccourcis',
      'Bien utiliser votre espace',
      Color(0xFF58778D),
    ),
  ];
  StudioController? _studio;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _studio = context.read<StudioController>();
  }

  @override
  void dispose() {
    _studio?.settingsBack = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studio = context.watch<StudioController>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final selected = _selected ?? (wide ? 'appearance' : null);
        studio.settingsBack = !wide && _selected != null
            ? () {
                if (mounted) setState(() => _selected = null);
              }
            : null;
        final menu = ListView(
          padding: const EdgeInsets.all(18),
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Rechercher un réglage',
              ),
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
            const SizedBox(height: 22),
            if (!wide)
              StudioCard(
                accent: true,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary
                          .withValues(alpha: .14),
                      child: const Icon(Icons.tune),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'À votre façon.',
                            style: TextStyle(
                              fontFamily: 'BricolageGrotesque',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text('Un espace adapté à votre quotidien.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            for (final category in categories.where(
              (c) => (context.read<WorkspaceController>().repository.isMock || const {'appearance','recruitment','messaging','help'}.contains(c.$1)) && '${c.$3} ${c.$4}'.toLowerCase().contains(_search),
            ))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: selected == category.$1
                      ? Theme.of(context).colorScheme.primary
                            .withValues(alpha: .1)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: category.$5.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(category.$2, color: category.$5),
                    ),
                    title: Text(
                      category.$3,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      category.$4,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => setState(() => _selected = category.$1),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Text(
              'Les préférences d’apparence s’appliquent à cet appareil.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
        final content = selected == null
            ? const SizedBox()
            : ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  if (!wide)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _selected = null),
                        icon: const Icon(Icons.chevron_left),
                        label: const Text('Tous les réglages'),
                      ),
                    ),
                  StudioSectionTitle(
                    categories.firstWhere((c) => c.$1 == selected).$3,
                    subtitle: categories.firstWhere((c) => c.$1 == selected).$4,
                  ),
                  if (studio.deviceError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        studio.deviceError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  switch (selected) {
                    'appearance' => _appearance(studio),
                    'notifications' => const _NotificationPreferences(),
                    'recruitment' => _recruitment(studio),
                    'messaging' => _messaging(studio),
                    'privacy' => _privacy(studio),
                    'account' => _account(studio),
                    _ => _help(),
                  },
                ],
              );
        return PopScope(
          canPop: wide || _selected == null,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) setState(() => _selected = null);
          },
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 330, child: menu),
                    VerticalDivider(
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    Expanded(child: content),
                  ],
                )
              : selected == null
              ? menu
              : content,
        );
      },
    );
  }

  Widget _appearance(StudioController c) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StudioCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Votre lumière, votre rythme',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text('Le thème suit votre choix immédiatement.'),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (ctx, box) => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final option in [
                    ('system', 'Système', Icons.brightness_auto_outlined),
                    ('light', 'Clair', Icons.light_mode_outlined),
                    ('dark', 'Sombre', Icons.dark_mode_outlined),
                  ])
                    SizedBox(
                      width: box.maxWidth < 440
                          ? box.maxWidth
                          : (box.maxWidth - 24) / 3,
                      child: InkWell(
                        key: ValueKey('theme-${option.$1}'),
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => c.setPreference('theme', option.$1),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              width: 2,
                              color:
                                  '${c.preferences['theme'] ?? 'system'}' ==
                                      option.$1
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    colors: option.$1 == 'light'
                                        ? [
                                            const Color(0xFFF2F5F9),
                                            Colors.white,
                                          ]
                                        : option.$1 == 'dark'
                                        ? [
                                            const Color(0xFF0B1525),
                                            const Color(0xFF213650),
                                          ]
                                        : [
                                            const Color(0xFFF2F5F9),
                                            const Color(0xFF213650),
                                          ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    option.$3,
                                    color: option.$1 == 'dark'
                                        ? Colors.white
                                        : const Color(0xFF244361),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                option.$2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Couleur d’accent',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final option in [
                  ('coral', 'Corail', const Color(0xFFFF6538)),
                  ('blue', 'Azur', const Color(0xFF3D86F5)),
                  ('mint', 'Menthe', const Color(0xFF198B75)),
                ])
                  ChoiceChip(
                    avatar: CircleAvatar(backgroundColor: option.$3, radius: 8),
                    label: Text(option.$2),
                    selected: c.accent == option.$1,
                    onSelected: (_) => c.setPreference('accent', option.$1),
                  ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      StudioCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Confort de lecture',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            _select(
              'Densité de l’interface',
              '${c.preferences['density'] ?? 'comfortable'}',
              const {'comfortable': 'Confortable', 'compact': 'Compacte'},
              (v) => c.setPreference('density', v),
            ),
            const SizedBox(height: 12),
            Text('Taille du texte · ${(c.textScale * 100).round()} %'),
            Slider(
              value: c.textScale,
              min: 1,
              max: 1.3,
              divisions: 3,
              label: '${(c.textScale * 100).round()} %',
              onChanged: (v) => c.setPreference('textScale', v),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Réduire les animations'),
              subtitle: const Text('Privilégier des transitions discrètes'),
              value: c.reducedMotion,
              onChanged: (v) => c.setPreference('reducedMotion', v),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Renforcer les contrastes'),
              value: c.highContrast,
              onChanged: (v) => c.setPreference('highContrast', v),
            ),
            const Divider(height: 28),
            const Text('Aperçu', style: TextStyle(fontWeight: FontWeight.w700)),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text('Un profil qui fait la différence'),
              subtitle: Text('Votre prochaine rencontre commence ici.'),
              trailing: Icon(Icons.check_circle_outline),
            ),
          ],
        ),
      ),
    ],
  );
  Widget _recruitment(StudioController c) {
    final defaults = c.object('offerDefaults');
    return Column(
      children: [
        const StudioLoadNotice(),
        StudioCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nouvelles offres',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ces valeurs préremplissent vos prochaines créations. Les offres existantes restent indépendantes.',
              ),
              const SizedBox(height: 20),
              _select(
                'Contrat par défaut',
                '${defaults['contract'] ?? 'APPRENTICESHIP'}',
                const {
                  'CDI': 'CDI',
                  'CDD': 'CDD',
                  'INTERNSHIP': 'Stage',
                  'APPRENTICESHIP': 'Alternance',
                  'FREELANCE': 'Freelance',
                },
                (v) => c.save('offerDefaults', {...defaults, 'contract': v}),
              ),
              const SizedBox(height: 16),
              _select(
                'Organisation du travail',
                '${defaults['remote'] ?? 'HYBRID'}',
                const {
                  'ONSITE': 'Présentiel',
                  'HYBRID': 'Hybride',
                  'REMOTE': 'Télétravail',
                },
                (v) => c.save('offerDefaults', {...defaults, 'remote': v}),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Localisation habituelle'),
                subtitle: Text('${defaults['location'] ?? 'Paris, France'}'),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => _editText(
                  'Localisation habituelle',
                  '${defaults['location'] ?? 'Paris, France'}',
                  (v) => c.save('offerDefaults', {...defaults, 'location': v}),
                ),
              ),
              const Divider(height: 28),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Confirmer avant de supprimer'),
                subtitle: const Text(
                  'Les suppressions restent toujours confirmées pour les offres et les données sensibles.',
                ),
                value: true,
                onChanged: null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _messaging(StudioController c) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const StudioLoadNotice(),
      StudioCard(
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.draw_outlined),
              title: const Text('Signature de message'),
              subtitle: Text('${c.data['signature'] ?? 'Aucune signature'}'),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editText(
                'Votre signature',
                '${c.data['signature'] ?? ''}',
                (v) => c.save('signature', v),
                allowEmpty: true,
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ajouter ma signature'),
              subtitle: const Text(
                'Elle est ajoutée avant l’envoi et reste visible dans le champ.',
              ),
              value: c.preferences['useSignature'] == true,
              onChanged: (v) => c.setPreference('useSignature', v),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Ouvrir les liens de conversation en dernier échange',
              ),
              subtitle: const Text(
                'Se placer en bas de la conversation à son ouverture',
              ),
              value: c.preferences['scrollToLatest'] != false,
              onChanged: (v) => c.setPreference('scrollToLatest', v),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      StudioCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Réponses enregistrées',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Réutilisez vos introductions, propositions d’entretien et suivis depuis la messagerie.',
            ),
            const SizedBox(height: 12),
            for (final template in c.list('templates'))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${template['title']}'),
                subtitle: Text(
                  '${template['text']}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  tooltip: 'Supprimer le modèle',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: c.saving
                      ? null
                      : () async {
                          if (await studioConfirm(
                                context,
                                'Supprimer ce modèle ?',
                                'Cette action retire la réponse enregistrée.',
                              ) &&
                              mounted) {
                            c.remove('templates', '${template['id']}');
                          }
                        },
                ),
              ),
            OutlinedButton.icon(
              onPressed: c.saving ? null : () => _template(c),
              icon: const Icon(Icons.add),
              label: const Text('Créer une réponse'),
            ),
          ],
        ),
      ),
    ],
  );
  Widget _privacy(StudioController c) {
    final workspace = context.watch<WorkspaceController>();
    return StudioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Profil entreprise visible'),
            subtitle: const Text(
              'Autoriser les candidats à consulter votre présentation',
            ),
            value: workspace.settings?['profileVisible'] != false,
            onChanged: workspace.busy
                ? null
                : (v) => workspace.saveSettings({
                    ...?workspace.settings,
                    'profileVisible': v,
                  }),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Aperçu des notifications'),
            subtitle: const Text(
              'Afficher le contenu des messages dans le centre de notifications',
            ),
            value: c.preferences['notificationPreview'] != false,
            onChanged: (v) => c.setPreference('notificationPreview', v),
          ),
          const Divider(height: 28),
          const Text(
            'Vos notes de recrutement restent privées dans votre espace. Les messages sont visibles par leur destinataire. Le serveur doit contrôler les droits d’accès en mode API.',
            style: TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _account(StudioController c) {
    final auth = context.watch<AuthController>();
    return StudioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.alternate_email),
            title: const Text('Adresse du compte'),
            subtitle: Text(auth.user?.email ?? ''),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_reset),
            title: const Text('Réinitialiser mon mot de passe'),
            subtitle: const Text('Recevoir un lien à l’adresse du compte'),
            enabled: !auth.isLoading,
            onTap: () async {
              if (auth.user == null) return;
              final ok = await auth.sendPasswordReset(auth.user!.email);
              if (mounted) {
                studioToast(
                  context,
                  ok
                      ? context.read<WorkspaceController>().repository.isMock
                            ? 'Démonstration : aucun e-mail n’est envoyé.'
                            : 'Demande envoyée.'
                      : auth.errorMessage ?? 'Demande impossible.',
                );
              }
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.data_object),
            title: const Text('Consulter et copier mes données de travail'),
            subtitle: const Text(
              'Notes, tâches, modèles et préférences ; aucun jeton',
            ),
            onTap: () => _export(c),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.restore),
            title: const Text('Réinitialiser l’apparence'),
            onTap: () async {
              if (await studioConfirm(
                    context,
                    'Réinitialiser l’apparence ?',
                    'Le thème système et les réglages de lecture par défaut seront rétablis.',
                  ) &&
                  mounted) {
                for (final e in {
                  'theme': 'system',
                  'accent': 'coral',
                  'density': 'comfortable',
                  'textScale': 1.0,
                  'reducedMotion': false,
                  'highContrast': false,
                }.entries) {
                  await c.setPreference(e.key, e.value);
                }
              }
            },
          ),
          const Divider(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            subtitle: const Text('Fermer la session sur cet appareil'),
            onTap: () async {
              if (await studioConfirm(
                    context,
                    'Se déconnecter ?',
                    'Vos préférences d’apparence resteront sur cet appareil.',
                    action: 'Se déconnecter',
                  ) &&
                  mounted) {
                try {
                  await auth.signOut();
                } catch (_) {}
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _help() => const StudioCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StudioSectionTitle('Des raccourcis pour avancer'),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.search),
          title: Text('Trouver une page ou une action'),
          subtitle: Text('Ouvrez la recherche depuis l’en-tête du studio.'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.bookmark_border),
          title: Text('Retrouver vos talents favoris'),
          subtitle: Text(
            'Enregistrez un candidat puis retrouvez-le dans l’onglet Enregistrés.',
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.task_alt),
          title: Text('Organiser votre prochaine action'),
          subtitle: Text(
            'Ajoutez une tâche ou un entretien dans votre centre de travail.',
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.info_outline),
          title: Text('JOYN · Studio recruteur'),
          subtitle: Text(
            'Vos préférences d’appareil sont locales. Les données serveur dépendent de votre connexion au backend.',
          ),
        ),
      ],
    ),
  );
  Widget _select(
    String label,
    String value,
    Map<String, String> values,
    ValueChanged<String> changed,
  ) => DropdownButtonFormField<String>(
    isExpanded: true,
    key: ValueKey('$label-$value'),
    initialValue: values.containsKey(value) ? value : values.keys.first,
    decoration: InputDecoration(labelText: label),
    items: [
      for (final e in values.entries)
        DropdownMenuItem(value: e.key, child: Text(e.value)),
    ],
    onChanged: (v) {
      if (v != null) changed(v);
    },
  );
  Future<void> _editText(
    String title,
    String current,
    Future<bool> Function(String) save, {
    bool allowEmpty = false,
  }) async {
    final value = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => StudioFormDialog(
        title: title,
        fields: [
          StudioFormField(
            'value',
            title,
            lines: 4,
            limit: 1000,
            required: !allowEmpty,
          ),
        ],
        initial: {'value': current},
      ),
    );
    if (value == null) return;
    final ok = await save(value['value']!);
    if (mounted) {
      studioToast(
        context,
        ok
            ? 'Modification enregistrée.'
            : 'Enregistrement impossible. Réessayez.',
      );
    }
  }

  Future<void> _template(StudioController c) async {
    final value = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const StudioFormDialog(
        title: 'Nouvelle réponse enregistrée',
        action: 'Créer',
        fields: [
          StudioFormField('title', 'Nom du modèle', limit: 70),
          StudioFormField(
            'text',
            'Message · utilisez {prenom} pour personnaliser',
            lines: 5,
            limit: 3000,
          ),
        ],
      ),
    );
    if (value == null) return;
    final ok = await c.upsert('templates', {
      'id': StudioController.newId(),
      ...value,
    });
    if (mounted) {
      studioToast(
        context,
        ok ? 'Réponse enregistrée.' : 'Création impossible.',
      );
    }
  }

  void _export(StudioController c) {
    final content = const JsonEncoder.withIndent('  ').convert({
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'workspace': c.data,
      'devicePreferences': c.preferences,
    });
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vos données de travail'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: SingleChildScrollView(child: SelectableText(content)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: content));
              if (ctx.mounted) {
                studioToast(ctx, 'Données copiées dans le presse-papiers.');
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copier le JSON'),
          ),
        ],
      ),
    );
  }
}

class _NotificationPreferences extends StatefulWidget {
  const _NotificationPreferences();
  @override
  State<_NotificationPreferences> createState() =>
      _NotificationPreferencesState();
}

class _NotificationPreferencesState extends State<_NotificationPreferences> {
  Map<String, dynamic>? _draft;
  bool _dirty = false;
  Map<String, dynamic>? _baseline;
  @override
  Widget build(BuildContext context) {
    final c = context.watch<WorkspaceController>();
    if (_draft == null) {
      _dirty = c.notificationDirty;
      _draft = c.notificationDraft ?? {...?c.settings};
    }
    if (!_dirty && !identical(_baseline, c.settings)) {
      _baseline = c.settings;
      _draft = {...?c.settings};
    }
    final d = _draft!;
    return StudioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choisissez ce qui compte',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les préférences sont transmises au serveur. La distribution des e-mails et alertes système dépend de son service de notifications.',
          ),
          const SizedBox(height: 16),
          for (final e in const {
            'emailNotifications': 'Recevoir les e-mails',
            'messageNotifications': 'Nouveaux messages',
            'matchNotifications': 'Nouveaux matches',
            'applicationNotifications': 'Nouvelles candidatures',
            'offerNotifications': 'Activité de mes offres',
          }.entries)
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(e.value),
              value: d[e.key] != false,
              onChanged: c.busy
                  ? null
                  : (v) => setState(() {
                      d[e.key] = v;
                      _dirty = true;
                      c.notificationDirty = true;
                      c.notificationDraft = d;
                    }),
            ),
          const Divider(height: 28),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: '${d['digest'] ?? 'daily'}',
            decoration: const InputDecoration(labelText: 'Résumé par e-mail'),
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Quotidien')),
              DropdownMenuItem(value: 'weekly', child: Text('Hebdomadaire')),
              DropdownMenuItem(value: 'off', child: Text('Désactivé')),
            ],
            onChanged: (v) => setState(() {
              d['digest'] = v;
              _dirty = true;
              c.notificationDirty = true;
              c.notificationDraft = d;
            }),
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Horaires calmes'),
            subtitle: const Text(
              'Reporter les alertes non urgentes en dehors de vos horaires',
            ),
            value: d['quietHours'] == true,
            onChanged: (v) => setState(() {
              d['quietHours'] = v;
              _dirty = true;
              c.notificationDirty = true;
              c.notificationDraft = d;
            }),
          ),
          if (d['quietHours'] == true)
            Wrap(
              spacing: 12,
              children: [
                for (final e in [
                  ('quietStart', 'Début', '20:00'),
                  ('quietEnd', 'Fin', '08:00'),
                ])
                  OutlinedButton.icon(
                    onPressed: () async {
                      final parts = '${d[e.$1] ?? e.$3}'.split(':');
                      final value = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: int.tryParse(parts.first) ?? 20,
                          minute: parts.length > 1
                              ? int.tryParse(parts[1]) ?? 0
                              : 0,
                        ),
                      );
                      if (value != null && mounted) {
                        setState(() {
                          d[e.$1] =
                              '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
                          _dirty = true;
                          c.notificationDirty = true;
                          c.notificationDraft = d;
                        });
                      }
                    },
                    icon: const Icon(Icons.schedule),
                    label: Text('${e.$2} · ${d[e.$1] ?? e.$3}'),
                  ),
              ],
            ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: !_dirty || c.busy
                ? null
                : () async {
                    if (d['quietHours'] == true &&
                        '${d['quietStart'] ?? '20:00'}' ==
                            '${d['quietEnd'] ?? '08:00'}') {
                      studioToast(
                        context,
                        'Choisissez deux horaires différents.',
                      );
                      return;
                    }
                    final ok = await c.saveSettings(d);
                    if (context.mounted) {
                      if (ok) {
                        setState(() {
                          _dirty = false;
                          c.notificationDirty = false;
                          c.notificationDraft = null;
                          _draft = {...?c.settings};
                        });
                      }
                      studioToast(
                        context,
                        ok ? 'Préférences enregistrées.' : 'Impossible d’enregistrer. Votre saisie est conservée.',
                      );
                    }
                  },
            icon: const Icon(Icons.check),
            label: const Text('Enregistrer les notifications'),
          ),
        ],
      ),
    );
  }
}
