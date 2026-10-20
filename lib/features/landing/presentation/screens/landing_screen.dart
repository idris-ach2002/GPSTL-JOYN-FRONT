import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../navigation/landing_section.dart';
import '../sections/companies_section.dart';
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
  final _keys = {for (final section in LandingSection.values) section: GlobalKey()};

  void _navigate(LandingSection section) {
    final destination = _keys[section]?.currentContext;
    if (destination == null) return;
    Scrollable.ensureVisible(destination,
      duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero : const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SelectionArea(child: Scrollbar(controller: _scrollController,
      child: SingleChildScrollView(controller: _scrollController,
        child: Column(children: [
          HeroSection(key: _keys[LandingSection.hero], onNavigate: _navigate),
          FeaturesSection(key: _keys[LandingSection.features]),
          CompaniesSection(key: _keys[LandingSection.companies]),
          const UniverseSection(),
          PricingSection(key: _keys[LandingSection.pricing]),
          _AssistanceSection(key: _keys[LandingSection.assistance]),
          FooterSection(onNavigate: _navigate),
        ]),
      ),
    )),
  );
}

/// Aide locale et factuelle ; aucun lien vers des guides non fournis.
class _AssistanceSection extends StatelessWidget {
  const _AssistanceSection({super.key});

  @override
  Widget build(BuildContext context) => ContentContainer(maxWidth: 1000,
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Questions fréquentes', style: Theme.of(context).textTheme.headlineMedium
          ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 24),
        const ExpansionTile(title: Text('À qui s’adresse JOYN ?'),
          childrenPadding: EdgeInsets.all(16),
          children: [Text('JOYN réunit les candidats à une alternance et les '
            'entreprises qui souhaitent recruter.')]),
        const ExpansionTile(title: Text('Le Boost remplace-t-il JOYN+ ?'),
          childrenPadding: EdgeInsets.all(16),
          children: [Text('Le Boost proposé est un complément ponctuel de visibilité. '
            'Il ne remplace pas la formule du compte.')]),
        const ExpansionTile(title: Text('Où retrouver mon espace ?'),
          childrenPadding: EdgeInsets.all(16),
          children: [Text('Les boutons Connexion et Inscription ouvrent les '
            'écrans d’accès. Leur service d’authentification reste à intégrer.')]),
      ])),
  );
}
