import 'dart:async';

import 'package:flutter/material.dart';

import '../../design_system/tokens/app_colors.dart';
import '../landing/presentation/widgets/joyn_mark.dart';

/// Introduction native courte puis remplacement de la route par la connexion.
/// Le timer est annulé au démontage ; Retour ne rejoue donc pas l'introduction.
class MobileStartupScreen extends StatefulWidget {
  const MobileStartupScreen({super.key});

  @override
  State<MobileStartupScreen> createState() => _MobileStartupScreenState();
}

class _MobileStartupScreenState extends State<MobileStartupScreen> {
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer ??= Timer(
      MediaQuery.disableAnimationsOf(context)
        ? Duration.zero : const Duration(milliseconds: 1600),
      () {
        if (mounted) Navigator.pushReplacementNamed(context, '/connexion');
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.navy,
    body: Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: .75, end: 1),
        duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero : const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (_, value, child) => Opacity(
          opacity: ((value - .75) * 4).clamp(0.0, 1.0),
          child: Transform.scale(scale: value, child: child),
        ),
        child: const Semantics(
          label: 'JOYN, ouverture de la connexion',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              JoynMark(size: 90),
              SizedBox(height: 24),
              Text('joyn', style: TextStyle(color: AppColors.white,
                fontSize: 48, fontWeight: FontWeight.w800)),
              Text('Le match avant la candidature.',
                style: TextStyle(color: AppColors.blue, fontSize: 16)),
            ],
          ),
        ),
      ),
    ),
  );
}
