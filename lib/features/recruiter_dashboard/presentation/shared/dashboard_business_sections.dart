import 'package:flutter/material.dart';

import '../../domain/recruiter_dashboard_models.dart';
import 'dashboard_components.dart';

class PaginatedOfferCards extends StatefulWidget {
  const PaginatedOfferCards({
    super.key,
    required this.offers,
    required this.onOpen,
    this.pageSize = 3,
    this.compact = false,
  });

  final List<DashboardOfferPerformance> offers;
  final ValueChanged<int> onOpen;
  final int pageSize;
  final bool compact;

  @override
  State<PaginatedOfferCards> createState() => _PaginatedOfferCardsState();
}

class _PaginatedOfferCardsState extends State<PaginatedOfferCards> {
  int _page = 0;

  @override
  void didUpdateWidget(covariant PaginatedOfferCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_page > _maxPage) _page = _maxPage;
  }

  int get _safePageSize => widget.pageSize.clamp(1, 8);
  int get _pageCount =>
      widget.offers.isEmpty ? 1 : (widget.offers.length / _safePageSize).ceil();
  int get _maxPage => _pageCount - 1;

  List<DashboardOfferPerformance> get _visible {
    final start = (_page * _safePageSize).clamp(0, widget.offers.length);
    final end = (start + _safePageSize).clamp(0, widget.offers.length);
    return widget.offers.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty) {
      return const _EmptyState(
        icon: Icons.work_off_outlined,
        title: 'Aucune offre active',
        subtitle:
            'Les offres publiées apparaîtront ici avec leurs indicateurs.',
      );
    }
    return Column(
      children: [
        for (var i = 0; i < _visible.length; i++) ...[
          _OfferCard(
            offer: _visible[i],
            compact: widget.compact,
            onOpen: () => widget.onOpen(_visible[i].id),
          ),
          if (i != _visible.length - 1) const SizedBox(height: 9),
        ],
        if (_pageCount > 1) ...[
          const SizedBox(height: 12),
          _PaginationFooter(
            page: _page,
            pageCount: _pageCount,
            onPrevious: _page == 0 ? null : () => setState(() => _page--),
            onNext: _page >= _maxPage ? null : () => setState(() => _page++),
          ),
        ],
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.compact,
    required this.onOpen,
  });

  final DashboardOfferPerformance offer;
  final bool compact;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final matchRate = offer.applications == 0
        ? 0.0
        : offer.matches / offer.applications * 100;
    final interviewRate = offer.matches == 0
        ? 0.0
        : offer.interviews / offer.matches * 100;
    final performance = _performanceFor(offer, matchRate);

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: dashboardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = compact || constraints.maxWidth < 720;
              if (narrow) {
                return _OfferCompactLayout(
                  offer: offer,
                  performance: performance,
                  matchRate: matchRate,
                  interviewRate: interviewRate,
                  onOpen: onOpen,
                );
              }
              return _OfferWideLayout(
                offer: offer,
                performance: performance,
                matchRate: matchRate,
                interviewRate: interviewRate,
                onOpen: onOpen,
              );
            },
          ),
        ),
      ),
    );
  }

  _OfferPerformanceBadge _performanceFor(
    DashboardOfferPerformance offer,
    double matchRate,
  ) {
    if (offer.applications >= 100 || matchRate >= 30) {
      return const _OfferPerformanceBadge(
        'Forte activité',
        Icons.local_fire_department_rounded,
        Color(0xFFFFF0E8),
        Color(0xFFDD5A16),
      );
    }
    if (offer.conversionRate >= 28) {
      return const _OfferPerformanceBadge(
        'Très demandée',
        Icons.star_rounded,
        Color(0xFFFFF7DC),
        Color(0xFF9B6A00),
      );
    }
    return const _OfferPerformanceBadge(
      'À suivre',
      Icons.trending_up_rounded,
      Color(0xFFEAF3FF),
      Color(0xFF2469B5),
    );
  }
}

class _OfferWideLayout extends StatelessWidget {
  const _OfferWideLayout({
    required this.offer,
    required this.performance,
    required this.matchRate,
    required this.interviewRate,
    required this.onOpen,
  });

  final DashboardOfferPerformance offer;
  final _OfferPerformanceBadge performance;
  final double matchRate;
  final double interviewRate;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      _OfferAvatar(title: offer.title),
      const SizedBox(width: 12),
      Expanded(
        flex: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 7,
              runSpacing: 5,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(
                    color: dashboardNavy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.15,
                  ),
                ),
                _StatusChip(label: offer.status),
                _PerformanceChip(value: performance),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${offer.location} · ${offer.contract}',
              style: const TextStyle(color: dashboardMuted, fontSize: 9.5),
            ),
            const SizedBox(height: 5),
            Text(
              '“${offer.tagline ?? 'Concentrez-vous sur les profils les plus pertinents.'}”',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF486277),
                fontSize: 9.5,
                height: 1.25,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 6,
        child: Row(
          children: [
            Expanded(
              child: _OfferMetric(
                value: '${offer.applications}',
                label: 'candidatures',
              ),
            ),
            Expanded(
              child: _OfferMetric(value: '${offer.matches}', label: 'matches'),
            ),
            Expanded(
              child: _OfferMetric(
                value: '${offer.interviews}',
                label: 'entretiens',
              ),
            ),
            Expanded(
              child: _OfferMetric(
                value: _percent(offer.conversionRate),
                label: 'conversion',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      SizedBox(
        width: 126,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RateBar(label: 'Match', value: matchRate),
            const SizedBox(height: 7),
            _RateBar(label: 'Entretien', value: interviewRate),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            offer.lastActivity ?? 'activité récente',
            style: const TextStyle(color: dashboardMuted, fontSize: 8.5),
          ),
          const SizedBox(height: 7),
          OutlinedButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.arrow_forward_rounded, size: 14),
            label: const Text('Voir l’offre'),
          ),
        ],
      ),
    ],
  );
}

class _OfferCompactLayout extends StatelessWidget {
  const _OfferCompactLayout({
    required this.offer,
    required this.performance,
    required this.matchRate,
    required this.interviewRate,
    required this.onOpen,
  });

  final DashboardOfferPerformance offer;
  final _OfferPerformanceBadge performance;
  final double matchRate;
  final double interviewRate;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OfferAvatar(title: offer.title, compact: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(
                    color: dashboardNavy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${offer.location} · ${offer.contract}',
                  style: const TextStyle(color: dashboardMuted, fontSize: 9.5),
                ),
              ],
            ),
          ),
          _StatusChip(label: offer.status),
        ],
      ),
      const SizedBox(height: 9),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _PerformanceChip(value: performance),
          _MiniInfoChip(
            icon: Icons.visibility_outlined,
            label: '${offer.views} vues',
          ),
          if (offer.lastActivity != null)
            _MiniInfoChip(
              icon: Icons.schedule_rounded,
              label: offer.lastActivity!,
            ),
        ],
      ),
      const SizedBox(height: 10),
      Text(
        '“${offer.tagline ?? 'Concentrez-vous sur les profils les plus pertinents.'}”',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF486277),
          fontSize: 9.5,
          height: 1.3,
          fontStyle: FontStyle.italic,
        ),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 18,
        runSpacing: 8,
        children: [
          _OfferMetric(value: '${offer.applications}', label: 'candidatures'),
          _OfferMetric(value: '${offer.matches}', label: 'matches'),
          _OfferMetric(value: '${offer.interviews}', label: 'entretiens'),
          _OfferMetric(
            value: _percent(offer.conversionRate),
            label: 'conversion',
          ),
        ],
      ),
      const SizedBox(height: 10),
      _RateBar(label: 'Taux de match', value: matchRate),
      const SizedBox(height: 7),
      _RateBar(label: 'Passage en entretien', value: interviewRate),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton.icon(
          onPressed: onOpen,
          icon: const Icon(Icons.arrow_forward_rounded, size: 14),
          label: const Text('Voir l’offre'),
        ),
      ),
    ],
  );
}

class _OfferAvatar extends StatelessWidget {
  const _OfferAvatar({required this.title, this.compact = false});
  final String title;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final initial = title.trim().isEmpty ? 'J' : title.trim().substring(0, 1);
    return Container(
      width: compact ? 38 : 42,
      height: compact ? 38 : 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A4F9E), Color(0xFF2676E8)],
        ),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        initial.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 15 : 17,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _OfferMetric extends StatelessWidget {
  const _OfferMetric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: dashboardNavy,
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(label, style: const TextStyle(color: dashboardMuted, fontSize: 8.5)),
    ],
  );
}

class _RateBar extends StatelessWidget {
  const _RateBar({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final safe = value.clamp(0, 100).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: dashboardMuted, fontSize: 8),
              ),
            ),
            Text(
              '${safe.round()}%',
              style: const TextStyle(
                color: dashboardNavy,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 4,
            value: safe / 100,
            backgroundColor: const Color(0xFFEAF0F5),
            valueColor: const AlwaysStoppedAnimation<Color>(dashboardBlue),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF7EF),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Color(0xFF198754),
        fontSize: 8,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _OfferPerformanceBadge {
  const _OfferPerformanceBadge(
    this.label,
    this.icon,
    this.background,
    this.foreground,
  );

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
}

class _PerformanceChip extends StatelessWidget {
  const _PerformanceChip({required this.value});
  final _OfferPerformanceBadge value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: value.background,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(value.icon, size: 11, color: value.foreground),
        const SizedBox(width: 4),
        Text(
          value.label,
          style: TextStyle(
            color: value.foreground,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _MiniInfoChip extends StatelessWidget {
  const _MiniInfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F7FA),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: dashboardMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: dashboardMuted,
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class PaginatedActivityFeed extends StatefulWidget {
  const PaginatedActivityFeed({
    super.key,
    required this.activities,
    this.pageSize = 5,
    this.onAction,
  });

  final List<DashboardActivity> activities;
  final int pageSize;
  final ValueChanged<DashboardActivity>? onAction;

  @override
  State<PaginatedActivityFeed> createState() => _PaginatedActivityFeedState();
}

class _PaginatedActivityFeedState extends State<PaginatedActivityFeed> {
  int _page = 0;

  @override
  void didUpdateWidget(covariant PaginatedActivityFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    final maxPage = _pageCount - 1;
    if (_page > maxPage) _page = maxPage;
  }

  int get _safePageSize => widget.pageSize.clamp(1, 8);
  int get _pageCount => widget.activities.isEmpty
      ? 1
      : (widget.activities.length / _safePageSize).ceil();

  @override
  Widget build(BuildContext context) {
    if (widget.activities.isEmpty) {
      return const _EmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'Aucune activité récente',
        subtitle: 'Les nouveaux événements de recrutement apparaîtront ici.',
      );
    }
    final maxPage = _pageCount - 1;
    final start = (_page * _safePageSize).clamp(0, widget.activities.length);
    final end = (start + _safePageSize).clamp(0, widget.activities.length);
    final visible = widget.activities.sublist(start, end);
    return Column(
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          _ActivityItem(
            activity: visible[i],
            onAction: widget.onAction == null
                ? null
                : () => widget.onAction!(visible[i]),
          ),
          if (i != visible.length - 1) const SizedBox(height: 8),
        ],
        if (_pageCount > 1) ...[
          const SizedBox(height: 12),
          _PaginationFooter(
            page: _page,
            pageCount: _pageCount,
            onPrevious: _page == 0 ? null : () => setState(() => _page--),
            onNext: _page >= maxPage ? null : () => setState(() => _page++),
          ),
        ],
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.activity, this.onAction});
  final DashboardActivity activity;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final style = _activityStyle(activity.kind);
    return Material(
      color: style.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
        side: const BorderSide(color: dashboardBorder),
      ),
      child: InkWell(
        onTap: onAction,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: style.iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(style.icon, color: style.foreground, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: dashboardNavy,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _ActivityBadge(style: style),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      activity.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: dashboardMuted,
                        fontSize: 9.2,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    activity.whenLabel,
                    style: const TextStyle(
                      color: dashboardMuted,
                      fontSize: 8.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (onAction != null)
                    Text(
                      '${style.action} →',
                      style: const TextStyle(
                        color: dashboardBlue,
                        fontSize: 8.7,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityStyle {
  const _ActivityStyle({
    required this.icon,
    required this.label,
    required this.action,
    required this.foreground,
    required this.iconBackground,
    required this.badgeBackground,
    required this.background,
  });

  final IconData icon;
  final String label;
  final String action;
  final Color foreground;
  final Color iconBackground;
  final Color badgeBackground;
  final Color background;
}

_ActivityStyle _activityStyle(ActivityKind kind) => switch (kind) {
  ActivityKind.application => const _ActivityStyle(
    icon: Icons.person_add_alt_1_outlined,
    label: 'Nouveau',
    action: 'Voir le profil',
    foreground: Color(0xFF2469B5),
    iconBackground: Color(0xFFE8F2FF),
    badgeBackground: Color(0xFFEAF4FF),
    background: Color(0xFFFBFDFF),
  ),
  ActivityKind.match => const _ActivityStyle(
    icon: Icons.adjust_rounded,
    label: 'Match qualifié',
    action: 'Examiner',
    foreground: Color(0xFF0B6E64),
    iconBackground: Color(0xFFE5F7F3),
    badgeBackground: Color(0xFFE8F8F4),
    background: Color(0xFFFBFEFD),
  ),
  ActivityKind.interview => const _ActivityStyle(
    icon: Icons.calendar_month_outlined,
    label: 'Entretien',
    action: 'Voir le détail',
    foreground: Color(0xFF6B4CC2),
    iconBackground: Color(0xFFF0EBFF),
    badgeBackground: Color(0xFFF2EEFF),
    background: Color(0xFFFDFCFF),
  ),
  ActivityKind.offer => const _ActivityStyle(
    icon: Icons.work_outline_rounded,
    label: 'Offre',
    action: 'Voir l’offre',
    foreground: Color(0xFF198754),
    iconBackground: Color(0xFFE7F7ED),
    badgeBackground: Color(0xFFEAF8EF),
    background: Color(0xFFFCFEFC),
  ),
  ActivityKind.system => const _ActivityStyle(
    icon: Icons.auto_awesome_outlined,
    label: 'Analyse',
    action: 'Ouvrir',
    foreground: Color(0xFFB35C00),
    iconBackground: Color(0xFFFFF0DF),
    badgeBackground: Color(0xFFFFF3E5),
    background: Color(0xFFFFFDFC),
  ),
};

class _ActivityBadge extends StatelessWidget {
  const _ActivityBadge({required this.style});
  final _ActivityStyle style;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: style.badgeBackground,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      style.label,
      style: TextStyle(
        color: style.foreground,
        fontSize: 7.5,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.page,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        tooltip: 'Page précédente',
        onPressed: onPrevious,
        icon: const Icon(Icons.chevron_left_rounded),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          'Page ${page + 1} / $pageCount',
          style: const TextStyle(
            color: dashboardMuted,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      IconButton(
        tooltip: 'Page suivante',
        onPressed: onNext,
        icon: const Icon(Icons.chevron_right_rounded),
      ),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      children: [
        Icon(icon, size: 28, color: dashboardMuted),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: dashboardNavy,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: dashboardMuted, fontSize: 9.5),
        ),
      ],
    ),
  );
}

String _percent(double value) =>
    '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}%';
