import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/landing_content.dart';
import 'audience_selector.dart';

/// Visite produit animée construite à partir des écrans Figma JOYN fournis.
///
/// Contrairement à l'ancienne démonstration dessinée en widgets génériques,
/// chaque étape montre désormais le visuel produit lui-même. Flutter ne fait
/// qu'orchestrer le rythme : changement d'écran, léger mouvement de caméra,
/// curseur guidé, pause et sélection manuelle des étapes.
class MatchingStoryDemo extends StatefulWidget {
  const MatchingStoryDemo({super.key});

  @override
  State<MatchingStoryDemo> createState() => _MatchingStoryDemoState();
}

class _MatchingStoryDemoState extends State<MatchingStoryDemo> {
  static const _stepDuration = Duration(milliseconds: 3600);

  Audience _audience = Audience.candidate;
  int _step = 0;
  bool _playing = true;
  bool _assetsPrecached = false;
  Timer? _timer;

  static const _candidateSteps = [
    _ProductStep(
      shortLabel: 'Dashboard',
      title: 'Ton tableau de bord, dès l’arrivée',
      caption:
          'Matches, candidatures en cours et prochain entretien : l’essentiel '
          'est réuni sur un seul écran.',
      asset: 'assets/figma_demo/candidate_dashboard.png',
      focus: Alignment.center,
      cursor: Alignment(-.56, -.18),
      zoom: 1.035,
    ),
    _ProductStep(
      shortLabel: 'Matchs',
      title: 'Découvre les matchs les plus proches',
      caption:
          'La vue Matchs rapproche directement l’offre des critères '
          'd’adéquation visibles dans le produit.',
      asset: 'assets/figma_demo/candidate_matches.png',
      focus: Alignment(-.14, .02),
      cursor: Alignment(.18, .56),
      zoom: 1.075,
    ),
    _ProductStep(
      shortLabel: 'Offre',
      title: 'Ouvre l’offre avant de décider',
      caption:
          'Missions, rythme, compétences et adéquation restent lisibles avant '
          'de poursuivre la candidature.',
      asset: 'assets/figma_demo/candidate_offer.png',
      focus: Alignment(.04, -.55),
      cursor: Alignment(.62, -.58),
      zoom: 1.11,
    ),
    _ProductStep(
      shortLabel: 'Suivi',
      title: 'Suis chaque candidature',
      caption:
          'Envoyée, en étude, entretien ou refus : le pipeline donne une vue '
          'immédiate de l’avancement.',
      asset: 'assets/figma_demo/candidate_applications.png',
      focus: Alignment.center,
      cursor: Alignment(.16, -.02),
      zoom: 1.045,
    ),
    _ProductStep(
      shortLabel: 'Messages',
      title: 'Échange sans perdre le contexte',
      caption:
          'La messagerie conserve l’entreprise et la candidature concernées '
          'dans la même expérience.',
      asset: 'assets/figma_demo/candidate_messages.png',
      focus: Alignment(.28, .08),
      cursor: Alignment(.55, .04),
      zoom: 1.06,
    ),
  ];

  static const _companySteps = [
    _ProductStep(
      shortLabel: 'Dashboard',
      title: 'Pilote tes recrutements depuis le dashboard',
      caption:
          'Matches, offres actives, candidatures reçues et délai de réponse '
          'sont visibles dès l’arrivée.',
      asset: 'assets/figma_demo/company_dashboard.png',
      focus: Alignment.center,
      cursor: Alignment(-.44, -.04),
      zoom: 1.035,
    ),
    _ProductStep(
      shortLabel: 'Offres',
      title: 'Garde tes offres actives sous les yeux',
      caption:
          'Le même dashboard permet de retrouver rapidement les recrutements '
          'en cours et leur état.',
      asset: 'assets/figma_demo/company_dashboard.png',
      focus: Alignment(.62, .52),
      cursor: Alignment(.64, .55),
      zoom: 1.14,
    ),
    _ProductStep(
      shortLabel: 'Talents',
      title: 'Explore les candidats compatibles',
      caption:
          'La vue dédiée présente le profil recommandé et l’adéquation avec '
          'l’offre sélectionnée.',
      asset: 'assets/figma_demo/company_candidates.png',
      focus: Alignment(-.1, .06),
      cursor: Alignment(-.02, .62),
      zoom: 1.07,
    ),
    _ProductStep(
      shortLabel: 'Profil',
      title: 'Comprends le profil avant de contacter',
      caption:
          'Compétences, parcours, CV et test d’adéquation sont réunis dans la '
          'fiche candidat.',
      asset: 'assets/figma_demo/company_profile.png',
      focus: Alignment(.12, -.05),
      cursor: Alignment(.69, -.63),
      zoom: 1.08,
    ),
    _ProductStep(
      shortLabel: 'Pipeline',
      title: 'Reviens aux candidatures reçues en un geste',
      caption:
          'La liste du dashboard garde les nouveaux profils et les actions de '
          'recrutement à portée de clic.',
      asset: 'assets/figma_demo/company_dashboard.png',
      focus: Alignment(-.47, .5),
      cursor: Alignment(-.45, .36),
      zoom: 1.14,
    ),
  ];

  List<_ProductStep> get _steps =>
      _audience == Audience.candidate ? _candidateSteps : _companySteps;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_assetsPrecached) {
      _assetsPrecached = true;
      for (final asset in {
        ..._candidateSteps.map((step) => step.asset),
        ..._companySteps.map((step) => step.asset),
      }) {
        precacheImage(AssetImage(asset), context);
      }
    }

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

  void _setStep(int index) {
    setState(() => _step = index);
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

    return Column(
      children: [
        _DemoToolbar(
          audience: _audience,
          playing: _playing,
          reduceMotion: reduceMotion,
          onAudienceChanged: _setAudience,
          onTogglePlayback: _togglePlayback,
        ),
        const SizedBox(height: 18),
        _StoryProgress(
          step: _step,
          steps: _steps,
          onStepSelected: _setStep,
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 520),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: .985, end: 1.0).animate(animation),
              child: child,
            ),
          ),
          child: _ProductTheater(
            key: ValueKey('${_audience.name}-$_step'),
            story: current,
            step: _step,
            reduceMotion: reduceMotion,
          ),
        ),
      ],
    );
  }
}

class _DemoToolbar extends StatelessWidget {
  const _DemoToolbar({
    required this.audience,
    required this.playing,
    required this.reduceMotion,
    required this.onAudienceChanged,
    required this.onTogglePlayback,
  });

  final Audience audience;
  final bool playing;
  final bool reduceMotion;
  final ValueChanged<Audience> onAudienceChanged;
  final VoidCallback onTogglePlayback;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final playback = Container(
        decoration: BoxDecoration(
          color: AppColors.navy.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white.withValues(alpha: .14)),
        ),
        child: IconButton(
          key: const ValueKey('story-playback'),
          tooltip: playing ? 'Mettre en pause' : 'Lire la démonstration',
          onPressed: reduceMotion ? null : onTogglePlayback,
          color: AppColors.white,
          disabledColor: AppColors.grey,
          icon: Icon(
            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
          ),
        ),
      );

      final selector = Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: .12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AudienceSelector(
          value: audience,
          onChanged: onAudienceChanged,
        ),
      );

      if (constraints.maxWidth < 620) {
        return Column(
          children: [
            selector,
            const SizedBox(height: 10),
            playback,
          ],
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [selector, const SizedBox(width: 12), playback],
      );
    },
  );
}

class _StoryProgress extends StatelessWidget {
  const _StoryProgress({
    required this.step,
    required this.steps,
    required this.onStepSelected,
  });

  final int step;
  final List<_ProductStep> steps;
  final ValueChanged<int> onStepSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 720) {
        return Row(
          children: [
            for (var index = 0; index < steps.length; index++) ...[
              Expanded(
                child: _ProgressSegment(
                  index: index,
                  selected: index == step,
                  completed: index < step,
                  label: '${index + 1}',
                  onTap: () => onStepSelected(index),
                ),
              ),
              if (index != steps.length - 1) const SizedBox(width: 7),
            ],
          ],
        );
      }

      return Row(
        children: [
          for (var index = 0; index < steps.length; index++) ...[
            Expanded(
              child: _ProgressSegment(
                index: index,
                selected: index == step,
                completed: index < step,
                label: steps[index].shortLabel,
                onTap: () => onStepSelected(index),
              ),
            ),
            if (index != steps.length - 1) const SizedBox(width: 8),
          ],
        ],
      );
    },
  );
}

class _ProgressSegment extends StatelessWidget {
  const _ProgressSegment({
    required this.index,
    required this.selected,
    required this.completed,
    required this.label,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final bool completed;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = selected || completed;
    return Tooltip(
      message: label,
      child: InkWell(
        key: ValueKey('story-step-$index'),
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 280),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.navy
                : AppColors.white.withValues(alpha: active ? .92 : .5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.navy
                  : AppColors.white.withValues(alpha: .65),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.navy,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductTheater extends StatelessWidget {
  const _ProductTheater({
    required this.story,
    required this.step,
    required this.reduceMotion,
    super.key,
  });

  final _ProductStep story;
  final int step;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColors.navy,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: AppColors.white.withValues(alpha: .22)),
      boxShadow: [
        BoxShadow(
          color: AppColors.navy.withValues(alpha: .28),
          blurRadius: 64,
          offset: const Offset(0, 28),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(29),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TheaterHeader(step: step),
          _CinematicFrame(story: story, reduceMotion: reduceMotion),
          _TheaterCaption(story: story, step: step),
        ],
      ),
    ),
  );
}

class _TheaterHeader extends StatelessWidget {
  const _TheaterHeader({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) => Container(
    height: 46,
    padding: const EdgeInsets.symmetric(horizontal: 18),
    decoration: BoxDecoration(
      color: AppColors.navyLight,
      border: Border(
        bottom: BorderSide(color: AppColors.white.withValues(alpha: .09)),
      ),
    ),
    child: Row(
      children: [
        const _WindowDot(color: AppColors.orange),
        const SizedBox(width: 7),
        const _WindowDot(color: AppColors.orangeLight),
        const SizedBox(width: 7),
        const _WindowDot(color: AppColors.blue),
        const Spacer(),
        Text(
          'JOYN · VISITE PRODUIT',
          style: TextStyle(
            color: AppColors.white.withValues(alpha: .68),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.25,
          ),
        ),
        const Spacer(),
        Text(
          '0${step + 1}',
          style: const TextStyle(
            color: AppColors.orangeLight,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _WindowDot extends StatelessWidget {
  const _WindowDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _CinematicFrame extends StatelessWidget {
  const _CinematicFrame({required this.story, required this.reduceMotion});

  final _ProductStep story;
  final bool reduceMotion;

  double _aspectRatioFor(double width) {
    if (width < 560) return 1.22;
    if (width < 760) return 1.32;
    if (width < 1040) return 1.58;
    if (width < 1400) return 1.68;
    return 1.74;
  }

  @override
  Widget build(BuildContext context) {
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 2900);

    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 620 ? 10 : 14),
      child: AspectRatio(
        aspectRatio: _aspectRatioFor(MediaQuery.sizeOf(context).width),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: AppColors.navyLight),
              TweenAnimationBuilder<double>(
                key: ValueKey('${story.asset}-${story.zoom}-${story.focus}'),
                tween: Tween(begin: 1, end: story.zoom),
                duration: duration,
                curve: Curves.easeInOutCubic,
                builder: (context, scale, child) => Transform.scale(
                  scale: scale,
                  alignment: story.focus,
                  child: child,
                ),
                child: Image.asset(
                  story.asset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              if (!reduceMotion)
                TweenAnimationBuilder<Alignment>(
                  key: ValueKey('cursor-${story.asset}-${story.cursor}'),
                  tween: Tween<Alignment>(
                    begin: const Alignment(-.8, .75),
                    end: story.cursor,
                  ),
                  duration: const Duration(milliseconds: 1350),
                  curve: Curves.easeOutCubic,
                  builder: (context, alignment, child) => Align(
                    alignment: alignment,
                    child: child,
                  ),
                  child: const _GuidedCursor(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidedCursor extends StatelessWidget {
  const _GuidedCursor();

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: AppColors.white.withValues(alpha: .94),
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.orange.withValues(alpha: .8), width: 2),
      boxShadow: [
        BoxShadow(
          color: AppColors.orange.withValues(alpha: .34),
          blurRadius: 18,
          spreadRadius: 2,
        ),
      ],
    ),
    child: const Icon(
      Icons.near_me_rounded,
      color: AppColors.orange,
      size: 19,
    ),
  );
}

class _TheaterCaption extends StatelessWidget {
  const _TheaterCaption({required this.story, required this.step});

  final _ProductStep story;
  final int step;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(
      MediaQuery.sizeOf(context).width < 620 ? 18 : 28,
      18,
      MediaQuery.sizeOf(context).width < 620 ? 18 : 24,
      22,
    ),
    decoration: BoxDecoration(
      color: AppColors.white,
      border: Border(
        top: BorderSide(color: AppColors.greyLight.withValues(alpha: .5)),
      ),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final number = Text(
          '0${step + 1}',
          style: const TextStyle(
            color: AppColors.orange,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        );
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              story.title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 19,
                height: 1.15,
                fontWeight: FontWeight.w900,
                letterSpacing: -.35,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              story.caption,
              style: const TextStyle(
                color: AppColors.blueGreyDark,
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ],
        );

        if (constraints.maxWidth < 700) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [number, const SizedBox(height: 10), copy],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 46, child: number),
            const SizedBox(width: 8),
            Expanded(child: copy),
          ],
        );
      },
    ),
  );
}

@immutable
class _ProductStep {
  const _ProductStep({
    required this.shortLabel,
    required this.title,
    required this.caption,
    required this.asset,
    required this.focus,
    required this.cursor,
    required this.zoom,
  });

  final String shortLabel;
  final String title;
  final String caption;
  final String asset;
  final Alignment focus;
  final Alignment cursor;
  final double zoom;
}
