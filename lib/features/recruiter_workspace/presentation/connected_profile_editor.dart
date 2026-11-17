import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../profile/data/profile_file_picker.dart';
import '../data/recruiter_workspace_repository.dart';
import 'workspace_controller.dart';

class ConnectedProfileEditor extends StatefulWidget {
  const ConnectedProfileEditor({super.key, required this.value});
  final Map<String, dynamic> value;
  @override
  State<ConnectedProfileEditor> createState() => _ConnectedProfileEditorState();
}

class _ConnectedProfileEditorState extends State<ConnectedProfileEditor> {
  final _form = GlobalKey<FormState>();
  final _companyForm = GlobalKey<FormState>();
  late final _first = TextEditingController(
    text: '${widget.value['firstName'] ?? ''}',
  );
  late final _last = TextEditingController(
    text: '${widget.value['lastName'] ?? ''}',
  );
  late final _companyFields = <String, TextEditingController>{
    for (final key in _labels.keys)
      key: TextEditingController(text: '${company[key] ?? ''}'),
  };
  static const _labels = {
    'name': 'Nom de l’entreprise',
    'description': 'Présentation',
    'website': 'Site internet',
    'sector': 'Secteur',
    'companySize': 'Effectif',
    'address': 'Adresse',
  };
  Map get company => widget.value['company'] as Map? ?? const {};
  int? get companyId => int.tryParse('${widget.value['companyId']}');
  ApiRecruiterWorkspaceRepository get repository =>
      context.read<WorkspaceController>().repository
          as ApiRecruiterWorkspaceRepository;
  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    for (final field in _companyFields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    final controller = context.read<WorkspaceController>();
    final success = await controller.run(action);
    if (!mounted || !success) return;
    await controller.load('profile');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modification enregistrée.')),
      );
    }
  }

  Future<void> _image(bool logo) async {
    try {
      final picked = await const DeviceProfileFilePicker().pickPhoto();
      if (picked == null || !mounted) return;
      await _run(
        () => logo
            ? repository.uploadLogo(companyId!, picked.bytes, picked.fileName)
            : repository.uploadPhoto(picked.bytes, picked.fileName),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Choisissez une image JPG, PNG ou WebP de moins de 5 Mo.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteCompany() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette entreprise ?'),
        content: const Text(
          'Cette action clôture ses offres actives et retire les droits de ses recruteurs. Les candidatures et conversations sont conservées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer l’entreprise'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    final auth = context.read<AuthController>();
    final success = await context.read<WorkspaceController>().run(
      () => repository.deleteCompany(companyId!),
    );
    if (success) await auth.signOut();
  }

  Widget _avatar(Object? url) => CircleAvatar(
    radius: 32,
    backgroundImage: url == null || '$url'.isEmpty
        ? null
        : NetworkImage('$url'),
    child: url == null || '$url'.isEmpty
        ? const Icon(Icons.person_outline)
        : null,
  );
  @override
  Widget build(BuildContext context) {
    final busy = context.watch<WorkspaceController>().busy;
    final photo =
        widget.value['profile_picture_url'] ?? widget.value['photo_url'];
    final logo = company['logoUrl'];
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Form(
          key: _form,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mon profil',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _avatar(photo),
                      OutlinedButton.icon(
                        onPressed: busy ? null : () => _image(false),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Changer ma photo'),
                      ),
                      if (photo != null)
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => _run(repository.deletePhoto),
                          child: const Text('Retirer la photo'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('${widget.value['email'] ?? ''}'),
                  TextFormField(
                    controller: _first,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                    validator: _required,
                  ),
                  TextFormField(
                    controller: _last,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: _required,
                  ),
                  FilledButton(
                    onPressed: busy
                        ? null
                        : () {
                            if (!_form.currentState!.validate()) return;
                            _run(() async {
                              await repository.saveProfile({
                                'firstName': _first.text.trim(),
                                'lastName': _last.text.trim(),
                              });
                            });
                          },
                    child: const Text('Enregistrer mon profil'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.value['companyError'] != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('${widget.value['companyError']}'),
          ),
        if (companyId != null && widget.value['companyError'] == null)
          Form(
            key: _companyForm,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Mon entreprise',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _avatar(logo),
                        OutlinedButton.icon(
                          onPressed: busy ? null : () => _image(true),
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text('Changer le logo'),
                        ),
                        if (logo != null)
                          TextButton(
                            onPressed: busy
                                ? null
                                : () => _run(
                                    () => repository.deleteLogo(companyId!),
                                  ),
                            child: const Text('Retirer le logo'),
                          ),
                      ],
                    ),
                    for (final entry in _labels.entries)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          controller: _companyFields[entry.key],
                          decoration: InputDecoration(labelText: entry.value),
                          maxLines: entry.key == 'description' ? 4 : 1,
                          validator: entry.key == 'name' ? _required : null,
                        ),
                      ),
                    FilledButton(
                      onPressed: busy
                          ? null
                          : () {
                              if (!_companyForm.currentState!.validate()) {
                                return;
                              }
                              _run(
                                () => repository.saveCompany(companyId!, {
                                  for (final entry in _companyFields.entries)
                                    entry.key: entry.value.text.trim(),
                                }),
                              );
                            },
                      child: const Text('Enregistrer l’entreprise'),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: busy ? null : _deleteCompany,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Supprimer l’entreprise'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: busy
              ? null
              : () => context.read<AuthController>().signOut(),
          icon: const Icon(Icons.logout),
          label: const Text('Se déconnecter'),
        ),
      ],
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Champ requis' : null;
}
