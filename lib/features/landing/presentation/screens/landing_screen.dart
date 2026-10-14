import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../navigation/landing_section.dart';
import '../sections/companies_section.dart';
import '../sections/features_section.dart';
import '../sections/final_cta_section.dart';
import '../sections/footer_section.dart';
import '../sections/hero_section.dart';
import '../sections/how_it_works_section.dart';
import '../sections/matching_demo_section.dart';
import '../sections/mobile_section.dart';
import '../sections/opportunities_section.dart';
import '../sections/pricing_section.dart';
import '../sections/problem_section.dart';
import '../sections/testimonials_section.dart';
import '../sections/trusted_section.dart';
import '../widgets/landing_motion.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final Map<LandingSection, GlobalKey> _sectionKeys = {
    LandingSection.hero: GlobalKey(),
    LandingSection.opportunities: GlobalKey(),
    LandingSection.howItWorks: GlobalKey(),
    LandingSection.features: GlobalKey(),
    LandingSection.companies: GlobalKey(),
    LandingSection.testimonials: GlobalKey(),
  };

  Future<void> _navigateTo(LandingSection section) async {
    final targetContext = _sectionKeys[section]?.currentContext;
    if (targetContext == null) return;

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 760),
      curve: Curves.easeInOutCubic,
      alignment: .02,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'JOYN — Trouve ton alternance autrement',
      color: AppColors.navy,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              HeroSection(
                key: _sectionKeys[LandingSection.hero],
                onNavigate: _navigateTo,
              ),
              const TrustedSection(),
              const ProblemSection(),
              OpportunitiesSection(
                key: _sectionKeys[LandingSection.opportunities],
              ),
              HowItWorksSection(key: _sectionKeys[LandingSection.howItWorks]),
              FeaturesSection(key: _sectionKeys[LandingSection.features]),
              const MobileSection(),
              const UniverseTransition(
                from: AppColors.white,
                to: Color(0xFF061F34),
                label: 'CHANGEMENT D’UNIVERS · CÔTÉ ENTREPRISE',
              ),
              CompaniesSection(key: _sectionKeys[LandingSection.companies]),
              const UniverseTransition(
                from: Color(0xFF061F34),
                to: Color(0xFFFF7446),
                label: 'LE MATCHING, EN VRAI',
                height: 170,
              ),
              const MatchingDemoSection(),
              const UniverseTransition(
                from: Color(0xFFFF7446),
                to: Color(0xFFF2F6F9),
                label: 'ILS RACONTENT JOYN',
              ),
              TestimonialsSection(
                key: _sectionKeys[LandingSection.testimonials],
              ),
              const PricingSection(),
              FinalCtaSection(
                onCandidate: () => _navigateTo(LandingSection.opportunities),
                onCompany: () => _navigateTo(LandingSection.companies),
              ),
              const FooterSection(),
            ],
          ),
        ),
      ),
    );
  }
}
