import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/landing_content.dart';
import '../../domain/pricing_plan.dart';
import '../widgets/audience_selector.dart';
import '../widgets/section_header.dart';

/// Même hiérarchie que Figma : cartes claires, formule centrale bleu nuit,
/// accent orange et bascule d'audience. Le contenu est séparé du rendu.
class PricingSection extends StatefulWidget {
  const PricingSection({super.key});

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> {
  Audience _audience = Audience.candidate;

  @override
  Widget build(BuildContext context) {
    final plans = _audience == Audience.candidate ? candidatePlans : companyPlans;
    return ColoredBox(
      color: AppColors.background,
      child: ContentContainer(maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 96),
          child: Column(children: [
            const SectionHeader(eyebrow: 'Tarifs', centered: true,
              title: 'Gratuit pour commencer.',
              description: 'L’essentiel pour démarrer. Plus de possibilités '
                'quand tu en as besoin.'),
            const SizedBox(height: 30),
            AudienceSelector(value: _audience,
              onChanged: (value) => setState(() => _audience = value)),
            const SizedBox(height: 48),
            AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero : const Duration(milliseconds: 280),
              child: LayoutBuilder(key: ValueKey(_audience),
                builder: (context, constraints) {
                  if (constraints.maxWidth < 900) {
                    return Column(children: [
                      for (final plan in plans)
                        Padding(padding: const EdgeInsets.only(bottom: 20),
                          child: _PlanCard(plan: plan)),
                    ]);
                  }
                  return Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < plans.length; i++) ...[
                        if (i != 0) const SizedBox(width: 20),
                        Expanded(child: Padding(
                          padding: EdgeInsets.only(top: plans[i].highlighted ? 0 : 18),
                          child: _PlanCard(plan: plans[i]))),
                      ],
                    ]);
                }),
            ),
            const SizedBox(height: 24),
            const Text('Offres proposées : tarifs, essais et limites à confirmer avant ouverture.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.blueGreyDark, fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});
  final PricingPlan plan;

  @override
  Widget build(BuildContext context) {
    final foreground = plan.highlighted ? AppColors.white : AppColors.navy;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 540),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: plan.highlighted ? AppColors.navy : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: plan.highlighted
          ? AppColors.orange.withValues(alpha: .3) : AppColors.greyLight),
        boxShadow: [BoxShadow(
          color: (plan.highlighted ? AppColors.orange : AppColors.navy)
            .withValues(alpha: plan.highlighted ? .22 : .06),
          blurRadius: plan.highlighted ? 32 : 18,
          offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 12, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(plan.name, style: TextStyle(color: foreground, fontSize: 25,
              fontWeight: FontWeight.w800)),
            if (plan.badge != null) Chip(
              backgroundColor: AppColors.orange,
              side: BorderSide.none,
              label: Text(plan.badge!, style: const TextStyle(
                color: AppColors.white, fontSize: 11))),
          ]),
        const SizedBox(height: 18),
        Text(plan.subtitle, style: TextStyle(color: foreground,
          height: 1.5, fontSize: 14)),
        const SizedBox(height: 28),
        Text(plan.price, style: TextStyle(color: foreground,
          fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1.2)),
        Text(plan.period, style: TextStyle(color: foreground, fontSize: 13)),
        const SizedBox(height: 28),
        for (final feature in plan.features)
          Padding(padding: const EdgeInsets.only(bottom: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.check_circle_outline, color: plan.highlighted
                ? AppColors.orange : AppColors.cyanBlue, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(feature, style: TextStyle(color: foreground,
                fontSize: 13, height: 1.45))),
            ])),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pushNamed(context, '/inscription'),
            style: FilledButton.styleFrom(backgroundColor: plan.highlighted
              ? AppColors.orange : AppColors.navy, foregroundColor: AppColors.white),
            child: Text(plan.action, textAlign: TextAlign.center),
          )),
      ]),
    );
  }
}
