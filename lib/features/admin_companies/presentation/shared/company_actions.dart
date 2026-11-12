import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/admin_company.dart';
import '../controllers/admin_companies_controller.dart';
import 'company_dialogs.dart';
import '../../../admin/presentation/shared/admin_ui.dart';

/// Enchaîne modale → appel au contrôleur → notification, pour chaque action.
/// Partagé par le tableau web et les cartes mobiles.
class CompanyActionsHandler {
  const CompanyActionsHandler(this.controller);

  final AdminCompaniesController controller;

  Future<void> create(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final draft = await showCompanyFormDialog(
      context,
      logoPicker: controller.logoPicker,
    );
    if (draft == null) return;
    _toast(messenger, await controller.create(draft));
  }

  Future<void> edit(BuildContext context, AdminCompany company) async {
    final messenger = ScaffoldMessenger.of(context);
    final draft = await showCompanyFormDialog(
      context,
      logoPicker: controller.logoPicker,
      initial: company,
    );
    if (draft == null) return;
    _toast(messenger, await controller.update(company.id, draft));
  }

  Future<void> approve(BuildContext context, AdminCompany company) async {
    final messenger = ScaffoldMessenger.of(context);
    _toast(messenger, await controller.approve(company));
  }

  Future<void> reactivate(BuildContext context, AdminCompany company) async {
    final messenger = ScaffoldMessenger.of(context);
    _toast(messenger, await controller.reactivate(company));
  }

  Future<void> reject(BuildContext context, AdminCompany company) async {
    final messenger = ScaffoldMessenger.of(context);
    final reason = await showModerationReasonDialog(
      context,
      company: company,
      action: ModerationAction.reject,
    );
    if (reason == null) return;
    _toast(messenger, await controller.reject(company, reason));
  }

  Future<void> suspend(BuildContext context, AdminCompany company) async {
    final messenger = ScaffoldMessenger.of(context);
    final reason = await showModerationReasonDialog(
      context,
      company: company,
      action: ModerationAction.suspend,
    );
    if (reason == null) return;
    _toast(messenger, await controller.suspend(company, reason));
  }

  Future<void> delete(BuildContext context, AdminCompany company) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDeleteCompanyDialog(context, company);
    if (!confirmed) return;
    _toast(messenger, await controller.delete(company));
  }

  void _toast(ScaffoldMessengerState messenger, AdminActionResult result) {
    showAdminToastWith(messenger, result.message, error: !result.succeeded);
  }
}

enum _MenuAction { approve, reject, edit, suspend, reactivate, delete }

/// Menu « ⋮ » des actions d'une entreprise. Pour une entreprise en attente,
/// « Valider » et « Rejeter » sont en tête du menu.
class CompanyRowActions extends StatelessWidget {
  const CompanyRowActions({
    required this.company,
    required this.handler,
    required this.busy,
    this.expandQuickActions = false,
    super.key,
  });

  final AdminCompany company;
  final CompanyActionsHandler handler;
  final bool busy;

  /// Menu aligné à droite (cartes mobiles).
  final bool expandQuickActions;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: SizedBox.square(
          dimension: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            semanticsLabel: 'Action en cours',
          ),
        ),
      );
    }

    final pending = company.status == CompanyStatus.pending;

    final editable = handler.controller.canEditCompanies;
    if (!editable && !pending && company.status != CompanyStatus.rejected) {
      return const SizedBox.shrink();
    }
    final menu = PopupMenuButton<_MenuAction>(
      key: ValueKey('menu-${company.id}'),
      tooltip: 'Actions',
      onSelected: (action) => switch (action) {
        _MenuAction.approve => handler.approve(context, company),
        _MenuAction.reject => handler.reject(context, company),
        _MenuAction.edit => handler.edit(context, company),
        _MenuAction.suspend => handler.suspend(context, company),
        _MenuAction.reactivate => handler.reactivate(context, company),
        _MenuAction.delete => handler.delete(context, company),
      },
      itemBuilder: (context) => [
        if (pending) ...[
          const PopupMenuItem(
            value: _MenuAction.approve,
            child: ListTile(
              leading: Icon(Icons.check_rounded, color: AppColors.successDeep),
              title: Text(
                'Valider',
                style: TextStyle(color: AppColors.successDeep),
              ),
            ),
          ),
          const PopupMenuItem(
            value: _MenuAction.reject,
            child: ListTile(
              leading: Icon(Icons.close_rounded, color: AppColors.errorDeep),
              title: Text(
                'Rejeter',
                style: TextStyle(color: AppColors.errorDeep),
              ),
            ),
          ),
          if (editable) const PopupMenuDivider(),
        ],
        if (editable)
          const PopupMenuItem(
            value: _MenuAction.edit,
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Modifier'),
            ),
          ),
        if (editable && company.status == CompanyStatus.approved)
          const PopupMenuItem(
            value: _MenuAction.suspend,
            child: ListTile(
              leading: Icon(Icons.pause_circle_outline_rounded),
              title: Text('Suspendre'),
            ),
          ),
        if (company.status == CompanyStatus.suspended ||
            company.status == CompanyStatus.rejected)
          const PopupMenuItem(
            value: _MenuAction.reactivate,
            child: ListTile(
              leading: Icon(Icons.verified_outlined),
              title: Text('Valider / réactiver'),
            ),
          ),
        if (editable) const PopupMenuDivider(),
        if (editable)
          const PopupMenuItem(
            value: _MenuAction.delete,
            child: ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.errorDeep,
              ),
              title: Text(
                'Supprimer',
                style: TextStyle(color: AppColors.errorDeep),
              ),
            ),
          ),
      ],
    );

    return expandQuickActions
        ? Align(alignment: Alignment.centerRight, child: menu)
        : menu;
  }
}
