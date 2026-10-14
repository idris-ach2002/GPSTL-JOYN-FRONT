import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../widgets/landing_motion.dart';
import '../widgets/section_header.dart';

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  final PageController _mobileController = PageController(viewportFraction: .9);
  int _page = 0;

  static const _quotes = [
    _QuoteData(
      initials: 'YK',
      name: 'Yalderim kem',
      role: 'M1 informatique · alternante développeuse chez Nxt Pay',
      tag: 'MATCH',
      quote: 'J’envoyais des dizaines de CV sans réponse. Sur JOYN, je ne voyais que des offres compatibles avec mon rythme, et c’est Nébula Pay qui m’a écrit en premier.',
    ),
    _QuoteData(
      initials: 'AB',
      name: 'Ariel Benatsi',
      role: 'M1 informatique · alternante développeuse',
      tag: 'SKILL GAP',
      quote: 'Le Skill Gap m’a montré qu’il me manquait Docker. Deux week-ends de mini-projet plus tard, il était sur mon CV, et j’en ai parlé en entretien.',
    ),
    _QuoteData(
      initials: 'AB',
      name: 'Ariel Benatsi',
      role: 'M1 informatique · alternante développeuse',
      tag: 'REMPLACE-MOI',
      quote: 'Une alternante en fin de contrat avait signalé son poste avec Remplace-moi. J’ai postulé avant même la publication de l’offre.',
    ),
  ];

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF2F6F9),
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                eyebrow: 'Témoignages',
                title: 'Ils ont trouvé leur alternance sur JOYN.',
                description: 'Des retours qui racontent le produit mieux qu’une liste de fonctionnalités : moins de bruit, plus de contexte et des échanges au bon moment.',
              ),
              const SizedBox(height: 54),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 760) {
                    return Column(
                      children: [
                        SizedBox(
                          height: constraints.maxWidth < 420 ? 440 : 420,
                          child: PageView.builder(
                            controller: _mobileController,
                            onPageChanged: (value) =>
                                setState(() => _page = value),
                            itemCount: _quotes.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                              ),
                              child: _QuoteCard(
                                data: _quotes[index],
                                featured: index == 0,
                                compact: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < _quotes.length; i++)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                width: i == _page ? 24 : 7,
                                height: 7,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: i == _page
                                      ? AppColors.orange
                                      : const Color(0xFFD5E0E8),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: LandingReveal(
                          child: _QuoteCard(data: _quotes[0], featured: true),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            LandingReveal(
                              delay: const Duration(milliseconds: 100),
                              offset: const Offset(24, 0),
                              child: _QuoteCard(
                                data: _quotes[1],
                                compact: true,
                              ),
                            ),
                            const SizedBox(height: 18),
                            LandingReveal(
                              delay: const Duration(milliseconds: 180),
                              offset: const Offset(24, 0),
                              child: _QuoteCard(
                                data: _quotes[2],
                                compact: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuoteData {
  const _QuoteData({
    required this.initials,
    required this.name,
    required this.role,
    required this.tag,
    required this.quote,
  });
  final String initials;
  final String name;
  final String role;
  final String tag;
  final String quote;
}

class _QuoteCard extends StatefulWidget {
  const _QuoteCard({
    required this.data,
    this.featured = false,
    this.compact = false,
  });
  final _QuoteData data;
  final bool featured;
  final bool compact;

  @override
  State<_QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<_QuoteCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final dark = widget.featured;
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: hovered ? 1.01 : 1,
        child: Container(
          constraints: BoxConstraints(minHeight: widget.compact ? 182 : 370),
          padding: EdgeInsets.all(widget.compact ? 20 : 32),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF0F304F) : AppColors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: dark
                  ? AppColors.cyanBlue.withValues(alpha: .5)
                  : const Color(0xFFE2E9EF),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: hovered ? .12 : .06),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '“',
                    style: TextStyle(
                      color: dark ? AppColors.orangeLight : AppColors.orange,
                      fontSize: 42,
                      height: .7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: dark
                          ? AppColors.white.withValues(alpha: .08)
                          : const Color(0xFFF3F7F9),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      widget.data.tag,
                      style: TextStyle(
                        color: dark
                            ? AppColors.white.withValues(alpha: .68)
                            : AppColors.grey,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: widget.compact ? 14 : 28),
              Text(
                widget.data.quote,
                style: TextStyle(
                  color: dark ? AppColors.white : const Color(0xFF5D7287),
                  fontSize: widget.compact ? 15 : 25,
                  height: 1.25,
                  fontWeight: dark ? FontWeight.w800 : FontWeight.w500,
                  letterSpacing: dark ? -.6 : -.2,
                ),
              ),
              SizedBox(height: widget.compact ? 14 : 30),
              Row(
                children: [
                  CircleAvatar(
                    radius: widget.compact ? 20 : 27,
                    backgroundColor: dark
                        ? const Color(0xFF68AEE1)
                        : const Color(0xFFFFD487),
                    foregroundColor: dark ? AppColors.white : AppColors.navy,
                    child: Text(
                      widget.data.initials,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.name,
                          style: TextStyle(
                            color: dark ? AppColors.white : AppColors.navy,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          widget.data.role,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: dark
                                ? AppColors.white.withValues(alpha: .5)
                                : AppColors.grey,
                            fontSize: 9,
                            height: 1.35,
                          ),
                        ),
                      ],
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
