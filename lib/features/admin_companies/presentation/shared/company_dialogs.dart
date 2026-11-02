import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/material/joyn_chip_group.dart';
import '../../../../design_system/material/joyn_notice.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../data/admin_company_repository.dart';
import '../../data/company_logo_picker.dart';
import '../../domain/admin_company.dart';
import '../../domain/admin_company_options.dart';
import '../../domain/company_validators.dart';
import 'company_visuals.dart';

/// Affiche une modale en gardant le thème de la page (Material JOYN), en
/// plein écran sur les petits écrans.
Future<T?> _showAdaptiveDialog<T>(
  BuildContext context,
  Widget Function(BuildContext context, bool fullscreen) builder,
) {
  final fullscreen = MediaQuery.sizeOf(context).width < 600;
  return showDialog<T>(
    context: context,
    builder: (dialogContext) => Theme(
      data: Theme.of(context),
      child: Builder(builder: (context) => builder(context, fullscreen)),
    ),
  );
}

// =============================================================================
// Création / modification
// =============================================================================

/// Formulaire de création ([initial] `null`) ou de modification.
/// Renvoie les données saisies, ou `null` si annulé.
Future<CompanyDraft?> showCompanyFormDialog(
  BuildContext context, {
  required CompanyLogoPicker logoPicker,
  AdminCompany? initial,
}) {
  return _showAdaptiveDialog<CompanyDraft>(
    context,
    (context, fullscreen) => _CompanyFormDialog(
      initial: initial,
      logoPicker: logoPicker,
      fullscreen: fullscreen,
    ),
  );
}

class _CompanyFormDialog extends StatefulWidget {
  const _CompanyFormDialog({
    required this.initial,
    required this.logoPicker,
    required this.fullscreen,
  });

  final AdminCompany? initial;
  final CompanyLogoPicker logoPicker;
  final bool fullscreen;

  @override
  State<_CompanyFormDialog> createState() => _CompanyFormDialogState();
}

class _CompanyFormDialogState extends State<_CompanyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _siret = TextEditingController(
    text: CompanyValidators.formatSiret(widget.initial?.siret ?? ''),
  );
  late final _city = TextEditingController(text: widget.initial?.city);
  late final _address = TextEditingController(text: widget.initial?.address);
  late final _website = TextEditingController(text: widget.initial?.website);
  late String? _sector = widget.initial?.sector;
  late CompanyLogo? _logo = widget.initial?.logo;
  CompanyStatus _initialStatus = CompanyStatus.pending;
  String? _logoError;

  bool get _editing => widget.initial != null;

  @override
  void dispose() {
    for (final controller in [_name, _siret, _city, _address, _website]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final logo = await widget.logoPicker.pickLogo();
      if (!mounted) return;
      setState(() {
        if (logo != null) _logo = logo;
        _logoError = null;
      });
    } on AdminCompanyException catch (error) {
      if (!mounted) return;
      setState(() => _logoError = error.message);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      CompanyDraft(
        name: _name.text.trim(),
        siret: CompanyValidators.siretDigits(_siret.text),
        sector: _sector!,
        city: _city.text.trim(),
        address: _address.text.trim(),
        website: CompanyValidators.normalizeWebsite(_website.text),
        logo: _logo,
        initialStatus: _initialStatus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = _editing ? "Modifier l'entreprise" : 'Ajouter une entreprise';
    final name = _name.text.trim();

    final form = Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CompanyLogoAvatar(
                name: name.isEmpty ? 'Entreprise' : name,
                initials: name.isEmpty ? '?' : name[0].toUpperCase(),
                logo: _logo,
                size: 56,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  children: [
                    TextButton.icon(
                      onPressed: _pickLogo,
                      icon: const Icon(Icons.image_outlined, size: 18),
                      label: Text(
                        _logo == null || _logo!.isEmpty
                            ? 'Ajouter un logo'
                            : 'Changer le logo',
                      ),
                    ),
                    if (_logo != null && !_logo!.isEmpty)
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.slate,
                        ),
                        onPressed: () => setState(() => _logo = null),
                        child: const Text('Retirer'),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_logoError != null) ...[
            const SizedBox(height: 8),
            JoynNotice(tone: JoynNoticeTone.error, message: _logoError!),
          ],
          const SizedBox(height: 18),
          TextFormField(
            key: const ValueKey('company-form-name'),
            controller: _name,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            validator: (value) =>
                CompanyValidators.requiredError(value ?? '', 'le nom'),
            decoration: const InputDecoration(
              labelText: 'Raison sociale ou nom',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const ValueKey('company-form-siret'),
            controller: _siret,
            keyboardType: TextInputType.number,
            inputFormatters: const [_SiretFormatter()],
            validator: (value) => CompanyValidators.siretError(value ?? ''),
            decoration: const InputDecoration(
              labelText: 'Numéro SIRET',
              hintText: '123 456 789 00012',
              prefixIcon: Icon(Icons.badge_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 14),
          DropdownMenuFormField<String>(
            key: const ValueKey('company-form-sector'),
            initialSelection: _sector,
            expandedInsets: EdgeInsets.zero,
            requestFocusOnTap: false,
            label: const Text("Secteur d'activité"),
            onSelected: (value) => setState(() => _sector = value),
            validator: (value) =>
                value == null ? "Choisissez un secteur d'activité." : null,
            dropdownMenuEntries: [
              for (final sector in {...AdminCompanyOptions.sectors, ?_sector})
                DropdownMenuEntry(value: sector, label: sector),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _address,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Adresse',
              prefixIcon: Icon(Icons.place_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const ValueKey('company-form-city'),
            controller: _city,
            textCapitalization: TextCapitalization.words,
            validator: (value) =>
                CompanyValidators.requiredError(value ?? '', 'la ville'),
            decoration: const InputDecoration(labelText: 'Ville'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const ValueKey('company-form-website'),
            controller: _website,
            keyboardType: TextInputType.url,
            validator: (value) => CompanyValidators.websiteError(value ?? ''),
            decoration: const InputDecoration(
              labelText: 'Site web (facultatif)',
              hintText: 'https://entreprise.fr',
              prefixIcon: Icon(Icons.language_rounded, size: 20),
            ),
          ),
          if (!_editing) ...[
            const SizedBox(height: 18),
            Text('Statut initial', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            JoynChipGroup<CompanyStatus>.single(
              options: const [CompanyStatus.pending, CompanyStatus.approved],
              selected: _initialStatus,
              labelOf: (status) => status.label,
              onSelected: (status) => setState(() => _initialStatus = status),
            ),
          ],
        ],
      ),
    );

    final actions = [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Annuler'),
      ),
      FilledButton(
        key: const ValueKey('company-form-submit'),
        onPressed: _submit,
        child: Text(_editing ? 'Enregistrer' : "Ajouter l'entreprise"),
      ),
    ];

    if (widget.fullscreen) {
      return Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: IconButton(
              tooltip: 'Fermer',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: form,
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [actions[0], const SizedBox(width: 8), actions[1]],
              ),
            ),
          ),
        ),
      );
    }

    return AlertDialog(
      title: Text(title),
      content: SizedBox(width: 520, child: SingleChildScrollView(child: form)),
      actions: actions,
    );
  }
}

class _SiretFormatter extends TextInputFormatter {
  const _SiretFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = CompanyValidators.formatSiret(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// =============================================================================
// Motif de rejet ou de suspension
// =============================================================================

enum ModerationAction {
  reject('Rejeter', 'Rejeter l’entreprise'),
  suspend('Suspendre', 'Suspendre l’entreprise');

  const ModerationAction(this.verb, this.title);

  final String verb;
  final String title;
}

/// Demande le motif d'un rejet ou d'une suspension. Renvoie le motif, ou
/// `null` si annulé.
Future<String?> showModerationReasonDialog(
  BuildContext context, {
  required AdminCompany company,
  required ModerationAction action,
}) {
  return _showAdaptiveDialog<String>(
    context,
    (context, _) => _ReasonDialog(company: company, action: action),
  );
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({required this.company, required this.action});

  final AdminCompany company;
  final ModerationAction action;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
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
    final email = widget.company.recruiterEmail;

    return AlertDialog(
      title: Text(widget.action.title),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '« ${widget.company.name} » · SIRET ${CompanyValidators.formatSiret(widget.company.siret)}',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
              ),
              const SizedBox(height: 16),
              Text('Motif', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              JoynChipGroup<String>.single(
                options: AdminCompanyOptions.moderationReasons,
                selected: _preset,
                onSelected: (reason) => setState(() => _preset = reason),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('moderation-reason-details'),
                controller: _details,
                minLines: 2,
                maxLines: 5,
                maxLength: 500,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: _preset == null
                      ? 'Motif détaillé'
                      : 'Précisions (facultatif)',
                  errorText: _attempted && _reason.length < 5
                      ? 'Choisissez ou saisissez un motif.'
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              JoynNotice(
                message: email == null
                    ? 'Aucun recruteur rattaché : personne ne sera prévenu par e-mail.'
                    : 'Le motif sera envoyé par e-mail à $email.',
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
          key: const ValueKey('moderation-confirm'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.errorDeep),
          onPressed: _submit,
          child: Text(widget.action.verb),
        ),
      ],
    );
  }
}

// =============================================================================
// Suppression en deux étapes
// =============================================================================

/// Suppression logique, confirmée en deux étapes : explication de l'impact,
/// puis saisie du nom de l'entreprise. Renvoie `true` si confirmée.
Future<bool> showDeleteCompanyDialog(
  BuildContext context,
  AdminCompany company,
) async {
  final confirmed = await _showAdaptiveDialog<bool>(
    context,
    (context, _) => _DeleteDialog(company: company),
  );
  return confirmed ?? false;
}

class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog({required this.company});

  final AdminCompany company;

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  final _confirmation = TextEditingController();
  bool _secondStep = false;

  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  bool get _matches =>
      _confirmation.text.trim().toLowerCase() ==
      widget.company.name.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = widget.company.name;

    Widget impact(IconData icon, String text) => ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, color: AppColors.errorDeep),
      title: Text(text, style: textTheme.bodyMedium),
    );

    return AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.errorDeep,
        size: 32,
      ),
      title: Text('Supprimer « $name » ?'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_secondStep) ...[
                Text('Conséquences :', style: textTheme.titleSmall),
                impact(
                  Icons.visibility_off_outlined,
                  "L'entreprise et toutes ses offres disparaissent du flux public.",
                ),
                impact(
                  Icons.person_off_outlined,
                  'Ses recruteurs ne peuvent plus publier ni contacter d’étudiant·e·s.',
                ),
                impact(
                  Icons.history_rounded,
                  "L'historique légal des candidatures et des offres déjà émises est conservé (suppression logique).",
                ),
              ] else ...[
                Text.rich(
                  TextSpan(
                    text: 'Pour confirmer, saisissez le nom de l’entreprise : ',
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('delete-confirmation'),
                  controller: _confirmation,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: "Nom de l'entreprise",
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        if (!_secondStep)
          FilledButton(
            key: const ValueKey('delete-continue'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDeep),
            onPressed: () => setState(() => _secondStep = true),
            child: const Text('Continuer'),
          )
        else
          FilledButton(
            key: const ValueKey('delete-confirm'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDeep),
            onPressed: _matches ? () => Navigator.of(context).pop(true) : null,
            child: const Text("Supprimer l'entreprise"),
          ),
      ],
    );
  }
}
