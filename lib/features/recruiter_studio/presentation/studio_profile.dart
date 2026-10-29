import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../recruiter_workspace/presentation/workspace_controller.dart';
import 'studio_components.dart';

class StudioProfile extends StatefulWidget {
  const StudioProfile({super.key, required this.value});
  final Map<String, dynamic> value;
  @override
  State<StudioProfile> createState() => _StudioProfileState();
}

class _StudioProfileState extends State<StudioProfile> {
  final _form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields = {
    for (final key in labels.keys)
      key: TextEditingController(text: '${widget.value[key] ?? ''}'),
  };
  int _tab = 0;
  bool _dirty = false;
  late String _cover = '${widget.value['cover'] ?? 'ocean'}';
  static const labels = {
    'firstName': 'Prénom',
    'lastName': 'Nom',
    'jobTitle': 'Fonction',
    'phone': 'Téléphone professionnel',
    'companyName': 'Entreprise',
    'city': 'Ville',
    'website': 'Site internet',
    'sector': 'Secteur d’activité',
    'sizeRange': 'Effectif',
    'tagline': 'Votre promesse en une phrase',
    'description': 'Présentation de votre entreprise',
    'benefits': 'Avantages et cadre de travail',
    'values': 'Vos valeurs',
    'recruitmentProcess': 'Votre processus de recrutement',
  };
  void _changed() {
    _dirty = true;
    context.read<WorkspaceController>().profileDirty = true;
    setState(() {});
  }

  WorkspaceController? _workspace;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _workspace = context.read<WorkspaceController>();
  }

  @override
  void didUpdateWidget(covariant StudioProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dirty && !identical(oldWidget.value, widget.value)) {
      for (final key in labels.keys) {
        _fields[key]!.text = '${widget.value[key] ?? ''}';
      }
      _cover = '${widget.value['cover'] ?? 'ocean'}';
    }
  }

  @override
  void dispose() {
    _workspace?.profileDirty = false;
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<WorkspaceController>();
    final colors = Theme.of(context).colorScheme;
    final complete = [
      'firstName',
      'lastName',
      'jobTitle',
      'companyName',
      'city',
      'website',
      'sector',
      'description',
    ].where((k) => _fields[k]!.text.trim().isNotEmpty).length;
    final progress = complete / 8;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth > 1000;
            final preview = _preview(context);
            final form = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StudioCard(
                  accent: true,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: colors.primary.withValues(alpha: .13),
                        child: Text(
                          _initials,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_fields['firstName']!.text} ${_fields['lastName']!.text}'
                                  .trim(),
                              style: const TextStyle(
                                fontFamily: 'BricolageGrotesque',
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              context.read<AuthController>().user?.email ?? '',
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: progress,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Profil complété à ${(progress * 100).round()} % · $complete/8 informations',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final e in [
                        (0, 'Mon identité'),
                        (1, 'Mon entreprise'),
                        (2, 'Marque employeur'),
                        (3, 'Aperçu public'),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(e.$2),
                            selected: _tab == e.$1,
                            onSelected: (_) => setState(() => _tab = e.$1),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (_tab == 3)
                  preview
                else
                  StudioCard(
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StudioSectionTitle(
                            _tab == 0
                                ? 'Présentez-vous.'
                                : _tab == 1
                                ? 'Une entreprise, une histoire.'
                                : 'Donnez envie de vous rejoindre.',
                            subtitle: _tab == 0
                                ? 'L’identité professionnelle qui accompagne vos échanges.'
                                : _tab == 1
                                ? 'Les informations utiles pour vous découvrir.'
                                : 'Aidez les candidats à se projeter dans votre équipe.',
                          ),
                          LayoutBuilder(
                            builder: (ctx, b) => Wrap(
                              spacing: 16,
                              runSpacing: 18,
                              children: [
                                for (final key
                                    in _tab == 0
                                        ? [
                                            'firstName',
                                            'lastName',
                                            'jobTitle',
                                            'phone',
                                          ]
                                        : _tab == 1
                                        ? [
                                            'companyName',
                                            'city',
                                            'website',
                                            'sector',
                                            'sizeRange',
                                            'tagline',
                                            'description',
                                          ]
                                        : [
                                            'benefits',
                                            'values',
                                            'recruitmentProcess',
                                          ])
                                  SizedBox(
                                    width:
                                        b.maxWidth > 600 &&
                                            ![
                                              'description',
                                              'benefits',
                                              'values',
                                              'recruitmentProcess',
                                              'tagline',
                                            ].contains(key)
                                        ? (b.maxWidth - 16) / 2
                                        : b.maxWidth,
                                    child: TextFormField(
                                      controller: _fields[key],
                                      enabled: !c.busy,
                                      onChanged: (_) => _changed(),
                                      decoration: InputDecoration(
                                        labelText: labels[key],
                                        helperText: key == 'benefits'
                                            ? 'Séparez les avantages par une virgule'
                                            : null,
                                      ),
                                      maxLength:
                                          [
                                            'description',
                                            'benefits',
                                            'values',
                                            'recruitmentProcess',
                                          ].contains(key)
                                          ? 2500
                                          : 200,
                                      maxLines:
                                          [
                                            'description',
                                            'benefits',
                                            'values',
                                            'recruitmentProcess',
                                          ].contains(key)
                                          ? 4
                                          : 1,
                                      validator: (value) {
                                        final v = (value ?? '').trim();
                                        if ([
                                              'firstName',
                                              'lastName',
                                              'companyName',
                                            ].contains(key) &&
                                            v.isEmpty) {
                                          return 'Champ obligatoire';
                                        }
                                        if (key == 'website' && v.isNotEmpty) {
                                          final uri = Uri.tryParse(v);
                                          if (uri == null ||
                                              ![
                                                'http',
                                                'https',
                                              ].contains(uri.scheme) ||
                                              uri.host.isEmpty) {
                                            return 'URL complète attendue (https://…)';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (_tab == 2) ...[
                            const SizedBox(height: 20),
                            const Text(
                              'Ambiance de votre couverture',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                for (final item in {
                                  'ocean': 'Océan',
                                  'forest': 'Forêt',
                                  'sunset': 'Crépuscule',
                                }.entries)
                                  ChoiceChip(
                                    label: Text(item.value),
                                    selected: _cover == item.key,
                                    onSelected: (_) {
                                      _cover = item.key;
                                      _changed();
                                    },
                                  ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton.icon(
                                onPressed: c.busy || !_dirty ? null : _save,
                                icon: const Icon(Icons.check),
                                label: const Text('Enregistrer le profil'),
                              ),
                              if (_dirty)
                                TextButton(
                                  onPressed: c.busy
                                      ? null
                                      : () async {
                                          if (await studioConfirm(
                                                context,
                                                'Annuler les modifications ?',
                                                'Votre dernière version enregistrée sera rétablie.',
                                              ) &&
                                              mounted) {
                                            setState(() {
                                              for (final k in labels.keys) {
                                                _fields[k]!.text =
                                                    '${widget.value[k] ?? ''}';
                                              }
                                              _cover =
                                                  '${widget.value['cover'] ?? 'ocean'}';
                                              _dirty = false;
                                              c.profileDirty = false;
                                            });
                                          }
                                        },
                                  child: const Text('Annuler les changements'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: form),
                      const SizedBox(width: 22),
                      Expanded(flex: 2, child: preview),
                    ],
                  )
                : form;
          },
        ),
      ],
    );
  }

  String get _initials => ['firstName', 'lastName']
      .map((k) => _fields[k]!.text.trim())
      .where((v) => v.isNotEmpty)
      .map((v) => v.characters.first.toUpperCase())
      .join();
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final required = ['firstName', 'lastName', 'companyName'];
    if (required.any((k) => _fields[k]!.text.trim().isEmpty)) {
      studioToast(context, 'Complétez votre prénom, nom et entreprise.');
      return;
    }
    final c = context.read<WorkspaceController>();
    final ok = await c.saveProfile({
      for (final e in _fields.entries) e.key: e.value.text.trim(),
      'cover': _cover,
    });
    if (!mounted) return;
    if (ok) {
      setState(() {
        _dirty = false;
        c.profileDirty = false;
      });
    }
    studioToast(
      context,
      ok
          ? 'Votre profil a été enregistré.'
          : 'Impossible d’enregistrer. Vos modifications restent disponibles.',
    );
  }

  Widget _preview(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final cover = switch (_cover) {
      'forest' => [const Color(0xFF083D36), const Color(0xFF3E8A70)],
      'sunset' => [const Color(0xFF3A234F), const Color(0xFFC47769)],
      _ => [const Color(0xFF03203B), const Color(0xFF276FA1)],
    };
    return StudioCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 150,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'APERÇU ENTREPRISE',
                  style: TextStyle(
                    color: Colors.white70,
                    letterSpacing: 2,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  _fields['companyName']!.text.trim().isEmpty
                      ? 'Votre entreprise'
                      : _fields['companyName']!.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'BricolageGrotesque',
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_fields['tagline']!.text.isNotEmpty)
                  Text(
                    _fields['tagline']!.text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final k in ['city', 'sector', 'sizeRange'])
                      if (_fields[k]!.text.isNotEmpty)
                        Chip(label: Text(_fields[k]!.text)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _fields['description']!.text.isEmpty
                      ? 'Racontez votre mission et ce qui rend votre équipe unique.'
                      : _fields['description']!.text,
                  style: TextStyle(color: colors.onSurfaceVariant, height: 1.6),
                ),
                if (_fields['benefits']!.text.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Ce que nous proposons',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final item
                          in _fields['benefits']!.text
                              .split(',')
                              .where((v) => v.trim().isNotEmpty))
                        Chip(
                          avatar: const Icon(Icons.check, size: 14),
                          label: Text(item.trim()),
                        ),
                    ],
                  ),
                ],
                for (final k in ['values', 'recruitmentProcess'])
                  if (_fields[k]!.text.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      k == 'values'
                          ? 'Nos valeurs'
                          : 'Comment se déroule la rencontre ?',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _fields[k]!.text,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                const Divider(height: 32),
                Row(
                  children: [
                    CircleAvatar(
                      child: Text(_initials.isEmpty ? '?' : _initials),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_fields['firstName']!.text} ${_fields['lastName']!.text}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _fields['jobTitle']!.text,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  context
                              .watch<WorkspaceController>()
                              .settings?['profileVisible'] ==
                          false
                      ? 'Profil masqué aux candidats'
                      : 'Visibilité entreprise activée',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final text =
                        '${_fields['companyName']!.text}\n${_fields['tagline']!.text}\n${_fields['description']!.text}\n${_fields['website']!.text}';
                    await Clipboard.setData(ClipboardData(text: text));
                    if (context.mounted) {
                      studioToast(context, 'Présentation copiée.');
                    }
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copier la présentation'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
