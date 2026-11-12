import 'package:flutter/material.dart';

import '../../../../design_system/material/joyn_chip_group.dart';
import '../../../../design_system/material/joyn_notice.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/admin_user.dart';
import '../../domain/admin_user_options.dart';

Future<T?> _showThemedDialog<T>(BuildContext context, Widget dialog) {
  return showDialog<T>(
    context: context,
    builder: (_) => Theme(data: Theme.of(context), child: dialog),
  );
}

// =============================================================================
// Suspension / bannissement : motif obligatoire
// =============================================================================

enum SanctionKind {
  suspend('Suspendre', 'Suspendre le compte'),
  ban('Bannir', 'Bannir le compte');

  const SanctionKind(this.verb, this.title);

  final String verb;
  final String title;
}

/// Demande le motif d'une suspension ou d'un bannissement. Renvoie le motif,
/// ou `null` si annulé.
Future<String?> showSanctionDialog(
  BuildContext context, {
  required AdminUserAccount user,
  required SanctionKind kind,
}) =>
    _showThemedDialog<String>(context, _SanctionDialog(user: user, kind: kind));

class _SanctionDialog extends StatefulWidget {
  const _SanctionDialog({required this.user, required this.kind});

  final AdminUserAccount user;
  final SanctionKind kind;

  @override
  State<_SanctionDialog> createState() => _SanctionDialogState();
}

class _SanctionDialogState extends State<_SanctionDialog> {
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
    final ban = widget.kind == SanctionKind.ban;

    return AlertDialog(
      title: Text(widget.kind.title),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.user.fullName} · ${widget.user.email}',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
              ),
              const SizedBox(height: 12),
              JoynNotice(
                tone: ban ? JoynNoticeTone.error : JoynNoticeTone.warning,
                message: ban
                    ? 'Le compte sera bloqué définitivement : connexion impossible et profil masqué.'
                    : 'Le compte sera bloqué jusqu’à sa réactivation par un administrateur.',
              ),
              const SizedBox(height: 16),
              Text('Motif (obligatoire)', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              JoynChipGroup<String>.single(
                options: AdminUserOptions.sanctionReasons,
                selected: _preset,
                onSelected: (reason) => setState(() => _preset = reason),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('sanction-details'),
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
          key: const ValueKey('sanction-confirm'),
          style: FilledButton.styleFrom(
            backgroundColor: ban
                ? const Color(0xFF111827)
                : AppColors.errorDeep,
          ),
          onPressed: _submit,
          child: Text(widget.kind.verb),
        ),
      ],
    );
  }
}

// =============================================================================
// Changement de rôle : confirmation renforcée
// =============================================================================

/// Choix d'un nouveau rôle, confirmé par la saisie de l'e-mail du compte.
/// Renvoie le rôle choisi, ou `null` si annulé.
Future<AccountRole?> showChangeRoleDialog(
  BuildContext context,
  AdminUserAccount user,
) => _showThemedDialog<AccountRole>(context, _RoleDialog(user: user));

class _RoleDialog extends StatefulWidget {
  const _RoleDialog({required this.user});

  final AdminUserAccount user;

  @override
  State<_RoleDialog> createState() => _RoleDialogState();
}

class _RoleDialogState extends State<_RoleDialog> {
  final _confirmation = TextEditingController();
  late AccountRole _role = widget.user.role;

  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  bool get _confirmed =>
      _role != widget.user.role &&
      _confirmation.text.trim().toLowerCase() ==
          widget.user.email.toLowerCase();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final promotesAdmin =
        _role == AccountRole.admin && widget.user.role != AccountRole.admin;

    return AlertDialog(
      title: const Text('Modifier le rôle'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.user.fullName} · rôle actuel : ${widget.user.role.label}',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
              ),
              const SizedBox(height: 16),
              Text('Nouveau rôle', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              JoynChipGroup<AccountRole>.single(
                options: AccountRole.values,
                selected: _role,
                labelOf: (role) => role.label,
                onSelected: (role) => setState(() => _role = role),
              ),
              if (promotesAdmin) ...[
                const SizedBox(height: 14),
                const JoynNotice(
                  tone: JoynNoticeTone.warning,
                  message: 'Un administrateur peut modérer tous les comptes et toutes les entreprises de la plateforme.',
                ),
              ],
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  text: 'Pour confirmer, saisissez l’e-mail du compte : ',
                  children: [
                    TextSpan(
                      text: widget.user.email,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              TextField(
                key: const ValueKey('role-confirmation'),
                controller: _confirmation,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'E-mail'),
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
          key: const ValueKey('role-confirm'),
          onPressed: _confirmed ? () => Navigator.of(context).pop(_role) : null,
          child: const Text('Changer le rôle'),
        ),
      ],
    );
  }
}

// =============================================================================
// Suppression / anonymisation RGPD : deux étapes
// =============================================================================

/// Renvoie `true` si la suppression est confirmée.
Future<bool> showDeleteUserDialog(
  BuildContext context,
  AdminUserAccount user,
) async {
  final confirmed = await _showThemedDialog<bool>(
    context,
    _DeleteDialog(user: user),
  );
  return confirmed ?? false;
}

class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog({required this.user});

  final AdminUserAccount user;

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
      widget.user.email.toLowerCase();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
      title: Text('Supprimer le compte de ${widget.user.fullName} ?'),
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
                  Icons.person_off_outlined,
                  'Connexion impossible et profil retiré de la plateforme.',
                ),
                impact(
                  Icons.privacy_tip_outlined,
                  'Nom, e-mail et coordonnées sont anonymisés (RGPD).',
                ),
                impact(
                  Icons.history_rounded,
                  'L’historique des candidatures et des offres est conservé de façon anonyme.',
                ),
              ] else ...[
                Text.rich(
                  TextSpan(
                    text: 'Pour confirmer, saisissez l’e-mail du compte : ',
                    children: [
                      TextSpan(
                        text: widget.user.email,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('delete-user-confirmation'),
                  controller: _confirmation,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'E-mail'),
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
            key: const ValueKey('delete-user-continue'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDeep),
            onPressed: () => setState(() => _secondStep = true),
            child: const Text('Continuer'),
          )
        else
          FilledButton(
            key: const ValueKey('delete-user-confirm'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDeep),
            onPressed: _matches ? () => Navigator.of(context).pop(true) : null,
            child: const Text('Supprimer le compte'),
          ),
      ],
    );
  }
}

// =============================================================================
// Ajout d'un administrateur (invitation)
// =============================================================================

/// Informations saisies pour inviter un administrateur.
typedef AdminInvitation = ({String firstName, String lastName, String email});

/// Formulaire d'invitation d'un administrateur, avec confirmation des
/// droits accordés. Renvoie les informations, ou `null` si annulé.
Future<AdminInvitation?> showInviteAdminDialog(BuildContext context) =>
    _showThemedDialog<AdminInvitation>(context, const _InviteAdminDialog());

class _InviteAdminDialog extends StatefulWidget {
  const _InviteAdminDialog();

  @override
  State<_InviteAdminDialog> createState() => _InviteAdminDialogState();
}

class _InviteAdminDialogState extends State<_InviteAdminDialog> {
  static final _emailFormat = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  bool _confirmed = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false) || !_confirmed) return;
    Navigator.of(context).pop((
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim(),
    ));
  }

  String? _required(String? value, String label) =>
      (value ?? '').trim().isEmpty ? 'Indiquez $label.' : null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Ajouter un administrateur'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Un e-mail d’invitation lui sera envoyé pour définir son mot de passe.',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: const ValueKey('invite-first-name'),
                        controller: _firstName,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) => _required(value, 'le prénom'),
                        decoration: const InputDecoration(labelText: 'Prénom'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        key: const ValueKey('invite-last-name'),
                        controller: _lastName,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) => _required(value, 'le nom'),
                        decoration: const InputDecoration(labelText: 'Nom'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const ValueKey('invite-email'),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      _emailFormat.hasMatch((value ?? '').trim())
                      ? null
                      : 'Saisissez une adresse e-mail valide.',
                  decoration: const InputDecoration(
                    labelText: 'E-mail professionnel',
                    prefixIcon: Icon(Icons.alternate_email_rounded, size: 18),
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  key: const ValueKey('invite-confirm'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _confirmed,
                  onChanged: (value) =>
                      setState(() => _confirmed = value ?? false),
                  title: Text(
                    'Je confirme donner à cette personne les droits d’administration : '
                    'modérer tous les comptes et toutes les entreprises.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const ValueKey('invite-submit'),
          onPressed: _confirmed ? _submit : null,
          child: const Text('Envoyer l’invitation'),
        ),
      ],
    );
  }
}
