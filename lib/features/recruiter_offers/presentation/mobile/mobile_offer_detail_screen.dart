import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/job_offer.dart';
import '../../domain/recruiter_company.dart';
import '../controllers/offer_detail_controller.dart';
import '../shared/offer_candidates_panel.dart';
import '../shared/offer_ui.dart';

class MobileOfferDetailScreen extends StatelessWidget {
  const MobileOfferDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OfferDetailController>();
    if (controller.isLoading) {
      return const MobileAppSurface(child: Center(child: CircularProgressIndicator()));
    }
    final offer = controller.offer;
    final company = controller.company;
    if (offer == null || company == null) {
      return MobileAppSurface(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 34),
                const SizedBox(height: 12),
                Text(
                  controller.errorMessage ?? 'Offre introuvable.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.recruiterJobs),
                  child: const Text('Retour aux offres'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MobileAppSurface(
      systemUiOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          const _MobileTopBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _Breadcrumb(offer: offer),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: _SummaryCard(
                    offer: offer,
                    company: company,
                    onCandidates: offer.candidateCount <= 0
                        ? null
                        : () => showOfferCandidatesPanel(context, offer: offer),
                    onEdit: () => context.go(AppRoutes.recruiterJobEdit(offer.id)),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: _MobileTabs(
                    candidateCount: offer.candidateCount,
                    onCandidates: offer.candidateCount <= 0
                        ? null
                        : () => showOfferCandidatesPanel(context, offer: offer),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      _SectionCard(
                        title: 'À propos de l’offre',
                        icon: Icons.description_outlined,
                        child: OfferRichText(
                          value: offer.description,
                          baseStyle: const TextStyle(color: AppColors.slateDark, fontSize: 13.5, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _SectionCard(
                        title: 'Compétences recherchées',
                        icon: Icons.auto_awesome_outlined,
                        child: Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [for (final skill in offer.skills) OfferSkillTag(label: skill)],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _SectionCard(
                        title: 'Informations',
                        icon: Icons.info_outline_rounded,
                        child: Column(
                          children: [
                            _Info(icon: Icons.work_outline_rounded, label: 'Contrat', value: offer.contractType.label),
                            _Info(icon: Icons.location_on_outlined, label: 'Localisation', value: offer.location),
                            _Info(icon: Icons.laptop_mac_rounded, label: 'Mode de travail', value: offer.remoteMode.label),
                            _Info(icon: Icons.trending_up_rounded, label: 'Expérience', value: offer.experienceLevel.label),
                            _Info(icon: Icons.payments_outlined, label: 'Rémunération', value: salaryLabel(offer)),
                          ],
                        ),
                      ),
                      if (offer.contractType.isWorkStudy) ...[
                        const SizedBox(height: 10),
                        _SectionCard(
                          title: 'Alternance',
                          icon: Icons.school_outlined,
                          child: Column(
                            children: [
                              _Info(icon: Icons.repeat_rounded, label: 'Rythme', value: offer.rhythmType ?? '—'),
                              _Info(icon: Icons.event_outlined, label: 'Début', value: monthYearLabel(offer.startDate)),
                              _Info(icon: Icons.timelapse_rounded, label: 'Durée', value: offer.durationMonths == null ? '—' : '${offer.durationMonths} mois'),
                              _Info(icon: Icons.school_outlined, label: 'Niveau', value: offer.degreeLevelRequired?.replaceAll('BAC_', 'Bac+') ?? '—'),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      _SectionCard(
                        title: 'Candidatures',
                        icon: Icons.groups_2_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                if (offer.candidateCount > 0) ...[
                                  OfferCandidateAvatars(count: offer.candidateCount, size: 30, maxVisible: 4),
                                  const SizedBox(width: 9),
                                ],
                                Expanded(
                                  child: Text(
                                    '${offer.candidateCount} candidat${offer.candidateCount > 1 ? 's' : ''} sur cette offre',
                                    style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                            if (offer.candidateCount > 0) ...[
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () => showOfferCandidatesPanel(context, offer: offer),
                                icon: const Icon(Icons.people_alt_outlined, size: 17),
                                label: const Text('Voir les candidats'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1475D1),
                                  side: const BorderSide(color: Color(0xFFB9DDFB)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _SectionCard(
                        title: 'Entreprise',
                        icon: Icons.apartment_outlined,
                        child: Column(
                          children: [
                            _Info(icon: Icons.business_outlined, label: 'Nom', value: company.name),
                            _Info(icon: Icons.category_outlined, label: 'Secteur', value: company.sector),
                            _Info(icon: Icons.groups_outlined, label: 'Taille', value: company.sizeRange),
                            _Info(icon: Icons.location_city_outlined, label: 'Ville', value: company.city),
                          ],
                        ),
                      ),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5ECF1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.recruiterJobEdit(offer.id)),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Modifier'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1475D1),
                        side: const BorderSide(color: Color(0xFFB9DDFB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                      ),
                    ),
                  ),
                ),
                if (offer.status != JobOfferStatus.closed) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: controller.isClosing ? null : () => _showCloseSheet(context, controller),
                        icon: const Icon(Icons.pause_circle_outline_rounded, size: 18),
                        label: const Text('Clôturer'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCloseSheet(BuildContext context, OfferDetailController controller) async {
    final shouldClose = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 42, height: 4, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(99))),
              const SizedBox(height: 18),
              const Text('Clôturer l’offre ?', style: TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              const Text('Elle ne sera plus proposée aux candidats. Les candidatures existantes seront conservées.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.slate, fontSize: 12, height: 1.45)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler'))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.orange),
                      child: const Text('Clôturer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (shouldClose == true) await controller.close();
  }
}

class _MobileTopBar extends StatelessWidget {
  const _MobileTopBar();

  @override
  Widget build(BuildContext context) => Container(
    height: 70,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    color: AppColors.navy,
    child: Row(
      children: [
        const MobileBrandMark(onDark: true, compact: true),
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(5)),
          child: const Text('Entreprise', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
        ),
        const Spacer(),
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded), color: Colors.white),
        const CircleAvatar(radius: 18, backgroundColor: Colors.white, child: Text('E', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900))),
      ],
    ),
  );
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.offer});
  final JobOffer offer;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
    child: Row(
      children: [
        TextButton.icon(
          onPressed: () => context.go(AppRoutes.recruiterJobs),
          icon: const Icon(Icons.chevron_left_rounded, size: 18),
          label: const Text('Offres'),
          style: TextButton.styleFrom(foregroundColor: AppColors.slateDark),
        ),
        const Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.placeholder),
        const SizedBox(width: 4),
        const Text('Détail de l’offre', style: TextStyle(color: AppColors.slateDark, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.offer,
    required this.company,
    required this.onCandidates,
    required this.onEdit,
  });
  final JobOffer offer;
  final RecruiterCompany company;
  final VoidCallback? onCandidates;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => _SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            OfferStatusBadge(status: offer.status),
            const SizedBox(width: 8),
            CompanyMiniLogo(company: company, size: 23),
            const SizedBox(width: 6),
            Text(company.name, style: const TextStyle(color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.w900)),
            const Spacer(),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 19), color: AppColors.navy),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          offer.title,
          style: const TextStyle(color: AppColors.navy, fontSize: 24, height: 1.08, fontWeight: FontWeight.w900, letterSpacing: -.4),
        ),
        const SizedBox(height: 8),
        Text(
          offer.description.replaceAll(RegExp(r'\s+'), ' ').trim(),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.slate, fontSize: 13.3, height: 1.48),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final skill in offer.skills.take(3)) OfferSkillTag(label: skill),
            if (offer.skills.length > 3) OfferSkillTag(label: '+${offer.skills.length - 3}'),
          ],
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 12,
          runSpacing: 9,
          children: [
            _Meta(icon: Icons.work_outline_rounded, label: offer.contractType.label),
            _Meta(icon: Icons.location_on_outlined, label: offer.location),
            _Meta(icon: Icons.laptop_mac_rounded, label: offer.remoteMode.label),
            _Meta(icon: Icons.calendar_today_outlined, label: dateLabel(offer.publishedAt ?? offer.updatedAt)),
          ],
        ),
        if (onCandidates != null) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onCandidates,
              icon: const Icon(Icons.group_outlined, size: 17),
              label: Text('${offer.candidateCount} candidats'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1475D1),
                side: const BorderSide(color: Color(0xFF88C3F9)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class _MobileTabs extends StatelessWidget {
  const _MobileTabs({required this.candidateCount, required this.onCandidates});
  final int candidateCount;
  final VoidCallback? onCandidates;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _Tab(label: 'Description', active: true, onTap: () {}),
        _Tab(label: 'Candidats ($candidateCount)', onTap: onCandidates),
        _Tab(label: 'Statistiques', onTap: () {}),
        _Tab(label: 'Paramètres', onTap: () {}),
      ],
    ),
  );
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.onTap, this.active = false});
  final String label;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 7),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? const Color(0xFF1687F8) : AppColors.lineSoft),
        ),
        child: Text(label, style: TextStyle(color: active ? const Color(0xFF1475D1) : AppColors.slate, fontSize: 11, fontWeight: FontWeight.w800)),
      ),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.title, this.icon});
  final Widget child;
  final String? title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE5ECF1)),
      boxShadow: const [BoxShadow(color: Color(0x0B153B5B), blurRadius: 16, offset: Offset(0, 6))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: const Color(0xFFF0F7FF), borderRadius: BorderRadius.circular(9)),
                  child: Icon(icon, size: 18, color: const Color(0xFF1475D1)),
                ),
                const SizedBox(width: 9),
              ],
              Expanded(child: Text(title!, style: const TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.w900))),
            ],
          ),
          const SizedBox(height: 13),
        ],
        child,
      ],
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Row(
      children: [
        Icon(icon, size: 17, color: AppColors.slate),
        const SizedBox(width: 8),
        SizedBox(width: 95, child: Text(label, style: const TextStyle(color: AppColors.slate, fontSize: 10.5, fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: AppColors.navy, fontSize: 10.8, fontWeight: FontWeight.w800))),
      ],
    ),
  );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: const Color(0xFF1475D1)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: AppColors.slateDark, fontSize: 10.5, fontWeight: FontWeight.w700)),
    ],
  );
}
