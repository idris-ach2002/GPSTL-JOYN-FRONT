import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';

class EditorialSection extends StatelessWidget {
  const EditorialSection({
    super.key,
    required this.child,
    this.tinted = false,
    this.transparent = false,
  });
  final Widget child;
  final bool tinted;
  final bool transparent;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: transparent
        ? JoynTokens.ink.withValues(alpha: 0)
        : tinted
        ? JoynTokens.canvas
        : JoynTokens.paper,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < JoynTokens.mobile;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? JoynTokens.md : JoynTokens.xl,
            vertical: compact ? JoynTokens.xl : JoynTokens.section,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: JoynTokens.content),
              child: child,
            ),
          ),
        );
      },
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.number,
    required this.title,
    this.description,
  });
  final String number;
  final String title;
  final String? description;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: JoynTokens.md,
            height: JoynTokens.hairline,
            color: JoynTokens.ink,
          ),
          const SizedBox(width: JoynTokens.sm),
          Expanded(
            child: Text(number, style: Theme.of(context).textTheme.labelLarge),
          ),
        ],
      ),
      const SizedBox(height: JoynTokens.md),
      Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.headlineLarge),
      ),
      if (description != null) ...[
        const SizedBox(height: JoynTokens.md),
        Text(description!),
      ],
      const SizedBox(height: JoynTokens.lg),
    ],
  );
}

class EditorialSplit extends StatelessWidget {
  const EditorialSplit({
    super.key,
    required this.leading,
    required this.trailing,
  });
  final Widget leading;
  final Widget trailing;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < JoynTokens.tablet - JoynTokens.xl * 2) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leading,
            const SizedBox(height: JoynTokens.lg),
            trailing,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: leading),
          const SizedBox(width: JoynTokens.xl),
          Expanded(child: trailing),
        ],
      );
    },
  );
}

class InformationRow extends StatelessWidget {
  const InformationRow({super.key, required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Divider(),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: JoynTokens.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label)),
            const SizedBox(width: JoynTokens.sm),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
