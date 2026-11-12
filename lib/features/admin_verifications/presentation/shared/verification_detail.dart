import 'package:flutter/material.dart';

import '../../../../design_system/material/joyn_notice.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../admin/presentation/shared/admin_ui.dart';
import '../../../admin_companies/domain/company_validators.dart';
import '../../domain/company_verification.dart';
import '../controllers/admin_verifications_controller.dart';
import 'verification_dialogs.dart';
import 'verification_visuals.dart';

/// Enchaîne modale → appel au contrôleur → notification.
class VerificationActionsHandler {
  const VerificationActionsHandler(this.controller);

  final AdminVerificationsController controller;

  Future<void> retry(BuildContext context, CompanyVerification item) async {
    final messenger = ScaffoldMessenger.of(context);
    _toast(messenger, await controller.retry(item));
  }

  Future<void> approve(BuildContext context, CompanyVerification item) async {
    final messenger = ScaffoldMessenger.of(context);
    final note = await showApproveVerificationDialog(context, item);
    if (note == null) return;
    _toast(messenger, await controller.approve(item, note: note));
  }

  Future<void> requestDocument(
    BuildContext context,
    CompanyVerification item,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final note = await showRequestDocumentDialog(context, item);
    if (note == null) return;
    _toast(messenger, await controller.requestDocument(item, note));
  }

  Future<void> refuse(BuildContext context, CompanyVerification item) async {
    final messenger = ScaffoldMessenger.of(context);
    final reason = await showRefuseVerificationDialog(context, item);
    if (reason == null) return;
    _toast(messenger, await controller.refuse(item, reason));
  }

  void _toast(ScaffoldMessengerState messenger, VerificationActionResult r) {
    showAdminToastWith(messenger, r.message, error: !r.succeeded);
  }
}

/// Une demande dans la file (colonne de gauche ou liste mobile).
class VerificationListRow extends StatelessWidget {
  const VerificationListRow({
    required this.item,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final CompanyVerification item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: selected ? AppColors.skyMist : Colors.transparent,
      child: InkWell(
        key: ValueKey('verification-${item.id}'),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected ? AppColors.navy : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(13, 11, 14, 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VerificationLogo(initials: item.initials),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.companyName,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        Text(
                          formatVerificationAge(item.submittedAt),
                          style: textTheme.bodySmall?.copyWith(fontSize: 11.5),
                        ),
                      ],
                    ),
                    Text(
                      '${CompanyValidators.formatSiret(item.siret)} · ${item.city}',
                      style: textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    item.status.isOpen && item.issue != VerificationIssue.none
                        ? VerificationIssueTag(issue: item.issue)
                        : VerificationStatusTag(status: item.status),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Détail d'une demande : problème, comparaison déclaré / registre,
/// contrôles automatiques, recruteur, historique et actions.
class VerificationDetail extends StatelessWidget {
  const VerificationDetail({
    required this.item,
    required this.controller,
    this.onClose,
    super.key,
  });

  final CompanyVerification item;
  final AdminVerificationsController controller;

  /// Bouton « fermer » (panneau mobile ou tiroir).
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final handler = VerificationActionsHandler(controller);
    final busy = controller.isBusy(item.id);
    final onClose = this.onClose;
    final email = item.recruiterEmail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
          child: Row(
            children: [
              VerificationLogo(initials: item.initials, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.companyName,
                      style: textTheme.titleMedium?.copyWith(fontSize: 17),
                    ),
                    Text(
                      'SIRET ${CompanyValidators.formatSiret(item.siret)}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              VerificationStatusTag(status: item.status),
              if (onClose != null)
                IconButton(
                  tooltip: 'Fermer',
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            children: [
              if (item.status.isOpen &&
                  item.issue != VerificationIssue.none) ...[
                JoynNotice(
                  tone: item.issue == VerificationIssue.apiUnavailable
                      ? JoynNoticeTone.warning
                      : JoynNoticeTone.error,
                  message: [
                    'Vérification automatique : ${item.issue.label.toLowerCase()}.',
                    ?item.apiMessage,
                    if (item.issue == VerificationIssue.apiUnavailable)
                      'Relancez la vérification ou validez manuellement.',
                  ].join('\n'),
                ),
                const SizedBox(height: 18),
              ],
              const _SectionTitle('Déclaré / registre SIRENE'),
              _Comparison(
                label: 'Raison sociale',
                declared: item.companyName,
                registry: item.registryName,
              ),
              _Comparison(
                label: 'Adresse',
                declared: item.declaredAddress,
                registry: item.registryAddress,
              ),
              const SizedBox(height: 18),
              const _SectionTitle('Contrôles automatiques'),
              for (final check in item.checks)
                VerificationCheckRow(check: check),
              const SizedBox(height: 18),
              const _SectionTitle('Recruteur'),
              Text(
                item.recruiterName ?? 'Aucun recruteur rattaché',
                style: textTheme.bodyMedium?.copyWith(fontSize: 13.5),
              ),
              if (email != null)
                SelectableText(
                  email,
                  style: textTheme.bodySmall?.copyWith(fontSize: 12.5),
                ),
              const SizedBox(height: 18),
              const _SectionTitle('Historique'),
              for (final event in item.history)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: AppColors.slate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.label,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              [
                                formatAdminDate(event.date),
                                event.author,
                                if (event.note.isNotEmpty) event.note,
                              ].join(' · '),
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (item.status.isOpen && !controller.supportsReviewWorkflow)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Ouvrez Entreprises pour valider ou rejeter cette entreprise.',
            ),
          ),
        if (item.status.isOpen && controller.supportsReviewWorkflow) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: busy
                ? const LinearProgressIndicator(minHeight: 2)
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        key: const ValueKey('verification-retry'),
                        onPressed: () => handler.retry(context, item),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Relancer la vérification'),
                      ),
                      OutlinedButton(
                        onPressed: () => handler.requestDocument(context, item),
                        child: const Text('Demander un justificatif'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.errorDeep,
                        ),
                        onPressed: () => handler.refuse(context, item),
                        child: const Text('Refuser'),
                      ),
                      FilledButton.icon(
                        key: const ValueKey('verification-approve'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.successDeep,
                        ),
                        onPressed: () => handler.approve(context, item),
                        icon: const Icon(Icons.verified_outlined, size: 18),
                        label: const Text('Valider manuellement'),
                      ),
                    ],
                  ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.slate,
          fontSize: 11,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Une ligne « déclaré » / « registre », en rouge si elles diffèrent.
class _Comparison extends StatelessWidget {
  const _Comparison({
    required this.label,
    required this.declared,
    required this.registry,
  });

  final String label;
  final String declared;
  final String? registry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final registry = this.registry;
    final differs =
        registry != null &&
        registry.trim().toLowerCase() != declared.trim().toLowerCase();

    Widget cell(String title, String value, {Color? color}) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.bodySmall?.copyWith(fontSize: 11.5)),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: color,
              fontWeight: color == null ? null : FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(fontSize: 12.5),
            ),
          ),
          cell('Déclaré', declared.isEmpty ? '—' : declared),
          const SizedBox(width: 12),
          cell(
            'Registre',
            registry ?? 'Non disponible',
            color: differs
                ? AppColors.errorDeep
                : (registry == null ? AppColors.slate : null),
          ),
        ],
      ),
    );
  }
}
