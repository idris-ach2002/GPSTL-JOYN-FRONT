import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/components/joyn_button.dart';
import '../../../../design_system/components/joyn_pill.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../../../design_system/tokens/app_gradients.dart';
import '../../../../design_system/tokens/app_shadows.dart';
import '../../domain/job_offer.dart';
import '../../domain/recruiter_company.dart';
import '../controllers/offer_management_controller.dart';
import '../shared/offer_ui.dart';
import 'recruiter_offers_top_bar.dart';

class WebRecruiterOffersScreen extends StatelessWidget {
  const WebRecruiterOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OfferManagementController>();
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Container(
                  height: 280,
                  decoration: const BoxDecoration(gradient: AppGradients.hero),
                ),
                const Expanded(child: ColoredBox(color: AppColors.background)),
              ],
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: controller.load,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  width < 760 ? 18 : 28,
                  16,
                  width < 760 ? 18 : 28,
                  40,
                ),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1220),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const RecruiterOffersTopBar(),
                          const SizedBox(height: 28),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mes offres',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: AppFonts.display,
                                        fontSize: 34,
                                        height: 1,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -.8,
                                      ),
                                    ),
                                    SizedBox(height: 7),
                                    Text(
                                      'Gérez, modifiez et suivez toutes vos offres.',
                                      style: TextStyle(
                                        color: Color(0xFFE4F3FB),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              JoynButton(
                                label: 'Publier une offre',
                                leadingIcon: Icons.add_rounded,
                                variant: JoynButtonVariant.accent,
                                height: 48,
                                onPressed: () =>
                                    context.go(AppRoutes.recruiterJobCreate),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          if (controller.errorMessage != null) ...[
                            _ErrorMessage(message: controller.errorMessage!),
                            const SizedBox(height: 12),
                          ],
                          if (controller.isLoading)
                            const _LoadingPanel()
                          else ...[
                            _CompanyFilterCard(controller: controller),
                            const SizedBox(height: 12),
                            _StatsRow(controller: controller),
                            const SizedBox(height: 12),
                            _FiltersCard(controller: controller),
                            const SizedBox(height: 12),
                            if (controller.visibleOffers.isEmpty)
                              _EmptyState(
                                onCreate: () =>
                                    context.go(AppRoutes.recruiterJobCreate),
                              )
                            else
                              for (final offer in controller.visibleOffers) ...[
                                _OfferRow(
                                  offer: offer,
                                  company: controller.companyFor(
                                    offer.companyId,
                                  ),
                                  onEdit: () => context.go(
                                    AppRoutes.recruiterJobEdit(offer.id),
                                  ),
                                  onClose: () =>
                                      _confirmClose(context, controller, offer),
                                  onDelete: () =>
                                      _confirmDelete(context, controller, offer),
                                ),
                                const SizedBox(height: 9),
                              ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClose(
    BuildContext context,
    OfferManagementController controller,
    JobOffer offer,
  ) async {
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.orangeTint,
              child: Icon(
                Icons.pause_circle_outline_rounded,
                color: AppColors.orange,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Clôturer l’offre ?',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Elle ne sera plus proposée aux candidats. Les candidatures et conversations existantes sont conservées.',
                style: TextStyle(color: AppColors.slate, height: 1.45),
              ),
              const SizedBox(height: 16),
              const Text(
                'Motif (facultatif)',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 7),
              TextField(
                controller: reason,
                maxLines: 3,
                maxLength: 2000,
                decoration: InputDecoration(
                  hintText: 'Ex. : poste pourvu, changement de besoin…',
                  filled: true,
                  fillColor: AppColors.surfaceSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.lineSoft),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clôturer l’offre'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await controller.closeOffer(
        offer.id,
        reason: reason.text.trim().isEmpty ? null : reason.text.trim(),
      );
      if (context.mounted && ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offre clôturée.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    reason.dispose();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    OfferManagementController controller,
    JobOffer offer,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFFFECE8),
              child: Icon(Icons.delete_outline_rounded, color: AppColors.error),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Supprimer cette offre ?',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        content: const SizedBox(
          width: 440,
          child: Text(
            'Cette action retire définitivement l’offre de votre espace JOYN. Cette suppression est simulée côté Front tant que l’API dédiée n’est pas disponible.',
            style: TextStyle(color: AppColors.slate, height: 1.45),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await controller.deleteOffer(offer.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Offre supprimée.' : 'Suppression impossible.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _CompanyFilterCard extends StatelessWidget {
  const _CompanyFilterCard({required this.controller});
  final OfferManagementController controller;

  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Filtrer par entreprise',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            _CompanyFilterTile(
              label: 'Toutes',
              subtitle: '${controller.totalCount} offres',
              icon: Icons.grid_view_rounded,
              selected: controller.companyFilter == null,
              onTap: () => controller.setCompanyFilter(null),
            ),
            for (final company in controller.companies)
              _CompanyFilterTile(
                company: company,
                label: company.name,
                subtitle:
                    '${controller.offers.where((offer) => offer.companyId == company.id).length} offres',
                selected: controller.companyFilter == company.id,
                onTap: () => controller.setCompanyFilter(company.id),
              ),
          ],
        ),
      ],
    ),
  );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.controller});
  final OfferManagementController controller;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth < 720 ? 2 : 4;
      final gap = 10.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          SizedBox(
            width: width,
            child: _StatCard(
              label: 'Publiées',
              value: controller.count(JobOfferStatus.published),
              icon: Icons.description_outlined,
              iconColor: AppColors.successDeep,
              tint: AppColors.successTint,
            ),
          ),
          SizedBox(
            width: width,
            child: _StatCard(
              label: 'Brouillons',
              value: controller.count(JobOfferStatus.draft),
              icon: Icons.schedule_rounded,
              iconColor: AppColors.warningDeep,
              tint: AppColors.warningTint,
            ),
          ),
          SizedBox(
            width: width,
            child: _StatCard(
              label: 'Clôturées',
              value: controller.count(JobOfferStatus.closed),
              icon: Icons.inventory_2_outlined,
              iconColor: AppColors.slateDark,
              tint: const Color(0xFFEAF0F4),
            ),
          ),
          SizedBox(
            width: width,
            child: _StatCard(
              label: 'Total',
              value: controller.totalCount,
              icon: Icons.bar_chart_rounded,
              iconColor: AppColors.navy,
              tint: const Color(0xFFEAF4FC),
            ),
          ),
        ],
      );
    },
  );
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({required this.controller});
  final OfferManagementController controller;

  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: controller.setQuery,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.slate,
                  ),
                  hintText: 'Rechercher une offre (poste, compétences, lieu…)',
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: AppColors.lineSoft),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: AppColors.lineSoft),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
                  _StatusChip(
                    label: 'Toutes',
                    count: controller.totalCount,
                    active: controller.statusFilter == null,
                    onTap: () => controller.setStatusFilter(null),
                  ),
                  _StatusChip(
                    label: 'Publiées',
                    count: controller.count(JobOfferStatus.published),
                    active: controller.statusFilter == JobOfferStatus.published,
                    dot: AppColors.success,
                    onTap: () =>
                        controller.setStatusFilter(JobOfferStatus.published),
                  ),
                  _StatusChip(
                    label: 'Brouillons',
                    count: controller.count(JobOfferStatus.draft),
                    active: controller.statusFilter == JobOfferStatus.draft,
                    dot: AppColors.warning,
                    onTap: () =>
                        controller.setStatusFilter(JobOfferStatus.draft),
                  ),
                  _StatusChip(
                    label: 'Clôturées',
                    count: controller.count(JobOfferStatus.closed),
                    active: controller.statusFilter == JobOfferStatus.closed,
                    dot: AppColors.slate,
                    onTap: () =>
                        controller.setStatusFilter(JobOfferStatus.closed),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MiniSelect<ContractType>(
                label: 'Type de contrat',
                value: controller.contractFilter,
                allLabel: 'Tous les contrats',
                icon: Icons.description_outlined,
                values: ContractType.values,
                labelOf: (value) => value.label,
                onChanged: controller.setContractFilter,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(child: _CompanySelect(controller: controller)),
            const SizedBox(width: 9),
            Expanded(
              child: _MiniSelect<OfferSort>(
                label: 'Trier par',
                value: controller.sort,
                allLabel: 'Plus récentes',
                icon: Icons.tune_rounded,
                values: OfferSort.values,
                labelOf: (value) => switch (value) {
                  OfferSort.recent => 'Plus récentes',
                  OfferSort.oldest => 'Plus anciennes',
                  OfferSort.title => 'Titre A → Z',
                },
                onChanged: (value) {
                  if (value != null) controller.setSort(value);
                },
                nullable: false,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _CompanySelect extends StatelessWidget {
  const _CompanySelect({required this.controller});
  final OfferManagementController controller;
  @override
  Widget build(BuildContext context) => _MiniSelect<int>(
    label: 'Entreprise',
    value: controller.companyFilter,
    allLabel: 'Toutes les entreprises',
    icon: Icons.apartment_outlined,
    values: controller.companies.map((e) => e.id).toList(),
    labelOf: (id) => controller.companyFor(id)?.name ?? 'Entreprise',
    onChanged: controller.setCompanyFilter,
  );
}

class _OfferRow extends StatefulWidget {
  const _OfferRow({
    required this.offer,
    required this.company,
    required this.onEdit,
    required this.onClose,
    required this.onDelete,
  });

  final JobOffer offer;
  final RecruiterCompany? company;
  final VoidCallback onEdit;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  @override
  State<_OfferRow> createState() => _OfferRowState();
}

class _OfferRowState extends State<_OfferRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final company =
        widget.company ??
        const RecruiterCompany(
          id: 99,
          name: 'Entreprise',
          siret: '',
          activity: '',
          sector: '',
          sizeRange: '',
          city: '',
        );
    final accent = companyColor(company.id);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -2.5 : 0, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color.alphaBlend(accent.withValues(alpha: .035), Colors.white),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? const Color(0xFF98C8F2)
                : const Color(0xFFE1E8EE),
            width: _hovered ? 1.25 : 1,
          ),
          boxShadow: _hovered
              ? [
                  const BoxShadow(
                    color: Color(0x1A0A3152),
                    blurRadius: 26,
                    offset: Offset(0, 12),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x0D0A3152),
                    blurRadius: 14,
                    offset: Offset(0, 7),
                  ),
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 18,
              bottom: 18,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 190),
                width: _hovered ? 4 : 3,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Positioned(
              right: -44,
              top: -54,
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  width: _hovered ? 175 : 150,
                  height: _hovered ? 175 : 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: _hovered ? .075 : .04),
                        accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 17, 16, 15),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 860;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CompanyAvatar(company: company, size: 48),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offer.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.navy,
                                    fontFamily: AppFonts.display,
                                    fontSize: 15.5,
                                    height: 1.12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${company.name} · ${company.city.isEmpty ? offer.location : company.city}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.slate,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          OfferStatusBadge(status: offer.status),
                          const SizedBox(width: 8),
                          OfferOptionsButton(
                            status: offer.status,
                            onEdit: widget.onEdit,
                            onClose: offer.status == JobOfferStatus.closed
                                ? null
                                : widget.onClose,
                            onDelete: widget.onDelete,
                            compact: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          OfferMetaChip(
                            label: offer.contractType.label,
                            icon: Icons.work_outline_rounded,
                          ),
                          OfferMetaChip(
                            label: offer.location,
                            icon: Icons.location_on_outlined,
                          ),
                          OfferMetaChip(
                            label: offer.remoteMode.label,
                            icon: Icons.laptop_mac_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),
                      Text(
                        offer.description.replaceAll(RegExp(r'[*#>\[\]]'), ''),
                        maxLines: compact ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.slate,
                          fontSize: 10.5,
                          height: 1.42,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(height: 1, color: const Color(0xFFEAF0F4)),
                      const SizedBox(height: 11),
                      if (compact) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _skillPills(offer),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 18,
                          runSpacing: 7,
                          children: _metrics(offer),
                        ),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: _skillPills(offer),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ..._metrics(offer).expand(
                              (metric) => [metric, const SizedBox(width: 16)],
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _skillPills(JobOffer offer) {
    final visible = offer.skills.take(5).toList();
    return [
      for (final skill in visible)
        JoynPill(
          label: skill,
          background: const Color(0xFFEAF4FC),
          foreground: const Color(0xFF1976D2),
          fontSize: 9,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      if (offer.skills.length > visible.length)
        JoynPill(
          label: '+${offer.skills.length - visible.length}',
          background: const Color(0xFFF0F3F6),
          foreground: AppColors.slateDark,
          fontSize: 9,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
    ];
  }

  List<Widget> _metrics(JobOffer offer) => [
    _OfferMetric(
      icon: Icons.group_outlined,
      label: '${offer.candidateCount} candidat${offer.candidateCount > 1 ? 's' : ''}',
    ),
    _OfferMetric(
      icon: Icons.calendar_today_outlined,
      label: offer.publishedAt == null
          ? 'Modifiée le ${dateLabel(offer.updatedAt)}'
          : 'Publiée le ${dateLabel(offer.publishedAt)}',
    ),
  ];
}

class _OfferMetric extends StatelessWidget {
  const _OfferMetric({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: AppColors.slate),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(
          color: AppColors.slate,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.lineSoft),
      boxShadow: AppShadows.card,
    ),
    child: child,
  );
}

class _CompanyFilterTile extends StatelessWidget {
  const _CompanyFilterTile({
    this.company,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.icon,
  });
  final RecruiterCompany? company;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFF4F9FD) : Colors.white,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 164,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.orange : AppColors.lineSoft,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            if (company != null)
              CompanyAvatar(company: company!, size: 36)
            else
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF1976D2)),
              ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.slate, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.tint,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color iconColor;
  final Color tint;

  @override
  Widget build(BuildContext context) => Container(
    height: 96,
    padding: const EdgeInsets.fromLTRB(14, 13, 12, 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Color.alphaBlend(tint.withValues(alpha: .32), Colors.white)],
      ),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: const Color(0xFFE4EBF0)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D0A3152),
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: iconColor, size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$value',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 24,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    value == 0 ? Icons.remove_rounded : Icons.trending_up_rounded,
                    size: 12,
                    color: value == 0 ? AppColors.placeholder : AppColors.successDeep,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    value == 0 ? 'stable' : 'activité récente',
                    style: TextStyle(
                      color: value == 0 ? AppColors.placeholder : AppColors.successDeep,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          width: 54,
          height: 34,
          child: CustomPaint(
            painter: _SparklinePainter(color: iconColor, seed: value),
          ),
        ),
      ],
    ),
  );
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.color, required this.seed});
  final Color color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final baseline = size.height * .72;
    final points = <Offset>[
      Offset(0, baseline),
      Offset(size.width * .18, size.height * (.64 - (seed % 2) * .05)),
      Offset(size.width * .36, size.height * .7),
      Offset(size.width * .55, size.height * (.48 + (seed % 3) * .035)),
      Offset(size.width * .73, size.height * .55),
      Offset(size.width, size.height * (.26 + (seed % 2) * .08)),
    ];
    final area = Path()..moveTo(points.first.dx, size.height);
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      line.lineTo(point.dx, point.dy);
      area.lineTo(point.dx, point.dy);
    }
    area
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: .16), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color.withValues(alpha: .55)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.seed != seed;
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
    this.dot,
  });
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;
  final Color? dot;
  @override
  Widget build(BuildContext context) => ChoiceChip(
    selected: active,
    onSelected: (_) => onTap(),
    selectedColor: const Color(0xFFEAF4FC),
    backgroundColor: Colors.white,
    side: BorderSide(color: active ? AppColors.blue : AppColors.lineSoft),
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot != null) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
        ],
        Text(label),
        const SizedBox(width: 5),
        Text('$count', style: const TextStyle(color: AppColors.slate)),
      ],
    ),
    labelStyle: TextStyle(
      color: active ? const Color(0xFF1976D2) : AppColors.slateDark,
      fontSize: 10,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _MiniSelect<T> extends StatelessWidget {
  const _MiniSelect({
    required this.label,
    required this.value,
    required this.allLabel,
    required this.icon,
    required this.values,
    required this.labelOf,
    required this.onChanged,
    this.nullable = true,
  });
  final String label;
  final T? value;
  final String allLabel;
  final IconData icon;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;
  final bool nullable;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T?>(
    initialValue: value,
    isExpanded: true,
    items: [
      if (nullable) DropdownMenuItem<T?>(value: null, child: Text(allLabel)),
      ...values.map(
        (item) => DropdownMenuItem<T?>(value: item, child: Text(labelOf(item))),
      ),
    ],
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lineSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lineSoft),
      ),
    ),
  );
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();
  @override
  Widget build(BuildContext context) => const _Card(
    child: SizedBox(
      height: 260,
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) => _Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFEAF4FC),
            child: Icon(Icons.work_outline_rounded, color: AppColors.navy),
          ),
          const SizedBox(height: 14),
          const Text(
            'Aucune offre à afficher',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Modifiez vos filtres ou publiez votre première offre.',
            style: TextStyle(color: AppColors.slate, fontSize: 12),
          ),
          const SizedBox(height: 16),
          JoynButton(
            label: 'Publier une offre',
            variant: JoynButtonVariant.accent,
            onPressed: onCreate,
          ),
        ],
      ),
    ),
  );
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.errorTint,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      message,
      style: const TextStyle(
        color: AppColors.errorDeep,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
