import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/landing_content.dart';
import '../widgets/audience_selector.dart';
import '../widgets/section_header.dart';

/// Deux audiences, quatre entrées chacune et un détail sélectionnable.
/// L'état reste local ; aucun service ni gestionnaire d'état supplémentaire.
class FeaturesSection extends StatefulWidget {
  const FeaturesSection({super.key});

  @override
  State<FeaturesSection> createState() => _FeaturesSectionState();
}

class _FeaturesSectionState extends State<FeaturesSection> {
  Audience _audience = Audience.candidate;
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final features = _audience == Audience.candidate
      ? candidateFeatures : companyFeatures;
    final feature = features[_selected];
    return ColoredBox(
      color: AppColors.white,
      child: ContentContainer(maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 96),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeader(eyebrow: 'Fonctionnalités',
              title: 'Tout ce qu’il faut pour\nfaire le bon match.',
              description: 'Un espace pour avancer, que tu cherches ta place '
                'ou que vous cherchiez votre prochain talent.'),
            const SizedBox(height: 32),
            Center(child: AudienceSelector(value: _audience,
              onChanged: (value) => setState(() {
                _audience = value;
                _selected = 0;
              }))),
            const SizedBox(height: 44),
            LayoutBuilder(builder: (context, constraints) {
              final selector = Column(children: [
                for (var index = 0; index < features.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: _selected == index
                        ? AppColors.blueGrey10 : AppColors.background,
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        key: ValueKey('feature-${_audience.name}-$index'),
                        selected: _selected == index,
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(features[index].icon),
                        title: Text(features[index].title,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(features[index].summary),
                        trailing: Text('0${index + 1}',
                          style: const TextStyle(color: AppColors.orange)),
                        onTap: () => setState(() => _selected = index),
                      ),
                    ),
                  ),
              ]);
              final detail = AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero : const Duration(milliseconds: 250),
                child: _FeatureDetail(
                  key: ValueKey('${_audience.name}-$_selected'), feature: feature),
              );
              if (constraints.maxWidth < 850) {
                return Column(children: [selector, const SizedBox(height: 24), detail]);
              }
              return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(flex: 5, child: selector), const SizedBox(width: 40),
                Expanded(flex: 6, child: detail),
              ]);
            }),
          ]),
        ),
      ),
    );
  }
}

class _FeatureDetail extends StatelessWidget {
  const _FeatureDetail({required this.feature, super.key});
  final LandingFeature feature;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 520 ? 24 : 40),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(begin: Alignment.topLeft,
        end: Alignment.bottomRight, colors: [AppColors.navy, AppColors.cyanBlue])),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(feature.icon, size: 42, color: AppColors.white),
      const SizedBox(height: 24),
      Text(feature.title, style: const TextStyle(color: AppColors.white,
        fontSize: 28, height: 1.15, fontWeight: FontWeight.w800)),
      const SizedBox(height: 20),
      Text(feature.detail, style: const TextStyle(color: AppColors.white,
        fontSize: 16, height: 1.65)),
      const SizedBox(height: 32),
      Card(child: Padding(padding: const EdgeInsets.all(24),
        child: Column(children: [
          for (var i = 0; i < feature.steps.length; i++)
            Padding(padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                CircleAvatar(radius: 15, backgroundColor: AppColors.blueGrey10,
                  child: Text('${i + 1}', style: const TextStyle(
                    color: AppColors.navy, fontSize: 13))),
                const SizedBox(width: 14),
                Expanded(child: Text(feature.steps[i],
                  style: const TextStyle(fontWeight: FontWeight.w600))),
                const Icon(Icons.check_circle_outline,
                  color: AppColors.orange, size: 20),
              ])),
        ]))),
    ]),
  );
}
