import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/mobile/mobile_bottom_navigation.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/job_offer.dart';
import '../../domain/recruiter_company.dart';
import '../controllers/offer_management_controller.dart';
import '../shared/offer_ui.dart';

class MobileRecruiterOffersScreen extends StatelessWidget {
  const MobileRecruiterOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OfferManagementController>();
    return MobileAppSurface(
      systemUiOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: const Color(0xFFF5F7F6),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: controller.load,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _Hero(controller: controller),
                      Transform.translate(
                        offset: const Offset(0, -18),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                            _CompanyFilters(controller: controller),
                            const SizedBox(height: 12),
                            _SearchAndStatus(controller: controller),
                            const SizedBox(height: 12),
                            if (controller.isLoading)
                              const SizedBox(height: 260, child: Center(child: CircularProgressIndicator()))
                            else if (controller.visibleOffers.isEmpty)
                              const _Empty()
                            else
                              for (final offer in controller.visibleOffers) ...[
                                _MobileOfferCard(
                                  offer: offer,
                                  company: controller.companyFor(offer.companyId),
                                  onTap: () => context.go(AppRoutes.recruiterJobDetail(offer.id)),
                                  onEdit: () => context.go(AppRoutes.recruiterJobEdit(offer.id)),
                                ),
                                const SizedBox(height: 10),
                              ],
                            const SizedBox(height: 82),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: FloatingActionButton.extended(
                    heroTag: 'publish-offer',
                    onPressed: () => context.go(AppRoutes.recruiterJobCreate),
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Publier', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
          MobileBottomNavigation(
            selectedIndex: 2,
            onSelected: (index) {
              if (index == 0) context.go(AppRoutes.dashboard);
              if (index == 2) return;
            },
            items: const [
              MobileNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
              MobileNavItem(icon: Icons.people_alt_rounded, label: 'Talents'),
              MobileNavItem(icon: Icons.work_rounded, label: 'Offres'),
              MobileNavItem(icon: Icons.chat_bubble_rounded, label: 'Messages'),
              MobileNavItem(icon: Icons.more_horiz_rounded, label: 'Plus'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.controller});
  final OfferManagementController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 42),
    decoration: const BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.navy, Color(0xFF0C5179), Color(0xFF55B5DD)]),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        const MobileBrandMark(onDark: true, compact: true),
        const SizedBox(width: 7),
        Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(5)), child: const Text('Entreprise', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))),
        const Spacer(),
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded), color: Colors.white, style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: .1))),
        const SizedBox(width: 5),
        const CircleAvatar(radius: 19, backgroundColor: Colors.white, child: Text('E', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900))),
      ]),
      const SizedBox(height: 22),
      const Text('Mes offres', style: TextStyle(color: Colors.white, fontSize: 29, height: 1, fontWeight: FontWeight.w900, letterSpacing: -.8)),
      const SizedBox(height: 6),
      const Text('Gérez et suivez toutes vos offres d’emploi sur Joyn.', style: TextStyle(color: Color(0xFFE4F3FB), fontSize: 12, height: 1.4)),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: _HeroStat(value: controller.count(JobOfferStatus.published), label: 'Publiées')),
        const SizedBox(width: 8),
        Expanded(child: _HeroStat(value: controller.count(JobOfferStatus.draft), label: 'Brouillons')),
        const SizedBox(width: 8),
        Expanded(child: _HeroStat(value: controller.count(JobOfferStatus.closed), label: 'Clôturées')),
      ]),
    ]),
  );
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});
  final int value;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$value', style: const TextStyle(color: AppColors.navy, fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(label, style: const TextStyle(color: AppColors.slate, fontSize: 9, fontWeight: FontWeight.w700))]),
  );
}

class _CompanyFilters extends StatelessWidget {
  const _CompanyFilters({required this.controller});
  final OfferManagementController controller;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: controller.companies.length + 1,
      separatorBuilder: (_, _) => const SizedBox(width: 7),
      itemBuilder: (context, index) {
        if (index == 0) {
          final active = controller.companyFilter == null;
          return ChoiceChip(label: const Text('Toutes'), selected: active, onSelected: (_) => controller.setCompanyFilter(null), selectedColor: AppColors.navy, backgroundColor: Colors.white, labelStyle: TextStyle(color: active ? Colors.white : AppColors.navy, fontSize: 10, fontWeight: FontWeight.w800), side: BorderSide.none);
        }
        final company = controller.companies[index - 1];
        final active = controller.companyFilter == company.id;
        return ChoiceChip(
          avatar: CompanyAvatar(company: company, size: 25),
          label: Text(company.name),
          selected: active,
          onSelected: (_) => controller.setCompanyFilter(company.id),
          selectedColor: AppColors.orangeTint,
          backgroundColor: Colors.white,
          labelStyle: const TextStyle(color: AppColors.navy, fontSize: 10, fontWeight: FontWeight.w800),
          side: BorderSide(color: active ? AppColors.orange : const Color(0xFFE4E8E3)),
        );
      },
    ),
  );
}

class _SearchAndStatus extends StatelessWidget {
  const _SearchAndStatus({required this.controller});
  final OfferManagementController controller;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    TextField(
      onChanged: controller.setQuery,
      decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate), suffixIcon: IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded, size: 19)), hintText: 'Rechercher une offre…', filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE4E8E3))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE4E8E3)))),
    ),
    const SizedBox(height: 9),
    SizedBox(
      height: 36,
      child: ListView(scrollDirection: Axis.horizontal, children: [
        _StatusFilter(label: 'Toutes (${controller.totalCount})', active: controller.statusFilter == null, onTap: () => controller.setStatusFilter(null)),
        _StatusFilter(label: 'Actives (${controller.count(JobOfferStatus.published)})', active: controller.statusFilter == JobOfferStatus.published, tone: AppColors.successTint, onTap: () => controller.setStatusFilter(JobOfferStatus.published)),
        _StatusFilter(label: 'Brouillons (${controller.count(JobOfferStatus.draft)})', active: controller.statusFilter == JobOfferStatus.draft, tone: AppColors.warningTint, onTap: () => controller.setStatusFilter(JobOfferStatus.draft)),
        _StatusFilter(label: 'Clôturées (${controller.count(JobOfferStatus.closed)})', active: controller.statusFilter == JobOfferStatus.closed, onTap: () => controller.setStatusFilter(JobOfferStatus.closed)),
      ]),
    ),
  ]);
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.label, required this.active, required this.onTap, this.tone});
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? tone;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 7),
    child: FilterChip(selected: active, onSelected: (_) => onTap(), label: Text(label), selectedColor: tone ?? const Color(0xFFEAF4FC), backgroundColor: Colors.white, side: BorderSide(color: active ? AppColors.blue : const Color(0xFFE4E8E3)), labelStyle: TextStyle(color: active ? const Color(0xFF1976D2) : AppColors.slate, fontSize: 9, fontWeight: FontWeight.w800)),
  );
}

class _MobileOfferCard extends StatelessWidget {
  const _MobileOfferCard({required this.offer, required this.company, required this.onTap, required this.onEdit});
  final JobOffer offer;
  final RecruiterCompany? company;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final c = company;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (c != null) CompanyAvatar(company: c, size: 42),
              if (c != null) const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(offer.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.navy, fontSize: 13, height: 1.15, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text('${c?.name ?? 'Entreprise'} · ${offer.location}', style: const TextStyle(color: AppColors.slate, fontSize: 10, fontWeight: FontWeight.w600)),
              ])),
              OfferStatusBadge(status: offer.status),
              PopupMenuButton<String>(padding: EdgeInsets.zero, icon: const Icon(Icons.more_vert_rounded, color: AppColors.slate, size: 19), onSelected: (value) { if (value == 'edit') onEdit(); }, itemBuilder: (context) => const [PopupMenuItem(value: 'edit', child: Text('Modifier'))]),
            ]),
            const SizedBox(height: 9),
            Wrap(spacing: 6, runSpacing: 6, children: [OfferMetaChip(label: offer.contractType.label, icon: Icons.work_outline_rounded), OfferMetaChip(label: offer.remoteMode.label, icon: Icons.laptop_mac_rounded)]),
            const SizedBox(height: 8),
            Text('${offer.candidateCount} candidat${offer.candidateCount > 1 ? 's' : ''} · ${offer.publishedAt == null ? 'Modifiée' : 'Publiée'} le ${dateLabel(offer.publishedAt ?? offer.updatedAt)}', style: const TextStyle(color: AppColors.placeholder, fontSize: 9, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Column(children: [Icon(Icons.work_outline_rounded, color: AppColors.orange, size: 32), SizedBox(height: 10), Text('Aucune offre à afficher', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900)), SizedBox(height: 5), Text('Changez vos filtres ou créez une nouvelle offre.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.slate, fontSize: 11))]));
}
