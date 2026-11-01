import 'package:flutter/material.dart';

import '../../../recruiter_offers/presentation/shared/recruiter_offer_header_art.dart';
import '../../domain/recruiter_dashboard_models.dart';

const _navy = Color(0xFF082846);
const _blue = Color(0xFF2676E8);
const _orange = Color(0xFFFF7043);
const _muted = Color(0xFF687D91);
const _surface = Color(0xFFFFFFFF);
const _border = Color(0xFFE3EAF0);

class RecruiterDashboardHeaderBackground extends StatelessWidget {
  const RecruiterDashboardHeaderBackground({super.key});

  @override
  Widget build(BuildContext context) => const RecruiterOfferHeaderArt();
}

class DashboardPeriodSelector extends StatelessWidget {
  const DashboardPeriodSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.onDark = false,
  });

  final DashboardPeriod value;
  final ValueChanged<DashboardPeriod> onChanged;
  final bool onDark;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final period in DashboardPeriod.values)
        _DashboardPeriodPill(
          label: period.label,
          selected: period == value,
          onTap: () => onChanged(period),
          onDark: onDark,
        ),
    ],
  );
}

class _DashboardPeriodPill extends StatelessWidget {
  const _DashboardPeriodPill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onDark,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? Colors.white
        : (onDark ? Colors.white.withValues(alpha: .08) : Colors.white);
    final foreground = selected ? _navy : (onDark ? Colors.white : _muted);
    final border = onDark
        ? Colors.white.withValues(alpha: selected ? .78 : .42)
        : _border;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minWidth: 74, minHeight: 34),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
            boxShadow: selected && onDark
                ? const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0B082846),
          blurRadius: 22,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Material(
      color: _surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: _border),
      ),
      child: Padding(padding: padding, child: child),
    ),
  );
}

class DashboardSectionTitle extends StatelessWidget {
  const DashboardSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _navy,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -.25,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
      ?trailing,
    ],
  );
}

class DashboardKpiCard extends StatelessWidget {
  const DashboardKpiCard({super.key, required this.kpi});

  final DashboardKpi kpi;

  @override
  Widget build(BuildContext context) {
    final positive = (kpi.deltaPercent ?? 0) >= 0;
    final accent = switch (kpi.id) {
      'matches' => _orange,
      'response' => const Color(0xFF457DB9),
      _ => _blue,
    };
    final icon = switch (kpi.id) {
      'matches' => Icons.adjust_rounded,
      'offers' => Icons.work_outline_rounded,
      'response' => Icons.schedule_rounded,
      'interviews' => Icons.calendar_month_outlined,
      'conversion' => Icons.query_stats_rounded,
      _ => Icons.groups_2_outlined,
    };

    return DashboardCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kpi.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  kpi.value,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.7,
                  ),
                ),
                if (kpi.deltaPercent != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    '${positive ? '↑' : '↓'} ${kpi.deltaPercent!.abs().toStringAsFixed(kpi.deltaPercent!.abs() % 1 == 0 ? 0 : 1)}%${kpi.deltaLabel == null ? '' : '  ${kpi.deltaLabel}'}',
                    maxLines: 2,
                    style: TextStyle(
                      color: positive
                          ? const Color(0xFF198754)
                          : const Color(0xFF1A7B67),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
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
}

Color dashboardSeriesColor(DashboardSeriesKind kind) => switch (kind) {
  DashboardSeriesKind.applications => const Color(0xFF123E72),
  DashboardSeriesKind.matches => const Color(0xFF4A91E8),
  DashboardSeriesKind.interviews => _orange,
  DashboardSeriesKind.previousApplications => const Color(0xFFB7C5D3),
};

const dashboardNavy = _navy;
const dashboardBlue = _blue;
const dashboardOrange = _orange;
const dashboardMuted = _muted;
const dashboardBorder = _border;

class DistributionDonut extends StatelessWidget {
  const DistributionDonut({
    super.key,
    required this.items,
    required this.centerLabel,
    this.size = 150,
  });

  final List<DashboardDistributionItem> items;
  final String centerLabel;
  final double size;

  static const _colors = [
    Color(0xFF153F70),
    Color(0xFF4A91E8),
    Color(0xFF94BDEB),
    Color(0xFFD8E2EB),
  ];

  Widget _donut(double diameter) => SizedBox(
    width: diameter,
    height: diameter,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(size: Size.square(diameter), painter: _DonutPainter(items)),
        Text(
          centerLabel,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _navy,
            fontSize: 15,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );

  Widget _legend() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < items.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _colors[i % _colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  items[i].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 10.5),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${items[i].value.round()}%',
                style: const TextStyle(
                  color: _navy,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 360;
      final diameter = compact ? size.clamp(112, 132).toDouble() : size;
      if (compact) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [_donut(diameter), const SizedBox(height: 14), _legend()],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _donut(diameter),
          const SizedBox(width: 18),
          Expanded(child: _legend()),
        ],
      );
    },
  );
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter(this.items);
  final List<DashboardDistributionItem> items;

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold<double>(0, (sum, item) => sum + item.value);
    if (total <= 0) return;
    final rect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    var start = -1.57079632679;
    for (var i = 0; i < items.length; i++) {
      final sweep = 6.28318530718 * items[i].value / total;
      canvas.drawArc(
        rect,
        start,
        sweep - .025,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.butt
          ..color =
              DistributionDonut._colors[i % DistributionDonut._colors.length],
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.items != items;
}

class OfferPerformanceList extends StatelessWidget {
  const OfferPerformanceList({
    super.key,
    required this.offers,
    required this.onOpen,
    this.compact = false,
  });

  final List<DashboardOfferPerformance> offers;
  final ValueChanged<int> onOpen;
  final bool compact;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < offers.length; i++) ...[
        InkWell(
          onTap: () => onOpen(offers[i].id),
          borderRadius: BorderRadius.circular(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final dense = compact || constraints.maxWidth < 500;
              final veryDense = constraints.maxWidth < 330;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _blue.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.work_outline_rounded,
                        color: _blue,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offers[i].title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${offers[i].location} · ${offers[i].contract}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!dense) ...[
                      _MiniMetric(
                        value: '${offers[i].applications}',
                        label: 'candid.',
                      ),
                      _MiniMetric(
                        value: '${offers[i].matches}',
                        label: 'matches',
                      ),
                      _MiniMetric(
                        value:
                            '${offers[i].conversionRate.toStringAsFixed(offers[i].conversionRate % 1 == 0 ? 0 : 1)}%',
                        label: 'conversion',
                      ),
                    ] else if (!veryDense)
                      _CompactOfferMetric(
                        value: '${offers[i].applications}',
                        label: 'candid.',
                      ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: _muted,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (i != offers.length - 1) const Divider(height: 1, color: _border),
      ],
    ],
  );
}

class _CompactOfferMetric extends StatelessWidget {
  const _CompactOfferMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: _navy,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(label, style: const TextStyle(color: _muted, fontSize: 8)),
    ],
  );
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 76,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: _navy,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(label, style: const TextStyle(color: _muted, fontSize: 8.5)),
      ],
    ),
  );
}

class RecruiterMobileHeaderBar extends StatelessWidget {
  const RecruiterMobileHeaderBar({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Color(0xFFFF6538),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          'J',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      const SizedBox(width: 8),
      const Text(
        'joyn',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -.8,
        ),
      ),
      const SizedBox(width: 7),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
      const Spacer(),
      _MobileHeaderIcon(icon: Icons.notifications_none_rounded),
      const SizedBox(width: 7),
      _MobileHeaderIcon(icon: Icons.settings_outlined),
      const SizedBox(width: 7),
      const CircleAvatar(
        radius: 17,
        backgroundColor: Colors.white,
        child: Text(
          'E',
          style: TextStyle(color: _navy, fontWeight: FontWeight.w900),
        ),
      ),
    ],
  );
}

class _MobileHeaderIcon extends StatelessWidget {
  const _MobileHeaderIcon({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: .52)),
    ),
    child: Icon(icon, color: Colors.white, size: 18),
  );
}
