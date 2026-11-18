import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../profile/data/profile_repository.dart';
import '../../../profile/domain/student_profile.dart';
import '../../domain/candidate_application.dart';
import '../candidate_applications_controller.dart';

Future<bool?> showCoverLetterDialog(
  BuildContext context,
  CandidateApplication application,
  CandidateApplicationsController controller,
) => showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (_) => _CoverLetterDialog(
    application: application,
    controller: controller,
    profiles: context.read<ProfileRepository?>(),
  ),
);

enum _LetterMode { none, general, personalized, pdf }

class _CoverLetterDialog extends StatefulWidget {
  const _CoverLetterDialog({
    required this.application,
    required this.controller,
    required this.profiles,
  });

  final CandidateApplication application;
  final CandidateApplicationsController controller;
  final ProfileRepository? profiles;

  @override
  State<_CoverLetterDialog> createState() => _CoverLetterDialogState();
}

class _CoverLetterDialogState extends State<_CoverLetterDialog> {
  final _letter = TextEditingController();
  _LetterMode _mode = _LetterMode.none;
  Uint8List? _pdf;
  String? _fileName;
  String? _error;
  bool _busy = false;

  String get _job => widget.application.jobTitle ?? 'ce poste';

  @override
  void dispose() {
    _letter.dispose();
    super.dispose();
  }

  String _template([StudentProfile? profile]) {
    final company = widget.application.companyName;
    final bio = profile?.headline.trim() ?? '';
    final skills =
        profile?.skills.take(4).map((skill) => skill.name).join(', ') ?? '';
    final name = [
      profile?.firstName,
      profile?.lastName,
    ].whereType<String>().join(' ').trim();
    return [
      'Madame, Monsieur,',
      'Je vous adresse ma candidature pour l’offre « $_job »'
          '${company == null || company.isEmpty ? '' : ' chez $company'}.',
      if (bio.isNotEmpty) 'Mon profil en quelques mots : $bio.',
      if (skills.isNotEmpty)
        'Je peux notamment mobiliser les compétences suivantes : $skills.',
      'Je serais disponible pour échanger sur vos besoins et vous présenter ma motivation.',
      'Cordialement,',
      if (name.isNotEmpty) name,
    ].join('\n\n');
  }

  Future<void> _choose(_LetterMode mode) async {
    setState(() {
      _mode = mode;
      _error = null;
      _busy = mode == _LetterMode.personalized;
    });
    if (mode == _LetterMode.general) _letter.text = _template();
    if (mode != _LetterMode.personalized) return;
    try {
      final profile = await widget.profiles?.fetchProfile();
      if (mounted) {
        _letter.text = _template(profile);
        if (profile == null) {
          _error = 'Profil indisponible. Vous pouvez compléter ce modèle.';
        }
      }
    } catch (_) {
      if (mounted) {
        _letter.text = _template();
        _error = 'Profil indisponible. Vous pouvez compléter ce modèle.';
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pick() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (file == null || !mounted) return;
      final size = file.lengthSync() ?? await file.length() ?? 0;
      if (!file.name.toLowerCase().endsWith('.pdf') ||
          size <= 0 ||
          size > 5 * 1024 * 1024) {
        setState(() => _error = 'Choisissez un PDF de 5 Mo maximum.');
        return;
      }
      final bytes = await file.readAsBytes();
      if (mounted) {
        setState(() {
          _pdf = bytes;
          _fileName = file.name;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Impossible de lire le fichier.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send() async {
    final text =
        _mode == _LetterMode.general || _mode == _LetterMode.personalized
        ? _letter.text.trim()
        : null;
    if (text?.isEmpty == true || (_mode == _LetterMode.pdf && _pdf == null)) {
      setState(
        () => _error = 'Ajoutez votre lettre ou choisissez « Sans lettre ».',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final sent = await widget.controller.send(
      widget.application,
      coverMessage: text,
      coverPdf: _mode == _LetterMode.pdf ? _pdf : null,
      coverPdfName: _fileName,
    );
    if (!mounted) return;
    if (sent) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _busy = false;
        _error = 'Envoi impossible. Vérifiez le PDF ou réessayez.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: const Text('Envoyer ma candidature'),
      content: SizedBox(
        width: 550,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_job, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              DropdownButtonFormField<_LetterMode>(
                isExpanded: true,
                initialValue: _mode,
                decoration: const InputDecoration(
                  labelText: 'Lettre de motivation facultative',
                ),
                items: const [
                  DropdownMenuItem(
                    value: _LetterMode.none,
                    child: Text('Sans lettre'),
                  ),
                  DropdownMenuItem(
                    value: _LetterMode.general,
                    child: Text('Modèle généraliste'),
                  ),
                  DropdownMenuItem(
                    value: _LetterMode.personalized,
                    child: Text('Modèle adapté à mon profil'),
                  ),
                  DropdownMenuItem(
                    value: _LetterMode.pdf,
                    child: Text('Joindre mon PDF'),
                  ),
                ],
                onChanged: _busy ? null : (mode) => _choose(mode!),
              ),
              const SizedBox(height: 12),
              if (_mode == _LetterMode.general ||
                  _mode == _LetterMode.personalized)
                TextField(
                  controller: _letter,
                  enabled: !_busy,
                  minLines: 6,
                  maxLines: 12,
                  maxLength: 10000,
                  decoration: const InputDecoration(
                    labelText: 'Relisez et adaptez votre lettre',
                  ),
                ),
              if (_mode == _LetterMode.pdf)
                OutlinedButton.icon(
                  onPressed: _busy ? null : _pick,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(_fileName ?? 'Choisir un PDF · 5 Mo maximum'),
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
          onPressed: _busy ? null : _send,
          child: const Text('Envoyer'),
        ),
      ],
    ),
  );
}
