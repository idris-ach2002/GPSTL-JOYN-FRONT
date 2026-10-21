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
            child: Column(children: [
              Container(height: 280, decoration: const BoxDecoration(gradient: AppGradients.hero)),
              const Expanded(child: ColoredBox(color: AppColors.background)),
            ]),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: controller.load,
              child: ListView(
                padding: EdgeInsets.fromLTRB(width < 760 ? 18 : 28, 16, width < 760 ? 18 : 28, 40),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1220),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        const RecruiterOffersTopBar(),
                        const SizedBox(height: 28),
                        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Mes offres', style: TextStyle(color: Colors.white, fontFamily: AppFonts.display, fontSize: 34, height: 1, fontWeight: FontWeight.w800, letterSpacing: -.8)),
                            SizedBox(height: 7),
                            Text('Gérez, modifiez et suivez toutes vos offres.', style: TextStyle(color: Color(0xFFE4F3FB), fontSize: 14, fontWeight: FontWeight.w500)),
                          ])),
                          JoynButton(label: 'Publier une offre', leadingIcon: Icons.add_rounded, variant: JoynButtonVariant.accent, height: 48, onPressed: () => context.go(AppRoutes.recruiterJobCreate)),
                        ]),
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
                            _EmptyState(onCreate: () => context.go(AppRoutes.recruiterJobCreate))
                          else
                            for (final offer in controller.visibleOffers) ...[
                              _OfferRow(
                                offer: offer,
                                company: controller.companyFor(offer.companyId),
                                onEdit: () => context.go(AppRoutes.recruiterJobEdit(offer.id)),
                                onClose: () => _confirmClose(context, controller, offer),
                              ),
                              const SizedBox(height: 9),
                            ],
                        ],
                      ]),
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

  Future<void> _confirmClose(BuildContext context, OfferManagementController controller, JobOffer offer) async {
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(children: [
          CircleAvatar(backgroundColor: AppColors.orangeTint, child: Icon(Icons.pause_circle_outline_rounded, color: AppColors.orange)),
          SizedBox(width: 12),
          Expanded(child: Text('Clôturer l’offre ?', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900))),
        ]),
        content: SizedBox(
          width: 460,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Elle ne sera plus proposée aux candidats. Les candidatures et conversations existantes sont conservées.', style: TextStyle(color: AppColors.slate, height: 1.45)),
            const SizedBox(height: 16),
            const Text('Motif (facultatif)', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(height: 7),
            TextField(controller: reason, maxLines: 3, maxLength: 2000, decoration: InputDecoration(hintText: 'Ex. : poste pourvu, changement de besoin…', filled: true, fillColor: AppColors.surfaceSubtle, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.lineSoft)))),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white),
            child: const Text('Clôturer l’offre'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await controller.closeOffer(offer.id, reason: reason.text.trim().isEmpty ? null : reason.text.trim());
      if (context.mounted && ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offre clôturée.'), behavior: SnackBarBehavior.floating));
      }
    }
    reason.dispose();
  }
}

class _CompanyFilterCard extends StatelessWidget {
  const _CompanyFilterCard({required this.controller});
  final OfferManagementController controller;

  @override
  Widget build(BuildContext context) => _Card(
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Filtrer par entreprise', style: TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      Wrap(spacing: 9, runSpacing: 9, children: [
        _CompanyFilterTile(label: 'Toutes', subtitle: '${controller.totalCount} offres', icon: Icons.grid_view_rounded, selected: controller.companyFilter == null, onTap: () => controller.setCompanyFilter(null)),
        for (final company in controller.companies)
          _CompanyFilterTile(company: company, label: company.name, subtitle: '${controller.offers.where((offer) => offer.companyId == company.id).length} offres', selected: controller.companyFilter == company.id, onTap: () => controller.setCompanyFilter(company.id)),
      ]),
    ]),
  );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.controller});
  final OfferManagementController controller;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final columns = constraints.maxWidth < 720 ? 2 : 4;
    final gap = 10.0;
    final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
    return Wrap(spacing: gap, runSpacing: gap, children: [
      SizedBox(width: width, child: _StatCard(label: 'Publiées', value: controller.count(JobOfferStatus.published), icon: Icons.description_outlined, iconColor: AppColors.successDeep, tint: AppColors.successTint)),
      SizedBox(width: width, child: _StatCard(label: 'Brouillons', value: controller.count(JobOfferStatus.draft), icon: Icons.schedule_rounded, iconColor: AppColors.warningDeep, tint: AppColors.warningTint)),
      SizedBox(width: width, child: _StatCard(label: 'Clôturées', value: controller.count(JobOfferStatus.closed), icon: Icons.inventory_2_outlined, iconColor: AppColors.slateDark, tint: const Color(0xFFEAF0F4))),
      SizedBox(width: width, child: _StatCard(label: 'Total', value: controller.totalCount, icon: Icons.bar_chart_rounded, iconColor: AppColors.navy, tint: const Color(0xFFEAF4FC))),
    ]);
  });
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({required this.controller});
  final OfferManagementController controller;

  @override
  Widget build(BuildContext context) => _Card(
    child: Column(children: [
      Row(children: [
        Expanded(
          child: TextField(
            onChanged: controller.setQuery,
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate), hintText: 'Rechercher une offre (poste, compétences, lieu…)', isDense: true, filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: AppColors.lineSoft)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: AppColors.lineSoft))),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.end, children: [
            _StatusChip(label: 'Toutes', count: controller.totalCount, active: controller.statusFilter == null, onTap: () => controller.setStatusFilter(null)),
            _StatusChip(label: 'Publiées', count: controller.count(JobOfferStatus.published), active: controller.statusFilter == JobOfferStatus.published, dot: AppColors.success, onTap: () => controller.setStatusFilter(JobOfferStatus.published)),
            _StatusChip(label: 'Brouillons', count: controller.count(JobOfferStatus.draft), active: controller.statusFilter == JobOfferStatus.draft, dot: AppColors.warning, onTap: () => controller.setStatusFilter(JobOfferStatus.draft)),
            _StatusChip(label: 'Clôturées', count: controller.count(JobOfferStatus.closed), active: controller.statusFilter == JobOfferStatus.closed, dot: AppColors.slate, onTap: () => controller.setStatusFilter(JobOfferStatus.closed)),
          ]),
        ),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _MiniSelect<ContractType>(label: 'Type de contrat', value: controller.contractFilter, allLabel: 'Tous les contrats', icon: Icons.description_outlined, values: ContractType.values, labelOf: (value) => value.label, onChanged: controller.setContractFilter)),
        const SizedBox(width: 9),
        Expanded(child: _CompanySelect(controller: controller)),
        const SizedBox(width: 9),
        Expanded(child: _MiniSelect<OfferSort>(label: 'Trier par', value: controller.sort, allLabel: 'Plus récentes', icon: Icons.tune_rounded, values: OfferSort.values, labelOf: (value) => switch (value) { OfferSort.recent => 'Plus récentes', OfferSort.oldest => 'Plus anciennes', OfferSort.title => 'Titre A → Z' }, onChanged: (value) { if (value != null) controller.setSort(value); }, nullable: false)),
      ]),
    ]),
  );
}

class _CompanySelect extends StatelessWidget {
  const _CompanySelect({required this.controller});
  final OfferManagementController controller;
  @override
  Widget build(BuildContext context) => _MiniSelect<int>(label: 'Entreprise', value: controller.companyFilter, allLabel: 'Toutes les entreprises', icon: Icons.apartment_outlined, values: controller.companies.map((e) => e.id).toList(), labelOf: (id) => controller.companyFor(id)?.name ?? 'Entreprise', onChanged: controller.setCompanyFilter);
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({required this.offer, required this.company, required this.onEdit, required this.onClose});
  final JobOffer offer;
  final RecruiterCompany? company;
  final VoidCallback onEdit;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final c = company ?? const RecruiterCompany(id: 99, name: 'Entreprise', siret: '', activity: '', sector: '', sizeRange: '', city: '');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.lineSoft), boxShadow: AppShadows.card),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CompanyAvatar(company: c, size: 46),
        const SizedBox(width: 13),
        Expanded(flex: 5, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(offer.title, style: const TextStyle(color: AppColors.navy, fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text('${c.name} · ${offer.location}', style: const TextStyle(color: AppColors.slate, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text(offer.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.slate, fontSize: 10, height: 1.35)),
          const SizedBox(height: 7),
          Wrap(spacing: 5, runSpacing: 5, children: offer.skills.take(5).map((skill) => JoynPill(label: skill, background: const Color(0xFFEAF4FC), foreground: const Color(0xFF1976D2), fontSize: 9, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4))).toList()),
        ])),
        const SizedBox(width: 12),
        Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 6, runSpacing: 6, children: [
            OfferMetaChip(label: offer.contractType.label, icon: Icons.work_outline_rounded),
            OfferMetaChip(label: offer.location, icon: Icons.location_on_outlined),
            OfferMetaChip(label: offer.remoteMode.label, icon: Icons.home_outlined),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.group_outlined, size: 15, color: AppColors.slate),
            const SizedBox(width: 5),
            Text('${offer.candidateCount} candidat${offer.candidateCount > 1 ? 's' : ''}', style: const TextStyle(color: AppColors.slate, fontSize: 10)),
            const SizedBox(width: 16),
            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.slate),
            const SizedBox(width: 5),
            Flexible(child: Text(offer.publishedAt == null ? 'Modifiée le ${dateLabel(offer.updatedAt)}' : 'Publiée le ${dateLabel(offer.publishedAt)}', overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.slate, fontSize: 10))),
          ]),
        ])),
        const SizedBox(width: 12),
        SizedBox(width: 138, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [OfferStatusBadge(status: offer.status), const SizedBox(width: 5), PopupMenuButton<String>(tooltip: 'Actions', icon: const Icon(Icons.more_vert_rounded, size: 19, color: AppColors.slate), onSelected: (value) { if (value == 'edit') onEdit(); if (value == 'close') onClose(); }, itemBuilder: (context) => [const PopupMenuItem(value: 'edit', child: Text('Modifier')), if (offer.status != JobOfferStatus.closed) const PopupMenuItem(value: 'close', child: Text('Clôturer'))])]),
          if (offer.status != JobOfferStatus.closed) ...[
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 14), label: const Text('Modifier'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1976D2), padding: const EdgeInsets.symmetric(horizontal: 10))),
              if (offer.status == JobOfferStatus.published) ...[
                const SizedBox(width: 5),
                OutlinedButton(onPressed: onClose, style: OutlinedButton.styleFrom(foregroundColor: AppColors.orange, side: const BorderSide(color: AppColors.orangeLine), padding: const EdgeInsets.symmetric(horizontal: 10)), child: const Text('Clôturer')),
              ],
            ]),
          ],
        ])),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.lineSoft), boxShadow: AppShadows.card), child: child);
}

class _CompanyFilterTile extends StatelessWidget {
  const _CompanyFilterTile({this.company, required this.label, required this.subtitle, required this.selected, required this.onTap, this.icon});
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
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? AppColors.orange : AppColors.lineSoft, width: selected ? 1.4 : 1)),
        child: Row(children: [
          if (company != null) CompanyAvatar(company: company!, size: 36) else Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFEAF4FC), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: const Color(0xFF1976D2))),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: AppColors.slate, fontSize: 9))])),
        ]),
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.iconColor, required this.tint});
  final String label;
  final int value;
  final IconData icon;
  final Color iconColor;
  final Color tint;

  @override
  Widget build(BuildContext context) => Container(
    height: 92,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: AppShadows.card),
    child: Row(children: [
      CircleAvatar(radius: 24, backgroundColor: tint, child: Icon(icon, color: iconColor, size: 21)),
      const SizedBox(width: 12),
      Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text('$value', style: const TextStyle(color: AppColors.navy, fontSize: 24, fontWeight: FontWeight.w900)), const Text('vs. mois dernier', style: TextStyle(color: AppColors.placeholder, fontSize: 8))]),
    ]),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.count, required this.active, required this.onTap, this.dot});
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
    label: Row(mainAxisSize: MainAxisSize.min, children: [if (dot != null) ...[Container(width: 6, height: 6, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)), const SizedBox(width: 5)], Text(label), const SizedBox(width: 5), Text('$count', style: const TextStyle(color: AppColors.slate))]),
    labelStyle: TextStyle(color: active ? const Color(0xFF1976D2) : AppColors.slateDark, fontSize: 10, fontWeight: FontWeight.w700),
  );
}

class _MiniSelect<T> extends StatelessWidget {
  const _MiniSelect({required this.label, required this.value, required this.allLabel, required this.icon, required this.values, required this.labelOf, required this.onChanged, this.nullable = true});
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
    items: [if (nullable) DropdownMenuItem<T?>(value: null, child: Text(allLabel)), ...values.map((item) => DropdownMenuItem<T?>(value: item, child: Text(labelOf(item))))],
    onChanged: onChanged,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18), isDense: true, filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lineSoft)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lineSoft))),
  );
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();
  @override
  Widget build(BuildContext context) => const _Card(child: SizedBox(height: 260, child: Center(child: CircularProgressIndicator())));
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) => _Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 42), child: Column(children: [
    const CircleAvatar(radius: 28, backgroundColor: Color(0xFFEAF4FC), child: Icon(Icons.work_outline_rounded, color: AppColors.navy)),
    const SizedBox(height: 14),
    const Text('Aucune offre à afficher', style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.w900)),
    const SizedBox(height: 6),
    const Text('Modifiez vos filtres ou publiez votre première offre.', style: TextStyle(color: AppColors.slate, fontSize: 12)),
    const SizedBox(height: 16),
    JoynButton(label: 'Publier une offre', variant: JoynButtonVariant.accent, onPressed: onCreate),
  ])));
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.errorTint, borderRadius: BorderRadius.circular(12)), child: Text(message, style: const TextStyle(color: AppColors.errorDeep, fontWeight: FontWeight.w700)));
}
