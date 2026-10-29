import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'studio_controller.dart';

class StudioCard extends StatelessWidget {
  const StudioCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.accent = false,
  });
  final Widget child;
  final EdgeInsets padding;
  final bool accent;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = context.watch<StudioController?>()?.compact ?? false;
    return Material(
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(compact ? 14 : 22),
        side: BorderSide(
          color: accent
              ? theme.colorScheme.primary.withValues(alpha: .5)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(padding: compact ? padding * .75 : padding, child: child),
    );
  }
}

class StudioSectionTitle extends StatelessWidget {
  const StudioSectionTitle(this.title, {super.key, this.subtitle, this.action});
  final String title;
  final String? subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'BricolageGrotesque',
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    ),
  );
}

class StudioEmpty extends StatelessWidget {
  const StudioEmpty({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.auto_awesome_outlined,
    this.action,
  });
  final String title, message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 44, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (action != null)
          Padding(padding: const EdgeInsets.only(top: 16), child: action!),
      ],
    ),
  );
}

class StudioLoadNotice extends StatelessWidget {
  const StudioLoadNotice({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.watch<StudioController>();
    if (c.loading || c.saving)
      return const LinearProgressIndicator(minHeight: 2);
    if (c.error == null) return const SizedBox.shrink();
    return MaterialBanner(
      content: Text(c.error!),
      actions: [TextButton(onPressed: c.retry, child: const Text('Réessayer'))],
    );
  }
}

Future<bool> studioConfirm(
  BuildContext context,
  String title,
  String message, {
  String action = 'Confirmer',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;
void studioToast(BuildContext context, String text) {
  if (context.mounted)
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

String studioDate(Object? value) {
  final d = DateTime.tryParse('$value')?.toLocal();
  if (d == null) return '';
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

/// Adaptation des surfaces historiques, sans filtre sur les images ni inversion des graphiques.
abstract final class StudioColors {
  static Color background(BuildContext context, Color original) {
    if (Theme.of(context).brightness != Brightness.dark) return original;
    final hsl = HSLColor.fromColor(original);
    if (hsl.lightness > .94) return Theme.of(context).colorScheme.surface;
    if (hsl.lightness > .82 && hsl.saturation < .65)
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    return original;
  }

  static Color text(BuildContext context, Color original) {
    if (Theme.of(context).brightness != Brightness.dark) return original;
    final hsl = HSLColor.fromColor(original);
    if (hsl.lightness < .27) return Theme.of(context).colorScheme.onSurface;
    if (hsl.lightness < .64 && hsl.saturation < .5)
      return Theme.of(context).colorScheme.onSurfaceVariant;
    return original;
  }
}
