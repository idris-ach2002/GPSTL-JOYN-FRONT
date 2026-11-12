import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/material/joyn_chip_group.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../admin/presentation/mobile/mobile_admin_section_menu.dart';
import '../../../admin/presentation/shared/admin_ui.dart';
import '../../domain/admin_company.dart';
import '../../domain/admin_company_options.dart';
import '../../domain/company_validators.dart';
import '../controllers/admin_companies_controller.dart';
import '../shared/company_actions.dart';
import '../shared/company_visuals.dart';

/// Back-office : gestion des entreprises (mobile).
class MobileAdminCompaniesScreen extends StatelessWidget {
  const MobileAdminCompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Le contenu est un widget à part : son `context` est sous le thème
    // Material JOYN, que les modales ouvertes depuis la page reprennent.
    return const JoynMaterialScope(child: _MobileAdminCompaniesView());
  }
}

class _MobileAdminCompaniesView extends StatefulWidget {
  const _MobileAdminCompaniesView();

  @override
  State<_MobileAdminCompaniesView> createState() =>
      _MobileAdminCompaniesViewState();
}

class _MobileAdminCompaniesViewState extends State<_MobileAdminCompaniesView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openFilters(AdminCompaniesController controller) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => Theme(
        data: Theme.of(context),
        child: _FiltersSheet(controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminCompaniesController>();
    final handler = CompanyActionsHandler(controller);
    final textTheme = Theme.of(context).textTheme;

    if (controller.status == AdminCompaniesStatus.forbidden) {
      return MobileAppSurface(
        child: AdminForbiddenView(
          message: controller.error,
          onLeave: () => context.go(AppRoutes.dashboard),
        ),
      );
    }

    return MobileAppSurface(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
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
                                'Entreprises',
                                style: textTheme.headlineMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const MobileAdminSectionMenu(
                        current: AdminSection.companies,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('mobile-admin-search'),
                          controller: _search,
                          onChanged: controller.setSearch,
                          decoration: const InputDecoration(
                            hintText: 'Nom ou SIRET',
                            prefixIcon: Icon(Icons.search_rounded, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: 'Secteur et tri',
                        onPressed: () => _openFilters(controller),
                        icon: Badge(
                          isLabelVisible: controller.query.sector != null,
                          smallSize: 8,
                          child: const Icon(Icons.tune_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Row(
                    children: [
                      for (final filter in CompanyStatusFilter.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            label: Text(filter.label),
                            selected: controller.query.status == filter,
                            showCheckmark: false,
                            selectedColor: AppColors.navy,
                            labelStyle: textTheme.labelMedium?.copyWith(
                              color: controller.query.status == filter
                                  ? AppColors.white
                                  : AppColors.slateDark,
                            ),
                            onSelected: (_) =>
                                controller.setStatusFilter(filter),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (controller.isRefreshing)
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(minHeight: 3),
                ),
              ..._content(context, controller, handler),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
          if (controller.canEditCompanies)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              key: const ValueKey('mobile-admin-add-company'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adminRadius),
              ),
              backgroundColor: AppColors.navy,
              foregroundColor: AppColors.white,
              onPressed: () => handler.create(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajouter'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    AdminCompaniesController controller,
    CompanyActionsHandler handler,
  ) {
    if (controller.showSkeleton) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: DecoratedSliver(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(adminRadius),
              border: Border.all(color: AppColors.line),
            ),
            sliver: SliverList.separated(
              itemCount: 5,
              separatorBuilder: (context, _) => const Divider(height: 1),
              itemBuilder: (context, _) => const _CardSkeleton(),
            ),
          ),
        ),
      ];
    }
    if (controller.status == AdminCompaniesStatus.error) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _CenteredMessage(
            text: controller.error ?? 'Erreur de chargement.',
            action: FilledButton(
              onPressed: controller.load,
              child: const Text('Réessayer'),
            ),
          ),
        ),
      ];
    }
    final companies = controller.companies;
    if (companies.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _CenteredMessage(
            text: controller.hasActiveFilters
                ? 'Aucune entreprise ne correspond à ces filtres.'
                : 'Aucune entreprise enregistrée pour l’instant.',
            action: controller.hasActiveFilters
                ? TextButton(
                    onPressed: () {
                      _search.clear();
                      controller.resetFilters();
                    },
                    child: const Text('Réinitialiser les filtres'),
                  )
                : null,
          ),
        ),
      ];
    }

    final page = controller.page;
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: DecoratedSliver(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(adminRadius),
            border: Border.all(color: AppColors.line),
          ),
          sliver: SliverList.separated(
            itemCount: companies.length,
            separatorBuilder: (context, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _CompanyCard(
              company: companies[index],
              handler: handler,
              busy: controller.isBusy(companies[index].id),
            ),
          ),
        ),
      ),
      if (page != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${page.firstIndex}–${page.lastIndex} sur ${page.total}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Page précédente',
                  onPressed: page.page > 1
                      ? () => controller.goToPage(page.page - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text('${page.page} / ${page.totalPages}'),
                IconButton(
                  tooltip: 'Page suivante',
                  onPressed: page.page < page.totalPages
                      ? () => controller.goToPage(page.page + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ),
    ];
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({
    required this.company,
    required this.handler,
    required this.busy,
  });

  final AdminCompany company;
  final CompanyActionsHandler handler;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reason = company.statusReason;

    // Ligne de liste (dans le panneau) plutôt qu'une carte arrondie.
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyLogoAvatar(
                name: company.name,
                initials: company.initials,
                logo: company.logo,
                size: 34,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SIRET ${CompanyValidators.formatSiret(company.siret)}',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    CompanyStatusBadge(status: company.status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${company.sector} · ${company.city}',
            style: textTheme.bodyMedium,
          ),
          Text(
            'Inscrite le ${formatCompanyDate(company.createdAt)}'
            '${company.recruiterName == null ? " par l'administration" : ' par ${company.recruiterName}'}',
            style: textTheme.bodySmall,
          ),
          if (reason != null &&
              (company.status == CompanyStatus.rejected ||
                  company.status == CompanyStatus.suspended)) ...[
            const SizedBox(height: 6),
            Text(
              'Motif : $reason',
              style: textTheme.bodySmall?.copyWith(color: AppColors.errorDeep),
            ),
          ],
          const SizedBox(height: 8),
          CompanyRowActions(
            company: company,
            handler: handler,
            busy: busy,
            expandQuickActions: true,
          ),
        ],
      ),
    );
  }
}

class _FiltersSheet extends StatelessWidget {
  const _FiltersSheet({required this.controller});

  final AdminCompaniesController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Secteur d'activité", style: textTheme.titleSmall),
              const SizedBox(height: 10),
              JoynChipGroup<String>.single(
                options: const ['Tous', ...AdminCompanyOptions.sectors],
                selected: controller.query.sector ?? 'Tous',
                onSelected: (sector) =>
                    controller.setSector(sector == 'Tous' ? null : sector),
              ),
              const SizedBox(height: 20),
              Text('Trier par', style: textTheme.titleSmall),
              const SizedBox(height: 10),
              JoynChipGroup<CompanySort>.single(
                options: CompanySort.values,
                selected: controller.query.sort,
                labelOf: (sort) => sort.label,
                onSelected: controller.setSort,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voir les résultats'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 34, height: 34, radius: 5),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 120, height: 10),
                SizedBox(height: 12),
                SkeletonBox(width: 90, height: 22, radius: 99),
                SizedBox(height: 14),
                SkeletonBox(width: 200, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: AppColors.slate,
            ),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 12), action],
          ],
        ),
      ),
    );
  }
}
