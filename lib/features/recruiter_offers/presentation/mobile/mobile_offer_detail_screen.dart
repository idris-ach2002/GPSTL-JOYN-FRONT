import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/job_offer.dart';
import '../../domain/recruiter_company.dart';
import '../controllers/offer_detail_controller.dart';
import '../shared/offer_ui.dart';

class MobileOfferDetailScreen extends StatelessWidget {
  const MobileOfferDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OfferDetailController>();
    if (controller.isLoading) {
      return const MobileAppSurface(
        child: Center(child: CircularProgressIndicator()),
      );
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
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 34,
                ),
                const SizedBox(height: 12),
                Text(
                  controller.errorMessage ?? 'Offre introuvable.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
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
      backgroundColor: const Color(0xFFF5F7F6),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _Header(offer: offer, company: company),
                Transform.translate(
                  offset: const Offset(0, -22),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Section(
                          title: 'Description',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              OfferRichText(
                                value: offer.description,
                                baseStyle: const TextStyle(
                                  color: AppColors.slateDark,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (final skill in offer.skills)
                                    OfferSkillTag(label: skill),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Section(
                          title: 'Informations clés',
                          child: Column(
                            children: [
                              _Info(
                                icon: Icons.work_outline_rounded,
                                label: 'Type de contrat',
                                value: offer.contractType.label,
                              ),
                              _Info(
                                icon: Icons.location_on_outlined,
                                label: 'Localisation',
                                value: offer.location,
                              ),
                              _Info(
                                icon: Icons.laptop_mac_rounded,
                                label: 'Mode de travail',
                                value: offer.remoteMode.label,
                              ),
                              _Info(
                                icon: Icons.trending_up_rounded,
                                label: 'Niveau d’expérience',
                                value: offer.experienceLevel.label,
                              ),
                              _Info(
                                icon: Icons.euro_rounded,
                                label: 'Rémunération',
                                value: salaryLabel(offer),
                              ),
                              _Info(
                                icon: Icons.flag_outlined,
                                label: 'Statut',
                                value: offer.status.label,
                              ),
                              _Info(
                                icon: Icons.publish_outlined,
                                label: 'Publication',
                                value: dateLabel(offer.publishedAt),
                              ),
                              _Info(
                                icon: Icons.update_rounded,
                                label: 'Dernière modification',
                                value: dateLabel(offer.updatedAt),
                              ),
                              if (offer.contractType.isWorkStudy) ...[
                                _Info(
                                  icon: Icons.school_outlined,
                                  label: 'Niveau d’études',
                                  value:
                                      offer.degreeLevelRequired?.replaceAll(
                                        'BAC_',
                                        'Bac+',
                                      ) ??
                                      '—',
                                ),
                                _Info(
                                  icon: Icons.sync_alt_rounded,
                                  label: 'Rythme',
                                  value: offer.rhythmType ?? '—',
                                ),
                                _Info(
                                  icon: Icons.calendar_month_outlined,
                                  label: 'Date de début',
                                  value: monthYearLabel(offer.startDate),
                                ),
                                _Info(
                                  icon: Icons.schedule_rounded,
                                  label: 'Durée',
                                  value: offer.durationMonths == null
                                      ? '—'
                                      : '${offer.durationMonths} mois',
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Section(
                          title: 'Candidatures',
                          child: Row(
                            children: [
                              if (offer.candidateCount > 0)
                                OfferCandidateAvatars(
                                  count: offer.candidateCount,
                                  size: 32,
                                  maxVisible: 4,
                                ),
                              if (offer.candidateCount > 0)
                                const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${offer.candidateCount} candidat${offer.candidateCount > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    color: AppColors.navy,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Section(
                          title: 'Entreprise',
                          child: Column(
                            children: [
                              _Info(
                                icon: Icons.apartment_outlined,
                                label: 'Nom',
                                value: company.name,
                              ),
                              _Info(
                                icon: Icons.category_outlined,
                                label: 'Activité',
                                value: company.activity,
                              ),
                              _Info(
                                icon: Icons.business_center_outlined,
                                label: 'Secteur',
                                value: company.sector,
                              ),
                              _Info(
                                icon: Icons.groups_2_outlined,
                                label: 'Taille',
                                value: company.sizeRange,
                              ),
                              _Info(
                                icon: Icons.location_city_outlined,
                                label: 'Ville',
                                value: company.city,
                              ),
                              if ((company.website ?? '').isNotEmpty)
                                _Info(
                                  icon: Icons.language_rounded,
                                  label: 'Site',
                                  value: company.website!,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE9ECE8))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.go(AppRoutes.recruiterJobEdit(offer.id)),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Modifier'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1976D2),
                        side: const BorderSide(color: Color(0xFFB8D7F3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                if (offer.status != JobOfferStatus.closed) ...[
                  const SizedBox(width: 9),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: controller.isClosing
                            ? null
                            : () => _showCloseSheet(context, controller),
                        icon: const Icon(Icons.pause_circle_outline_rounded),
                        label: const Text('Clôturer'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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

  Future<void> _showCloseSheet(
    BuildContext context,
    OfferDetailController controller,
  ) async {
    final reason = TextEditingController();
    final shouldClose = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
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
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.orangeTint,
                  child: Icon(
                    Icons.pause_circle_outline_rounded,
                    color: AppColors.orange,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Clôturer l’offre ?',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Elle ne sera plus proposée aux candidats.',
                  style: TextStyle(color: AppColors.slate, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FC),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: Color(0xFF1976D2),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Les candidatures et conversations existantes seront conservées.',
                          style: TextStyle(
                            color: AppColors.slateDark,
                            fontSize: 11,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Motif (facultatif)',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: reason,
                  maxLines: 4,
                  maxLength: 2000,
                  decoration: InputDecoration(
                    hintText: 'Ex. : poste pourvu, changement de besoin…',
                    filled: true,
                    fillColor: const Color(0xFFF5F7F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE4E8E3)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.navy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Clôturer l’offre'),
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
    if (shouldClose == true) {
      final ok = await controller.close(
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
}

class _Header extends StatelessWidget {
  const _Header({required this.offer, required this.company});
  final JobOffer offer;
  final RecruiterCompany company;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 46),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.navy,
          companyColor(company.id).withValues(alpha: .82),
        ],
      ),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.go(AppRoutes.recruiterJobs),
              icon: const Icon(Icons.arrow_back_rounded),
              color: Colors.white,
            ),
            const Spacer(),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'share', child: Text('Partager')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            CompanyAvatar(company: company, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    company.activity,
                    style: const TextStyle(
                      color: Color(0xFFD4E7F3),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          offer.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _DarkChip(
              label: offer.contractType.label,
              icon: Icons.work_outline_rounded,
            ),
            _DarkChip(label: offer.location, icon: Icons.location_on_outlined),
            _DarkChip(
              label: offer.remoteMode.label,
              icon: Icons.laptop_mac_rounded,
            ),
            OfferStatusBadge(status: offer.status),
          ],
        ),
      ],
    ),
  );
}

class _DarkChip extends StatelessWidget {
  const _DarkChip({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
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
        Icon(icon, size: 18, color: AppColors.slate),
        const SizedBox(width: 9),
        SizedBox(
          width: 108,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.slate,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}
