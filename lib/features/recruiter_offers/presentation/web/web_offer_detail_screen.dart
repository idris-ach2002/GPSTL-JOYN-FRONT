import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/components/joyn_button.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../../../design_system/tokens/app_gradients.dart';
import '../../domain/job_offer.dart';
import '../../domain/recruiter_company.dart';
import '../controllers/offer_detail_controller.dart';
import '../shared/offer_ui.dart';
import 'recruiter_offers_top_bar.dart';

class WebOfferDetailScreen extends StatelessWidget {
  const WebOfferDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OfferDetailController>();
    final width = MediaQuery.sizeOf(context).width;

    if (controller.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final offer = controller.offer;
    final company = controller.company;
    if (offer == null || company == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 38, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                controller.errorMessage ?? 'Offre introuvable.',
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
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Container(
                  height: 260,
                  decoration: const BoxDecoration(gradient: AppGradients.hero),
                ),
                const Expanded(child: ColoredBox(color: AppColors.background)),
              ],
            ),
          ),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                width < 880 ? 18 : 28,
                16,
                width < 880 ? 18 : 28,
                44,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1220),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const RecruiterOffersTopBar(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => context.go(AppRoutes.recruiterJobs),
                              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                              label: const Text(
                                'Retour aux offres',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const Spacer(),
                            JoynButton(
                              label: 'Modifier l’offre',
                              leadingIcon: Icons.edit_outlined,
                              variant: JoynButtonVariant.outlineOnDark,
                              height: 44,
                              onPressed: () => context.go(
                                AppRoutes.recruiterJobEdit(offer.id),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _OfferHero(offer: offer, company: company),
                        const SizedBox(height: 14),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final singleColumn = constraints.maxWidth < 900;
                            if (singleColumn) {
                              return Column(
                                children: [
                                  _DescriptionPanel(offer: offer),
                                  const SizedBox(height: 14),
                                  _DetailsPanel(offer: offer, company: company),
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _DescriptionPanel(offer: offer),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  flex: 4,
                                  child: _DetailsPanel(
                                    offer: offer,
                                    company: company,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferHero extends StatelessWidget {
  const _OfferHero({required this.offer, required this.company});
  final JobOffer offer;
  final RecruiterCompany company;

  @override
  Widget build(BuildContext context) => OfferGlassSurface(
    waveWidth: 470,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontFamily: AppFonts.display,
                        fontSize: 28,
                        height: 1.08,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.5,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        CompanyMiniLogo(company: company, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          company.name,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Text('·', style: TextStyle(color: AppColors.placeholder)),
                        const SizedBox(width: 7),
                        Text(
                          offer.location,
                          style: const TextStyle(
                            color: AppColors.slate,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              OfferStatusBadge(status: offer.status),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OfferMetaChip(
                label: offer.contractType.label,
                icon: Icons.work_outline_rounded,
              ),
              OfferMetaChip(
                label: offer.remoteMode.label,
                icon: Icons.laptop_mac_rounded,
              ),
              OfferMetaChip(
                label: offer.experienceLevel.label,
                icon: Icons.trending_up_rounded,
              ),
            ],
          ),
          const SizedBox(height: 17),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _HeroMetric(
                icon: Icons.group_outlined,
                label: '${offer.candidateCount} candidat${offer.candidateCount > 1 ? 's' : ''}',
              ),
              _HeroMetric(
                icon: Icons.calendar_today_outlined,
                label: offer.publishedAt == null
                    ? 'Modifiée le ${dateLabel(offer.updatedAt)}'
                    : 'Publiée le ${dateLabel(offer.publishedAt)}',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _DescriptionPanel extends StatelessWidget {
  const _DescriptionPanel({required this.offer});
  final JobOffer offer;

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'Description complète',
    icon: Icons.description_outlined,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OfferRichText(
          value: offer.description,
          baseStyle: const TextStyle(
            color: AppColors.slateDark,
            fontSize: 13,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Compétences recherchées',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [for (final skill in offer.skills) OfferSkillTag(label: skill)],
        ),
      ],
    ),
  );
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.offer, required this.company});
  final JobOffer offer;
  final RecruiterCompany company;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Panel(
        title: 'Informations de l’offre',
        icon: Icons.info_outline_rounded,
        child: Column(
          children: [
            _DetailLine('Contrat', offer.contractType.label),
            _DetailLine('Localisation', offer.location),
            _DetailLine('Mode de travail', offer.remoteMode.label),
            _DetailLine('Expérience', offer.experienceLevel.label),
            _DetailLine('Rémunération', salaryLabel(offer)),
            _DetailLine('Statut', offer.status.label),
            _DetailLine('Publication', dateLabel(offer.publishedAt)),
            _DetailLine('Dernière modification', dateLabel(offer.updatedAt)),
          ],
        ),
      ),
      if (offer.contractType.isWorkStudy) ...[
        const SizedBox(height: 14),
        _Panel(
          title: 'Détails de l’alternance',
          icon: Icons.school_outlined,
          child: Column(
            children: [
              _DetailLine('Rythme', offer.rhythmType ?? '—'),
              _DetailLine('Date de début', monthYearLabel(offer.startDate)),
              _DetailLine(
                'Durée',
                offer.durationMonths == null ? '—' : '${offer.durationMonths} mois',
              ),
              _DetailLine(
                'Niveau d’études',
                offer.degreeLevelRequired?.replaceAll('BAC_', 'Bac+') ?? '—',
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 14),
      _Panel(
        title: 'Candidatures',
        icon: Icons.groups_2_outlined,
        child: Row(
          children: [
            if (offer.candidateCount > 0)
              OfferCandidateAvatars(
                count: offer.candidateCount,
                size: 34,
                maxVisible: 5,
              ),
            if (offer.candidateCount > 0) const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${offer.candidateCount} candidat${offer.candidateCount > 1 ? 's' : ''} sur cette offre',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      _Panel(
        title: 'Entreprise',
        icon: Icons.apartment_outlined,
        child: Column(
          children: [
            _DetailLine('Nom', company.name),
            _DetailLine('Activité', company.activity),
            _DetailLine('Secteur', company.sector),
            _DetailLine('Taille', company.sizeRange),
            _DetailLine('Ville', company.city),
            if ((company.website ?? '').isNotEmpty)
              _DetailLine('Site', company.website!),
          ],
        ),
      ),
    ],
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Color(0x0C001E3B),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF1976D2), size: 20),
            const SizedBox(width: 9),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        child,
      ],
    ),
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.slate,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
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

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: AppColors.slate),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(
          color: AppColors.slate,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
