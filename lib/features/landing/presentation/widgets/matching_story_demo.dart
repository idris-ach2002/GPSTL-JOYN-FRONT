import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/landing_content.dart';
import 'audience_selector.dart';

/// Démonstration « vidéo » entièrement dessinée en Flutter.
///
/// Elle raconte les deux parcours de bout en bout, sans asset vidéo ni appel
/// réseau : le scénario avance automatiquement, peut être mis en pause et
/// chaque étape reste accessible au clavier/souris via les contrôles Material.
/// En mode « réduire les animations », la lecture automatique est désactivée.
class MatchingStoryDemo extends StatefulWidget {
  const MatchingStoryDemo({super.key});

  @override
  State<MatchingStoryDemo> createState() => _MatchingStoryDemoState();
}

class _MatchingStoryDemoState extends State<MatchingStoryDemo> {
  static const _stepDuration = Duration(milliseconds: 2800);
  Audience _audience = Audience.candidate;
  int _step = 0;
  bool _playing = true;
  Timer? _timer;

  static const _candidateSteps = [
    _StoryStep(
      title: 'Ton profil prend forme',
      caption: 'Parcours, compétences et préférences sont réunis au même endroit.',
      icon: Icons.badge_outlined,
    ),
    _StoryStep(
      title: 'Les offres les plus proches remontent',
      caption: 'Tu compares le poste, le rythme et les critères qui comptent pour toi.',
      icon: Icons.auto_awesome_outlined,
    ),
    _StoryStep(
      title: 'L’intérêt devient réciproque',
      caption: 'Quand le profil et l’offre se rencontrent, le match devient visible.',
      icon: Icons.favorite_outline,
    ),
    _StoryStep(
      title: 'Ta candidature reste lisible',
      caption: 'Envoyée, en étude, entretien : tu sais toujours où tu en es.',
      icon: Icons.view_kanban_outlined,
    ),
    _StoryStep(
      title: 'La conversation commence au bon moment',
      caption: 'L’échange reste rattaché à l’offre et à la candidature concernées.',
      icon: Icons.forum_outlined,
    ),
  ];

  static const _companySteps = [
    _StoryStep(
      title: 'Votre entreprise pose son identité',
      caption: 'Le profil recruteur et la présentation de l’entreprise ouvrent le parcours.',
      icon: Icons.apartment_outlined,
    ),
    _StoryStep(
      title: 'L’offre part avec les bons critères',
      caption: 'Missions, rythme, localisation et compétences structurent la recherche.',
      icon: Icons.work_outline,
    ),
    _StoryStep(
      title: 'Les profils pertinents apparaissent',
      caption: 'Les recommandations permettent de concentrer l’attention sur les bons profils.',
      icon: Icons.people_outline,
    ),
    _StoryStep(
      title: 'Chaque candidature avance',
      caption: 'Le statut évolue sans perdre l’historique du recrutement.',
      icon: Icons.fact_check_outlined,
    ),
    _StoryStep(
      title: 'Le recrutement passe à la conversation',
      caption: 'Le contexte de l’offre reste disponible pendant l’échange.',
      icon: Icons.chat_bubble_outline,
    ),
  ];

  List<_StoryStep> get _steps =>
      _audience == Audience.candidate ? _candidateSteps : _companySteps;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _playing = false;
      _timer?.cancel();
      _timer = null;
    } else {
      _syncTimer();
    }
  }

  void _syncTimer() {
    _timer?.cancel();
    if (!_playing || !mounted) return;
    _timer = Timer.periodic(_stepDuration, (_) {
      if (!mounted) return;
      setState(() {
        if (_step < _steps.length - 1) {
          _step++;
        } else {
          _audience = _audience == Audience.candidate
              ? Audience.company
              : Audience.candidate;
          _step = 0;
        }
      });
    });
  }

  void _setAudience(Audience audience) {
    setState(() {
      _audience = audience;
      _step = 0;
    });
    _syncTimer();
  }

  void _setStep(int step) {
    setState(() => _step = step);
    _syncTimer();
  }

  void _togglePlayback() {
    setState(() => _playing = !_playing);
    _syncTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final current = _steps[_step];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 620 ? 16 : 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: AppColors.white.withValues(alpha: .65)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: .22),
            blurRadius: 70,
            offset: const Offset(0, 28),
          ),
        ],
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final controls = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.filledTonal(
                    key: const ValueKey('story-playback'),
                    tooltip: _playing ? 'Mettre en pause' : 'Lire la démonstration',
                    onPressed: reduceMotion ? null : _togglePlayback,
                    icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _playing && !reduceMotion ? 'Lecture' : 'Pause',
                    style: const TextStyle(
                      color: AppColors.blueGreyDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
              if (constraints.maxWidth < 650) {
                return Column(
                  children: [
                    AudienceSelector(value: _audience, onChanged: _setAudience),
                    const SizedBox(height: 12),
                    controls,
                  ],
                );
              }
              return Row(
                children: [
                  AudienceSelector(value: _audience, onChanged: _setAudience),
                  const Spacer(),
                  controls,
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          _StoryProgress(
            step: _step,
            steps: _steps,
            onStepSelected: _setStep,
          ),
          const SizedBox(height: 26),
          AnimatedSwitcher(
            duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 520),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(.055, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _StoryFrame(
              key: ValueKey('${_audience.name}-$_step'),
              audience: _audience,
              step: _step,
              story: current,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryProgress extends StatelessWidget {
  const _StoryProgress({
    required this.step,
    required this.steps,
    required this.onStepSelected,
  });

  final int step;
  final List<_StoryStep> steps;
  final ValueChanged<int> onStepSelected;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var index = 0; index < steps.length; index++) ...[
        Expanded(
          child: Tooltip(
            message: steps[index].title,
            child: InkWell(
              key: ValueKey('story-step-$index'),
              borderRadius: BorderRadius.circular(20),
              onTap: () => onStepSelected(index),
              child: AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 320),
                height: 6,
                decoration: BoxDecoration(
                  color: index <= step ? AppColors.orange : AppColors.blueGrey10,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
        if (index != steps.length - 1) const SizedBox(width: 7),
      ],
    ],
  );
}

class _StoryFrame extends StatelessWidget {
  const _StoryFrame({
    required this.audience,
    required this.step,
    required this.story,
    super.key,
  });

  final Audience audience;
  final int step;
  final _StoryStep story;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final copy = _StoryCopy(story: story, step: step);
      final scene = _ProductScene(audience: audience, step: step);
      if (constraints.maxWidth < 760) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [copy, const SizedBox(height: 24), scene],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 4, child: copy),
          const SizedBox(width: 32),
          Expanded(flex: 7, child: scene),
        ],
      );
    },
  );
}

class _StoryCopy extends StatelessWidget {
  const _StoryCopy({required this.story, required this.step});
  final _StoryStep story;
  final int step;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.orange.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(story.icon, color: AppColors.orange),
      ),
      const SizedBox(height: 22),
      Text(
        '0${step + 1}',
        style: const TextStyle(
          color: AppColors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        story.title,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 26,
          height: 1.1,
          fontWeight: FontWeight.w900,
          letterSpacing: -.6,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        story.caption,
        style: const TextStyle(
          color: AppColors.blueGreyDark,
          fontSize: 14,
          height: 1.55,
        ),
      ),
    ],
  );
}

class _ProductScene extends StatelessWidget {
  const _ProductScene({required this.audience, required this.step});
  final Audience audience;
  final int step;

  @override
  Widget build(BuildContext context) {
    final child = audience == Audience.candidate
        ? _candidateScene(step)
        : _companyScene(step);
    return Container(
      constraints: const BoxConstraints(minHeight: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyLight, AppColors.cyanBlue],
        ),
      ),
      child: child,
    );
  }

  Widget _candidateScene(int index) => switch (index) {
    0 => const _ProfileScene(),
    1 => const _OfferScene(),
    2 => const _MatchScene(),
    3 => const _PipelineScene(company: false),
    _ => const _ConversationScene(company: false),
  };

  Widget _companyScene(int index) => switch (index) {
    0 => const _CompanyIdentityScene(),
    1 => const _PublishedOfferScene(),
    2 => const _TalentScene(),
    3 => const _PipelineScene(company: true),
    _ => const _ConversationScene(company: true),
  };
}

class _ProfileScene extends StatelessWidget {
  const _ProfileScene();

  @override
  Widget build(BuildContext context) => const _SceneSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SceneHeader(icon: Icons.badge_outlined, title: 'Camille R.', subtitle: 'Développement mobile · Alternance'),
        SizedBox(height: 18),
        _SceneLabel('Profil complété à 92 %'),
        SizedBox(height: 9),
        LinearProgressIndicator(value: .92, minHeight: 7),
        SizedBox(height: 22),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _SceneChip('Flutter'),
          _SceneChip('Dart'),
          _SceneChip('Git'),
          _SceneChip('Paris'),
        ]),
      ],
    ),
  );
}

class _OfferScene extends StatelessWidget {
  const _OfferScene();

  @override
  Widget build(BuildContext context) => const _SceneSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SceneEyebrow('RECOMMANDÉ POUR TOI'),
        SizedBox(height: 12),
        _SceneHeader(icon: Icons.work_outline, title: 'Développeur Flutter', subtitle: 'Nova Studio · Paris · Alternance'),
        SizedBox(height: 20),
        Row(children: [
          Expanded(child: _MiniMetric(value: '94 %', label: 'compatibilité')),
          SizedBox(width: 10),
          Expanded(child: _MiniMetric(value: '3/4', label: 'critères clés')),
        ]),
        SizedBox(height: 18),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _SceneChip('Flutter'),
          _SceneChip('3 j / 2 j'),
          _SceneChip('Hybride'),
        ]),
      ],
    ),
  );
}

class _MatchScene extends StatelessWidget {
  const _MatchScene();

  @override
  Widget build(BuildContext context) => const _SceneSurface(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AvatarToken(label: 'CR', accent: AppColors.blue),
            SizedBox(width: 14),
            Icon(Icons.favorite_rounded, color: AppColors.orange, size: 38),
            SizedBox(width: 14),
            _AvatarToken(label: 'N', accent: AppColors.orange),
          ],
        ),
        SizedBox(height: 22),
        Text('C’est un match.', style: TextStyle(color: AppColors.navy, fontSize: 28, fontWeight: FontWeight.w900)),
        SizedBox(height: 8),
        Text('L’intérêt est réciproque.', style: TextStyle(color: AppColors.blueGreyDark)),
      ],
    ),
  );
}

class _CompanyIdentityScene extends StatelessWidget {
  const _CompanyIdentityScene();

  @override
  Widget build(BuildContext context) => const _SceneSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SceneEyebrow('ESPACE ENTREPRISE'),
        SizedBox(height: 12),
        _SceneHeader(icon: Icons.apartment_outlined, title: 'Atelier Horizon', subtitle: 'Tech · 51–200 collaborateurs'),
        SizedBox(height: 22),
        _SceneLine(icon: Icons.language, text: 'Présentation de l’entreprise'),
        _SceneLine(icon: Icons.location_on_outlined, text: 'Paris · Hybride'),
        _SceneLine(icon: Icons.verified_outlined, text: 'Profil entreprise validé'),
      ],
    ),
  );
}

class _PublishedOfferScene extends StatelessWidget {
  const _PublishedOfferScene();

  @override
  Widget build(BuildContext context) => const _SceneSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SceneEyebrow('OFFRE ACTIVE'),
        SizedBox(height: 12),
        _SceneHeader(icon: Icons.work_outline, title: 'Développeur Flutter', subtitle: 'Alternance · Paris · Hybride'),
        SizedBox(height: 20),
        _SceneLine(icon: Icons.check_circle_outline, text: 'Compétences cibles définies'),
        _SceneLine(icon: Icons.check_circle_outline, text: 'Rythme et localisation renseignés'),
        _SceneLine(icon: Icons.check_circle_outline, text: 'Offre publiée'),
      ],
    ),
  );
}

class _TalentScene extends StatelessWidget {
  const _TalentScene();

  @override
  Widget build(BuildContext context) => const _SceneSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SceneEyebrow('PROFILS RECOMMANDÉS'),
        SizedBox(height: 14),
        _TalentRow(initials: 'CR', name: 'Camille R.', skills: 'Flutter · Dart', score: '94 %'),
        SizedBox(height: 10),
        _TalentRow(initials: 'AM', name: 'Alex M.', skills: 'Vue · TypeScript', score: '87 %'),
        SizedBox(height: 10),
        _TalentRow(initials: 'NS', name: 'Noa S.', skills: 'Java · Spring', score: '82 %'),
      ],
    ),
  );
}

class _PipelineScene extends StatelessWidget {
  const _PipelineScene({required this.company});
  final bool company;

  @override
  Widget build(BuildContext context) => _SceneSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SceneEyebrow(company ? 'SUIVI DU RECRUTEMENT' : 'MA CANDIDATURE'),
        const SizedBox(height: 14),
        const _SceneHeader(icon: Icons.work_outline, title: 'Développeur Flutter', subtitle: 'Nova Studio · Paris'),
        const SizedBox(height: 28),
        const _StatusRail(),
        const SizedBox(height: 24),
        _SceneLine(
          icon: Icons.event_available_outlined,
          text: company ? 'Entretien proposé au candidat' : 'Entretien confirmé · jeudi, 14:00',
        ),
      ],
    ),
  );
}

class _ConversationScene extends StatelessWidget {
  const _ConversationScene({required this.company});
  final bool company;

  @override
  Widget build(BuildContext context) => _SceneSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SceneEyebrow('CONVERSATION LIÉE À L’OFFRE'),
        const SizedBox(height: 14),
        _MessageBubble(
          text: company
              ? 'Bonjour Camille, nous aimerions échanger sur ton parcours.'
              : 'Bonjour Camille, nous aimerions échanger sur ton parcours.',
          mine: company,
        ),
        const SizedBox(height: 10),
        _MessageBubble(
          text: company
              ? 'Avec plaisir, jeudi à 14 h me convient.'
              : 'Avec plaisir, jeudi à 14 h me convient.',
          mine: !company,
        ),
        const SizedBox(height: 16),
        const _SceneLine(icon: Icons.videocam_outlined, text: 'Entretien · jeudi 14:00 · Visio'),
      ],
    ),
  );
}

class _SceneSurface extends StatelessWidget {
  const _SceneSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 280),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: AppColors.navy.withValues(alpha: .15), blurRadius: 28, offset: const Offset(0, 14)),
      ],
    ),
    child: child,
  );
}

class _SceneHeader extends StatelessWidget {
  const _SceneHeader({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 23,
        backgroundColor: AppColors.blueGrey10,
        child: Icon(icon, color: AppColors.navy),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(subtitle, style: const TextStyle(color: AppColors.blueGreyDark, fontSize: 12)),
          ],
        ),
      ),
    ],
  );
}

class _SceneEyebrow extends StatelessWidget {
  const _SceneEyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: AppColors.orange, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
  );
}

class _SceneLabel extends StatelessWidget {
  const _SceneLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: AppColors.blueGreyDark, fontSize: 12, fontWeight: FontWeight.w700));
}

class _SceneChip extends StatelessWidget {
  const _SceneChip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Chip(
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    side: BorderSide.none,
    backgroundColor: AppColors.blueGrey10,
    label: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
  );
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: AppColors.blueGreyDark, fontSize: 10)),
      ],
    ),
  );
}

class _AvatarToken extends StatelessWidget {
  const _AvatarToken({required this.label, required this.accent});
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    width: 70,
    height: 70,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: accent.withValues(alpha: .16),
      border: Border.all(color: accent, width: 2),
    ),
    child: Text(label, style: const TextStyle(color: AppColors.navy, fontSize: 20, fontWeight: FontWeight.w900)),
  );
}

class _SceneLine extends StatelessWidget {
  const _SceneLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Row(
      children: [
        Icon(icon, color: AppColors.cyanBlue, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.blueGreyDark, fontSize: 12, fontWeight: FontWeight.w600))),
      ],
    ),
  );
}

class _TalentRow extends StatelessWidget {
  const _TalentRow({required this.initials, required this.name, required this.skills, required this.score});
  final String initials;
  final String name;
  final String skills;
  final String score;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
    child: Row(
      children: [
        CircleAvatar(backgroundColor: AppColors.blueGrey10, child: Text(initials, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
              Text(skills, style: const TextStyle(color: AppColors.blueGreyDark, fontSize: 11)),
            ],
          ),
        ),
        Text(score, style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

class _StatusRail extends StatelessWidget {
  const _StatusRail();

  @override
  Widget build(BuildContext context) {
    const labels = ['Envoyée', 'En étude', 'Entretien'];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: i < 2 ? AppColors.cyanBlue : AppColors.orange,
                  child: Icon(i < 2 ? Icons.check_rounded : Icons.event_available_rounded, color: AppColors.white, size: 17),
                ),
                const SizedBox(height: 7),
                Text(labels[i], textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (i != labels.length - 1)
            Expanded(child: Container(height: 2, color: AppColors.blueGrey10)),
        ],
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.text, required this.mine});
  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) => Align(
    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: mine ? AppColors.navy : AppColors.blueGrey10,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(color: mine ? AppColors.white : AppColors.blueGreyDark, fontSize: 12, height: 1.35),
      ),
    ),
  );
}

class _StoryStep {
  const _StoryStep({required this.title, required this.caption, required this.icon});
  final String title;
  final String caption;
  final IconData icon;
}
