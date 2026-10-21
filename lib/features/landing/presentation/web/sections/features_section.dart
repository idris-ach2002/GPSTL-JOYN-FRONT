import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/layout/content_container.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/landing/domain/landing_content.dart';
import 'package:joyn_front/features/landing/presentation/widgets/audience_selector.dart';
import 'package:joyn_front/features/landing/presentation/widgets/feature_demo.dart';
import 'package:joyn_front/features/landing/presentation/widgets/section_header.dart';

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
        ? candidateFeatures
        : companyFeatures;
    final feature = features[_selected];
    return ColoredBox(
      color: AppColors.white,
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                eyebrow: 'Fonctionnalités',
                title: 'Tout ce qu’il faut pour\nfaire le bon match.',
                description:
                    'Un espace pour avancer, que tu cherches ta place '
                    'ou que vous cherchiez votre prochain talent.',
              ),
              const SizedBox(height: 32),
              Center(
                child: AudienceSelector(
                  value: _audience,
                  onChanged: (value) => setState(() {
                    _audience = value;
                    _selected = 0;
                  }),
                ),
              ),
              const SizedBox(height: 44),
              LayoutBuilder(
                builder: (context, constraints) {
                  final selector = Column(
                    children: [
                      for (var index = 0; index < features.length; index++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: _selected == index
                                ? AppColors.blueGrey10
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(18),
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              key: ValueKey('feature-${_audience.name}-$index'),
                              selected: _selected == index,
                              contentPadding: const EdgeInsets.all(16),
                              leading: Icon(features[index].icon),
                              title: Text(
                                features[index].title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(features[index].summary),
                              trailing: Text(
                                '0${index + 1}',
                                style: const TextStyle(color: AppColors.orange),
                              ),
                              onTap: () => setState(() => _selected = index),
                            ),
                          ),
                        ),
                    ],
                  );
                  final detail = AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 250),
                    child: _FeatureDetail(
                      key: ValueKey('${_audience.name}-$_selected'),
                      feature: feature,
                      audience: _audience,
                      index: _selected,
                    ),
                  );
                  if (constraints.maxWidth < 850) {
                    return Column(
                      children: [selector, const SizedBox(height: 24), detail],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 5, child: selector),
                      const SizedBox(width: 40),
                      Expanded(flex: 6, child: detail),
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

/// Écrin du laboratoire : description courte et démonstration manipulable.
class _FeatureDetail extends StatelessWidget {
  const _FeatureDetail({
    required this.feature,
    required this.audience,
    required this.index,
    super.key,
  });
  final LandingFeature feature;
  final Audience audience;
  final int index;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 520 ? 16 : 30),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.navy, AppColors.navyLight, AppColors.cyanBlue],
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.blue.withValues(alpha: .14),
          blurRadius: 44,
          offset: const Offset(0, 20),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(feature.icon, color: AppColors.orange, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature.title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          feature.detail,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 26),
        FeatureDemo(audience: audience, index: index),
      ],
    ),
  );
}
