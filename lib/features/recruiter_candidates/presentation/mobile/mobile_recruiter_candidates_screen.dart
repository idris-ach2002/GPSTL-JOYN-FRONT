import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/mobile/mobile_bottom_navigation.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/recruiter_candidate_models.dart';
import '../recruiter_candidate_controller.dart';
import '../shared/recruiter_candidate_widgets.dart';

const _mobileBackground = Color(0xFFF4F7F9);
const _mobileMuted = Color(0xFF6C8093);
const _mobileBorder = Color(0xFFE0E8EF);
const _mobileBlue = Color(0xFF2676E8);
const _mobileGreen = Color(0xFF15845A);
const _mobileSoftBlue = Color(0xFFEAF3FF);

class MobileRecruiterCandidatesScreen extends StatefulWidget {
  const MobileRecruiterCandidatesScreen({super.key});

  @override
  State<MobileRecruiterCandidatesScreen> createState() =>
      _MobileRecruiterCandidatesScreenState();
}

class _MobileRecruiterCandidatesScreenState
    extends State<MobileRecruiterCandidatesScreen> {
  String? _shownMatchId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecruiterCandidateController>();
    final data = controller.data;
    final match = controller.reciprocalMatch;

    if (match != null && match.id != _shownMatchId) {
      _shownMatchId = match.id;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (_) => ReciprocalMatchDialog(candidate: match),
        );
        controller.clearReciprocalMatch();
      });
    }

    return MobileAppSurface(
      systemUiOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: _mobileBackground,
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.reload,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: _MobileCandidatesHero(
                      totalProfiles: data?.totalItems ?? 0,
                      onFiltersPressed: () => _openFilters(context, controller),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Transform.translate(
                          offset: const Offset(0, -16),
                          child: _MobileCandidatesBody(
                            controller: controller,
                            data: data,
                            onFiltersPressed: () =>
                                _openFilters(context, controller),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          MobileBottomNavigation(
            selectedIndex: 1,
            onSelected: (index) {
              if (index == 0) context.go(AppRoutes.recruiterDashboard);
              if (index == 1) return;
              if (index == 2) context.go(AppRoutes.recruiterJobs);
            },
            items: const [
              MobileNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
              MobileNavItem(icon: Icons.people_alt_rounded, label: 'Talents'),
              MobileNavItem(icon: Icons.work_rounded, label: 'Offres'),
              MobileNavItem(icon: Icons.chat_bubble_rounded, label: 'Messages'),
              MobileNavItem(icon: Icons.more_horiz_rounded, label: 'Plus'),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openFilters(
    BuildContext context,
    RecruiterCandidateController controller,
  ) async {
    final filters = await showCandidateFiltersDialog(
      context,
      query: controller.query,
    );
    if (filters == null || !context.mounted) return;
    await controller.applyFilters(
      scoreMin: filters.scoreMin,
      location: filters.location,
      experienceMin: filters.experienceMin,
      experienceMax: filters.experienceMax,
      skills: filters.skills,
      contractType: filters.contractType,
    );
  }
}

class _MobileCandidatesHero extends StatelessWidget {
  const _MobileCandidatesHero({
    required this.totalProfiles,
    required this.onFiltersPressed,
  });

  final int totalProfiles;
  final VoidCallback onFiltersPressed;

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.navy,
    padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
    child: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Talents',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.7,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Candidats recommandés',
                      style: TextStyle(
                        color: Color(0xFFDCE8F2),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Filtres avancés',
                onPressed: onFiltersPressed,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: .12),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(46, 46),
                ),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Comparez les profils qui correspondent le mieux à l’offre sélectionnée.',
            style: TextStyle(
              color: Color(0xFFBFD0DE),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          _HeroCountPill(totalProfiles: totalProfiles),
        ],
      ),
    ),
  );
}

class _HeroCountPill extends StatelessWidget {
  const _HeroCountPill({required this.totalProfiles});

  final int totalProfiles;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white.withValues(alpha: .12)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          '$totalProfiles profil${totalProfiles > 1 ? 's' : ''} compatible${totalProfiles > 1 ? 's' : ''}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _MobileCandidatesBody extends StatelessWidget {
  const _MobileCandidatesBody({
    required this.controller,
    required this.data,
    required this.onFiltersPressed,
  });

  final RecruiterCandidateController controller;
  final CandidateRecommendationData? data;
  final VoidCallback onFiltersPressed;

  @override
  Widget build(BuildContext context) {
    final loadedData = data;

    if (controller.isLoading && loadedData == null) {
      return const CandidateSurfaceCard(
        child: SizedBox(
          height: 260,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (controller.error != null && loadedData == null) {
      return CandidateSurfaceCard(
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 38, color: _mobileMuted),
            const SizedBox(height: 10),
            const Text(
              'Impossible de charger les recommandations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: controller.reload,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (loadedData == null) return const SizedBox.shrink();

    final candidate = controller.currentCandidate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CandidateSurfaceCard(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: DropdownButtonFormField<int>(
            initialValue:
                loadedData.offers.any(
                  (offer) => offer.id == controller.query.offerId,
                )
                ? controller.query.offerId
                : null,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Offre analysée',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.work_outline_rounded),
              contentPadding: EdgeInsets.zero,
            ),
            items: [
              for (final offer in loadedData.offers)
                DropdownMenuItem(
                  value: offer.id,
                  child: Text(offer.title, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: controller.selectOffer,
          ),
        ),
        const SizedBox(height: 10),
        _MobileStatsStrip(stats: loadedData.stats),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CandidateStatusTabs(
                value: controller.query.status,
                onChanged: controller.selectStatus,
              ),
            ),
            const SizedBox(width: 6),
            IconButton.outlined(
              tooltip: 'Filtres',
              onPressed: onFiltersPressed,
              icon: const Icon(Icons.filter_alt_outlined),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (loadedData.items.isEmpty)
          EmptyCandidatesState(
            label: controller.query.status.label,
            onReload: controller.reload,
          )
        else ...[
          _CarouselHeader(
            current: controller.currentIndex + 1,
            total: loadedData.items.length,
            totalResults: loadedData.totalItems,
          ),
          const SizedBox(height: 10),
          _CandidateCarousel(
            items: loadedData.items,
            currentIndex: controller.currentIndex,
            onPageChanged: controller.selectIndex,
            onOpen: (item) => showCandidateProfileDialog(context, item),
          ),
          const SizedBox(height: 8),
          _StageProgress(
            itemCount: loadedData.items.length,
            currentIndex: controller.currentIndex,
          ),
          const SizedBox(height: 12),
          if (candidate != null)
            _StageActions(
              busy: controller.isActionLoading,
              onReject: controller.rejectCurrent,
              onSave: controller.saveCurrent,
              onInterest: controller.interestCurrent,
            ),
          const SizedBox(height: 9),
          const Text(
            'Votre intérêt reste privé tant que le candidat n’a pas manifesté le sien.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _mobileMuted, fontSize: 9.5, height: 1.35),
          ),
          if (candidate != null) ...[
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: KeyedSubtree(
                key: ValueKey(candidate.id),
                child: CandidateMatchPanel(candidate: candidate),
              ),
            ),
          ],
          if (loadedData.page < loadedData.totalPages) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: controller.isLoading
                  ? null
                  : () => controller.goToPage(loadedData.page + 1),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Charger la suite'),
            ),
          ],
        ],
      ],
    );
  }
}

class _MobileStatsStrip extends StatelessWidget {
  const _MobileStatsStrip({required this.stats});

  final CandidateRecommendationStats stats;

  @override
  Widget build(BuildContext context) {
    final values = [
      (
        'Recommandés',
        stats.recommended,
        Icons.auto_awesome_outlined,
        _mobileBlue,
      ),
      (
        'Enregistrés',
        stats.saved,
        Icons.bookmark_border_rounded,
        const Color(0xFF7A5AF8),
      ),
      (
        'Intéressés',
        stats.interested,
        Icons.favorite_border_rounded,
        AppColors.orange,
      ),
      ('Matches', stats.matches, Icons.handshake_outlined, _mobileGreen),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (var index = 0; index < values.length; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            _MobileStatCard(
              label: values[index].$1,
              value: values[index].$2,
              icon: values[index].$3,
              color: values[index].$4,
            ),
          ],
        ],
      ),
    );
  }
}

class _MobileStatCard extends StatelessWidget {
  const _MobileStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 132,
    height: 72,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _mobileBorder),
      boxShadow: const [
        BoxShadow(
          color: Color(0x09082846),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _mobileMuted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CarouselHeader extends StatelessWidget {
  const _CarouselHeader({
    required this.current,
    required this.total,
    required this.totalResults,
  });

  final int current;
  final int total;
  final int totalResults;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.swipe_rounded, size: 18, color: _mobileBlue),
      const SizedBox(width: 7),
      const Expanded(
        child: Text(
          'Glissez pour comparer',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
      _StageCounter(position: current, total: total),
      const SizedBox(width: 6),
      Text(
        '$totalResults profils',
        style: const TextStyle(
          color: _mobileMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _CandidateCarousel extends StatefulWidget {
  const _CandidateCarousel({
    required this.items,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onOpen,
  });

  final List<RecruiterCandidateRecommendation> items;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<RecruiterCandidateRecommendation> onOpen;

  @override
  State<_CandidateCarousel> createState() => _CandidateCarouselState();
}

class _CandidateCarouselState extends State<_CandidateCarousel> {
  late final PageController _pageController;
  late double _visualPage;

  @override
  void initState() {
    super.initState();
    final initialPage = widget.items.isEmpty
        ? 0
        : widget.currentIndex.clamp(0, widget.items.length - 1).toInt();
    _visualPage = initialPage.toDouble();
    _pageController = PageController(
      viewportFraction: .91,
      initialPage: initialPage,
    );
    _pageController.addListener(_handlePageScroll);
  }

  void _handlePageScroll() {
    if (!_pageController.hasClients || _pageController.positions.length != 1) {
      return;
    }
    final position = _pageController.positions.single;
    if (!position.haveDimensions) return;
    final page = _pageController.page;
    if (page == null || !mounted || (_visualPage - page).abs() <= .001) return;
    setState(() => _visualPage = page);
  }

  @override
  void didUpdateWidget(covariant _CandidateCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.items.map((item) => item.id).join('|');
    final newIds = widget.items.map((item) => item.id).join('|');
    final target = widget.items.isEmpty
        ? 0
        : widget.currentIndex.clamp(0, widget.items.length - 1).toInt();

    if (oldIds == newIds && oldWidget.currentIndex == widget.currentIndex) {
      return;
    }

    _visualPage = target.toDouble();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pageController.positions.length != 1) return;
      final position = _pageController.positions.single;
      if (!position.haveDimensions) return;
      final page = (_pageController.page ?? target).round();
      if (page == target) return;
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_handlePageScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = constraints.maxWidth < 350 ? 430.0 : 400.0;
      return SizedBox(
        height: height,
        child: PageView.builder(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.items.length,
          onPageChanged: (index) {
            _visualPage = index.toDouble();
            widget.onPageChanged(index);
          },
          itemBuilder: (context, index) {
            final candidate = widget.items[index];
            final distance = (_visualPage - index).abs();
            final bounded = distance.clamp(0.0, 1.0).toDouble();
            final scale = 1.0 - (bounded * .075);
            final opacity = 1.0 - (bounded * .38);
            final translateY = bounded * 12.0;
            return Transform.translate(
              offset: Offset(0, translateY),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: Opacity(
                  opacity: opacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: _MobileStageCandidateCard(
                      candidate: candidate,
                      active: index == widget.currentIndex,
                      onOpen: () => widget.onOpen(candidate),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

class _MobileStageCandidateCard extends StatelessWidget {
  const _MobileStageCandidateCard({
    required this.candidate,
    required this.active,
    required this.onOpen,
  });

  final RecruiterCandidateRecommendation candidate;
  final bool active;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: Material(
      color: Colors.white,
      elevation: active ? 7 : 1,
      shadowColor: const Color(0x22082846),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active
                ? AppColors.navy.withValues(alpha: .18)
                : const Color(0xFFDDE5EC),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StageAvatar(candidate: candidate),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              candidate.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          _StageScore(score: candidate.compatibilityScore),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        candidate.jobTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 9,
                        runSpacing: 5,
                        children: [
                          _StageMeta(
                            icon: Icons.place_outlined,
                            text: candidate.location,
                          ),
                          _StageMeta(
                            icon: Icons.school_outlined,
                            text: candidate.education,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _StagePill(
                  '${candidate.experienceYears.toStringAsFixed(1)} ans d’expérience',
                ),
                _StagePill(candidate.contractPreference),
                _StagePill(candidate.remotePreference),
                _StagePill(candidate.availability),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              candidate.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF43586B),
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 13),
            const Text(
              'Compétences clés',
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final skill in candidate.skills.take(5))
                  _StageSkill(skill),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Text(
                    candidate.connections > 0
                        ? '${candidate.connections} connexion${candidate.connections > 1 ? 's' : ''} JOYN'
                        : 'Profil JOYN',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _mobileMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new_rounded, size: 15),
                  label: const Text('Profil complet'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
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

class _StageAvatar extends StatelessWidget {
  const _StageAvatar({required this.candidate});

  final RecruiterCandidateRecommendation candidate;

  @override
  Widget build(BuildContext context) {
    final source = candidate.avatarUrl;
    Widget child;
    if (source == null || source.isEmpty) {
      child = Center(
        child: Text(
          candidate.firstName.isEmpty ? '?' : candidate.firstName[0],
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    } else if (source.startsWith('assets/')) {
      child = Image.asset(source, fit: BoxFit.cover);
    } else {
      child = Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) => Center(
          child: Text(
            candidate.firstName.isEmpty ? '?' : candidate.firstName[0],
          ),
        ),
      );
    }

    return Container(
      width: 58,
      height: 58,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: _mobileSoftBlue,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}

class _StageScore extends StatelessWidget {
  const _StageScore({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFE5F5ED),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      '${score.toStringAsFixed(0)} %',
      style: const TextStyle(
        color: _mobileGreen,
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _StageMeta extends StatelessWidget {
  const _StageMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: _mobileMuted),
      const SizedBox(width: 4),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 150),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _mobileMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

class _StagePill extends StatelessWidget {
  const _StagePill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFF4F7FA),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: _mobileBorder),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: _mobileMuted,
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _StageSkill extends StatelessWidget {
  const _StageSkill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: _mobileSoftBlue,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.navy,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _StageCounter extends StatelessWidget {
  const _StageCounter({required this.position, required this.total});

  final int position;
  final int total;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F4F7),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      '$position / $total',
      style: const TextStyle(
        color: AppColors.navy,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _StageProgress extends StatelessWidget {
  const _StageProgress({required this.itemCount, required this.currentIndex});

  final int itemCount;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final visible = math.min(itemCount, 7);
    final maxStart = math.max(0, itemCount - visible);
    final start = (currentIndex - (visible ~/ 2)).clamp(0, maxStart).toInt();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var offset = 0; offset < visible; offset++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: start + offset == currentIndex ? 24 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: start + offset == currentIndex
                  ? AppColors.navy
                  : const Color(0xFFD6E0E8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class _StageActions extends StatelessWidget {
  const _StageActions({
    required this.busy,
    required this.onReject,
    required this.onSave,
    required this.onInterest,
  });

  final bool busy;
  final VoidCallback onReject;
  final VoidCallback onSave;
  final VoidCallback onInterest;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: busy ? null : onReject,
          icon: const Icon(Icons.close_rounded, size: 16),
          label: const Text('Écarter'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
          ),
        ),
      ),
      const SizedBox(width: 7),
      Expanded(
        child: FilledButton.tonalIcon(
          onPressed: busy ? null : onSave,
          icon: const Icon(Icons.bookmark_border_rounded, size: 16),
          label: const Text('Enregistrer'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
          ),
        ),
      ),
      const SizedBox(width: 7),
      Expanded(
        child: FilledButton.icon(
          onPressed: busy ? null : onInterest,
          icon: const Icon(Icons.favorite_border_rounded, size: 16),
          label: const Text('Intéressé'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.orange,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
          ),
        ),
      ),
    ],
  );
}
