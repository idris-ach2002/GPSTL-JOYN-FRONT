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
  if (offer.salaryMin == null && offer.salaryMax == null) {
    return 'Rémunération selon profil';
  }
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color.alphaBlend(
              companyColor(company.id).withValues(alpha: .035),
              Colors.white,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(compact ? 22 : 28),
        border: Border.all(color: AppColors.lineSoft),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    const SizedBox(width: 8),
                    OfferStatusBadge(status: offer.status),
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
                const SizedBox(height: 14),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: offer.skills
                      .take(compact ? 3 : 5)
                      .map(
                        (skill) => JoynPill(
                          label: skill,
                          background: const Color(0xFFEAF4FC),
                          foreground: const Color(0xFF1976D2),
                          fontSize: compact ? 9 : 10,
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
                OfferRichText(
                  value: offer.description,
                  baseStyle: TextStyle(
                    color: AppColors.slate,
                    fontSize: compact ? 11 : 12,
                    height: 1.5,
                  ),
                ),
                if (offer.contractType.isWorkStudy && !compact) ...[
                  const SizedBox(height: 16),
                  Text('Informations clés', style: _sectionStyle),
                  const SizedBox(height: 8),
                  _InfoLine(
                    icon: Icons.school_outlined,
                    label:
                        offer.degreeLevelRequired?.replaceAll('_', '+') ?? '—',
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

enum OfferMenuAction { edit, close, delete }

class OfferOptionsButton extends StatefulWidget {
  const OfferOptionsButton({
    super.key,
    required this.status,
    required this.onEdit,
    required this.onDelete,
    this.onClose,
    this.dark = false,
    this.compact = false,
  });

  final JobOfferStatus status;
  final VoidCallback onEdit;
  final VoidCallback? onClose;
  final VoidCallback onDelete;
  final bool dark;
  final bool compact;

  @override
  State<OfferOptionsButton> createState() => _OfferOptionsButtonState();
}

class _OfferOptionsButtonState extends State<OfferOptionsButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final foreground = widget.dark ? Colors.white : const Color(0xFF1769C2);
    final background = widget.dark
        ? Colors.white.withValues(alpha: .12)
        : const Color(0xFFF4F9FD);
    final border = widget.dark
        ? Colors.white.withValues(alpha: .24)
        : const Color(0xFFCFE5F8);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: PopupMenuButton<OfferMenuAction>(
        tooltip: 'Options de l’offre',
        offset: Offset(0, widget.compact ? 42 : 48),
        elevation: 18,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onSelected: (action) {
          switch (action) {
            case OfferMenuAction.edit:
              widget.onEdit();
              break;
            case OfferMenuAction.close:
              widget.onClose?.call();
              break;
            case OfferMenuAction.delete:
              widget.onDelete();
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: OfferMenuAction.edit,
            child: _OfferMenuEntry(
              icon: Icons.edit_outlined,
              title: 'Modifier',
              subtitle: 'Mettre à jour l’offre',
            ),
          ),
          if (widget.status != JobOfferStatus.closed && widget.onClose != null)
            const PopupMenuItem(
              value: OfferMenuAction.close,
              child: _OfferMenuEntry(
                icon: Icons.pause_circle_outline_rounded,
                title: 'Clôturer',
                subtitle: 'Retirer l’offre des recommandations',
              ),
            ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: OfferMenuAction.delete,
            child: _OfferMenuEntry(
              icon: Icons.delete_outline_rounded,
              title: 'Supprimer',
              subtitle: 'Supprimer définitivement cette offre',
              destructive: true,
            ),
          ),
        ],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOutCubic,
          width: widget.compact ? 36 : 42,
          height: widget.compact ? 36 : 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered ? foreground : background,
            borderRadius: BorderRadius.circular(widget.compact ? 12 : 14),
            border: Border.all(color: _hovered ? foreground : border),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: foreground.withValues(alpha: .18),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            tween: Tween(begin: 0, end: _hovered ? .16 : 0),
            builder: (context, turns, child) => Transform.rotate(
              angle: turns * 6.283185307179586,
              child: child,
            ),
            child: Icon(
              Icons.settings_outlined,
              size: widget.compact ? 19 : 21,
              color: _hovered ? background : foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferMenuEntry extends StatelessWidget {
  const _OfferMenuEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.navy;
    return SizedBox(
      width: 225,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: destructive
                  ? AppColors.error.withValues(alpha: .08)
                  : const Color(0xFFEAF4FC),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.slate,
                    fontSize: 9.5,
                    height: 1.25,
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

class OfferRichText extends StatelessWidget {
  const OfferRichText({
    super.key,
    required this.value,
    this.baseStyle = const TextStyle(
      color: AppColors.slateDark,
      fontSize: 12,
      height: 1.5,
    ),
  });

  final String value;
  final TextStyle baseStyle;

  @override
  Widget build(BuildContext context) {
    final lines = value.replaceAll('\r\n', '\n').split('\n');
    final children = <Widget>[];
    var orderedIndex = 1;

    for (final rawLine in lines) {
      var line = rawLine;
      var alignment = TextAlign.left;
      if (line.startsWith('[center]')) {
        alignment = TextAlign.center;
        line = line.substring(8);
      } else if (line.startsWith('[right]')) {
        alignment = TextAlign.right;
        line = line.substring(7);
      }

      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 8));
        orderedIndex = 1;
        continue;
      }

      var style = baseStyle;
      if (line.startsWith('## ')) {
        style = baseStyle.copyWith(
          color: AppColors.navy,
          fontSize: (baseStyle.fontSize ?? 12) + 3,
          fontWeight: FontWeight.w900,
          height: 1.3,
        );
        line = line.substring(3);
      } else if (line.startsWith('# ')) {
        style = baseStyle.copyWith(
          color: AppColors.navy,
          fontSize: (baseStyle.fontSize ?? 12) + 6,
          fontWeight: FontWeight.w900,
          height: 1.25,
        );
        line = line.substring(2);
      }

      if (line.startsWith('- ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(top: 7, right: 9),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1976D2),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(child: _InlineMarkup(text: line.substring(2), style: style)),
              ],
            ),
          ),
        );
        orderedIndex = 1;
        continue;
      }

      final ordered = RegExp(r'^\d+\.\s').firstMatch(line);
      if (ordered != null) {
        final body = line.substring(ordered.end);
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '$orderedIndex.',
                    style: style.copyWith(
                      color: const Color(0xFF1976D2),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(child: _InlineMarkup(text: body, style: style)),
              ],
            ),
          ),
        );
        orderedIndex += 1;
        continue;
      }
      orderedIndex = 1;

      if (line.startsWith('> ')) {
        children.add(
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F1FF),
              border: Border(left: BorderSide(color: Color(0xFF6956E8), width: 3)),
            ),
            child: _InlineMarkup(
              text: line.substring(2),
              style: style.copyWith(color: AppColors.navy),
              textAlign: alignment,
            ),
          ),
        );
        continue;
      }

      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: _InlineMarkup(text: line, style: style, textAlign: alignment),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _InlineMarkup extends StatelessWidget {
  const _InlineMarkup({
    required this.text,
    required this.style,
    this.textAlign = TextAlign.left,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final pattern = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*|\[[^\]]+\]\([^)]+\))');
    final spans = <InlineSpan>[];
    var index = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > index) {
        spans.add(TextSpan(text: text.substring(index, match.start)));
      }
      final token = match.group(0)!;
      if (token.startsWith('**')) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        );
      } else if (token.startsWith('*')) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      } else {
        final labelEnd = token.indexOf('](');
        spans.add(
          TextSpan(
            text: token.substring(1, labelEnd),
            style: const TextStyle(
              color: Color(0xFF1976D2),
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }
      index = match.end;
    }
    if (index < text.length) spans.add(TextSpan(text: text.substring(index)));

    return Text.rich(TextSpan(style: style, children: spans), textAlign: textAlign);
  }
}
