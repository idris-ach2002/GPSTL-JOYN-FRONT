import 'package:flutter/material.dart';

import '../../../../design_system/material/joyn_chip_group.dart';
import '../../../../design_system/material/joyn_notice.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/company_verification.dart';

Future<T?> _showThemedDialog<T>(BuildContext context, Widget dialog) {
  return showDialog<T>(
    context: context,
    builder: (_) => Theme(data: Theme.of(context), child: dialog),
  );
}

/// Validation manuelle : l'admin confirme avoir contrôlé les informations
/// légales. Renvoie la note (éventuellement vide), ou `null` si annulé.
Future<String?> showApproveVerificationDialog(
  BuildContext context,
  CompanyVerification item,
) => _showThemedDialog<String>(context, _ApproveDialog(item: item));

class _ApproveDialog extends StatefulWidget {
  const _ApproveDialog({required this.item});

  final CompanyVerification item;

  @override
  State<_ApproveDialog> createState() => _ApproveDialogState();
}

class _ApproveDialogState extends State<_ApproveDialog> {
  final _note = TextEditingController();
  bool _checked = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: const Text('Valider manuellement'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '« ${widget.item.companyName} » sera marquée comme vérifiée et ses offres deviendront visibles.',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              key: const ValueKey('approve-checked'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _checked,
              onChanged: (value) => setState(() => _checked = value ?? false),
              title: Text(
                'J’ai contrôlé les informations légales (Kbis, avis SIRENE ou site officiel).',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Note interne (facultatif)',
                hintText: 'Ex. : Kbis reçu par e-mail le 08/11',
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
        FilledButton(
          key: const ValueKey('approve-confirm'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.successDeep),
          onPressed: _checked
              ? () => Navigator.of(context).pop(_note.text.trim())
              : null,
          child: const Text('Valider l’entreprise'),
        ),
      ],
    );
  }
}

/// Demande de justificatif : documents attendus et message au recruteur.
/// Renvoie le texte transmis, ou `null` si annulé.
Future<String?> showRequestDocumentDialog(
  BuildContext context,
  CompanyVerification item,
) => _showThemedDialog<String>(context, _RequestDocumentDialog(item: item));

class _RequestDocumentDialog extends StatefulWidget {
  const _RequestDocumentDialog({required this.item});

  final CompanyVerification item;

  @override
  State<_RequestDocumentDialog> createState() => _RequestDocumentDialogState();
}

class _RequestDocumentDialogState extends State<_RequestDocumentDialog> {
  final _message = TextEditingController();
  final Set<String> _documents = {VerificationOptions.documents.first};

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  String get _note => [
    _documents.join(', '),
    if (_message.text.trim().isNotEmpty) _message.text.trim(),
  ].join(' — ');

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final email = widget.item.recruiterEmail;
    return AlertDialog(
      title: const Text('Demander un justificatif'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Documents attendus', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              JoynChipGroup<String>.multi(
                options: VerificationOptions.documents,
                selected: _documents,
                onToggled: (document) => setState(() {
                  if (!_documents.remove(document)) _documents.add(document);
                }),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _message,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Message au recruteur (facultatif)',
                ),
              ),
              const SizedBox(height: 8),
              JoynNotice(
                message: email == null
                    ? 'Aucun recruteur rattaché.'
                    : 'La demande sera envoyée à $email.',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const ValueKey('request-document-confirm'),
          onPressed: _documents.isEmpty
              ? null
              : () => Navigator.of(context).pop(_note),
          child: const Text('Envoyer la demande'),
        ),
      ],
    );
  }
}

/// Refus : motif obligatoire, transmis au recruteur. Renvoie le motif, ou
/// `null` si annulé.
Future<String?> showRefuseVerificationDialog(
  BuildContext context,
  CompanyVerification item,
) => _showThemedDialog<String>(context, _RefuseDialog(item: item));

class _RefuseDialog extends StatefulWidget {
  const _RefuseDialog({required this.item});

  final CompanyVerification item;

  @override
  State<_RefuseDialog> createState() => _RefuseDialogState();
}

class _RefuseDialogState extends State<_RefuseDialog> {
  final _details = TextEditingController();
  String? _preset;
  bool _attempted = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  String get _reason {
    final details = _details.text.trim();
    final preset = _preset;
    if (preset == null) return details;
    return details.isEmpty ? preset : '$preset — $details';
  }

  void _submit() {
    if (_reason.length < 5) {
      setState(() => _attempted = true);
      return;
    }
    Navigator.of(context).pop(_reason);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: const Text('Refuser la vérification'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '« ${widget.item.companyName} » ne pourra pas publier d’offres.',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
              ),
              const SizedBox(height: 14),
              Text('Motif (obligatoire)', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              JoynChipGroup<String>.single(
                options: VerificationOptions.refusalReasons,
                selected: _preset,
                onSelected: (reason) => setState(() => _preset = reason),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('refuse-details'),
                controller: _details,
                minLines: 2,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: _preset == null
                      ? 'Motif détaillé'
                      : 'Précisions (facultatif)',
                  errorText: _attempted && _reason.length < 5
                      ? 'Le motif est obligatoire.'
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const ValueKey('refuse-confirm'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.errorDeep),
          onPressed: _submit,
          child: const Text('Refuser'),
        ),
      ],
    );
  }
}
