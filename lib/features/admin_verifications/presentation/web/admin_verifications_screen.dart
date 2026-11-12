import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/theme/joyn_material_theme.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/admin/presentation/shared/admin_ui.dart';
import 'package:joyn_front/features/admin/presentation/web/admin_shell.dart';
import 'package:joyn_front/features/admin_verifications/domain/company_verification.dart';
import 'package:joyn_front/features/admin_verifications/presentation/controllers/admin_verifications_controller.dart';
import 'package:joyn_front/features/admin_verifications/presentation/shared/verification_detail.dart';

/// Back-office : vérification manuelle des entreprises (web).
class AdminVerificationsScreen extends StatelessWidget {
  const AdminVerificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Le contenu est un widget à part : son `context` est sous le thème
    // Material JOYN, que les modales ouvertes depuis la page reprennent.
    return const JoynMaterialScope(child: _VerificationsView());
  }
}

class _VerificationsView extends StatelessWidget {
  const _VerificationsView();

  /// En dessous, le détail s'ouvre dans un tiroir latéral.
  static const double _twoPanesBreakpoint = 1180;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminVerificationsController>();
    final twoPanes = MediaQuery.sizeOf(context).width >= _twoPanesBreakpoint;
    final selected = controller.selected;

    return AdminShell(
      section: AdminSection.verifications,
      child: controller.status == VerificationsStatus.forbidden
          ? AdminForbiddenView(
              message: controller.error,
              onLeave: () => context.go(AppRoutes.dashboard),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AdminPageHeader(
                    title: 'Vérifications',
                    subtitle:
                        'Les inscriptions sont vérifiées automatiquement via l’API SIRENE. '
                        'Traitez ici les cas où elle n’a pas abouti.',
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: AdminPanel(
                      child: twoPanes
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: 380,
                                  child: _Queue(
                                    controller: controller,
                                    twoPanes: true,
                                  ),
                                ),
                                const VerticalDivider(width: 1),
                                Expanded(
                                  child: selected == null
                                      ? const AdminMessage(
                                          icon: Icons.fact_check_outlined,
                                          title: 'Aucune demande sélectionnée',
                                          text: 'Choisissez une entreprise dans la file.',
                                        )
                                      : VerificationDetail(
                                          key: ValueKey(selected.id),
                                          item: selected,
                                          controller: controller,
                                        ),
                                ),
                              ],
                            )
                          : _Queue(controller: controller, twoPanes: false),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// File des demandes : recherche, filtre et liste.
class _Queue extends StatelessWidget {
  const _Queue({required this.controller, required this.twoPanes});

  final AdminVerificationsController controller;
  final bool twoPanes;

  void _open(BuildContext context, CompanyVerification item) {
    controller.select(item.id);
    if (twoPanes) return;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fermer le détail',
      barrierColor: const Color(0x55000000),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, _, _) => Theme(
        data: Theme.of(context),
        child: Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: AppColors.surface,
            elevation: 12,
            child: SizedBox(
              width: 520,
              height: double.infinity,
              child: SafeArea(
                child: ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    final current = controller.selected;
                    if (current == null) return const SizedBox.shrink();
                    return VerificationDetail(
                      item: current,
                      controller: controller,
                      onClose: () => Navigator.of(dialogContext).pop(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (_, animation, _, child) => SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = controller.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: AdminDenseFields(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const ValueKey('verification-search'),
                  onChanged: controller.setSearch,
                  decoration: const InputDecoration(
                    hintText: 'Nom ou SIRET',
                    prefixIcon: Icon(Icons.search_rounded, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownMenu<VerificationFilter>(
                  key: ValueKey(
                    'verification-filter-${controller.filter.name}',
                  ),
                  expandedInsets: EdgeInsets.zero,
                  requestFocusOnTap: false,
                  label: const Text('Afficher'),
                  initialSelection: controller.filter,
                  onSelected: (filter) {
                    if (filter != null) controller.setFilter(filter);
                  },
                  dropdownMenuEntries: [
                    for (final filter in VerificationFilter.values)
                      DropdownMenuEntry(value: filter, label: filter.label),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (controller.isRefreshing)
          const LinearProgressIndicator(minHeight: 2)
        else
          const Divider(height: 2, thickness: 1),
        Expanded(
          child: switch (controller.status) {
            VerificationsStatus.loading => const _QueueSkeleton(),
            VerificationsStatus.error => AdminMessage(
              icon: Icons.cloud_off_rounded,
              title: 'Chargement impossible',
              text: controller.error ?? '',
              action: FilledButton(
                onPressed: controller.load,
                child: const Text('Réessayer'),
              ),
            ),
            _ when items.isEmpty => AdminMessage(
              icon: Icons.task_alt_rounded,
              title: controller.filter == VerificationFilter.toReview
                  ? 'Rien à traiter'
                  : 'Aucune demande',
              text: controller.filter == VerificationFilter.toReview
                  ? 'Toutes les entreprises ont été vérifiées.'
                  : 'Aucune demande ne correspond à ces critères.',
            ),
            _ => ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, _) => const Divider(height: 1),
              itemBuilder: (context, index) => VerificationListRow(
                item: items[index],
                selected:
                    twoPanes && items[index].id == controller.selected?.id,
                onTap: () => _open(context, items[index]),
              ),
            ),
          },
        ),
        if (items.isNotEmpty && controller.status == VerificationsStatus.ready)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.lineSoft)),
            ),
            child: Text(
              '${items.length} demande${items.length > 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _QueueSkeleton extends StatelessWidget {
  const _QueueSkeleton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Chargement des vérifications',
      excludeSemantics: true,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (context, _) => const Divider(height: 1),
        itemBuilder: (context, _) => const Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 32, height: 32, radius: 5),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 150),
                    SizedBox(height: 8),
                    SkeletonBox(width: 110, height: 10),
                    SizedBox(height: 8),
                    SkeletonBox(width: 120, height: 18),
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
