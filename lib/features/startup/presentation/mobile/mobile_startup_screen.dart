import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/core/theme/app_colors.dart';
import 'package:joyn_front/core/widgets/joyn_logo.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';

/// Intro native JOYN.
///
/// Cette scène est volontairement différente de la landing web : deux cartes
/// de profil se rapprochent, le match est confirmé, puis la marque prend le
/// relais avant l'ouverture de l'authentification.
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
      duration: const Duration(milliseconds: 2250),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (MediaQuery.disableAnimationsOf(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openNext());
      return;
    }

    _controller.forward();
    _navigationTimer = Timer(const Duration(milliseconds: 2550), _openNext);
  }

  void _openNext() {
    if (!mounted) return;
    final auth = context.read<AuthController>();
    context.go(auth.isAuthenticated ? AppRoutes.dashboard : AppRoutes.login);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.navy,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxHeight < 650 || constraints.maxWidth < 360;
              final tiny = constraints.maxWidth < 330;
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  final entrance = Curves.easeOutBack.transform(
                    (t / .34).clamp(0.0, 1.0).toDouble(),
                  );
                  final meet = Curves.easeInOutCubic.transform(
                    ((t - .16) / .34).clamp(0.0, 1.0).toDouble(),
                  );
                  final pulse = Curves.easeOutBack.transform(
                    ((t - .43) / .22).clamp(0.0, 1.0).toDouble(),
                  );
                  final brand = Curves.easeOutCubic.transform(
                    ((t - .58) / .24).clamp(0.0, 1.0).toDouble(),
                  );
                  final curtain = Curves.easeInCubic.transform(
                    ((t - .88) / .12).clamp(0.0, 1.0).toDouble(),
                  );

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      const _StartupBackground(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          tiny ? 16 : 24,
                          compact ? 22 : 40,
                          tiny ? 16 : 24,
                          compact ? 20 : 34,
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Opacity(
                                opacity: entrance.clamp(0.0, 1.0).toDouble(),
                                child: const Hero(
                                  tag: 'joyn-mobile-brand',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: JoynLogo(
                                      size: 34,
                                      showWordmark: true,
                                      wordmarkColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Semantics(
                              label: 'Animation de matching JOYN',
                              child: _MatchScene(
                                entrance: entrance,
                                meet: meet,
                                pulse: pulse,
                                compact: compact,
                              ),
                            ),
                            SizedBox(height: compact ? 20 : 34),
                            Transform.translate(
                              offset: Offset(0, 14 * (1 - brand)),
                              child: Opacity(
                                opacity: brand,
                                child: Column(
                                  children: [
                                    const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text.rich(
                                        TextSpan(
                                          text: 'joyn',
                                          children: [
                                            TextSpan(
                                              text: '.',
                                              style: TextStyle(
                                                color: AppColors.coral,
                                              ),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 46,
                                          height: .95,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -2.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Le match avant la candidature.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFFD7E6F1),
                                        fontSize: compact ? 13 : 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            Opacity(
                              opacity: brand,
                              child: const Text(
                                'Trouve. Matche. Échange.',
                                style: TextStyle(
                                  color: Color(0xFFAFC5D7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: .7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (curtain > 0)
                        IgnorePointer(
                          child: Opacity(
                            opacity: curtain,
                            child: const ColoredBox(
                              color: AppColors.background,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StartupBackground extends StatelessWidget {
  const _StartupBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF001A34), AppColors.navy, Color(0xFF052B52)],
            ),
          ),
        ),
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sky.withValues(alpha: .10),
            ),
          ),
        ),
        Positioned(
          left: -100,
          bottom: 40,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.coral.withValues(alpha: .10),
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchScene extends StatelessWidget {
  const _MatchScene({
    required this.entrance,
    required this.meet,
    required this.pulse,
    required this.compact,
  });

  final double entrance;
  final double meet;
  final double pulse;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 272.0 : 320.0;
    final height = compact ? 196.0 : 245.0;
    final cardWidth = compact ? 152.0 : 188.0;
    final cardHeight = compact ? 108.0 : 128.0;
    final x = compact ? 58.0 : 78.0;

    final leftOffset = Offset.lerp(
      Offset(-x, 18),
      Offset(compact ? -20 : -26, 4),
      meet,
    )!;
    final rightOffset = Offset.lerp(
      Offset(x, -12),
      Offset(compact ? 21 : 27, -6),
      meet,
    )!;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: leftOffset,
            child: Transform.rotate(
              angle: -.10 * (1 - meet),
              child: Opacity(
                opacity: entrance.clamp(0.0, 1.0).toDouble(),
                child: _ProfileCard(
                  width: cardWidth,
                  height: cardHeight,
                  accent: AppColors.sky,
                  icon: Icons.person_outline_rounded,
                  title: 'Alex Dupont',
                  subtitle: 'Développeur Full-Stack',
                  tag: 'Candidat',
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: rightOffset,
            child: Transform.rotate(
              angle: .10 * (1 - meet),
              child: Opacity(
                opacity: entrance.clamp(0.0, 1.0).toDouble(),
                child: _ProfileCard(
                  width: cardWidth,
                  height: cardHeight,
                  accent: AppColors.coral,
                  icon: Icons.apartment_rounded,
                  title: 'Nébula Pay',
                  subtitle: 'Alternance · Paris',
                  tag: 'Entreprise',
                ),
              ),
            ),
          ),
          if (pulse > 0)
            Transform.scale(
              scale: .76 + (.24 * pulse),
              child: Opacity(
                opacity: pulse.clamp(0.0, 1.0).toDouble(),
                child: Container(
                  width: compact ? 68 : 88,
                  height: compact ? 68 : 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.coral,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .78),
                      width: 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coral.withValues(alpha: .40),
                        blurRadius: 34,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 8,
            right: 14,
            child: Opacity(
              opacity: pulse.clamp(0.0, 1.0).toDouble(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '92 % MATCH',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .35,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.width,
    required this.height,
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  final double width;
  final double height;
  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(width < 170 ? 11 : 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .60)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .16),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: width < 170 ? 30 : 34,
                height: width < 170 ? 30 : 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: accent, size: width < 170 ? 18 : 20),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width < 170 ? 6 : 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: accent,
                    fontSize: width < 170 ? 8 : 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: width < 170 ? 13 : 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: width < 170 ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
