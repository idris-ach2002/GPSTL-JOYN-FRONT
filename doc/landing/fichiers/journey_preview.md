# `journey_preview.dart`

Dessine les aperçus du profil, de l’offre, des intérêts et de la conversation.

[Code source](../../../lib/features/landing/presentation/widgets/journey_preview.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `person_portrait.dart`
- `product_atmosphere.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `JourneyPreview` | `Bibliothèque` | Sélecteur d’aperçu pour les quatre états du parcours. | `class JourneyPreview extends StatelessWidget` |
| `JourneyPreview` | `JourneyPreview` | Initialise les paramètres de JourneyPreview ; les valeurs par défaut figurent dans la signature. | `const JourneyPreview({super.key, required this.stage, this.compact = false})` |
| `_ProfilePreview` | `Bibliothèque` | Vue illustrée du profil candidat. | `class _ProfilePreview extends StatelessWidget` |
| `_ProfilePreview` | `_ProfilePreview` | Initialise les paramètres de _ProfilePreview ; les valeurs par défaut figurent dans la signature. | `const _ProfilePreview()` |
| `_OpportunityPreview` | `Bibliothèque` | Vue illustrée d’une offre et de ses correspondances. | `class _OpportunityPreview extends StatelessWidget` |
| `_OpportunityPreview` | `_OpportunityPreview` | Initialise les paramètres de _OpportunityPreview ; les valeurs par défaut figurent dans la signature. | `const _OpportunityPreview()` |
| `_ConversationPreview` | `Bibliothèque` | Vue illustrée d’un échange, avec variante compacte. | `class _ConversationPreview extends StatelessWidget` |
| `_ConversationPreview` | `_ConversationPreview` | Initialise les paramètres de _ConversationPreview ; les valeurs par défaut figurent dans la signature. | `const _ConversationPreview({this.compact = false})` |
| `_ChatMessage` | `Bibliothèque` | Bulle de texte alignée selon le sens du message. | `class _ChatMessage extends StatelessWidget` |
| `_ChatMessage` | `_ChatMessage` | Initialise les paramètres de _ChatMessage ; les valeurs par défaut figurent dans la signature. | `const _ChatMessage({required this.text, this.outgoing = false})` |
| `_PreviewLine` | `Bibliothèque` | Couple libellé/valeur compact utilisé dans les aperçus. | `class _PreviewLine extends StatelessWidget` |
| `_PreviewLine` | `_PreviewLine` | Initialise les paramètres de _PreviewLine ; les valeurs par défaut figurent dans la signature. | `const _PreviewLine({required this.label, required this.value})` |
| `_InterestPreview` | `Bibliothèque` | Présentation séparée des intérêts candidat et recruteur. | `class _InterestPreview extends StatelessWidget` |
| `_InterestPreview` | `_InterestPreview` | Initialise les paramètres de _InterestPreview ; les valeurs par défaut figurent dans la signature. | `const _InterestPreview()` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `build` | `JourneyPreview` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `build` | `_ProfilePreview` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `build` | `_OpportunityPreview` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `build` | `_ConversationPreview` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `build` | `_ChatMessage` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `build` | `_PreviewLine` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |
| `build` | `_InterestPreview` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `stage` | `JourneyPreview` | Indice de l’étape actuellement affichée. | `final int stage` |
| `compact` | `JourneyPreview` | Sélectionne une présentation compacte ou indique le mode de navigation mobile. | `final bool compact` |
| `compact` | `_ConversationPreview` | Sélectionne une présentation compacte ou indique le mode de navigation mobile. | `final bool compact` |
| `text` | `_ChatMessage` | Styles typographiques ou contenu du message, selon la portée. | `final String text` |
| `outgoing` | `_ChatMessage` | Aligne le message du côté de son émetteur. | `final bool outgoing` |
| `label` | `_PreviewLine` | Libellé présenté à l’utilisateur. | `final String label` |
| `value` | `_PreviewLine` | Valeur reçue par le paramètre ou affichée dans la ligne, selon la portée. | `final String value` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `JourneyPreview` | Identité du widget dans l’arbre Flutter. |
| `this.stage` | `JourneyPreview` | Indice de l’étape actuellement affichée. |
| `this.compact` | `JourneyPreview` | Sélectionne une présentation compacte ou indique le mode de navigation mobile. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `this.compact` | `_ConversationPreview` | Sélectionne une présentation compacte ou indique le mode de navigation mobile. |
| `this.text` | `_ChatMessage` | Styles typographiques ou contenu du message, selon la portée. |
| `this.outgoing` | `_ChatMessage` | Aligne le message du côté de son émetteur. |
| `this.label` | `_PreviewLine` | Libellé présenté à l’utilisateur. |
| `this.value` | `_PreviewLine` | Valeur reçue par le paramètre ou affichée dans la ligne, selon la portée. |

