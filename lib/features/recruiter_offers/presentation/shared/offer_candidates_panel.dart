import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/job_offer.dart';

const _candidateAvatars = [
  'assets/images/candidate_avatar_1.png',
  'assets/images/candidate_avatar_2.png',
  'assets/images/candidate_avatar_3.png',
  'assets/images/candidate_avatar_4.png',
  'assets/images/candidate_avatar_5.png',
  'assets/images/candidate_avatar_6.png',
];

enum OfferCandidateStage { newLead, inProgress, interview, rejected }

extension OfferCandidateStageUi on OfferCandidateStage {
  String get label => switch (this) {
    OfferCandidateStage.newLead => 'Nouveau',
    OfferCandidateStage.inProgress => 'En cours',
    OfferCandidateStage.interview => 'Entretien',
    OfferCandidateStage.rejected => 'Refusé',
  };

  Color get foreground => switch (this) {
    OfferCandidateStage.newLead => const Color(0xFF1769C2),
    OfferCandidateStage.inProgress => const Color(0xFFB56A00),
    OfferCandidateStage.interview => const Color(0xFF6852C9),
    OfferCandidateStage.rejected => const Color(0xFFD64343),
  };

  Color get background => switch (this) {
    OfferCandidateStage.newLead => const Color(0xFFEAF4FC),
    OfferCandidateStage.inProgress => const Color(0xFFFFF4E1),
    OfferCandidateStage.interview => const Color(0xFFF0ECFF),
    OfferCandidateStage.rejected => const Color(0xFFFFECEC),
  };
}

class OfferCandidatePreview {
  const OfferCandidatePreview({
    required this.name,
    required this.school,
    required this.skills,
    required this.stage,
    required this.appliedAt,
    required this.avatarAsset,
  });

  final String name;
  final String school;
  final List<String> skills;
  final OfferCandidateStage stage;
  final DateTime appliedAt;
  final String avatarAsset;
}

List<OfferCandidatePreview> demoOfferCandidates(JobOffer offer) {
  if (offer.candidateCount <= 0) return const [];
  const names = [
    'Alex Dupont',
    'Sarah Benali',
    'Thomas Martin',
    'Léa Moreau',
    'Hugo Bernard',
    'Manon Petit',
    'Lucas Renault',
    'Chloé Garcia',
    'Nathan Lefèvre',
    'Emma Dubois',
    'Yanis Cohen',
    'Inès Robert',
    'Noah Roux',
    'Camille Simon',
    'Mehdi Laurent',
    'Jade Michel',
    'Arthur Leroy',
    'Sofia Fontaine',
    'Louis Muller',
    'Nina David',
    'Adam Richard',
    'Clara Bertrand',
    'Ilyes Thomas',
    'Eva Girard',
  ];
  const schools = [
    'EPITECH',
    'ESEIA',
    'Efrei',
    'INSA Lyon',
    'CentraleSupélec',
    'IUT',
    'EPSI',
    'Epita',
    'INSA',
    'Sorbonne',
    'ESILV',
    'Télécom SudParis',
  ];
  const stages = [
    OfferCandidateStage.newLead,
    OfferCandidateStage.inProgress,
    OfferCandidateStage.interview,
    OfferCandidateStage.inProgress,
    OfferCandidateStage.newLead,
    OfferCandidateStage.rejected,
    OfferCandidateStage.inProgress,
    OfferCandidateStage.newLead,
    OfferCandidateStage.interview,
    OfferCandidateStage.inProgress,
  ];

  return List.generate(offer.candidateCount, (index) {
    final skills = offer.skills.isEmpty
        ? const ['Motivé·e']
        : [
            offer.skills[index % offer.skills.length],
            if (offer.skills.length > 1)
              offer.skills[(index + 1) % offer.skills.length],
            if (offer.skills.length > 2 && index.isEven)
              offer.skills[(index + 2) % offer.skills.length],
          ];
    return OfferCandidatePreview(
      name: names[index % names.length],
      school: schools[index % schools.length],
      skills: skills,
      stage: stages[index % stages.length],
      appliedAt: DateTime(2026, 10, math.max(1, 12 - index)),
      avatarAsset: _candidateAvatars[index % _candidateAvatars.length],
    );
  });
}

Future<void> showOfferCandidatesPanel(
  BuildContext context, {
  required JobOffer offer,
}) async {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 760) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: .88,
        child: _CandidatePanel(offer: offer, mobile: true),
      ),
    );
    return;
  }

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fermer les candidats',
    barrierColor: const Color(0x33001E3B),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) => Align(
      alignment: Alignment.centerRight,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: math.min(470.0, width * .38),
            height: double.infinity,
            child: _CandidatePanel(offer: offer),
          ),
        ),
      ),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

class _CandidatePanel extends StatefulWidget {
  const _CandidatePanel({required this.offer, this.mobile = false});
  final JobOffer offer;
  final bool mobile;

  @override
  State<_CandidatePanel> createState() => _CandidatePanelState();
}

class _CandidatePanelState extends State<_CandidatePanel> {
  static const int pageSize = 20;
  String query = '';
  OfferCandidateStage? stage;
  int page = 0;

  List<OfferCandidatePreview> get _all => demoOfferCandidates(widget.offer);

  List<OfferCandidatePreview> get _filtered {
    final q = query.trim().toLowerCase();
    return _all.where((candidate) {
      if (stage != null && candidate.stage != stage) return false;
      if (q.isEmpty) return true;
      return '${candidate.name} ${candidate.school} ${candidate.skills.join(' ')}'
          .toLowerCase()
          .contains(q);
    }).toList();
  }

  int get _pageCount => math.max(1, (_filtered.length / pageSize).ceil());

  List<OfferCandidatePreview> get _visible {
    final safePage = math.min(page, _pageCount - 1);
    final start = safePage * pageSize;
    final end = math.min(start + pageSize, _filtered.length);
    return _filtered.sublist(start, end);
  }

  int _countFor(OfferCandidateStage value) =>
      _all.where((candidate) => candidate.stage == value).length;

  void _selectStage(OfferCandidateStage? value) {
    setState(() {
      stage = value;
      page = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.mobile
        ? const BorderRadius.vertical(top: Radius.circular(28))
        : const BorderRadius.only(
            topLeft: Radius.circular(26),
            bottomLeft: Radius.circular(26),
          );
    return Material(
      color: Colors.white,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (widget.mobile) ...[
            const SizedBox(height: 9),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD6DEE5),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.fromLTRB(
              widget.mobile ? 18 : 22,
              widget.mobile ? 15 : 22,
              widget.mobile ? 12 : 16,
              12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Candidats (${widget.offer.candidateCount})',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.3,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.navy,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.mobile ? 18 : 22),
            child: TextField(
              onChanged: (value) => setState(() {
                query = value;
                page = 0;
              }),
              decoration: InputDecoration(
                hintText: 'Rechercher un candidat (nom, compétences…)',
                hintStyle: const TextStyle(
                  color: AppColors.placeholder,
                  fontSize: 12,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: const Icon(Icons.tune_rounded, size: 18),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.lineSoft),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.lineSoft),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: widget.mobile ? 18 : 22),
              children: [
                _StageChip(
                  label: 'Tous',
                  count: _all.length,
                  selected: stage == null,
                  onTap: () => _selectStage(null),
                ),
                _StageChip(
                  label: 'Nouveau',
                  count: _countFor(OfferCandidateStage.newLead),
                  selected: stage == OfferCandidateStage.newLead,
                  onTap: () => _selectStage(OfferCandidateStage.newLead),
                ),
                _StageChip(
                  label: 'En cours',
                  count: _countFor(OfferCandidateStage.inProgress),
                  selected: stage == OfferCandidateStage.inProgress,
                  onTap: () => _selectStage(OfferCandidateStage.inProgress),
                ),
                _StageChip(
                  label: 'Entretien',
                  count: _countFor(OfferCandidateStage.interview),
                  selected: stage == OfferCandidateStage.interview,
                  onTap: () => _selectStage(OfferCandidateStage.interview),
                ),
                _StageChip(
                  label: 'Refusé',
                  count: _countFor(OfferCandidateStage.rejected),
                  selected: stage == OfferCandidateStage.rejected,
                  onTap: () => _selectStage(OfferCandidateStage.rejected),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE8EEF2)),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Aucun candidat pour ce filtre.',
                      style: TextStyle(color: AppColors.slate),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      widget.mobile ? 14 : 18,
                      8,
                      widget.mobile ? 14 : 18,
                      8,
                    ),
                    itemCount: _visible.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: Color(0xFFEDF1F4),
                    ),
                    itemBuilder: (context, index) => _CandidateRow(
                      candidate: _visible[index],
                      dense: widget.mobile,
                    ),
                  ),
          ),
          _PaginationBar(
            page: page,
            pageCount: _pageCount,
            total: _filtered.length,
            onPageChanged: (value) => setState(() => page = value),
          ),
        ],
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 7),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? const Color(0xFF1687F8) : AppColors.lineSoft,
          ),
        ),
        child: Text(
          '$label  $count',
          style: TextStyle(
            color: selected ? const Color(0xFF1475D1) : AppColors.slateDark,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  );
}

class _CandidateRow extends StatefulWidget {
  const _CandidateRow({required this.candidate, required this.dense});
  final OfferCandidatePreview candidate;
  final bool dense;

  @override
  State<_CandidateRow> createState() => _CandidateRowState();
}

class _CandidateRowState extends State<_CandidateRow> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final candidate = widget.candidate;
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
          horizontal: widget.dense ? 4 : 7,
          vertical: widget.dense ? 10 : 11,
        ),
        decoration: BoxDecoration(
          color: hovered ? const Color(0xFFF8FBFD) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: widget.dense ? 21 : 24,
              backgroundImage: AssetImage(candidate.avatarAsset),
              backgroundColor: const Color(0xFFEAF2F8),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.name,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Étudiant·e · ${candidate.school}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.slate,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final skill in candidate.skills.take(3))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F6FA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(
                              color: AppColors.slateDark,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: candidate.stage.background,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: candidate.stage.foreground,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        candidate.stage.label,
                        style: TextStyle(
                          color: candidate.stage.foreground,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${candidate.appliedAt.day} oct. 2026',
                  style: const TextStyle(
                    color: AppColors.placeholder,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                const Icon(Icons.more_horiz_rounded, color: AppColors.slate, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.pageCount,
    required this.total,
    required this.onPageChanged,
  });
  final int page;
  final int pageCount;
  final int total;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final maxButtons = math.min(pageCount, 5);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EEF2))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            visualDensity: VisualDensity.compact,
          ),
          for (var index = 0; index < maxButtons; index++) ...[
            const SizedBox(width: 3),
            InkWell(
              onTap: () => onPageChanged(index),
              borderRadius: BorderRadius.circular(7),
              child: Container(
                width: 31,
                height: 31,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: page == index ? const Color(0xFF1687F8) : Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: page == index
                        ? const Color(0xFF1687F8)
                        : AppColors.lineSoft,
                  ),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: page == index ? Colors.white : AppColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(width: 3),
          IconButton(
            onPressed: page + 1 < pageCount
                ? () => onPageChanged(page + 1)
                : null,
            icon: const Icon(Icons.chevron_right_rounded, size: 20),
            visualDensity: VisualDensity.compact,
          ),
          const Spacer(),
          Text(
            '$total candidat${total > 1 ? 's' : ''}',
            style: const TextStyle(
              color: AppColors.slate,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
