import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routing/app_routes.dart';
import '../../design_system/tokens/app_colors.dart';
import '../auth/presentation/auth_controller.dart';
import '../landing/presentation/widgets/joyn_mark.dart';

/// Intro native JOYN : une courte animation de marque précède l'accès au
/// compte. La landing marketing reste réservée au web.
class MobileStartupScreen extends StatefulWidget {
  const MobileStartupScreen({super.key});

  @override
  State<MobileStartupScreen> createState() => _MobileStartupScreenState();
}

class _MobileStartupScreenState extends State<MobileStartupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _navigationTimer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openNext());
      return;
    }

    _controller.forward();
    _navigationTimer = Timer(
      const Duration(milliseconds: 2450),
      _openNext,
    );
  }

  void _openNext() {
    if (!mounted) return;
    final auth = context.read<AuthController>();
    context.go(
      auth.isAuthenticated ? AppRoutes.dashboard : AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final value = _controller.value;
              final meet = Curves.easeInOutCubic.transform(
                (value / .48).clamp(0.0, 1.0).toDouble(),
              );
              final reveal = Curves.easeOutCubic.transform(
                ((value - .34) / .28).clamp(0.0, 1.0).toDouble(),
              );
              final copy = Curves.easeOutCubic.transform(
                ((value - .58) / .28).clamp(0.0, 1.0).toDouble(),
              );

              return Semantics(
                label: 'JOYN, ouverture de la connexion',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 210,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _OrbitNode(
                              progress: meet,
                              from: const Offset(-76, 18),
                              angle: -math.pi / 10,
                            ),
                            _OrbitNode(
                              progress: meet,
                              from: const Offset(76, -18),
                              angle: math.pi / 10,
                              secondary: true,
                            ),
                            Opacity(
                              opacity: reveal,
                              child: Transform.scale(
                                scale: .78 + (.22 * reveal),
                                child: const JoynMark(size: 104),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Transform.translate(
                        offset: Offset(0, 14 * (1 - copy)),
                        child: Opacity(
                          opacity: copy,
                          child: const Column(
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: 'joyn',
                                  children: [
                                    TextSpan(
                                      text: '.',
                                      style: TextStyle(
                                        color: AppColors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 46,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.8,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Le match avant la candidature.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.blueGreyDark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrbitNode extends StatelessWidget {
  const _OrbitNode({
    required this.progress,
    required this.from,
    required this.angle,
    this.secondary = false,
  });

  final double progress;
  final Offset from;
  final double angle;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final offset = Offset.lerp(from, Offset.zero, progress)!;
    final opacity = (1 -
            ((progress - .72) / .28).clamp(0.0, 1.0).toDouble())
        .clamp(0.0, 1.0)
        .toDouble();

    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: angle * (1 - progress),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: secondary ? AppColors.blueGrey10 : AppColors.grey08,
              border: Border.all(
                color: secondary ? AppColors.blue : AppColors.orange,
                width: 2,
              ),
            ),
            child: Icon(
              secondary
                  ? Icons.apartment_rounded
                  : Icons.person_outline_rounded,
              color: secondary ? AppColors.blue : AppColors.orange,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
