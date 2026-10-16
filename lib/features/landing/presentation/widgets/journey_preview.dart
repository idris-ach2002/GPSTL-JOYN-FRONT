import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import 'person_portrait.dart';
import 'product_atmosphere.dart';

class JourneyPreview extends StatelessWidget {
  const JourneyPreview({super.key, required this.stage, this.compact = false});
  final int stage;
  final bool compact;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(JoynTokens.radius),
    child: ProductAtmosphere(
      child: Padding(
        padding: const EdgeInsets.all(JoynTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [
                'TON PROFIL',
                'UNE OFFRE À COMPRENDRE',
                'LES DEUX INTÉRÊTS',
                'LE PREMIER ÉCHANGE',
              ][stage],
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: JoynTokens.paper),
            ),
            const SizedBox(height: JoynTokens.md),
            ProductSurface(
              child: switch (stage) {
                0 => const _ProfilePreview(),
                1 => const _OpportunityPreview(),
                2 => const _InterestPreview(),
                _ => _ConversationPreview(compact: compact),
              },
            ),
            const SizedBox(height: JoynTokens.sm),
            Text(
              'Aperçu du parcours candidat',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: JoynTokens.blue),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProfilePreview extends StatelessWidget {
  const _ProfilePreview();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const PersonPortrait(),
      const SizedBox(height: JoynTokens.sm),
      Text('Camille', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: JoynTokens.xs),
      const Text('Développement web · Paris'),
      const SizedBox(height: JoynTokens.md),
      const _PreviewLine(label: 'Je sais faire', value: 'Dart, interfaces web'),
      const _PreviewLine(
        label: 'Je veux apprendre',
        value: 'Flutter en équipe',
      ),
      const _PreviewLine(label: 'Mon rythme', value: '3 jours en entreprise'),
    ],
  );
}

class _OpportunityPreview extends StatelessWidget {
  const _OpportunityPreview();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Développement Flutter',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: JoynTokens.xs),
      const Text('Alternance · Paris · équipe produit'),
      const SizedBox(height: JoynTokens.md),
      const _PreviewLine(label: 'Localisation', value: 'Paris ↔ Paris'),
      const _PreviewLine(label: 'Rythme', value: '3 jours ↔ 3 jours'),
      const _PreviewLine(label: 'Compétences', value: 'Dart et Flutter'),
      const SizedBox(height: JoynTokens.sm),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(JoynTokens.sm),
        decoration: BoxDecoration(
          color: JoynTokens.canvas,
          borderRadius: BorderRadius.circular(JoynTokens.radius),
        ),
        child: const Text('Un profil et une offre qui correspondent.'),
      ),
    ],
  );
}

class _ConversationPreview extends StatelessWidget {
  const _ConversationPreview({this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const PersonPortrait(recruiter: true),
          const SizedBox(width: JoynTokens.sm),
          Expanded(
            child: Text(
              'Alex · recrutement',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ],
      ),
      const SizedBox(height: JoynTokens.md),
      _ChatMessage(
        text: compact
            ? 'Ton projet m’intéresse. On en parle ?'
            : 'Ton projet Flutter m’intéresse. Tu peux m’en parler ?',
      ),
      const SizedBox(height: JoynTokens.sm),
      _ChatMessage(
        text: compact ? 'Oui. Je peux présenter ma contribution et mes choix.' : 'Oui ! J’ai construit une interface de suivi de tâches. Je cherche à progresser avec une équipe.',
        outgoing: true,
      ),
      const SizedBox(height: JoynTokens.md),
      Text(
        'INTÉRÊT EXPRIMÉ DES DEUX CÔTÉS',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    ],
  );
}

class _ChatMessage extends StatelessWidget {
  const _ChatMessage({required this.text, this.outgoing = false});
  final String text;
  final bool outgoing;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(JoynTokens.sm),
    decoration: BoxDecoration(
      color: outgoing ? JoynTokens.ink : JoynTokens.canvas,
      borderRadius: BorderRadius.circular(JoynTokens.radius),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge
          ?.copyWith(color: outgoing ? JoynTokens.paper : JoynTokens.ink),
    ),
  );
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: JoynTokens.xs),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: JoynTokens.xs),
        Text(value),
        const SizedBox(height: JoynTokens.xs),
        const Divider(),
      ],
    ),
  );
}

class _InterestPreview extends StatelessWidget {
  const _InterestPreview();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const PersonPortrait(),
          const SizedBox(width: JoynTokens.sm),
          Expanded(
            child: Text(
              'Camille veut en savoir plus.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ],
      ),
      const SizedBox(height: JoynTokens.md),
      const Divider(),
      const SizedBox(height: JoynTokens.md),
      Row(
        children: [
          const PersonPortrait(recruiter: true),
          const SizedBox(width: JoynTokens.sm),
          Expanded(
            child: Text(
              'Alex veut comprendre son projet.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ],
      ),
      const SizedBox(height: JoynTokens.md),
      const Text(
        'Deux intérêts distincts. Une conversation dans le scénario proposé.',
      ),
    ],
  );
}
