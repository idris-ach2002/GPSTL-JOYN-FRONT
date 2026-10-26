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
                      onFiltersPressed: () => _openFilters(context, controller),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Transform.translate(
                          offset: const Offset(0, -18),
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
  const _MobileCandidatesHero({required this.onFiltersPressed});

  final VoidCallback onFiltersPressed;

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.navy,
    padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
    child: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Candidats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.6,
                  ),
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Filtres avancés',
                onPressed: onFiltersPressed,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: .12),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
        ],
      ),
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
          height: 320,
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
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
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
        const SizedBox(height: 12),
        CandidateStatsRow(stats: loadedData.stats),
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
          const SizedBox(height: 8),
          _CandidateCarousel(
            items: loadedData.items,
            currentIndex: controller.currentIndex,
            busy: controller.isActionLoading,
            onPageChanged: controller.selectIndex,
            onOpen: (item) => showCandidateProfileDialog(context, item),
            onReject: (item) => controller.updateCandidate(
              item,
              CandidateRecommendationStatus.rejected,
            ),
            onSave: (item) => controller.updateCandidate(
              item,
              CandidateRecommendationStatus.saved,
            ),
            onInterest: (item) => controller.updateCandidate(
              item,
              CandidateRecommendationStatus.interested,
            ),
          ),
          const SizedBox(height: 10),
          _CarouselProgress(
            currentIndex: controller.currentIndex,
            itemCount: loadedData.items.length,
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
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Charger d’autres profils'),
            ),
          ],
        ],
      ],
    );
  }
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
          'Glissez pour comparer les profils',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
      Text(
        '$current/$total · $totalResults profils',
        style: const TextStyle(
          color: _mobileMuted,
          fontSize: 11,
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
    required this.busy,
    required this.onPageChanged,
    required this.onOpen,
    required this.onReject,
    required this.onSave,
    required this.onInterest,
  });

  final List<RecruiterCandidateRecommendation> items;
  final int currentIndex;
  final bool busy;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<RecruiterCandidateRecommendation> onOpen;
  final ValueChanged<RecruiterCandidateRecommendation> onReject;
  final ValueChanged<RecruiterCandidateRecommendation> onSave;
  final ValueChanged<RecruiterCandidateRecommendation> onInterest;

  @override
  State<_CandidateCarousel> createState() => _CandidateCarouselState();
}

class _CandidateCarouselState extends State<_CandidateCarousel> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: .91,
      initialPage: widget.currentIndex
          .clamp(0, widget.items.length - 1)
          .toInt(),
    );
  }

  @override
  void didUpdateWidget(covariant _CandidateCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.items.map((item) => item.id).join('|');
    final newIds = widget.items.map((item) => item.id).join('|');
    final target = widget.items.isEmpty
        ? 0
        : widget.currentIndex.clamp(0, widget.items.length - 1);

    if ((oldIds != newIds || oldWidget.currentIndex != widget.currentIndex) &&
        _pageController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pageController.hasClients) return;
        final page = _pageController.page?.round() ?? 0;
        if (page != target) {
          _pageController.animateToPage(
            target,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 475,
    child: PageView.builder(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.items.length,
      onPageChanged: widget.onPageChanged,
      itemBuilder: (context, index) {
        final candidate = widget.items[index];
        return AnimatedBuilder(
          animation: _pageController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _MobileCandidateCard(
              candidate: candidate,
              busy: widget.busy,
              onOpen: () => widget.onOpen(candidate),
              onReject: () => widget.onReject(candidate),
              onSave: () => widget.onSave(candidate),
              onInterest: () => widget.onInterest(candidate),
            ),
          ),
          builder: (context, child) {
            var distance = (widget.currentIndex - index).abs().toDouble();
            if (_pageController.hasClients &&
                _pageController.position.haveDimensions) {
              distance =
                  (((_pageController.page ?? widget.currentIndex) - index)
                          .abs())
                      .toDouble();
            }
            final bounded = distance.clamp(0.0, 1.0).toDouble();
            final scale = 1 - (bounded * .045);
            final translateY = bounded * 10;
            return Transform.translate(
              offset: Offset(0, translateY),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: child,
              ),
            );
          },
        );
      },
    ),
  );
}

class _MobileCandidateCard extends StatelessWidget {
  const _MobileCandidateCard({
    required this.candidate,
    required this.busy,
    required this.onOpen,
    required this.onReject,
    required this.onSave,
    required this.onInterest,
  });

  final RecruiterCandidateRecommendation candidate;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onReject;
  final VoidCallback onSave;
  final VoidCallback onInterest;

  @override
  Widget build(BuildContext context) => CandidateSurfaceCard(
    padding: const EdgeInsets.fromLTRB(17, 18, 17, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MobileAvatar(candidate: candidate),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                            letterSpacing: -.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _MobileScore(score: candidate.compatibilityScore),
                    ],
                  ),
                  const SizedBox(height: 3),
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
                  _CompactMeta(
                    icon: Icons.place_outlined,
                    text: candidate.location,
                  ),
                  const SizedBox(height: 3),
                  _CompactMeta(
                    icon: Icons.schedule_rounded,
                    text: candidate.availability,
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
            _CompactPill('${candidate.experienceYears.toStringAsFixed(1)} ans'),
            _CompactPill(candidate.contractPreference),
            _CompactPill(candidate.remotePreference),
            if (candidate.connections > 0)
              _CompactPill('${candidate.connections} connexions JOYN'),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          candidate.summary,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF43586B),
            fontSize: 12.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Compétences clés',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final skill in candidate.skills.take(5))
              _SkillPill(label: skill),
          ],
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new_rounded, size: 17),
            label: const Text('Voir le profil complet'),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: _CandidateAction(
                icon: Icons.close_rounded,
                label: 'Écarter',
                color: AppColors.error,
                onPressed: busy ? null : onReject,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _CandidateAction(
                icon: Icons.bookmark_border_rounded,
                label: 'Sauver',
                color: const Color(0xFF7A5AF8),
                onPressed: busy ? null : onSave,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _CandidateAction(
                icon: Icons.favorite_border_rounded,
                label: 'Intérêt',
                color: AppColors.orange,
                onPressed: busy ? null : onInterest,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _MobileAvatar extends StatelessWidget {
  const _MobileAvatar({required this.candidate});

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
            fontSize: 22,
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
        errorBuilder: (_, _, _) => Center(
          child: Text(
            candidate.firstName.isEmpty ? '?' : candidate.firstName[0],
          ),
        ),
      );
    }

    return Container(
      width: 62,
      height: 62,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Color(0xFFEAF3FF),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}

class _MobileScore extends StatelessWidget {
  const _MobileScore({required this.score});

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
        fontSize: 11,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _CompactMeta extends StatelessWidget {
  const _CompactMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: _mobileMuted),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _mobileMuted, fontSize: 10.5),
        ),
      ),
    ],
  );
}

class _CompactPill extends StatelessWidget {
  const _CompactPill(this.label);

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

class _SkillPill extends StatelessWidget {
  const _SkillPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF3FF),
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

class _CandidateAction extends StatelessWidget {
  const _CandidateAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      side: BorderSide(color: color.withValues(alpha: .34)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 19),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _CarouselProgress extends StatelessWidget {
  const _CarouselProgress({
    required this.currentIndex,
    required this.itemCount,
  });

  final int currentIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final safeCount = itemCount <= 0 ? 1 : itemCount;
    final value = ((currentIndex + 1) / safeCount).clamp(0.0, 1.0).toDouble();
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 5,
              backgroundColor: const Color(0xFFDDE6EE),
              color: AppColors.navy,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${currentIndex + 1} / $itemCount',
          style: const TextStyle(
            color: _mobileMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
