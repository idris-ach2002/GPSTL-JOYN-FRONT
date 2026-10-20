import 'package:flutter/material.dart';

import '../navigation/landing_section.dart';
import '../sections/companies_section.dart';
import '../sections/constat_section.dart';
import '../sections/features_section.dart';
import '../sections/footer_section.dart';
import '../sections/hero_section.dart';
import '../sections/pricing_section.dart';
import '../sections/universe_section.dart';

/// Assemblage web uniquement. Aucune dépendance vers le parcours natif.
///
/// Les ancres restent montées afin que ensureVisible fonctionne même pour une
/// destination éloignée. Le contrôleur appartient à l'écran et est libéré ici.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scrollController = ScrollController();
  final _keys = {
    for (final section in LandingSection.values) section: GlobalKey(),
  };

  void _navigate(LandingSection section) {
    final destination = _keys[section]?.currentContext;
    if (destination == null) return;
    Scrollable.ensureVisible(
      destination,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SelectionArea(
      child: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              HeroSection(
                key: _keys[LandingSection.hero],
                onNavigate: _navigate,
              ),
              const ConstatSection(),
              FeaturesSection(key: _keys[LandingSection.features]),
              CompaniesSection(key: _keys[LandingSection.companies]),
              UniverseSection(scrollController: _scrollController),
              PricingSection(
                key: _keys[LandingSection.pricing],
                scrollController: _scrollController,
              ),
              FooterSection(
                onNavigate: _navigate,
                scrollController: _scrollController,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
