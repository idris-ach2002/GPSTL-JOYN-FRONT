import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import 'person_portrait.dart';
import 'product_atmosphere.dart';

/// One signature: the line joins both profiles when reciprocal interest is on.
class MatchSignature extends StatefulWidget {
  const MatchSignature({super.key});
  @override
  State<MatchSignature> createState() => _MatchSignatureState();
}

class _MatchSignatureState extends State<MatchSignature> {
  bool connected = false;
  @override
  Widget build(BuildContext context) => ProductSurface(
    dark: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'DEUX PARCOURS. UN POINT COMMUN.',
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: JoynTokens.paper),
              ),
            ),
            const SizedBox(width: JoynTokens.xs),
            Container(
              width: JoynTokens.xs,
              height: JoynTokens.xs,
              color: JoynTokens.orange,
            ),
          ],
        ),
        const SizedBox(height: JoynTokens.lg),
        const _ProfileStory(
          name: 'Camille',
          role: 'Candidate en développement',
          detail: '« Je développe des interfaces avec Dart et Flutter. »',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: JoynTokens.md),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: connected ? 1 : 0),
            duration: MediaQuery.disableAnimationsOf(context)
                ? JoynTokens.instant
                : JoynTokens.duration,
            curve: Curves.easeInOutCubic,
            builder: (context, progress, child) => SizedBox(
              height: JoynTokens.sceneLineHeight,
              width: double.infinity,
              child: CustomPaint(painter: _MatchConnection(progress)),
            ),
          ),
        ),
        const _ProfileStory(
          name: 'Alex',
          role: 'Recrutement côté entreprise',
          detail: '« Nous recrutons pour développer une interface Flutter. »',
          recruiter: true,
        ),
        const SizedBox(height: JoynTokens.lg),
        Semantics(
          liveRegion: true,
          child: Text(
            connected ? 'C’est un match.' : 'Et si l’intérêt était partagé ?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: connected ? JoynTokens.orangeLight : JoynTokens.paper,
            ),
          ),
        ),
        const SizedBox(height: JoynTokens.sm),
        if (connected) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(JoynTokens.sm),
            decoration: BoxDecoration(
              color: JoynTokens.paper,
              borderRadius: BorderRadius.circular(JoynTokens.radius),
            ),
            child: const Text(
              'Alex : « Ton projet Flutter m’intéresse. On en parle ? »',
            ),
          ),
          const SizedBox(height: JoynTokens.md),
        ],
        FilledButton(
          onPressed: () => setState(() => connected = !connected),
          child: Text(
            connected ? 'REJOUER LA RENCONTRE' : 'VOIR L’INTÉRÊT PARTAGÉ',
          ),
        ),
        const SizedBox(height: JoynTokens.sm),
        Text(
          'Exemple de mise en relation · portraits illustrés',
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: JoynTokens.blue),
        ),
      ],
    ),
  );
}

class _ProfileStory extends StatelessWidget {
  const _ProfileStory({
    required this.name,
    required this.role,
    required this.detail,
    this.recruiter = false,
  });
  final String name;
  final String role;
  final String detail;
  final bool recruiter;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      PersonPortrait(recruiter: recruiter),
      const SizedBox(width: JoynTokens.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: JoynTokens.paper),
            ),
            const SizedBox(height: JoynTokens.xs),
            Text(
              role,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: JoynTokens.blue),
            ),
            const SizedBox(height: JoynTokens.sm),
            Text(
              detail,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: JoynTokens.paper),
            ),
          ],
        ),
      ),
    ],
  );
}

class _MatchConnection extends CustomPainter {
  const _MatchConnection(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final paint = Paint()
      ..color = JoynTokens.cyan.withValues(alpha: .5)
      ..strokeWidth = JoynTokens.hairline;
    final path = Path()
      ..moveTo(0, y)
      ..cubicTo(
        size.width * .3,
        0,
        size.width * .7,
        size.height,
        size.width,
        y,
      );
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
    final metric = path.computeMetrics().first;
    paint
      ..color = JoynTokens.orange
      ..strokeWidth = JoynTokens.focusWidth;
    canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
    final position =
        metric.getTangentForOffset(metric.length * progress)?.position ??
        Offset(0, y);
    canvas.drawCircle(
      position,
      JoynTokens.xs / 2,
      Paint()..color = JoynTokens.orangeLight,
    );
  }

  @override
  bool shouldRepaint(covariant _MatchConnection oldDelegate) =>
      progress != oldDelegate.progress;
}
