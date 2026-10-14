import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../widgets/landing_motion.dart';
import '../widgets/section_header.dart';

class OpportunitiesSection extends StatefulWidget {
  const OpportunitiesSection({super.key});

  @override
  State<OpportunitiesSection> createState() => _OpportunitiesSectionState();
}

class _OpportunitiesSectionState extends State<OpportunitiesSection> {
  PageController? _controller;
  Timer? _timer;
  int _page = 0;
  bool _hovered = false;
  double _viewportFraction = .86;

  static const _jobs = [
    _JobData(
      'Nébula Pay',
      'Développeur Flutter',
      'Paris',
      'Alternance',
      94,
      Icons.code_rounded,
      'Tech',
    ),
    _JobData(
      'Atelier 21',
      'Product Designer',
      'Lyon',
      'Stage 6 mois',
      91,
      Icons.draw_outlined,
      'Produit',
    ),
    _JobData(
      'North Data',
      'Data Analyst',
      'Bordeaux',
      'Alternance',
      89,
      Icons.query_stats_rounded,
      'Data',
    ),
    _JobData(
      'Arche Conseil',
      'Analyste investissement',
      'Paris',
      'Stage',
      87,
      Icons.show_chart_rounded,
      'Finance',
    ),
    _JobData(
      'Nova Studio',
      'UX Researcher',
      'Nantes',
      'Alternance',
      93,
      Icons.travel_explore_rounded,
      'Design',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final controller = _controller;
      if (!mounted ||
          _hovered ||
          controller == null ||
          !controller.hasClients) {
        return;
      }
      final next = (_page + 1) % _jobs.length;
      controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 620),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.sizeOf(context).width;
    final nextFraction = width >= 1180
        ? .31
        : width >= 760
        ? .48
        : .86;
    if (_controller == null || nextFraction != _viewportFraction) {
      _viewportFraction = nextFraction;
      final old = _controller;
      _controller = PageController(
        initialPage: _page,
        viewportFraction: _viewportFraction,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => old?.dispose());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final controller = _controller;
    if (controller == null || !controller.hasClients) {
      return;
    }
    final next = (_page + delta).clamp(0, _jobs.length - 1).toInt();
    controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 110),
        child: Column(
          children: [
            ContentContainer(
              maxWidth: 1240,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: SectionHeader(
                      eyebrow: 'Le feed JOYN',
                      title: 'Des opportunités qui te ressemblent vraiment.',
                      description: 'Le bon poste remonte pour une raison. Score de compatibilité, rythme, trajet et formation : tu sais pourquoi avant de candidater.',
                    ),
                  ),
                  if (MediaQuery.sizeOf(context).width >= 760) ...[
                    const SizedBox(width: 24),
                    LandingReveal(
                      delay: const Duration(milliseconds: 120),
                      offset: const Offset(20, 0),
                      child: Row(
                        children: [
                          _ArrowButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => _go(-1),
                          ),
                          const SizedBox(width: 10),
                          _ArrowButton(
                            icon: Icons.arrow_forward_rounded,
                            onTap: () => _go(1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 54),
            MouseRegion(
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: SizedBox(
                height: 330,
                child: PageView.builder(
                  key: ValueKey('jobs-${_viewportFraction.toStringAsFixed(2)}'),
                  controller: _controller,
                  padEnds: true,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemCount: _jobs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: LandingReveal(
                        delay: Duration(milliseconds: 70 * math.min(index, 3)),
                        child: _JobCard(data: _jobs[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < _jobs.length; index++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: index == _page ? 26 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index == _page
                          ? AppColors.orange
                          : const Color(0xFFD7E1E9),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JobData {
  const _JobData(
    this.company,
    this.title,
    this.location,
    this.contract,
    this.match,
    this.icon,
    this.category,
  );
  final String company;
  final String title;
  final String location;
  final String contract;
  final int match;
  final IconData icon;
  final String category;
}

class _JobCard extends StatefulWidget {
  const _JobCard({required this.data});
  final _JobData data;

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: hovered ? 1.018 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: hovered ? const Color(0xFF0F304F) : const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: hovered
                  ? AppColors.orange.withValues(alpha: .45)
                  : const Color(0xFFE4ECF2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: hovered ? .13 : .07),
                blurRadius: hovered ? 38 : 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: hovered
                          ? AppColors.white.withValues(alpha: .1)
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.data.icon,
                      color: hovered
                          ? AppColors.orangeLight
                          : AppColors.cyanBlue,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(
                        alpha: hovered ? .18 : .1,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '${widget.data.match}% match',
                      style: TextStyle(
                        color: hovered
                            ? AppColors.orangeLight
                            : AppColors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                widget.data.category.toUpperCase(),
                style: TextStyle(
                  color: hovered
                      ? AppColors.white.withValues(alpha: .48)
                      : AppColors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.data.title,
                style: TextStyle(
                  color: hovered ? AppColors.white : AppColors.navy,
                  fontSize: 23,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.data.company,
                style: TextStyle(
                  color: hovered
                      ? AppColors.white.withValues(alpha: .72)
                      : const Color(0xFF5F7589),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: hovered
                        ? AppColors.white.withValues(alpha: .55)
                        : AppColors.grey,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.data.location,
                    style: TextStyle(
                      color: hovered
                          ? AppColors.white.withValues(alpha: .68)
                          : AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(
                    Icons.schedule_outlined,
                    size: 16,
                    color: hovered
                        ? AppColors.white.withValues(alpha: .55)
                        : AppColors.grey,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      widget.data.contract,
                      style: TextStyle(
                        color: hovered
                            ? AppColors.white.withValues(alpha: .68)
                            : AppColors.grey,
                        fontSize: 12,
                      ),
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

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFF0F5F8),
        foregroundColor: AppColors.navy,
        fixedSize: const Size(48, 48),
      ),
    );
  }
}
