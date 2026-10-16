// Dessine les aperçus du profil, de l’offre, des intérêts et de la conversation.
//
// Référence : doc/landing/fichiers/journey_preview.md.

import 'package:flutter/material.dart';
import '../../../../design_system/joyn_tokens.dart';
import 'person_portrait.dart';
import 'product_atmosphere.dart';
/// Sélecteur d’aperçu pour les quatre états du parcours.
class JourneyPreview extends StatelessWidget {
  /// Initialise les paramètres de JourneyPreview ; les valeurs par défaut figurent dans la signature.
  const JourneyPreview({super.key, required this.stage, this.compact = false});
  /// Indice de l’étape actuellement affichée.
  final int stage;
  /// Sélectionne une présentation compacte ou indique le mode de navigation mobile.
  final bool compact;
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(JoynTokens.radius),
    child: ProductAtmosphere(child: Padding(
      padding: const EdgeInsets.all(JoynTokens.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(['TON PROFIL', 'UNE OFFRE À COMPRENDRE', 'LES DEUX INTÉRÊTS', 'LE PREMIER ÉCHANGE'][stage],
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: JoynTokens.paper)),
        const SizedBox(height: JoynTokens.md),
        ProductSurface(child: switch(stage) {
          0 => const _ProfilePreview(),
          1 => const _OpportunityPreview(),
          2 => const _InterestPreview(),
          _ => _ConversationPreview(compact: compact),
        }),
        const SizedBox(height: JoynTokens.sm),
        Text('Aperçu du parcours candidat', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: JoynTokens.blue)),
      ]),
    )),
  );
}
/// Vue illustrée du profil candidat.
class _ProfilePreview extends StatelessWidget {
  /// Initialise les paramètres de _ProfilePreview ; les valeurs par défaut figurent dans la signature.
  const _ProfilePreview();
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const PersonPortrait(),
    const SizedBox(height: JoynTokens.sm),
    Text('Camille', style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: JoynTokens.xs),
    const Text('Développement web · Paris'),
    const SizedBox(height: JoynTokens.md),
    const _PreviewLine(label: 'Je sais faire', value: 'Dart, interfaces web'),
    const _PreviewLine(label: 'Je veux apprendre', value: 'Flutter en équipe'),
    const _PreviewLine(label: 'Mon rythme', value: '3 jours en entreprise'),
  ]);
}
/// Vue illustrée d’une offre et de ses correspondances.
class _OpportunityPreview extends StatelessWidget {
  /// Initialise les paramètres de _OpportunityPreview ; les valeurs par défaut figurent dans la signature.
  const _OpportunityPreview();
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Développement Flutter', style: Theme.of(context).textTheme.headlineSmall),
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
      decoration: BoxDecoration(color: JoynTokens.canvas, borderRadius: BorderRadius.circular(JoynTokens.radius)),
      child: const Text('Un profil et une offre qui correspondent.'),
    ),
  ]);
}
/// Vue illustrée d’un échange, avec variante compacte.
class _ConversationPreview extends StatelessWidget {
  /// Initialise les paramètres de _ConversationPreview ; les valeurs par défaut figurent dans la signature.
  const _ConversationPreview({this.compact = false});
  /// Sélectionne une présentation compacte ou indique le mode de navigation mobile.
  final bool compact;
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const PersonPortrait(recruiter: true), const SizedBox(width: JoynTokens.sm),
      Expanded(child: Text('Alex · recrutement', style: Theme.of(context).textTheme.headlineSmall)),
    ]),
    const SizedBox(height: JoynTokens.md),
    _ChatMessage(text: compact ? 'Ton projet m’intéresse. On en parle ?' : 'Ton projet Flutter m’intéresse. Tu peux m’en parler ?'),
    const SizedBox(height: JoynTokens.sm),
    _ChatMessage(text: compact ? 'Oui. Je peux présenter ma contribution et mes choix.' : 'Oui ! J’ai construit une interface de suivi de tâches. Je cherche à progresser avec une équipe.', outgoing: true),
    const SizedBox(height: JoynTokens.md),
    Text('INTÉRÊT EXPRIMÉ DES DEUX CÔTÉS', style: Theme.of(context).textTheme.labelLarge),
  ]);
}
/// Bulle de texte alignée selon le sens du message.
class _ChatMessage extends StatelessWidget {
  /// Initialise les paramètres de _ChatMessage ; les valeurs par défaut figurent dans la signature.
  const _ChatMessage({required this.text, this.outgoing = false});
  /// Styles typographiques ou contenu du message, selon la portée.
  final String text;
  /// Aligne le message du côté de son émetteur.
  final bool outgoing;
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(JoynTokens.sm),
    decoration: BoxDecoration(color: outgoing ? JoynTokens.ink : JoynTokens.canvas,
      borderRadius: BorderRadius.circular(JoynTokens.radius)),
    child: Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: outgoing ? JoynTokens.paper : JoynTokens.ink)),
  );
}
/// Couple libellé/valeur compact utilisé dans les aperçus.
class _PreviewLine extends StatelessWidget {
  /// Initialise les paramètres de _PreviewLine ; les valeurs par défaut figurent dans la signature.
  const _PreviewLine({required this.label, required this.value});
  /// Libellé présenté à l’utilisateur.
  final String label;
  /// Valeur reçue par le paramètre ou affichée dans la ligne, selon la portée.
  final String value;
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: JoynTokens.xs),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: JoynTokens.xs), Text(value),
      const SizedBox(height: JoynTokens.xs), const Divider(),
    ]),
  );
}
/// Présentation séparée des intérêts candidat et recruteur.
class _InterestPreview extends StatelessWidget {
  /// Initialise les paramètres de _InterestPreview ; les valeurs par défaut figurent dans la signature.
  const _InterestPreview();
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const PersonPortrait(), const SizedBox(width: JoynTokens.sm),
      Expanded(child: Text('Camille veut en savoir plus.', style: Theme.of(context).textTheme.headlineSmall))]),
    const SizedBox(height: JoynTokens.md), const Divider(), const SizedBox(height: JoynTokens.md),
    Row(children: [const PersonPortrait(recruiter: true), const SizedBox(width: JoynTokens.sm),
      Expanded(child: Text('Alex veut comprendre son projet.', style: Theme.of(context).textTheme.headlineSmall))]),
    const SizedBox(height: JoynTokens.md),
    const Text('Deux intérêts distincts. Une conversation dans le scénario proposé.'),
  ]);
}
