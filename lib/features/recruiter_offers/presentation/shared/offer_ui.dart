import 'package:flutter/material.dart';

import '../../../../design_system/components/joyn_pill.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../../../design_system/tokens/app_shadows.dart';
import '../../domain/job_offer.dart';
import '../../domain/recruiter_company.dart';

Color companyColor(int id) => switch (id % 4) {
  1 => AppColors.orange,
  2 => const Color(0xFF6956E8),
  3 => AppColors.navy,
  _ => const Color(0xFF43A66D),
};

class CompanyAvatar extends StatelessWidget {
  const CompanyAvatar({super.key, required this.company, this.size = 44});
  final RecruiterCompany company;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: companyColor(company.id),
      borderRadius: BorderRadius.circular(size * .28),
      boxShadow: AppShadows.card,
    ),
    child: Text(
      company.initial,
      style: TextStyle(
        color: Colors.white,
        fontFamily: AppFonts.display,
        fontSize: size * .42,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class OfferStatusBadge extends StatelessWidget {
  const OfferStatusBadge({super.key, required this.status});
  final JobOfferStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      JobOfferStatus.published => (
        AppColors.successTint,
        AppColors.successDeep,
      ),
      JobOfferStatus.draft => (AppColors.warningTint, AppColors.warningDeep),
      JobOfferStatus.closed => (const Color(0xFFE9EEF2), AppColors.slateDark),
      JobOfferStatus.archived => (AppColors.grey20, AppColors.slate),
    };
    return JoynPill(
      label: status.label,
      background: background,
      foreground: foreground,
      fontSize: 11,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    );
  }
}

class OfferMetaChip extends StatelessWidget {
  const OfferMetaChip({super.key, required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => JoynPill(
    label: label,
    icon: icon,
    background: const Color(0xFFEAF4FC),
    foreground: const Color(0xFF1565C0),
    fontSize: 11,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  );
}

String salaryLabel(JobOffer offer) {
  if (offer.salaryMin == null && offer.salaryMax == null)
    return 'Rémunération selon profil';
  String amount(double? value) {
    if (value == null) return '—';
    final rounded = value.round();
    final text = rounded.toString();
    final chunks = <String>[];
    for (var i = text.length; i > 0; i -= 3) {
      final start = (i - 3).clamp(0, i).toInt();
      chunks.insert(0, text.substring(start, i));
    }
    return chunks.join(' ');
  }

  final period = switch (offer.salaryPeriod) {
    SalaryPeriod.hour => 'heure',
    SalaryPeriod.month => 'mois',
    SalaryPeriod.year => 'an',
  };
  return '${amount(offer.salaryMin)} – ${amount(offer.salaryMax)} ${offer.currency == 'EUR' ? '€' : offer.currency} / $period';
}

String dateLabel(DateTime? date) {
  if (date == null) return '—';
  const months = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String monthYearLabel(DateTime? date) {
  if (date == null) return '—';
  const months = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

class OfferPreviewCard extends StatelessWidget {
  const OfferPreviewCard({
    super.key,
    required this.offer,
    required this.company,
    this.compact = false,
  });

  final JobOffer offer;
  final RecruiterCompany company;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 22 : 28),
        border: Border.all(color: AppColors.lineSoft),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OfferBanner(company: company, compact: compact),
          Padding(
            padding: EdgeInsets.all(compact ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CompanyAvatar(company: company, size: compact ? 42 : 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.title,
                            style: TextStyle(
                              color: AppColors.navy,
                              fontFamily: AppFonts.display,
                              fontSize: compact ? 18 : 22,
                              height: 1.08,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${company.name} · ${company.activity}',
                            style: const TextStyle(
                              color: AppColors.slate,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                if (offer.salaryMin != null || offer.salaryMax != null) ...[
                  const SizedBox(height: 10),
                  JoynPill(
                    label: salaryLabel(offer),
                    icon: Icons.euro_rounded,
                    background: AppColors.successTint,
                    foreground: AppColors.successDeep,
                    fontSize: 11,
                  ),
                ],
                if (!compact) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: offer.skills
                        .take(5)
                        .map(
                          (skill) => JoynPill(
                            label: skill,
                            background: const Color(0xFFEAF4FC),
                            foreground: const Color(0xFF1976D2),
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  Text('Description du poste', style: _sectionStyle),
                  const SizedBox(height: 8),
                  Text(
                    offer.description,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.slate,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  if (offer.contractType.isWorkStudy) ...[
                    const SizedBox(height: 16),
                    Text('Informations clés', style: _sectionStyle),
                    const SizedBox(height: 8),
                    _InfoLine(
                      icon: Icons.school_outlined,
                      label:
                          offer.degreeLevelRequired?.replaceAll('_', '+') ??
                          '—',
                    ),
                    _InfoLine(
                      icon: Icons.schedule_rounded,
                      label: '${offer.durationMonths ?? '—'} mois',
                    ),
                    _InfoLine(
                      icon: Icons.calendar_month_outlined,
                      label: monthYearLabel(offer.startDate),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _sectionStyle = TextStyle(
    color: AppColors.navy,
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );
}

class _OfferBanner extends StatelessWidget {
  const _OfferBanner({required this.company, required this.compact});
  final RecruiterCompany company;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    height: compact ? 110 : 140,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.navy,
          companyColor(company.id).withValues(alpha: .75),
        ],
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          right: -15,
          top: -20,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .08),
            ),
          ),
        ),
        Positioned(
          left: 18,
          bottom: 6,
          child: Row(
            children: [
              CompanyAvatar(company: company, size: compact ? 38 : 44),
              const SizedBox(width: 10),
              Text(
                company.name,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFonts.display,
                  fontSize: compact ? 20 : 24,
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

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      children: [
        Icon(icon, size: 17, color: AppColors.slate),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
