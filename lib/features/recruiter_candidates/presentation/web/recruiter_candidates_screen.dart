import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../recruiter_offers/presentation/shared/recruiter_offer_header_art.dart';
import '../../../recruiter_offers/presentation/web/recruiter_offers_top_bar.dart';
import '../../domain/recruiter_candidate_models.dart';
import '../recruiter_candidate_controller.dart';
import '../shared/recruiter_candidate_widgets.dart';

class WebRecruiterCandidatesScreen extends StatefulWidget {
  const WebRecruiterCandidatesScreen({super.key});

  @override
  State<WebRecruiterCandidatesScreen> createState() =>
      _WebRecruiterCandidatesScreenState();
}

class _WebRecruiterCandidatesScreenState
    extends State<WebRecruiterCandidatesScreen> {
  bool _listMode = false;
  String? _shownMatchId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecruiterCandidateController>();
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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      body: RefreshIndicator(
        onRefresh: controller.reload,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _CandidatesHero(controller: controller)),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 40),
                    child: _CandidatesBody(
                      controller: controller,
                      listMode: _listMode,
                      onModeChanged: (value) =>
                          setState(() => _listMode = value),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidatesHero extends StatelessWidget {
  const _CandidatesHero({required this.controller});

  final RecruiterCandidateController controller;

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    final offers = data?.offers ?? const <RecruiterCandidateOffer>[];
    final selectedId = controller.query.offerId ?? data?.selectedOfferId;

    return Stack(
      children: [
        const Positioned.fill(child: RecruiterOfferHeaderArt()),
        const Positioned.fill(child: ColoredBox(color: Color(0x33001E3B))),
        SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RecruiterOffersTopBar(
                      active: RecruiterTopTab.candidates,
                    ),
                    const SizedBox(height: 46),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 820;
                        final title = const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Candidats recommandés',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Découvrez les profils les plus compatibles avec vos offres et comprenez chaque recommandation.',
                              style: TextStyle(
                                color: Color(0xFFE4EDF5),
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          ],
                        );
                        final selector = _OfferSelector(
                          offers: offers,
                          selectedId: selectedId,
                          enabled: !controller.isLoading,
                          onChanged: controller.selectOffer,
                        );

                        if (compact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title,
                              const SizedBox(height: 18),
                              selector,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(child: title),
                            const SizedBox(width: 24),
                            SizedBox(width: 360, child: selector),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfferSelector extends StatelessWidget {
  const _OfferSelector({
    required this.offers,
    required this.selectedId,
    required this.enabled,
    required this.onChanged,
  });

  final List<RecruiterCandidateOffer> offers;
  final int? selectedId;
  final bool enabled;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [
        BoxShadow(
          color: Color(0x22000000),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: offers.any((offer) => offer.id == selectedId)
            ? selectedId
            : null,
        isExpanded: true,
        hint: const Text('Sélectionner une offre'),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: [
          for (final offer in offers)
            DropdownMenuItem(
              value: offer.id,
              child: Text(
                offer.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
        ],
        onChanged: enabled ? onChanged : null,
      ),
    ),
  );
}

class _CandidatesBody extends StatelessWidget {
  const _CandidatesBody({
    required this.controller,
    required this.listMode,
    required this.onModeChanged,
  });

  final RecruiterCandidateController controller;
  final bool listMode;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    if (controller.isLoading && data == null) {
      return const SizedBox(
        height: 420,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.error != null && data == null) {
      return CandidateSurfaceCard(
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: Color(0xFF6C8093),
            ),
            const SizedBox(height: 12),
            const Text(
              'Impossible de charger les recommandations.',
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
    if (data == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CandidateStatsRow(stats: data.stats),
        const SizedBox(height: 16),
        _CandidateToolbar(
          controller: controller,
          data: data,
          listMode: listMode,
          onModeChanged: onModeChanged,
        ),
        const SizedBox(height: 16),
        if (data.items.isEmpty)
          EmptyCandidatesState(
            label: controller.query.status.label,
            onReload: controller.reload,
          )
        else if (listMode)
          CandidateList(
            items: data.items,
            onOpen: (candidate) =>
                showCandidateProfileDialog(context, candidate),
            onInterest: (candidate) => controller.updateCandidate(
              candidate,
              CandidateRecommendationStatus.interested,
            ),
          )
        else
          _WebCandidateStage(controller: controller),
      ],
    );
  }
}

class _CandidateToolbar extends StatelessWidget {
  const _CandidateToolbar({
    required this.controller,
    required this.data,
    required this.listMode,
    required this.onModeChanged,
  });

  final RecruiterCandidateController controller;
  final CandidateRecommendationData data;
  final bool listMode;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) => CandidateSurfaceCard(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 940;
        final mode = SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              icon: Icon(Icons.view_carousel_outlined, size: 17),
              label: Text('Cartes'),
            ),
            ButtonSegment(
              value: true,
              icon: Icon(Icons.view_list_rounded, size: 17),
              label: Text('Liste'),
            ),
          ],
          selected: {listMode},
          onSelectionChanged: (value) => onModeChanged(value.first),
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        );
        final filter = OutlinedButton.icon(
          onPressed: () => _openFilters(context),
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: const Text('Filtres avancés'),
        );
        final count = Text(
          '${data.totalItems} profil${data.totalItems > 1 ? 's' : ''}',
          style: const TextStyle(
            color: Color(0xFF6C8093),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CandidateStatusTabs(
                value: controller.query.status,
                onChanged: controller.selectStatus,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [count, mode, filter],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: CandidateStatusTabs(
                value: controller.query.status,
                onChanged: controller.selectStatus,
              ),
            ),
            const SizedBox(width: 12),
            count,
            const SizedBox(width: 14),
            mode,
            const SizedBox(width: 8),
            filter,
          ],
        );
      },
    ),
  );

  Future<void> _openFilters(BuildContext context) async {
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

class _WebCandidateStage extends StatefulWidget {
  const _WebCandidateStage({required this.controller});

  final RecruiterCandidateController controller;

  @override
  State<_WebCandidateStage> createState() => _WebCandidateStageState();
}

class _WebCandidateStageState extends State<_WebCandidateStage> {
  late final PageController _pageController;
  late final FocusNode _focusNode;
  late double _visualPage;

  RecruiterCandidateController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _visualPage = controller.currentIndex.toDouble();
    _pageController = PageController(
      initialPage: controller.currentIndex,
      viewportFraction: .66,
    );
    _pageController.addListener(_handlePageScroll);
    _focusNode = FocusNode(debugLabel: 'web-candidate-carousel');
  }

  @override
  void didUpdateWidget(covariant _WebCandidateStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final items =
          controller.data?.items ?? const <RecruiterCandidateRecommendation>[];
      if (items.isEmpty) return;
      final target = controller.currentIndex.clamp(0, items.length - 1).toInt();

      if ((_visualPage - target).abs() > .001) {
        setState(() => _visualPage = target.toDouble());
      }

      if (_pageController.positions.length != 1) return;
      final position = _pageController.positions.single;
      if (!position.haveDimensions) return;

      final page = (_pageController.page ?? target).round();
      if (page != target) {
        _pageController.animateToPage(
          target,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handlePageScroll() {
    if (!mounted || _pageController.positions.length != 1) return;
    final position = _pageController.positions.single;
    if (!position.haveDimensions) return;

    final page = _pageController.page;
    if (page == null || (_visualPage - page).abs() <= .001) return;
    setState(() => _visualPage = page);
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    final items = data?.items ?? const <RecruiterCandidateRecommendation>[];
    final candidate = controller.currentCandidate;
    if (candidate == null || data == null || items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 1180;
        final stage = _buildStage(context, items, data);
        final match = AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: CandidateMatchPanel(
            key: ValueKey(candidate.id),
            candidate: candidate,
          ),
        );

        if (!sideBySide) {
          return Column(children: [stage, const SizedBox(height: 16), match]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 8, child: stage),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: match),
          ],
        );
      },
    );
  }

  Widget _buildStage(
    BuildContext context,
    List<RecruiterCandidateRecommendation> items,
    CandidateRecommendationData data,
  ) {
    final candidate = controller.currentCandidate!;

    return CandidateSurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _goRelative(1);
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _goRelative(-1);
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            showCandidateProfileDialog(context, candidate);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _focusNode.requestFocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profils recommandés',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Faites glisser les cartes, cliquez sur un profil latéral ou utilisez ← →.',
                          style: TextStyle(
                            color: Color(0xFF6C8093),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StageCounter(
                    position: controller.currentPosition,
                    total: data.totalItems,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 470,
                child: ScrollConfiguration(
                  behavior: const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: PageView.builder(
                    controller: _pageController,
                    padEnds: true,
                    itemCount: items.length,
                    onPageChanged: (index) {
                      if ((_visualPage - index).abs() > .001 && mounted) {
                        setState(() => _visualPage = index.toDouble());
                      }
                      controller.selectIndex(index);
                    },
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final distance = (_visualPage - index).abs();
                      final bounded = distance.clamp(0.0, 1.0).toDouble();
                      final scale = 1.0 - (bounded * .075);
                      final opacity = 1.0 - (bounded * .38);
                      final translateY = bounded * 14.0;

                      return Transform.translate(
                        offset: Offset(0, translateY),
                        child: Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: _StageCandidateCard(
                              candidate: item,
                              active: index == controller.currentIndex,
                              onTap: () => _selectPage(index),
                              onOpen: () =>
                                  showCandidateProfileDialog(context, item),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _StageProgress(
                itemCount: items.length,
                currentIndex: controller.currentIndex,
              ),
              const SizedBox(height: 14),
              _StageActions(
                busy: controller.isActionLoading,
                onReject: controller.rejectCurrent,
                onSave: controller.saveCurrent,
                onInterest: controller.interestCurrent,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Votre intérêt reste privé tant que le candidat n’a pas manifesté le sien.',
                      style: TextStyle(
                        color: Color(0xFF6C8093),
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                  if (data.page < data.totalPages)
                    TextButton.icon(
                      onPressed: controller.isLoading
                          ? null
                          : () => controller.goToPage(data.page + 1),
                      icon: const Icon(Icons.add_rounded, size: 17),
                      label: const Text('Charger la suite'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goRelative(int delta) {
    final items =
        controller.data?.items ?? const <RecruiterCandidateRecommendation>[];
    if (items.isEmpty) return;
    final target = (controller.currentIndex + delta).clamp(0, items.length - 1);
    _selectPage(target.toInt());
  }

  void _selectPage(int index) {
    final items =
        controller.data?.items ?? const <RecruiterCandidateRecommendation>[];
    if (items.isEmpty) return;
    final target = index.clamp(0, items.length - 1).toInt();
    controller.selectIndex(target);
    if ((_visualPage - target).abs() > .001 && mounted) {
      setState(() => _visualPage = target.toDouble());
    }
    if (_pageController.positions.length == 1) {
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
    _focusNode.requestFocus();
  }
}

class _StageCandidateCard extends StatelessWidget {
  const _StageCandidateCard({
    required this.candidate,
    required this.active,
    required this.onTap,
    required this.onOpen,
  });

  final RecruiterCandidateRecommendation candidate;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: Material(
      color: Colors.white,
      elevation: active ? 7 : 1,
      shadowColor: const Color(0x22082846),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: active
                  ? AppColors.navy.withValues(alpha: .18)
                  : const Color(0xFFDDE5EC),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StageAvatar(candidate: candidate),
                  const SizedBox(width: 14),
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
                            const SizedBox(width: 8),
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
                          spacing: 10,
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
              const SizedBox(height: 18),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _StagePill(
                    '${candidate.experienceYears.toStringAsFixed(1)} ans d’expérience',
                  ),
                  _StagePill(candidate.contractPreference),
                  _StagePill(candidate.remotePreference),
                  _StagePill(candidate.availability),
                ],
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final skill in candidate.skills.take(6))
                    _StageSkill(skill),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  if (candidate.connections > 0)
                    Expanded(
                      child: Text(
                        '${candidate.connections} connexion${candidate.connections > 1 ? 's' : ''} JOYN',
                        style: const TextStyle(
                          color: Color(0xFF6C8093),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  if (active)
                    OutlinedButton.icon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('Profil complet'),
                    )
                  else
                    const Text(
                      'Cliquer pour centrer',
                      style: TextStyle(
                        color: Color(0xFF6C8093),
                        fontSize: 10.5,
                      ),
                    ),
                ],
              ),
            ],
          ),
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
    final initials =
        '${candidate.firstName.isNotEmpty ? candidate.firstName[0] : ''}'
                '${candidate.lastName.isNotEmpty ? candidate.lastName[0] : ''}'
            .toUpperCase();
    final avatar = candidate.avatarUrl;

    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1F7),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: avatar != null && avatar.isNotEmpty
          ? Image.asset(
              avatar,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
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
      color: const Color(0xFFE8F6F0),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      '${score.toStringAsFixed(0)} %',
      style: const TextStyle(
        color: Color(0xFF17835D),
        fontSize: 11,
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
      Icon(icon, size: 14, color: const Color(0xFF6C8093)),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6C8093),
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
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
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F6F8),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: const Color(0xFFE1E8EE)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.navy,
        fontSize: 10.5,
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
      color: const Color(0xFFEAF3F9),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.navy,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
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
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F4F7),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      '$position / $total',
      style: const TextStyle(
        color: AppColors.navy,
        fontSize: 11,
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
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: 10,
    runSpacing: 10,
    children: [
      OutlinedButton.icon(
        onPressed: busy ? null : onReject,
        icon: const Icon(Icons.close_rounded, size: 18),
        label: const Text('Écarter'),
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
      ),
      FilledButton.tonalIcon(
        onPressed: busy ? null : onSave,
        icon: const Icon(Icons.bookmark_border_rounded, size: 18),
        label: const Text('Enregistrer'),
      ),
      FilledButton.icon(
        onPressed: busy ? null : onInterest,
        icon: const Icon(Icons.favorite_border_rounded, size: 18),
        label: const Text('Intéressé'),
        style: FilledButton.styleFrom(backgroundColor: AppColors.orange),
      ),
    ],
  );
}
