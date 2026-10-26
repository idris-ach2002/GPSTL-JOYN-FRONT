import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/recruiter_candidate_models.dart';

const _muted = Color(0xFF6C8093);
const _border = Color(0xFFE1E9EF);
const _blue = Color(0xFF2676E8);
const _softBlue = Color(0xFFEAF3FF);
const _green = Color(0xFF15845A);

class CandidateSurfaceCard extends StatelessWidget {
  const CandidateSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0B082846),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Padding(padding: padding, child: child),
  );
}

class CandidateStatsRow extends StatelessWidget {
  const CandidateStatsRow({super.key, required this.stats});

  final CandidateRecommendationStats stats;

  @override
  Widget build(BuildContext context) {
    final values = [
      ('Recommandés', stats.recommended, Icons.auto_awesome_outlined, _blue),
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
      ('Matches', stats.matches, Icons.handshake_outlined, _green),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        return GridView.count(
          crossAxisCount: compact ? 2 : 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: compact ? 1.95 : 2.35,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final item in values)
              CandidateSurfaceCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.$4.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.$3, color: item.$4, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.$2}',
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            item.$1,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class CandidateStatusTabs extends StatelessWidget {
  const CandidateStatusTabs({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final CandidateRecommendationStatus value;
  final ValueChanged<CandidateRecommendationStatus> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final status in CandidateRecommendationStatus.values)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status.label),
              selected: status == value,
              onSelected: (_) => onChanged(status),
              showCheckmark: false,
              labelStyle: TextStyle(
                color: status == value ? Colors.white : AppColors.navy,
                fontWeight: FontWeight.w700,
              ),
              selectedColor: AppColors.navy,
              backgroundColor: Colors.white,
              side: const BorderSide(color: _border),
              shape: const StadiumBorder(),
            ),
          ),
      ],
    ),
  );
}

class CandidateDeckCard extends StatelessWidget {
  const CandidateDeckCard({
    super.key,
    required this.candidate,
    required this.onOpen,
    required this.onReject,
    required this.onSave,
    required this.onInterest,
    this.busy = false,
  });

  final RecruiterCandidateRecommendation candidate;
  final VoidCallback onOpen;
  final VoidCallback onReject;
  final VoidCallback onSave;
  final VoidCallback onInterest;
  final bool busy;

  @override
  Widget build(BuildContext context) => CandidateSurfaceCard(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CandidateAvatar(candidate: candidate, size: 72),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        candidate.fullName,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.3,
                        ),
                      ),
                      _ScorePill(score: candidate.compatibilityScore),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    candidate.jobTitle,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _Meta(
                        icon: Icons.place_outlined,
                        text: candidate.location,
                      ),
                      _Meta(
                        icon: Icons.school_outlined,
                        text: candidate.education,
                      ),
                      _Meta(
                        icon: Icons.schedule_rounded,
                        text: candidate.availability,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoPill(
              '${candidate.experienceYears.toStringAsFixed(1)} ans d’expérience',
            ),
            _InfoPill(candidate.contractPreference),
            _InfoPill(candidate.remotePreference),
            if (candidate.connections > 0)
              _InfoPill(
                '${candidate.connections} connexion${candidate.connections > 1 ? 's' : ''} JOYN',
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          candidate.summary,
          style: const TextStyle(
            color: Color(0xFF43586B),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Compétences clés',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final skill in candidate.skills.take(6))
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _softBlue,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new_rounded, size: 17),
              label: const Text('Voir le profil complet'),
            ),
            Wrap(
              spacing: 8,
              children: [
                _ActionButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Écarter',
                  color: AppColors.error,
                  onPressed: busy ? null : onReject,
                ),
                _ActionButton(
                  icon: Icons.bookmark_border_rounded,
                  tooltip: 'Enregistrer',
                  color: const Color(0xFF7A5AF8),
                  onPressed: busy ? null : onSave,
                ),
                _ActionButton(
                  icon: Icons.favorite_border_rounded,
                  tooltip: 'Intéressé',
                  color: AppColors.orange,
                  onPressed: busy ? null : onInterest,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

class CandidateMatchPanel extends StatelessWidget {
  const CandidateMatchPanel({super.key, required this.candidate});

  final RecruiterCandidateRecommendation candidate;

  @override
  Widget build(BuildContext context) => CandidateSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Adéquation avec l’offre',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _ScorePill(score: candidate.compatibilityScore, large: true),
          ],
        ),
        const SizedBox(height: 18),
        for (final entry in candidate.match.entries) ...[
          _MatchMetric(label: entry.key, value: entry.value),
          const SizedBox(height: 13),
        ],
        const Divider(height: 28, color: _border),
        const Text(
          'Pourquoi ce profil ?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        for (final strength in candidate.strengths)
          _ReasonLine(
            icon: Icons.check_circle_rounded,
            color: _green,
            text: strength,
          ),
        if (candidate.warnings.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Points à vérifier',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          for (final warning in candidate.warnings)
            _ReasonLine(
              icon: Icons.warning_amber_rounded,
              color: AppColors.warningDeep,
              text: warning,
            ),
        ],
      ],
    ),
  );
}

class CandidateList extends StatelessWidget {
  const CandidateList({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onInterest,
  });

  final List<RecruiterCandidateRecommendation> items;
  final ValueChanged<RecruiterCandidateRecommendation> onOpen;
  final ValueChanged<RecruiterCandidateRecommendation> onInterest;

  @override
  Widget build(BuildContext context) => CandidateSurfaceCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _CandidateListRow(
            candidate: items[index],
            onOpen: () => onOpen(items[index]),
            onInterest: () => onInterest(items[index]),
          ),
          if (index != items.length - 1)
            const Divider(height: 1, color: _border),
        ],
      ],
    ),
  );
}

class EmptyCandidatesState extends StatelessWidget {
  const EmptyCandidatesState({
    super.key,
    required this.label,
    required this.onReload,
  });

  final String label;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) => CandidateSurfaceCard(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.person_search_outlined, size: 46, color: _muted),
            const SizedBox(height: 12),
            Text(
              'Aucun profil dans « $label » pour le moment.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onReload,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Actualiser'),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showCandidateProfileDialog(
  BuildContext context,
  RecruiterCandidateRecommendation candidate,
) => showDialog<void>(
  context: context,
  builder: (context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    alignment: Alignment.centerRight,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CandidateAvatar(candidate: candidate, size: 66),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.fullName,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        candidate.jobTitle,
                        style: const TextStyle(color: _muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CandidateMatchPanel(candidate: candidate),
            const SizedBox(height: 16),
            const Text(
              'À propos',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              candidate.summary,
              style: const TextStyle(color: Color(0xFF43586B), height: 1.5),
            ),
            const SizedBox(height: 18),
            const Text(
              'Compétences',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final skill in candidate.skills) Chip(label: Text(skill)),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);

class ReciprocalMatchDialog extends StatelessWidget {
  const ReciprocalMatchDialog({super.key, required this.candidate});
  final RecruiterCandidateRecommendation candidate;

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Icon(
      Icons.celebration_rounded,
      color: AppColors.orange,
      size: 38,
    ),
    title: const Text('C’est un match 🎉', textAlign: TextAlign.center),
    content: Text(
      '${candidate.firstName} est également intéressé·e. Vous pouvez maintenant poursuivre l’échange.',
      textAlign: TextAlign.center,
    ),
    actionsAlignment: MainAxisAlignment.center,
    actions: [
      OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Fermer'),
      ),
      FilledButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        label: const Text('Contacter'),
      ),
    ],
  );
}

class _CandidateListRow extends StatelessWidget {
  const _CandidateListRow({
    required this.candidate,
    required this.onOpen,
    required this.onInterest,
  });
  final RecruiterCandidateRecommendation candidate;
  final VoidCallback onOpen;
  final VoidCallback onInterest;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        _CandidateAvatar(candidate: candidate, size: 46),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                candidate.fullName,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                candidate.jobTitle,
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (final skill in candidate.skills.take(3)) _InfoPill(skill),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _ScorePill(score: candidate.compatibilityScore),
        const SizedBox(width: 10),
        IconButton(
          onPressed: onInterest,
          tooltip: 'Intéressé',
          icon: const Icon(
            Icons.favorite_border_rounded,
            color: AppColors.orange,
          ),
        ),
        IconButton(
          onPressed: onOpen,
          tooltip: 'Voir le profil',
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    ),
  );
}

class _CandidateAvatar extends StatelessWidget {
  const _CandidateAvatar({required this.candidate, required this.size});
  final RecruiterCandidateRecommendation candidate;
  final double size;

  @override
  Widget build(BuildContext context) {
    final provider =
        candidate.avatarUrl != null &&
            candidate.avatarUrl!.startsWith('assets/')
        ? AssetImage(candidate.avatarUrl!) as ImageProvider
        : null;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _softBlue,
      backgroundImage: provider,
      child: provider == null
          ? Text(
              candidate.firstName.isEmpty
                  ? '?'
                  : candidate.firstName.substring(0, 1),
              style: TextStyle(
                color: AppColors.navy,
                fontSize: size * .32,
                fontWeight: FontWeight.w900,
              ),
            )
          : null,
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.score, this.large = false});
  final double score;
  final bool large;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: large ? 13 : 10,
      vertical: large ? 8 : 6,
    ),
    decoration: BoxDecoration(
      color: score >= 90 ? AppColors.successTint : _softBlue,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      '${score.toStringAsFixed(0)} %',
      style: TextStyle(
        color: score >= 90 ? AppColors.successDeep : AppColors.navy,
        fontSize: large ? 16 : 12,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: _muted),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: _muted, fontSize: 11)),
    ],
  );
}

class _InfoPill extends StatelessWidget {
  const _InfoPill(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F8FB),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: _border),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF53697C),
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _MatchMetric extends StatelessWidget {
  const _MatchMetric({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)} %',
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          minHeight: 7,
          value: (value / 100).clamp(0.0, 1.0).toDouble(),
          backgroundColor: const Color(0xFFEAF0F4),
          valueColor: const AlwaysStoppedAnimation(_blue),
        ),
      ),
    ],
  );
}

class _ReasonLine extends StatelessWidget {
  const _ReasonLine({
    required this.icon,
    required this.color,
    required this.text,
  });
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF53697C),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: color,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(46),
        side: BorderSide(color: color.withValues(alpha: .28)),
        backgroundColor: color.withValues(alpha: .06),
      ),
    ),
  );
}

class CandidateFilterValues {
  const CandidateFilterValues({
    required this.scoreMin,
    this.location,
    this.experienceMin,
    this.experienceMax,
    this.skills = const [],
    this.contractType,
  });

  final double scoreMin;
  final String? location;
  final double? experienceMin;
  final double? experienceMax;
  final List<String> skills;
  final String? contractType;
}

Future<CandidateFilterValues?> showCandidateFiltersDialog(
  BuildContext context, {
  required CandidateRecommendationQuery query,
}) async {
  var score = query.scoreMin;
  final locationController = TextEditingController(text: query.location ?? '');
  final skillsController = TextEditingController(text: query.skills.join(', '));
  final minController = TextEditingController(
    text: query.experienceMin?.toString() ?? '',
  );
  final maxController = TextEditingController(
    text: query.experienceMax?.toString() ?? '',
  );
  String? contract = query.contractType;

  final result = await showDialog<CandidateFilterValues>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Filtres avancés'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score minimum · ${score.toStringAsFixed(0)} %',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Slider(
                  value: score.clamp(0.0, 100.0).toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${score.toStringAsFixed(0)} %',
                  onChanged: (value) => setState(() => score = value),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Localisation',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Expérience min.',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: maxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Expérience max.',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: skillsController,
                  decoration: const InputDecoration(
                    labelText: 'Compétences obligatoires',
                    hintText: 'React, TypeScript, Docker',
                    prefixIcon: Icon(Icons.code_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: contract,
                  decoration: const InputDecoration(
                    labelText: 'Type de contrat',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CDI', child: Text('CDI')),
                    DropdownMenuItem(value: 'CDD', child: Text('CDD')),
                    DropdownMenuItem(
                      value: 'Alternance',
                      child: Text('Alternance'),
                    ),
                    DropdownMenuItem(value: 'Stage', child: Text('Stage')),
                  ],
                  onChanged: (value) => setState(() => contract = value),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              score = 0;
              locationController.clear();
              skillsController.clear();
              minController.clear();
              maxController.clear();
              contract = null;
            }),
            child: const Text('Réinitialiser'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final skills = skillsController.text
                  .split(',')
                  .map((item) => item.trim())
                  .where((item) => item.isNotEmpty)
                  .toList();
              Navigator.pop(
                dialogContext,
                CandidateFilterValues(
                  scoreMin: score,
                  location: locationController.text.trim(),
                  experienceMin: double.tryParse(
                    minController.text.replaceAll(',', '.'),
                  ),
                  experienceMax: double.tryParse(
                    maxController.text.replaceAll(',', '.'),
                  ),
                  skills: skills,
                  contractType: contract,
                ),
              );
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    ),
  );

  locationController.dispose();
  skillsController.dispose();
  minController.dispose();
  maxController.dispose();
  return result;
}
