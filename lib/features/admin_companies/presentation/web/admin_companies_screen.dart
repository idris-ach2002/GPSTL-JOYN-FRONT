import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/theme/joyn_material_theme.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/admin_companies/domain/admin_company.dart';
import 'package:joyn_front/features/admin_companies/domain/admin_company_options.dart';
import 'package:joyn_front/features/admin_companies/domain/company_validators.dart';
import 'package:joyn_front/features/admin_companies/presentation/controllers/admin_companies_controller.dart';
import 'package:joyn_front/features/admin_companies/presentation/shared/company_actions.dart';
import 'package:joyn_front/features/admin_companies/presentation/shared/company_visuals.dart';
import 'package:joyn_front/features/admin/presentation/shared/admin_ui.dart';
import 'package:joyn_front/features/admin/presentation/web/admin_shell.dart';

/// Back-office : gestion des entreprises (web).
class AdminCompaniesScreen extends StatelessWidget {
  const AdminCompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Le contenu est un widget à part : son `context` est sous le thème
    // Material JOYN, que les modales ouvertes depuis la page reprennent.
    return const JoynMaterialScope(child: _AdminCompaniesView());
  }
}

class _AdminCompaniesView extends StatelessWidget {
  const _AdminCompaniesView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminCompaniesController>();
    final handler = CompanyActionsHandler(controller);

    return AdminShell(
      section: AdminSection.companies,
      child: controller.status == AdminCompaniesStatus.forbidden
          ? AdminForbiddenView(
              message: controller.error,
              onLeave: () => context.go(AppRoutes.dashboard),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AdminPageHeader(
                        title: 'Entreprises',
                        subtitle: 'Valider, modifier et modérer les entreprises enregistrées.',
                        actions: [
                          FilledButton.icon(
                            key: const ValueKey('admin-add-company'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AdminShell.sidebarColor,
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            onPressed: () => handler.create(context),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Ajouter une entreprise'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AdminPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: _Toolbar(controller: controller),
                            ),
                            if (controller.isRefreshing)
                              const LinearProgressIndicator(minHeight: 2)
                            else
                              const Divider(height: 2, thickness: 1),
                            _TableArea(
                              controller: controller,
                              handler: handler,
                            ),
                            if (controller.status ==
                                    AdminCompaniesStatus.ready &&
                                controller.companies.isNotEmpty) ...[
                              const Divider(height: 1),
                              if (controller.page case final page?)
                                AdminPagination(
                                  firstIndex: page.firstIndex,
                                  lastIndex: page.lastIndex,
                                  total: page.total,
                                  page: page.page,
                                  totalPages: page.totalPages,
                                  onPage: controller.goToPage,
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

/// Recherche, filtres (statut, secteur) et tri.
class _Toolbar extends StatefulWidget {
  const _Toolbar({required this.controller});

  final AdminCompaniesController controller;

  @override
  State<_Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<_Toolbar> {
  late final _search = TextEditingController(
    text: widget.controller.query.search,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final query = controller.query;

    return AdminDenseFields(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 280,
            child: TextField(
              key: const ValueKey('admin-company-search'),
              controller: _search,
              onChanged: (value) {
                controller.setSearch(value);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un nom ou un SIRET',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Effacer',
                        onPressed: () {
                          _search.clear();
                          controller.setSearch('');
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded, size: 16),
                      ),
              ),
            ),
          ),
          DropdownMenu<CompanyStatusFilter>(
            key: ValueKey('company-status-${query.status.name}'),
            width: 210,
            requestFocusOnTap: false,
            label: const Text('Statut'),
            initialSelection: query.status,
            onSelected: (status) {
              if (status != null) controller.setStatusFilter(status);
            },
            dropdownMenuEntries: [
              for (final status in CompanyStatusFilter.values)
                DropdownMenuEntry(value: status, label: status.label),
            ],
          ),
          DropdownMenu<String>(
            key: ValueKey('admin-company-sector-${query.sector}'),
            width: 190,
            requestFocusOnTap: false,
            label: const Text('Secteur'),
            initialSelection: query.sector ?? '',
            onSelected: (value) => controller.setSector(
              value == null || value.isEmpty ? null : value,
            ),
            dropdownMenuEntries: [
              const DropdownMenuEntry(value: '', label: 'Tous les secteurs'),
              for (final sector in AdminCompanyOptions.sectors)
                DropdownMenuEntry(value: sector, label: sector),
            ],
          ),
          DropdownMenu<CompanySort>(
            key: ValueKey('admin-company-sort-${query.sort.name}'),
            width: 180,
            requestFocusOnTap: false,
            label: const Text('Trier par'),
            initialSelection: query.sort,
            onSelected: (sort) {
              if (sort != null) controller.setSort(sort);
            },
            dropdownMenuEntries: [
              for (final sort in CompanySort.values)
                DropdownMenuEntry(value: sort, label: sort.label),
            ],
          ),
          TextButton.icon(
            onPressed: controller.hasActiveFilters
                ? () {
                    _search.clear();
                    controller.resetFilters();
                  }
                : null,
            icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
            label: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }
}

/// Tableau, squelettes, liste vide ou erreur.
class _TableArea extends StatelessWidget {
  const _TableArea({required this.controller, required this.handler});

  final AdminCompaniesController controller;
  final CompanyActionsHandler handler;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (controller.showSkeleton) return const _TableSkeleton();

    if (controller.status == AdminCompaniesStatus.error) {
      return AdminMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Chargement impossible',
        text: controller.error ?? '',
        action: FilledButton(
          onPressed: controller.load,
          child: const Text('Réessayer'),
        ),
      );
    }

    final companies = controller.companies;
    if (companies.isEmpty) {
      return AdminMessage(
        icon: Icons.search_off_rounded,
        title: 'Aucune entreprise',
        text: controller.hasActiveFilters
            ? 'Aucune entreprise ne correspond à ces filtres.'
            : 'Aucune entreprise enregistrée pour l’instant.',
        action: controller.hasActiveFilters
            ? TextButton(
                onPressed: controller.resetFilters,
                child: const Text('Réinitialiser les filtres'),
              )
            : null,
      );
    }

    final sort = controller.query.sort;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: AdminTableTheme(
            child: DataTable(
              sortColumnIndex: sort.byName ? 0 : 3,
              sortAscending: sort.ascending,
              columns: [
                DataColumn(
                  label: const Text('ENTREPRISE'),
                  onSort: (_, ascending) => controller.setSort(
                    ascending ? CompanySort.nameAsc : CompanySort.nameDesc,
                  ),
                ),
                const DataColumn(label: Text('SIRET')),
                const DataColumn(label: Text('SECTEUR · VILLE')),
                DataColumn(
                  label: const Text('INSCRIPTION'),
                  onSort: (_, ascending) => controller.setSort(
                    ascending ? CompanySort.oldest : CompanySort.newest,
                  ),
                ),
                const DataColumn(label: Text('STATUT')),
                const DataColumn(label: Text('ACTIONS')),
              ],
              rows: [
                for (final company in companies)
                  DataRow(
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CompanyLogoAvatar(
                              name: company.name,
                              initials: company.initials,
                              logo: company.logo,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 220),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    company.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  if (company.website.isNotEmpty)
                                    Text(
                                      company.website.replaceFirst(
                                        RegExp(r'^https?://'),
                                        '',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          CompanyValidators.formatSiret(company.siret),
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      DataCell(
                        _TwoLines(top: company.sector, bottom: company.city),
                      ),
                      DataCell(
                        _TwoLines(
                          top: formatCompanyDate(company.createdAt),
                          bottom: company.recruiterName == null
                              ? "Créée par l'administration"
                              : 'par ${company.recruiterName}',
                        ),
                      ),
                      DataCell(
                        Tooltip(
                          message: company.statusReason ?? '',
                          child: CompanyStatusBadge(status: company.status),
                        ),
                      ),
                      DataCell(
                        CompanyRowActions(
                          company: company,
                          handler: handler,
                          busy: controller.isBusy(company.id),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TwoLines extends StatelessWidget {
  const _TwoLines({required this.top, required this.bottom});

  final String top;
  final String bottom;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          top,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
        Text(bottom, style: textTheme.bodySmall?.copyWith(fontSize: 12)),
      ],
    );
  }
}

class _TableSkeleton extends StatelessWidget {
  const _TableSkeleton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Chargement des entreprises',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            for (var i = 0; i < 8; i++)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 11),
                child: Row(
                  children: [
                    SkeletonBox(width: 30, height: 30, radius: 5),
                    SizedBox(width: 12),
                    Expanded(flex: 3, child: _SkeletonLines()),
                    Expanded(flex: 2, child: SkeletonBox(width: 120)),
                    Expanded(flex: 2, child: _SkeletonLines()),
                    Expanded(flex: 2, child: _SkeletonLines()),
                    Expanded(
                      flex: 2,
                      child: SkeletonBox(width: 90, height: 22, radius: 99),
                    ),
                    SkeletonBox(width: 80, height: 32, radius: 99),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonLines extends StatelessWidget {
  const _SkeletonLines();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: 120),
        SizedBox(height: 8),
        SkeletonBox(width: 80, height: 10),
      ],
    );
  }
}
