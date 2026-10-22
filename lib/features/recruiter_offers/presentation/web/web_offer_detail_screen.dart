import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../domain/job_offer.dart';
import '../../domain/recruiter_company.dart';
import '../controllers/offer_detail_controller.dart';
import '../shared/offer_candidates_panel.dart';
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
              const Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: AppColors.error,
              ),
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
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 84,
            child: ColoredBox(color: AppColors.navy),
          ),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                width < 900 ? 18 : 28,
                14,
                width < 900 ? 18 : 28,
                46,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1260),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const RecruiterOffersTopBar(),
                        const SizedBox(height: 20),
                        _Breadcrumb(offer: offer),
                        const SizedBox(height: 12),
                        _OfferSummaryCard(
                          offer: offer,
                          company: company,
                          onCandidates: offer.candidateCount <= 0
                              ? null
                              : () => showOfferCandidatesPanel(
                                  context,
                                  offer: offer,
                                ),
                          onEdit: () =>
                              context.go(AppRoutes.recruiterJobEdit(offer.id)),
                          onClose: offer.status == JobOfferStatus.closed
                              ? null
                              : () => _confirmClose(context, controller),
                        ),
                        const SizedBox(height: 14),
                        _DetailTabs(
                          candidateCount: offer.candidateCount,
                          onCandidates: offer.candidateCount <= 0
                              ? null
                              : () => showOfferCandidatesPanel(
                                  context,
                                  offer: offer,
                                ),
                        ),
                        const SizedBox(height: 14),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final singleColumn = constraints.maxWidth < 920;
                            if (singleColumn) {
                              return Column(
                                children: [
                                  _OfferContentCards(offer: offer),
                                  const SizedBox(height: 14),
                                  _OfferSideCards(
                                    offer: offer,
                                    company: company,
                                    onCandidates: offer.candidateCount <= 0
                                        ? null
                                        : () => showOfferCandidatesPanel(
                                            context,
                                            offer: offer,
                                          ),
                                  ),
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _OfferContentCards(offer: offer),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  flex: 4,
                                  child: _OfferSideCards(
                                    offer: offer,
                                    company: company,
                                    onCandidates: offer.candidateCount <= 0
                                        ? null
                                        : () => showOfferCandidatesPanel(
                                            context,
                                            offer: offer,
                                          ),
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

  Future<void> _confirmClose(
    BuildContext context,
    OfferDetailController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clôturer l’offre ?'),
        content: const Text(
          'Elle ne sera plus proposée aux candidats. Les candidatures existantes seront conservées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.orange),
            child: const Text('Clôturer'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.close();
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.offer});
  final JobOffer offer;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      TextButton.icon(
        onPressed: () => context.go(AppRoutes.recruiterJobs),
        icon: const Icon(Icons.chevron_left_rounded, size: 18),
        label: const Text('Offres'),
        style: TextButton.styleFrom(foregroundColor: AppColors.slateDark),
      ),
      const Icon(
        Icons.chevron_right_rounded,
        size: 16,
        color: AppColors.placeholder,
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          offer.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ],
  );
}

class _OfferSummaryCard extends StatelessWidget {
  const _OfferSummaryCard({
    required this.offer,
    required this.company,
    required this.onCandidates,
    required this.onEdit,
    required this.onClose,
  });
  final JobOffer offer;
  final RecruiterCompany company;
  final VoidCallback? onCandidates;
  final VoidCallback onEdit;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => _InteractiveCard(
    padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OfferStatusBadge(status: offer.status),
                      CompanyMiniLogo(company: company, size: 24),
                      Text(
                        company.name,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        '·',
                        style: TextStyle(color: AppColors.placeholder),
                      ),
                      Text(
                        offer.location,
                        style: const TextStyle(
                          color: AppColors.slate,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        '·',
                        style: TextStyle(color: AppColors.placeholder),
                      ),
                      Text(
                        offer.remoteMode.label,
                        style: const TextStyle(
                          color: AppColors.slate,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    offer.title,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontFamily: AppFonts.display,
                      fontSize: 28,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offer.description.replaceAll(RegExp(r'\s+'), ' ').trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.slate,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text('Modifier'),
                  style: _buttonStyle(),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'close') onClose?.call();
                  },
                  itemBuilder: (context) => [
                    if (onClose != null)
                      const PopupMenuItem(
                        value: 'close',
                        child: Text('Clôturer l’offre'),
                      ),
                  ],
                  child: Container(
                    width: 42,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.lineSoft),
                    ),
                    child: const Icon(
                      Icons.more_horiz_rounded,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 20,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Meta(
              icon: Icons.work_outline_rounded,
              label: offer.contractType.label,
            ),
            _Meta(icon: Icons.location_on_outlined, label: offer.location),
            _Meta(
              icon: Icons.laptop_mac_rounded,
              label: offer.remoteMode.label,
            ),
            _Meta(
              icon: Icons.calendar_today_outlined,
              label: offer.publishedAt == null
                  ? 'Modifiée le ${dateLabel(offer.updatedAt)}'
                  : 'Publiée le ${dateLabel(offer.publishedAt)}',
            ),
            _CandidatesButton(offer: offer, onPressed: onCandidates),
          ],
        ),
        if (offer.skills.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final skill in offer.skills) OfferSkillTag(label: skill),
            ],
          ),
        ],
      ],
    ),
  );

  ButtonStyle _buttonStyle() => OutlinedButton.styleFrom(
    foregroundColor: AppColors.navy,
    side: const BorderSide(color: AppColors.lineSoft),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

class _CandidatesButton extends StatelessWidget {
  const _CandidatesButton({required this.offer, required this.onPressed});
  final JobOffer offer;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(10),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: onPressed == null
            ? const Color(0xFFF5F7F9)
            : const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: onPressed == null
              ? AppColors.lineSoft
              : const Color(0xFF88C3F9),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.group_outlined, size: 18, color: Color(0xFF1475D1)),
          const SizedBox(width: 7),
          Text(
            '${offer.candidateCount} candidat${offer.candidateCount > 1 ? 's' : ''}',
            style: const TextStyle(
              color: Color(0xFF1475D1),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DetailTabs extends StatelessWidget {
  const _DetailTabs({required this.candidateCount, required this.onCandidates});
  final int candidateCount;
  final VoidCallback? onCandidates;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.lineSoft)),
    ),
    child: Row(
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
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 11),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: active ? const Color(0xFF1687F8) : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFF1475D1) : AppColors.slate,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _OfferContentCards extends StatelessWidget {
  const _OfferContentCards({required this.offer});
  final JobOffer offer;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _InteractiveCard(
        title: 'À propos de l’offre',
        icon: Icons.description_outlined,
        child: OfferRichText(
          value: offer.description,
          baseStyle: const TextStyle(
            color: AppColors.slateDark,
            fontSize: 14,
            height: 1.65,
          ),
        ),
      ),
      const SizedBox(height: 14),
      _InteractiveCard(
        title: 'Compétences recherchées',
        icon: Icons.auto_awesome_outlined,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final skill in offer.skills) OfferSkillTag(label: skill),
          ],
        ),
      ),
      const SizedBox(height: 14),
      _InteractiveCard(
        title: 'Cadre du poste',
        icon: Icons.work_outline_rounded,
        child: LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FactCard(
                label: 'Contrat',
                value: offer.contractType.label,
                icon: Icons.badge_outlined,
              ),
              _FactCard(
                label: 'Localisation',
                value: offer.location,
                icon: Icons.location_on_outlined,
              ),
              _FactCard(
                label: 'Mode de travail',
                value: offer.remoteMode.label,
                icon: Icons.laptop_mac_rounded,
              ),
              _FactCard(
                label: 'Expérience',
                value: offer.experienceLevel.label,
                icon: Icons.trending_up_rounded,
              ),
              _FactCard(
                label: 'Rémunération',
                value: salaryLabel(offer),
                icon: Icons.payments_outlined,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _OfferSideCards extends StatelessWidget {
  const _OfferSideCards({
    required this.offer,
    required this.company,
    required this.onCandidates,
  });
  final JobOffer offer;
  final RecruiterCompany company;
  final VoidCallback? onCandidates;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _InteractiveCard(
        title: 'Informations',
        icon: Icons.info_outline_rounded,
        child: Column(
          children: [
            _DetailLine('Statut', offer.status.label),
            _DetailLine('Publication', dateLabel(offer.publishedAt)),
            _DetailLine('Dernière modification', dateLabel(offer.updatedAt)),
            _DetailLine('Nombre de candidats', '${offer.candidateCount}'),
          ],
        ),
      ),
      if (offer.contractType.isWorkStudy) ...[
        const SizedBox(height: 14),
        _InteractiveCard(
          title: 'Alternance',
          icon: Icons.school_outlined,
          child: Column(
            children: [
              _DetailLine('Rythme', offer.rhythmType ?? '—'),
              _DetailLine('Date de début', monthYearLabel(offer.startDate)),
              _DetailLine(
                'Durée',
                offer.durationMonths == null
                    ? '—'
                    : '${offer.durationMonths} mois',
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
      _InteractiveCard(
        title: 'Candidatures',
        icon: Icons.groups_2_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (offer.candidateCount > 0) ...[
                  OfferCandidateAvatars(
                    count: offer.candidateCount,
                    size: 34,
                    maxVisible: 5,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    '${offer.candidateCount} candidat${offer.candidateCount > 1 ? 's' : ''} sur cette offre',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (onCandidates != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onCandidates,
                icon: const Icon(Icons.people_alt_outlined, size: 17),
                label: const Text('Voir les candidats'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1475D1),
                  side: const BorderSide(color: Color(0xFFB9DDFB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 14),
      _InteractiveCard(
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

class _InteractiveCard extends StatefulWidget {
  const _InteractiveCard({
    required this.child,
    this.title,
    this.icon,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final String? title;
  final IconData? icon;
  final EdgeInsets padding;

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() => hovered = false),
    child: AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      scale: hovered ? 1.003 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hovered ? const Color(0xFFD7E8F6) : const Color(0xFFE5ECF1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF153B5B)
                  .withValues(alpha: hovered ? .085 : .04),
              blurRadius: hovered ? 26 : 16,
              offset: Offset(0, hovered ? 10 : 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.title != null) ...[
              Row(
                children: [
                  if (widget.icon != null) ...[
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.icon,
                        color: const Color(0xFF1475D1),
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      widget.title!,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            widget.child,
          ],
        ),
      ),
    ),
  );
}

class _FactCard extends StatelessWidget {
  const _FactCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 190,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE7EDF2)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1475D1)),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.placeholder,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
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
    padding: const EdgeInsets.only(bottom: 11),
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

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 17, color: AppColors.slate),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(
          color: AppColors.slate,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
