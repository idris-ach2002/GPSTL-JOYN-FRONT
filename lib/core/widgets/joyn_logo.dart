import 'package:flutter/material.dart';
import '../../design_system/components/joyn_logo.dart' as brand;
import '../theme/app_colors.dart';

/// The same JOYN logo is used in the candidate and recruiter experiences.
class JoynLogo extends StatelessWidget {
  const JoynLogo({super.key, this.size = 36,
    this.showWordmark = true, this.wordmarkColor = AppColors.ink});
  final double size;
  final bool showWordmark;
  final Color wordmarkColor;

  @override
  Widget build(BuildContext context) => brand.JoynLogo(
    markSize: size, onDark: wordmarkColor == Colors.white, showWordmark: showWordmark,
  );
}
