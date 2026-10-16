import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../widgets/joyn_mark.dart';
import '../widgets/landing_motion.dart';

class FinalCtaSection extends StatefulWidget {
  const FinalCtaSection({
    required this.onCandidate,
    required this.onCompany,
    super.key,
  });

  final VoidCallback onCandidate;
  final VoidCallback onCompany;

  @override
  State<FinalCtaSection> createState() => _FinalCtaSectionState();
}

class _FinalCtaSectionState extends State<FinalCtaSection> {
  int hovered = 0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 96),
          child: LandingReveal(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFF061F34),
                borderRadius: BorderRadius.circular(32),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 760;
                  if (stacked) {
                    return _MobileCta(
                      onCandidate: widget.onCandidate,
                      onCompany: widget.onCompany,
                    );
                  }

                  return SizedBox(
                    height: 470,
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: hovered == 1
                                  ? 12
                                  : hovered == 2
                                  ? 8
                                  : 10,
                              child: _CtaWorld(
                                candidate: true,
                                active: hovered == 1,
                                onEnter: () => setState(() => hovered = 1),
                                onExit: () => setState(() => hovered = 0),
                                onTap: widget.onCandidate,
                              ),
                            ),
                            Expanded(
                              flex: hovered == 2
                                  ? 12
                                  : hovered == 1
                                  ? 8
                                  : 10,
                              child: _CtaWorld(
                                candidate: false,
                                active: hovered == 2,
                                onEnter: () => setState(() => hovered = 2),
                                onExit: () => setState(() => hovered = 0),
                                onTap: widget.onCompany,
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: IgnorePointer(
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 260),
                              scale: hovered == 0 ? 1 : .92,
                              child: Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.orange.withValues(
                                      alpha: .28,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.orange.withValues(
                                        alpha: .28,
                                      ),
                                      blurRadius: 42,
                                    ),
                                  ],
                                ),
                                child: const Center(child: JoynMark(size: 66)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CtaWorld extends StatelessWidget {
  const _CtaWorld({
    required this.candidate,
    required this.active,
    required this.onEnter,
    required this.onExit,
    required this.onTap,
  });

  final bool candidate;
  final bool active;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = candidate
        ? 'Je cherche ma prochaine opportunité.'
        : 'Je cherche mon prochain talent.';
    final label = candidate
        ? 'Explorer les opportunités'
        : 'Découvrir le recrutement';
    final icon = candidate
        ? Icons.person_search_outlined
        : Icons.domain_outlined;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.fromLTRB(
            candidate ? 42 : 88,
            58,
            candidate ? 88 : 42,
            48,
          ),
          decoration: BoxDecoration(
            gradient: candidate
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        const Color(0xFF0C5A7E),
                        const Color(0xFF14749B),
                        active ? 1 : 0,
                      )!,
                      const Color(0xFF062A43),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0B2A43),
                      Color.lerp(
                        const Color(0xFF061F34),
                        const Color(0xFF123A58),
                        active ? 1 : 0,
                      )!,
                    ],
                  ),
          ),
          child: Column(
            crossAxisAlignment: candidate
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.orangeLight, size: 30),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: candidate ? TextAlign.left : TextAlign.right,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 30,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.9,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.orange
                      : AppColors.white.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: .10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileCta extends StatelessWidget {
  const _MobileCta({required this.onCandidate, required this.onCompany});

  final VoidCallback onCandidate;
  final VoidCallback onCompany;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(26),
      child: Column(
        children: [
          const JoynMark(size: 72),
          const SizedBox(height: 22),
          const Text(
            'Deux chemins. Un même match.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 34,
              height: 1.04,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCandidate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 17),
              ),
              icon: const Icon(Icons.person_search_outlined, size: 18),
              label: const Text('Je cherche une opportunité'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCompany,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                side: BorderSide(color: AppColors.white.withValues(alpha: .18)),
                padding: const EdgeInsets.symmetric(vertical: 17),
              ),
              icon: const Icon(Icons.domain_outlined, size: 18),
              label: const Text('Je recrute'),
            ),
          ),
        ],
      ),
    );
  }
}
