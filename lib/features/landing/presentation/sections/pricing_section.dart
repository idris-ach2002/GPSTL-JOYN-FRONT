import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/landing_content.dart';
import '../../domain/pricing_plan.dart';
import '../widgets/audience_selector.dart';
import '../widgets/scroll_atmosphere.dart';
import '../widgets/section_header.dart';

/// Cartes Figma dans un PageView Material : JOYN+ au centre à l'ouverture,
/// glissement, contrôles explicites et navigation au clavier contextualisée.
class PricingSection extends StatefulWidget {
  const PricingSection({this.scrollController, super.key});
  final ScrollController? scrollController;

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> {
  Audience _audience = Audience.candidate;

  @override
  Widget build(BuildContext context) {
    final plans = _audience == Audience.candidate
        ? candidatePlans
        : companyPlans;
    return ScrollAtmosphere(
      scrollController: widget.scrollController,
      child: ContentContainer(
        maxWidth: 1440,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 90),
          child: Column(
            children: [
              const SectionHeader(
                eyebrow: 'Tarifs',
                centered: true,
                title: 'Gratuit pour commencer.',
                description:
                    'L’essentiel pour démarrer. Plus de possibilités '
                    'quand tu en as besoin.',
              ),
              const SizedBox(height: 30),
              AudienceSelector(
                value: _audience,
                onChanged: (value) => setState(() => _audience = value),
              ),
              const SizedBox(height: 30),
              AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 320),
                child: LayoutBuilder(
                  key: ValueKey(_audience),
                  builder: (context, constraints) {
                    final fraction = constraints.maxWidth >= 1100
                        ? 1 / 3
                        : constraints.maxWidth >= 720
                        ? .56
                        : .94;
                    return _PlanCarousel(
                      key: ValueKey('${_audience.name}-$fraction'),
                      plans: plans,
                      fraction: fraction,
                      initialIndex: 1,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MovePlan extends Intent {
  const _MovePlan(this.direction);
  final int direction;
}

class _PlanCarousel extends StatefulWidget {
  const _PlanCarousel({
    required this.plans,
    required this.fraction,
    required this.initialIndex,
    super.key,
  });
  final List<PricingPlan> plans;
  final double fraction;
  final int initialIndex;

  @override
  State<_PlanCarousel> createState() => _PlanCarouselState();
}

class _PlanCarouselState extends State<_PlanCarousel> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
    viewportFraction: widget.fraction,
  );
  final _focus = FocusNode(debugLabel: 'Carrousel des formules');
  late int _index = widget.initialIndex;
  late final _measurementKeys = [for (final _ in widget.plans) GlobalKey()];
  double? _cardHeight;
  bool _measurementScheduled = false;

  /// Les cartes de mesure sont hors scène, sans focus ni Spacer. On lit leur
  /// hauteur naturelle réelle : aucune estimation de police ou de traduction.
  void _scheduleMeasurement() {
    if (_measurementScheduled) return;
    _measurementScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measurementScheduled = false;
      if (!mounted) return;
      final heights = _measurementKeys
          .map((key) => key.currentContext?.size?.height)
          .whereType<double>()
          .toList();
      if (heights.length != widget.plans.length) return;
      final height = heights.reduce(math.max).ceilToDouble();
      if (_cardHeight == null || (_cardHeight! - height).abs() > .5) {
        setState(() => _cardHeight = height);
      }
    });
  }

  void _move(int direction) {
    final target = (_index + direction)
        .clamp(0, widget.plans.length - 1)
        .toInt();
    _focus.requestFocus();
    if (target == _index) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(target);
    } else {
      _controller.animateToPage(
        target,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Shortcuts(
    shortcuts: const {
      SingleActivator(LogicalKeyboardKey.arrowLeft): _MovePlan(-1),
      SingleActivator(LogicalKeyboardKey.arrowRight): _MovePlan(1),
    },
    child: Actions(
      actions: {
        _MovePlan: CallbackAction<_MovePlan>(
          onInvoke: (intent) {
            _move(intent.direction);
            return null;
          },
        ),
      },
      child: Focus(
        focusNode: _focus,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    key: const ValueKey('pricing-previous'),
                    tooltip: 'Formule précédente',
                    onPressed: _index == 0 ? null : () => _move(-1),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 18),
                  Flexible(
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        'Formule ${_index + 1} sur ${widget.plans.length} · ${widget.plans[_index].name}',
                        key: const ValueKey('pricing-current'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  IconButton.filledTonal(
                    key: const ValueKey('pricing-next'),
                    tooltip: 'Formule suivante',
                    onPressed: _index == widget.plans.length - 1
                        ? null
                        : () => _move(1),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth * widget.fraction - 28;
                _scheduleMeasurement();
                return Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Offstage(
                        child: ExcludeFocus(
                          child: SizedBox(
                            width: width,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var i = 0; i < widget.plans.length; i++)
                                  _PlanCard(
                                    key: _measurementKeys[i],
                                    plan: widget.plans[i],
                                    natural: true,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_cardHeight == null)
                      const SizedBox(height: 746, width: double.infinity)
                    else
                      SizedBox(
                        height: _cardHeight! + 66,
                        child: PageView.builder(
                          key: const ValueKey('pricing-carousel'),
                          controller: _controller,
                          allowImplicitScrolling: true,
                          itemCount: widget.plans.length,
                          onPageChanged: (value) =>
                              setState(() => _index = value),
                          itemBuilder: (context, index) => AnimatedBuilder(
                            animation: _controller,
                            child: _PlanCard(plan: widget.plans[index]),
                            builder: (context, child) {
                              final page =
                                  _controller.hasClients &&
                                      _controller.position.hasContentDimensions
                                  ? _controller.page ??
                                        widget.initialIndex.toDouble()
                                  : widget.initialIndex.toDouble();
                              final distance = (page - index).abs().clamp(
                                0.0,
                                1.0,
                              );
                              final reduced = MediaQuery.disableAnimationsOf(
                                context,
                              );
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 24,
                                ),
                                child: Transform.translate(
                                  offset: Offset(
                                    0,
                                    reduced ? 0 : distance * 14,
                                  ),
                                  child: Transform.scale(
                                    scale: reduced ? 1 : 1 - distance * .045,
                                    alignment: Alignment.topCenter,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              children: [
                for (var i = 0; i < widget.plans.length; i++)
                  IconButton(
                    tooltip: 'Afficher ${widget.plans[i].name}',
                    onPressed: () => _move(i - _index),
                    icon: AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 220),
                      width: i == _index ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? AppColors.orange
                            : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(20),
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

List<String> _displayFeatures(PricingPlan plan) {
  if (plan.name == 'joyn+') {
    return plan.features
        .where((item) => !candidateBaseAccess.contains(item))
        .toList();
  }
  if (plan.name == 'Membre premium') {
    return plan.features
        .where((item) => !companyBaseAccess.contains(item))
        .toList();
  }
  return plan.features;
}

class _PlanCard extends StatefulWidget {
  const _PlanCard({required this.plan, this.natural = false, super.key});
  final bool natural;
  final PricingPlan plan;

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final foreground = plan.highlighted ? AppColors.white : AppColors.navy;
    final plus = plan.name == 'joyn+';
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 260);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: duration,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: plan.highlighted ? AppColors.navy : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _hover
                ? AppColors.orange
                : plan.highlighted
                ? AppColors.orange.withValues(alpha: .25)
                : AppColors.greyLight,
          ),
          boxShadow: [
            BoxShadow(
              color: (plan.highlighted ? AppColors.orange : AppColors.navy)
                  .withValues(
                    alpha: plan.highlighted
                        ? (_hover ? .38 : .24)
                        : (_hover ? .12 : .035),
                  ),
              blurRadius: _hover ? 42 : 28,
              spreadRadius: plan.highlighted ? 3 : 0,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: widget.natural ? MainAxisSize.min : MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 14,
              runSpacing: 14,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: plus ? 'joyn' : plan.name),
                      if (plus)
                        const TextSpan(
                          text: '+',
                          style: TextStyle(color: AppColors.orange),
                        ),
                    ],
                  ),
                  style: TextStyle(
                    color: foreground,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (plan.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withValues(alpha: .25),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Text(
                      plan.badge!,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              plan.subtitle,
              style: TextStyle(
                color: foreground.withValues(alpha: .8),
                height: 1.5,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 34),
            Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Text(
                  plan.price,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    plan.period,
                    style: TextStyle(color: foreground, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              plus
                  ? 'Sans engagement, annulable en un clic.'
                  : plan.name == 'Boost 48 h'
                  ? 'Paiement unique, quand tu en as besoin.'
                  : plan.price == '0 €'
                  ? 'Gratuit, sans limite de durée.'
                  : 'Une formule adaptée à vos besoins de recrutement.',
              style: TextStyle(
                color: foreground.withValues(alpha: .78),
                height: 1.5,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 22),
            Divider(color: foreground.withValues(alpha: .12)),
            const SizedBox(height: 20),
            Text(
              plan.highlighted
                  ? 'Tout ${plus ? 'JOYN' : 'Membre'}, plus :'
                  : 'INCLUS',
              style: TextStyle(
                color: plan.highlighted ? AppColors.orange : AppColors.cyanBlue,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            for (final feature in _displayFeatures(plan))
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: plan.highlighted
                          ? AppColors.orange
                          : AppColors.cyanBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (plan.name == 'Boost 48 h') const _BoostPreview(),
            if (!widget.natural) const Spacer(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.push('/inscription'),
                style: FilledButton.styleFrom(
                  backgroundColor: plan.highlighted
                      ? AppColors.orange
                      : AppColors.navy,
                  foregroundColor: AppColors.white,
                ),
                child: Text(plan.action, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Petite scène de mise en avant de la maquette, sans statistique réelle.
class _BoostPreview extends StatelessWidget {
  const _BoostPreview();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CÔTÉ RECRUTEURS · APERÇU',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColors.blueGreyDark,
          ),
        ),
        const SizedBox(height: 10),
        for (final (i, name) in ['Ton profil', 'Hugo L.', 'Nora B.'].indexed)
          Container(
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: i == 0 ? Border.all(color: AppColors.orange) : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 18,
                  color: i == 0 ? AppColors.orange : AppColors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (i == 0)
                  const Text(
                    'Boost',
                    style: TextStyle(fontSize: 10, color: AppColors.orange),
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}
