import 'dart:math' as math;

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

class CompanyMiniLogo extends StatelessWidget {
  const CompanyMiniLogo({super.key, required this.company, this.size = 22});

  final RecruiterCompany company;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: companyColor(company.id),
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white.withValues(alpha: .92),
        width: 1.5,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14001E3B),
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Text(
      company.initial,
      style: TextStyle(
        color: Colors.white,
        fontFamily: AppFonts.display,
        fontSize: size * .42,
        height: 1,
        fontWeight: FontWeight.w900,
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
        AppColors.successTint.withValues(alpha: .82),
        AppColors.successDeep,
      ),
      JobOfferStatus.draft => (
        AppColors.warningTint.withValues(alpha: .86),
        AppColors.warningDeep,
      ),
      JobOfferStatus.closed => (const Color(0xFFE9EEF2), AppColors.slateDark),
      JobOfferStatus.archived => (AppColors.grey20, AppColors.slate),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class OfferMetaChip extends StatefulWidget {
  const OfferMetaChip({super.key, required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  State<OfferMetaChip> createState() => _OfferMetaChipState();
}

class _OfferMetaChipState extends State<OfferMetaChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 190),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: .96),
            const Color(0xFFEAF6FF).withValues(alpha: _hovered ? .96 : .82),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _hovered ? const Color(0xFF8CC9FF) : const Color(0xFFCFE7FA),
          width: _hovered ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CA8F8)
                .withValues(alpha: _hovered ? .18 : .07),
            blurRadius: _hovered ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1, end: _hovered ? 1.16 : 1),
            duration: const Duration(milliseconds: 190),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Icon(widget.icon, size: 17, color: const Color(0xFF1488F5)),
          ),
          const SizedBox(width: 7),
          Text(
            widget.label,
            style: const TextStyle(
              color: Color(0xFF1674CF),
              fontSize: 12.5,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}

class OfferSkillTag extends StatelessWidget {
  const OfferSkillTag({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .88),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFD7E8F5)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Color(0xFF1769C2),
        fontSize: 11.5,
        height: 1,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class OfferCardSurface extends StatelessWidget {
  const OfferCardSurface({
    super.key,
    required this.child,
    this.hovered = false,
    this.accentWidth = 380,
  });

  final Widget child;
  final bool hovered;

  /// Largeur de la zone décorative animée située à droite de la carte.
  final double accentWidth;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    curve: Curves.easeOutCubic,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Color(hovered ? 0x1A0A3152 : 0x100A3152),
          blurRadius: hovered ? 26 : 18,
          offset: Offset(0, hovered ? 9 : 6),
        ),
      ],
    ),
    clipBehavior: Clip.hardEdge,
    child: Stack(
      children: [
        // Couche 1 : blanc -> gris froid -> bleu très clair.
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFFCFDFE),
                    Color(0xFFF4F7FA),
                    Color(0xFFEEF6FC),
                    Color(0xFFEAF5FF),
                  ],
                  stops: [0, .28, .56, .78, 1],
                ),
              ),
            ),
          ),
        ),
        // Couche 2 : halo bleu supérieur droit.
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1.05, -1.0),
                  radius: 1.18,
                  colors: [
                    Color(0x55D7ECFF),
                    Color(0x22EAF5FF),
                    Color(0x00FFFFFF),
                  ],
                  stops: [0, .48, 1],
                ),
              ),
            ),
          ),
        ),
        // Couche 3 : halo gris-bleu inférieur droit pour donner de la profondeur.
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1.1, 1.25),
                  radius: 1.0,
                  colors: [
                    Color(0x3ADBE3EA),
                    Color(0x20EEF3F7),
                    Color(0x00FFFFFF),
                  ],
                  stops: [0, .52, 1],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          width: accentWidth,
          child: const IgnorePointer(child: OfferDropletAccent()),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF0F4F7), width: .8),
                  bottom: BorderSide(color: Color(0xFFE4EBF1), width: .8),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    ),
  );
}

class OfferDropletAccent extends StatefulWidget {
  const OfferDropletAccent({super.key});

  @override
  State<OfferDropletAccent> createState() => _OfferDropletAccentState();
}

class _OfferDropletAccentState extends State<OfferDropletAccent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _OfferDropletPainter(phase: _controller.value),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _OfferDropletPainter extends CustomPainter {
  const _OfferDropletPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rect = Offset.zero & size;
    final tau = math.pi * 2;

    // Mouvement presque imperceptible : le fond reste élégant et calme.
    final breathe = .5 + .5 * math.sin(tau * phase);
    final driftX = size.width * (.008 * math.sin(tau * phase));
    final driftY = size.height * (.015 * math.cos(tau * phase));

    // 1) Voile général blanc -> bleu glacé, uniquement pour donner de la
    // profondeur à la partie droite de la card sans salir la lisibilité.
    final wash = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0x00FFFFFF),
          Color(0x12F4F9FE),
          Color(0x2AEAF4FE),
          Color(0x48DCEBFA),
        ],
        stops: [0, .28, .58, 1],
      ).createShader(rect);
    canvas.drawRect(rect, wash);

    // 2) Halo principal : grand volume bleu très doux en bas à droite.
    final mainCenter = Offset(
      size.width * .82 + driftX,
      size.height * (.69 + .025 * breathe) + driftY,
    );
    final mainRadius = size.width * .46;
    final mainHalo = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0x46A8CCF6),
          Color(0x2DC5DDF7),
          Color(0x17E5F1FB),
          Color(0x00FFFFFF),
        ],
        stops: [0, .36, .68, 1],
      ).createShader(Rect.fromCircle(center: mainCenter, radius: mainRadius));
    canvas.drawCircle(mainCenter, mainRadius, mainHalo);

    // 3) Halo secondaire : un léger contre-volume dans l'angle haut droit.
    final secondaryCenter = Offset(
      size.width * .97 - driftX * .35,
      size.height * (.12 - .012 * breathe),
    );
    final secondaryRadius = size.width * .25;
    final secondaryHalo = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x32C8E0FA), Color(0x18E6F2FD), Color(0x00FFFFFF)],
            stops: [0, .52, 1],
          ).createShader(
            Rect.fromCircle(center: secondaryCenter, radius: secondaryRadius),
          );
    canvas.drawCircle(secondaryCenter, secondaryRadius, secondaryHalo);

    // 4) Deux voiles translucides superposés : c'est le détail "Option B"
    // qui donne un fond premium sans motif visible ou artificiel.
    final lowerVeil = Path()
      ..moveTo(size.width * .34, size.height)
      ..cubicTo(
        size.width * .54,
        size.height * .76 + driftY,
        size.width * .71,
        size.height * .92,
        size.width,
        size.height * .66,
      )
      ..lineTo(size.width, size.height)
      ..close();

    final lowerVeilPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x00B9D7F7), Color(0x18BCD8F5), Color(0x30A9CDF4)],
      ).createShader(rect);
    canvas.drawPath(lowerVeil, lowerVeilPaint);

    final upperVeil = Path()
      ..moveTo(size.width * .50, 0)
      ..cubicTo(
        size.width * .69,
        size.height * .18,
        size.width * .82,
        size.height * .08 + driftY,
        size.width,
        size.height * .25,
      )
      ..lineTo(size.width, 0)
      ..close();

    final upperVeilPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x00FFFFFF), Color(0x18EAF3FC), Color(0x22D7E8F9)],
      ).createShader(rect);
    canvas.drawPath(upperVeil, upperVeilPaint);

    // 5) Un seul arc bleu fin et discret. Aucun point, aucune bulle,
    // aucune ligne sombre et aucune couleur orange.
    final arc = Path()
      ..moveTo(size.width * .36, size.height * (.56 + .012 * breathe))
      ..cubicTo(
        size.width * .53,
        size.height * .34 + driftY,
        size.width * .72,
        size.height * .27 - driftY,
        size.width * .91,
        size.height * .39,
      )
      ..cubicTo(
        size.width * .96,
        size.height * .42,
        size.width * 1.01,
        size.height * .46,
        size.width * 1.05,
        size.height * .49,
      );

    // Aura très légère autour de l'arc.
    final arcGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.5
      ..color = const Color(0x165FA8FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(arc, arcGlow);

    final arcCore = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.25
      ..shader = const LinearGradient(
        colors: [
          Color(0x005FA8FF),
          Color(0x765FA8FF),
          Color(0x4A88BCF4),
          Color(0x005FA8FF),
        ],
        stops: [0, .28, .72, 1],
      ).createShader(rect);
    canvas.drawPath(arc, arcCore);
  }

  @override
  bool shouldRepaint(covariant _OfferDropletPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class OfferCandidateAvatars extends StatelessWidget {
  const OfferCandidateAvatars({
    super.key,
    required this.count,
    this.size = 28,
    this.maxVisible = 4,
  });

  final int count;
  final double size;
  final int maxVisible;

  static const _assets = [
    'assets/images/candidate_avatar_1.png',
    'assets/images/candidate_avatar_2.png',
    'assets/images/candidate_avatar_3.png',
    'assets/images/candidate_avatar_4.png',
    'assets/images/candidate_avatar_5.png',
    'assets/images/candidate_avatar_6.png',
  ];

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }
    final visible = math.min(math.min(count, maxVisible), _assets.length);
    final overlap = size * .34;
    final extra = count - visible;
    final totalWidth =
        size + (visible - 1) * (size - overlap) + (extra > 0 ? size * .98 : 0);

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visible; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14001E3B),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(_assets[i], fit: BoxFit.cover),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: visible * (size - overlap) + 2,
              child: Container(
                height: size,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2F8),
                  borderRadius: BorderRadius.circular(size / 2),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  '+$extra',
                  style: const TextStyle(
                    color: AppColors.slateDark,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum OfferKpiChartStyle { bars, line, softLine, area }

class OfferKpiMiniChart extends StatelessWidget {
  const OfferKpiMiniChart({
    super.key,
    required this.color,
    required this.style,
    this.width = 58,
    this.height = 34,
  });

  final Color color;
  final OfferKpiChartStyle style;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: CustomPaint(painter: _OfferKpiChartPainter(color, style)),
  );
}

class _OfferKpiChartPainter extends CustomPainter {
  const _OfferKpiChartPainter(this.color, this.style);

  final Color color;
  final OfferKpiChartStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    if (style == OfferKpiChartStyle.bars) {
      final heights = [.28, .42, .38, .62, .78, 1.0];
      final barWidth = size.width / 10;
      for (var i = 0; i < heights.length; i++) {
        final left = i * (barWidth * 1.55);
        final h = size.height * heights[i];
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(left, size.height - h, barWidth, h),
          const Radius.circular(2),
        );
        canvas.drawRRect(
          rect,
          Paint()..color = color.withValues(alpha: .18 + i * .11),
        );
      }
      return;
    }

    final points = <Offset>[
      Offset(0, size.height * .76),
      Offset(size.width * .18, size.height * .62),
      Offset(size.width * .35, size.height * .68),
      Offset(size.width * .52, size.height * .46),
      Offset(size.width * .70, size.height * .55),
      Offset(size.width * .86, size.height * .35),
      Offset(size.width, size.height * .18),
    ];
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }

    if (style == OfferKpiChartStyle.area) {
      final area = Path.from(line)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: .22),
              color.withValues(alpha: .02),
            ],
          ).createShader(Offset.zero & size),
      );
    }

    canvas.drawPath(
      line,
      Paint()
        ..color = color.withValues(
          alpha: style == OfferKpiChartStyle.softLine ? .42 : .82,
        )
        ..strokeWidth = style == OfferKpiChartStyle.softLine ? 1.5 : 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _OfferKpiChartPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.style != style;
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
                Expanded(
                  child: _InlineMarkup(text: line.substring(2), style: style),
                ),
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
                Expanded(
                  child: _InlineMarkup(text: body, style: style),
                ),
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
              border: Border(
                left: BorderSide(color: Color(0xFF6956E8), width: 3),
              ),
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

    return Text.rich(
      TextSpan(style: style, children: spans),
      textAlign: textAlign,
    );
  }
}
