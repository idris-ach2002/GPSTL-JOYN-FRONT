import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../sections/hero_section.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(child: Column(children: [HeroSection()])),
    );
  }
}
