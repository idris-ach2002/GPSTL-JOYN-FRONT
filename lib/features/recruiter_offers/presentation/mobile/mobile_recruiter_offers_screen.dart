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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _CompanyFilters(controller: controller),
                              const SizedBox(height: 12),
                              _SearchAndStatus(controller: controller),
                              const SizedBox(height: 12),
                              if (controller.isLoading)
                                const SizedBox(
                                  height: 260,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (controller.visibleOffers.isEmpty)
                                const _Empty()
                              else
                                for (final offer
                                    in controller.visibleOffers) ...[
                                  _MobileOfferCard(
                                    offer: offer,
                                    company: controller.companyFor(
                                      offer.companyId,
                                    ),
                                    onTap: () => context.go(
                                      AppRoutes.recruiterJobDetail(offer.id),
                                    ),
                                    onEdit: () => context.go(
                                      AppRoutes.recruiterJobEdit(offer.id),
                                    ),
                                    onClose: () => _confirmClose(
                                      context,
                                      controller,
                                      offer,
                                    ),
                                    onDelete: () => _confirmDelete(
                                      context,
                                      controller,
                                      offer,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              const SizedBox(height: 82),
                            ],
                          ),
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
                    label: const Text(
                      'Publier',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
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

  Future<void> _confirmClose(
    BuildContext context,
    OfferManagementController controller,
    JobOffer offer,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ActionSheet(
        icon: Icons.pause_circle_outline_rounded,
        title: 'Clôturer cette offre ?',
        message: 'Elle ne sera plus proposée aux candidats, mais restera visible dans vos offres clôturées.',
        actionLabel: 'Clôturer l’offre',
        onConfirm: () => Navigator.pop(sheetContext, true),
      ),
    );
    if (confirmed != true) return;
    final ok = await controller.closeOffer(offer.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Offre clôturée.' : 'Impossible de clôturer l’offre.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    OfferManagementController controller,
    JobOffer offer,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ActionSheet(
        icon: Icons.delete_outline_rounded,
        title: 'Supprimer cette offre ?',
        message: 'Cette action supprime définitivement l’offre de votre espace JOYN.',
        actionLabel: 'Supprimer l’offre',
        destructive: true,
        onConfirm: () => Navigator.pop(sheetContext, true),
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

class _Hero extends StatelessWidget {
  const _Hero({required this.controller});
  final OfferManagementController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 42),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.navy, Color(0xFF0C5179), Color(0xFF55B5DD)],
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final showEntrepriseBadge = constraints.maxWidth >= 330;

            return Row(
              children: [
                const MobileBrandMark(onDark: true, compact: true),

                if (showEntrepriseBadge) ...[
                  const SizedBox(width: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Entreprise',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded, size: 20),
                  color: Colors.white,
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: .1),
                  ),
                ),

                const SizedBox(width: 5),

                const CircleAvatar(
                  radius: 19,
                  backgroundColor: Colors.white,
                  child: Text(
                    'E',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        const Text(
          'Mes offres',
          style: TextStyle(
            color: Colors.white,
            fontSize: 29,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: -.8,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Gérez et suivez toutes vos offres d’emploi sur Joyn.',
          style: TextStyle(color: Color(0xFFE4F3FB), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _HeroStat(
                value: controller.count(JobOfferStatus.published),
                label: 'Publiées',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _HeroStat(
                value: controller.count(JobOfferStatus.draft),
                label: 'Brouillons',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _HeroStat(
                value: controller.count(JobOfferStatus.closed),
                label: 'Clôturées',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});
  final int value;
  final String label;

  OfferKpiChartStyle get _chartStyle => switch (label) {
    'Publiées' => OfferKpiChartStyle.bars,
    'Brouillons' => OfferKpiChartStyle.line,
    _ => OfferKpiChartStyle.softLine,
  };

  @override
  Widget build(BuildContext context) {
    final (icon, tone, foreground) = switch (label) {
      'Publiées' => (
        Icons.description_outlined,
        AppColors.successTint,
        AppColors.successDeep,
      ),
      'Brouillons' => (
        Icons.schedule_rounded,
        AppColors.warningTint,
        AppColors.warningDeep,
      ),
      _ => (
        Icons.inventory_2_outlined,
        const Color(0xFFEAF0F4),
        AppColors.slateDark,
      ),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 9, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color.alphaBlend(tone.withValues(alpha: .36), Colors.white),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: .7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12001E3B),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$value',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.slate,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 27,
                height: 27,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
                child: Icon(icon, size: 14, color: foreground),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.bottomRight,
            child: OfferKpiMiniChart(
              color: foreground,
              style: _chartStyle,
              width: 44,
              height: 20,
            ),
          ),
        ],
      ),
    );
  }
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
          return ChoiceChip(
            label: const Text('Toutes'),
            selected: active,
            onSelected: (_) => controller.setCompanyFilter(null),
            selectedColor: AppColors.navy,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: active ? Colors.white : AppColors.navy,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
            side: BorderSide.none,
          );
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
          labelStyle: const TextStyle(
            color: AppColors.navy,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
          side: BorderSide(
            color: active ? AppColors.orange : const Color(0xFFE4E8E3),
          ),
        );
      },
    ),
  );
}

class _SearchAndStatus extends StatelessWidget {
  const _SearchAndStatus({required this.controller});
  final OfferManagementController controller;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        onChanged: controller.setQuery,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate),
          suffixIcon: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded, size: 19),
          ),
          hintText: 'Rechercher une offre…',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE4E8E3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE4E8E3)),
          ),
        ),
      ),
      const SizedBox(height: 9),
      SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _StatusFilter(
              label: 'Toutes (${controller.totalCount})',
              active: controller.statusFilter == null,
              onTap: () => controller.setStatusFilter(null),
            ),
            _StatusFilter(
              label: 'Actives (${controller.count(JobOfferStatus.published)})',
              active: controller.statusFilter == JobOfferStatus.published,
              tone: AppColors.successTint,
              onTap: () => controller.setStatusFilter(JobOfferStatus.published),
            ),
            _StatusFilter(
              label: 'Brouillons (${controller.count(JobOfferStatus.draft)})',
              active: controller.statusFilter == JobOfferStatus.draft,
              tone: AppColors.warningTint,
              onTap: () => controller.setStatusFilter(JobOfferStatus.draft),
            ),
            _StatusFilter(
              label: 'Clôturées (${controller.count(JobOfferStatus.closed)})',
              active: controller.statusFilter == JobOfferStatus.closed,
              onTap: () => controller.setStatusFilter(JobOfferStatus.closed),
            ),
          ],
        ),
      ),
    ],
  );
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({
    required this.label,
    required this.active,
    required this.onTap,
    this.tone,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? tone;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 7),
    child: FilterChip(
      selected: active,
      onSelected: (_) => onTap(),
      label: Text(label),
      selectedColor: tone ?? const Color(0xFFEAF4FC),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: active ? AppColors.blue : const Color(0xFFE4E8E3),
      ),
      labelStyle: TextStyle(
        color: active ? const Color(0xFF1976D2) : AppColors.slate,
        fontSize: 9,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _MobileOfferCard extends StatelessWidget {
  const _MobileOfferCard({
    required this.offer,
    required this.company,
    required this.onTap,
    required this.onEdit,
    required this.onClose,
    required this.onDelete,
  });

  final JobOffer offer;
  final RecruiterCompany? company;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c =
        company ??
        const RecruiterCompany(
          id: 99,
          name: 'Entreprise',
          siret: '',
          activity: '',
          sector: '',
          sizeRange: '',
          city: '',
        );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: OfferGlassSurface(
          waveWidth: 155,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              OfferStatusBadge(status: offer.status),
                              const SizedBox(width: 8),
                              CompanyMiniLogo(company: c, size: 18),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  c.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.navy,
                                    fontSize: 9.2,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                '·',
                                style: TextStyle(color: AppColors.placeholder),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  offer.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.slate,
                                    fontSize: 8.8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text(
                            offer.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 13.5,
                              height: 1.15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    OfferOptionsButton(
                      status: offer.status,
                      onEdit: onEdit,
                      onClose: offer.status == JobOfferStatus.closed
                          ? null
                          : onClose,
                      onDelete: onDelete,
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  _plainDescription(offer.description),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.slate,
                    fontSize: 9.7,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 3),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: onTap,
                    child: const Text(
                      'Lire la suite  →',
                      style: TextStyle(
                        color: Color(0xFF1475D1),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    OfferMetaChip(
                      label: offer.contractType.label,
                      icon: Icons.work_outline_rounded,
                    ),
                    OfferMetaChip(
                      label: offer.remoteMode.label,
                      icon: Icons.laptop_mac_rounded,
                    ),
                  ],
                ),
                if (offer.skills.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final skill in offer.skills.take(3))
                        OfferSkillTag(label: skill),
                      if (offer.skills.length > 3)
                        OfferSkillTag(label: '+${offer.skills.length - 3}'),
                    ],
                  ),
                ],
                const SizedBox(height: 9),
                Container(height: 1, color: const Color(0xFFDDE7EF)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (offer.candidateCount > 0) ...[
                      OfferCandidateAvatars(
                        count: offer.candidateCount,
                        size: 23,
                        maxVisible: 3,
                      ),
                      const SizedBox(width: 7),
                    ],
                    const Icon(
                      Icons.group_outlined,
                      size: 12,
                      color: AppColors.slate,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${offer.candidateCount} candidat${offer.candidateCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: AppColors.slate,
                        fontSize: 8.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: AppColors.slate,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        dateLabel(offer.publishedAt ?? offer.updatedAt),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.slate,
                          fontSize: 8.8,
                          fontWeight: FontWeight.w700,
                        ),
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

  String _plainDescription(String value) => value
      .replaceAll(RegExp(r'[*#>\[\]`]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class _ActionSheet extends StatelessWidget {
  const _ActionSheet({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onConfirm,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onConfirm;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final actionColor = destructive ? AppColors.error : AppColors.orange;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: actionColor.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: actionColor, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.slate,
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: onConfirm,
                style: FilledButton.styleFrom(
                  backgroundColor: actionColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(icon, size: 18),
                label: Text(actionLabel),
              ),
            ),
            const SizedBox(height: 7),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Column(
      children: [
        Icon(Icons.work_outline_rounded, color: AppColors.orange, size: 32),
        SizedBox(height: 10),
        Text(
          'Aucune offre à afficher',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 5),
        Text(
          'Changez vos filtres ou créez une nouvelle offre.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.slate, fontSize: 11),
        ),
      ],
    ),
  );
}
