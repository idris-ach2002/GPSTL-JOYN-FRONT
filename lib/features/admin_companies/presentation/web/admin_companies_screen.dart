import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/material/joyn_chip_group.dart';
import 'package:joyn_front/design_system/theme/joyn_material_theme.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/admin_companies/domain/admin_company.dart';
import 'package:joyn_front/features/admin_companies/domain/admin_company_options.dart';
import 'package:joyn_front/features/admin_companies/domain/company_validators.dart';
import 'package:joyn_front/features/admin_companies/presentation/controllers/admin_companies_controller.dart';
import 'package:joyn_front/features/admin_companies/presentation/shared/company_actions.dart';
import 'package:joyn_front/features/admin_companies/presentation/shared/company_visuals.dart';
import 'package:joyn_front/features/admin_companies/presentation/web/admin_shell.dart';

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
    final textTheme = Theme.of(context).textTheme;

    return AdminShell(
      child: controller.status == AdminCompaniesStatus.forbidden
          ? Card(
              margin: const EdgeInsets.all(36),
              child: AdminForbiddenView(
                message: controller.error,
                onLeave: () => context.go(AppRoutes.dashboard),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(36, 40, 36, 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  header: true,
                                  child: Text(
                                    'Entreprises',
                                    style: textTheme.displaySmall?.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Valider, modifier et modérer les entreprises enregistrées.',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: const Color(0xE6FFFFFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          FilledButton.icon(
                            key: const ValueKey('admin-add-company'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.textPrimary,
                            ),
                            onPressed: () => handler.create(context),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Ajouter une entreprise'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (controller.isRefreshing)
                              const LinearProgressIndicator(minHeight: 3)
                            else
                              const SizedBox(height: 3),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                              child: _Toolbar(controller: controller),
                            ),
                            const Divider(),
                            _TableArea(
                              controller: controller,
                              handler: handler,
                            ),
                            if (controller.status ==
                                AdminCompaniesStatus.ready) ...[
                              const Divider(),
                              _Pagination(controller: controller),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                key: const ValueKey('admin-company-search'),
                controller: _search,
                onChanged: (value) {
                  controller.setSearch(value);
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un nom ou un SIRET',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Effacer',
                          onPressed: () {
                            _search.clear();
                            controller.setSearch('');
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded, size: 18),
                        ),
                ),
              ),
            ),
            DropdownMenu<String>(
              key: const ValueKey('admin-company-sector'),
              width: 220,
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
              key: const ValueKey('admin-company-sort'),
              width: 200,
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
          ],
        ),
        const SizedBox(height: 14),
        JoynChipGroup<CompanyStatusFilter>.single(
          options: CompanyStatusFilter.values,
          selected: query.status,
          labelOf: (filter) => filter.label,
          onSelected: controller.setStatusFilter,
        ),
      ],
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
      return _Message(
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
      return _Message(
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
          child: DataTable(
            sortColumnIndex: sort.byName ? 0 : 3,
            sortAscending: sort.ascending,
            headingTextStyle: textTheme.labelSmall?.copyWith(
              color: AppColors.slate,
            ),
            dataRowMinHeight: 68,
            dataRowMaxHeight: 78,
            horizontalMargin: 20,
            columnSpacing: 28,
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
                            size: 38,
                          ),
                          const SizedBox(width: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  company.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleSmall,
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
                        style: textTheme.bodyMedium?.copyWith(
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
        Text(top, style: textTheme.bodyMedium),
        Text(bottom, style: textTheme.bodySmall),
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
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    SkeletonBox(width: 38, height: 38, radius: 10),
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

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.text,
    this.action,
  });

  final IconData icon;
  final String title;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final action = this.action;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.slate),
          const SizedBox(height: 12),
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(text, textAlign: TextAlign.center, style: textTheme.bodySmall),
          if (action != null) ...[const SizedBox(height: 14), action],
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({required this.controller});

  final AdminCompaniesController controller;

  @override
  Widget build(BuildContext context) {
    final page = controller.page;
    if (page == null || page.total == 0) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
      child: Row(
        children: [
          Text(
            '${page.firstIndex}–${page.lastIndex} sur ${page.total}',
            style: textTheme.bodySmall,
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Page précédente',
            onPressed: page.page > 1
                ? () => controller.goToPage(page.page - 1)
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            'Page ${page.page} / ${page.totalPages}',
            style: textTheme.labelMedium,
          ),
          IconButton(
            tooltip: 'Page suivante',
            onPressed: page.page < page.totalPages
                ? () => controller.goToPage(page.page + 1)
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
