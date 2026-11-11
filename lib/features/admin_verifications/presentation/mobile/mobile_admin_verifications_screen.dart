import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../admin/presentation/mobile/mobile_admin_section_menu.dart';
import '../../../admin/presentation/shared/admin_ui.dart';
import '../../domain/company_verification.dart';
import '../controllers/admin_verifications_controller.dart';
import '../shared/verification_detail.dart';

/// Back-office : vérification manuelle des entreprises (mobile).
class MobileAdminVerificationsScreen extends StatelessWidget {
  const MobileAdminVerificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const JoynMaterialScope(child: _MobileVerificationsView());
  }
}

class _MobileVerificationsView extends StatelessWidget {
  const _MobileVerificationsView();

  void _open(
    BuildContext context,
    AdminVerificationsController controller,
    CompanyVerification item,
  ) {
    controller.select(item.id);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => Theme(
        data: Theme.of(context),
        child: FractionallySizedBox(
          heightFactor: 0.92,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final current = controller.selected;
              if (current == null) return const SizedBox.shrink();
              return VerificationDetail(
                item: current,
                controller: controller,
                onClose: () => Navigator.of(sheetContext).pop(),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminVerificationsController>();
    final textTheme = Theme.of(context).textTheme;

    if (controller.status == VerificationsStatus.forbidden) {
      return MobileAppSurface(
        child: AdminForbiddenView(
          message: controller.error,
          onLeave: () => context.go(AppRoutes.dashboard),
        ),
      );
    }

    final items = controller.items;
    const panel = BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.all(Radius.circular(adminRadius)),
      border: Border.fromBorderSide(BorderSide(color: AppColors.line)),
    );

    return MobileAppSurface(
      backgroundColor: AppColors.background,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ADMINISTRATION', style: textTheme.labelSmall),
                        const SizedBox(height: 2),
                        Semantics(
                          header: true,
                          child: Text(
                            'Vérifications',
                            style: textTheme.headlineMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const MobileAdminSectionMenu(
                    current: AdminSection.verifications,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                'Cas où la vérification automatique (API SIRENE) n’a pas abouti.',
                style: textTheme.bodySmall,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                key: const ValueKey('mobile-verification-search'),
                onChanged: controller.setSearch,
                decoration: const InputDecoration(
                  hintText: 'Nom ou SIRET',
                  prefixIcon: Icon(Icons.search_rounded, size: 20),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
              child: Row(
                children: [
                  for (final filter in VerificationFilter.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        label: Text(filter.label),
                        selected: controller.filter == filter,
                        showCheckmark: false,
                        selectedColor: AppColors.navy,
                        labelStyle: textTheme.labelMedium?.copyWith(
                          color: controller.filter == filter
                              ? AppColors.white
                              : AppColors.slateDark,
                        ),
                        onSelected: (_) => controller.setFilter(filter),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (controller.isRefreshing)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (controller.showSkeleton)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Chargement des vérifications',
                  ),
                ),
              ),
            )
          else if (controller.status == VerificationsStatus.error)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AdminMessage(
                icon: Icons.cloud_off_rounded,
                title: 'Chargement impossible',
                text: controller.error ?? '',
                action: FilledButton(
                  onPressed: controller.load,
                  child: const Text('Réessayer'),
                ),
              ),
            )
          else if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AdminMessage(
                icon: Icons.task_alt_rounded,
                title: controller.filter == VerificationFilter.toReview
                    ? 'Rien à traiter'
                    : 'Aucune demande',
                text: controller.filter == VerificationFilter.toReview
                    ? 'Toutes les entreprises ont été vérifiées.'
                    : 'Aucune demande ne correspond à ces critères.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: DecoratedSliver(
                decoration: panel,
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => VerificationListRow(
                    item: items[index],
                    selected: false,
                    onTap: () => _open(context, controller, items[index]),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
