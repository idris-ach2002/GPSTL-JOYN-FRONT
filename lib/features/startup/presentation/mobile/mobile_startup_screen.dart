import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../auth/presentation/auth_controller.dart';

/// Splash natif JOYN inspiré du rythme d'une vraie application mobile :
/// illustration centrale, révélation de marque, puis ouverture de la session.
class MobileStartupScreen extends StatefulWidget {
  const MobileStartupScreen({super.key});

  @override
  State<MobileStartupScreen> createState() => _MobileStartupScreenState();
}

class _MobileStartupScreenState extends State<MobileStartupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6200),
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
    _timer = Timer(const Duration(milliseconds: 6400), _openNext);
  }

  void _openNext() {
    if (!mounted) return;
    final auth = context.read<AuthController>();
    context.go(auth.isAuthenticated ? AppRoutes.dashboard : AppRoutes.login);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileAppSurface(
      systemUiOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: const Color(0xFFF7F8F2),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final scene = Curves.easeOutBack.transform(
            (t / .22).clamp(0.0, 1.0).toDouble(),
          );
          final connect = Curves.easeInOutCubic.transform(
            ((t - .16) / .40).clamp(0.0, 1.0).toDouble(),
          );
          final brand = Curves.easeOutCubic.transform(
            ((t - .58) / .24).clamp(0.0, 1.0).toDouble(),
          );
          final exit = Curves.easeInCubic.transform(
            ((t - .88) / .12).clamp(0.0, 1.0).toDouble(),
          );

          return Opacity(
            opacity: 1 - exit,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 620;
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    28,
                    compact ? 28 : 48,
                    28,
                    compact ? 30 : 48,
                  ),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: MobileBrandMark(compact: true),
                      ),
                      const Spacer(),
                      Transform.scale(
                        scale: .82 + (.18 * scene),
                        child: Opacity(
                          opacity: scene.clamp(0.0, 1.0).toDouble(),
                          child: _StartupIllustration(progress: connect),
                        ),
                      ),
                      SizedBox(height: compact ? 28 : 40),
                      Transform.translate(
                        offset: Offset(0, 16 * (1 - brand)),
                        child: Opacity(
                          opacity: brand,
                          child: const Column(
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: 'joyn',
                                  children: [
                                    TextSpan(
                                      text: '.',
                                      style: TextStyle(color: AppColors.orange),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 48,
                                  height: .95,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -2.5,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Le match avant la candidature.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.slate,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
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
                          'Trouve · Matche · Échange',
                          style: TextStyle(
                            color: AppColors.placeholder,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StartupIllustration extends StatelessWidget {
  const _StartupIllustration({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final sceneWidth = (width - 56).clamp(240.0, 340.0).toDouble();
    final pull = 44 * (1 - progress);

    return SizedBox(
      width: sceneWidth,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 4,
            left: 14 + pull,
            child: Transform.rotate(angle: -.07, child: const _ProfileCard()),
          ),
          Positioned(
            right: 8 + pull,
            bottom: 16,
            child: Transform.rotate(angle: .06, child: const _OfferCard()),
          ),
          Positioned.fill(
            child: CustomPaint(painter: _ConnectionPainter(progress: progress)),
          ),
          Transform.scale(
            scale: .65 + (.35 * progress),
            child: Opacity(
              opacity: progress,
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: .28),
                      blurRadius: 28,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 31,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Opacity(
              opacity: progress,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '92 % · MATCH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
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
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 146,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x17001E3B),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFE6F3FF),
            child: Icon(Icons.person_rounded, color: AppColors.navy),
          ),
          SizedBox(height: 12),
          Text(
            'Alex',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'React · Node.js',
            style: TextStyle(
              color: AppColors.slate,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22001E3B),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.orange,
                child: Icon(
                  Icons.business_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Nébula Pay',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Développeur·se\nFull-Stack',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Paris · Alternance',
            style: TextStyle(
              color: Color(0xFFBDD2E3),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionPainter extends CustomPainter {
  const _ConnectionPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.orange.withValues(alpha: .7 * progress)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final start = Offset(size.width * .42, size.height * .38);
    final end = Offset(size.width * .62, size.height * .61);
    final current = Offset.lerp(start, end, progress)!;
    canvas.drawLine(start, current, paint);
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
