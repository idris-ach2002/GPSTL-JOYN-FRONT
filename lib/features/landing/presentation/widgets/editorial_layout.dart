// Fournit les compositions de section, de titre, de colonnes et de lignes d’information.
//
// Référence : doc/landing/fichiers/editorial_layout.md.

import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';

/// Cadre de section qui applique largeur maximale, marges et fond.
class EditorialSection extends StatelessWidget {
  /// Initialise les paramètres de EditorialSection ; les valeurs par défaut figurent dans la signature.
  const EditorialSection({
    super.key,
    required this.child,
    this.tinted = false,
    this.transparent = false,
  });

  /// Contenu enveloppé par le composant.
  final Widget child;

  /// Applique le fond canvas à la section.
  final bool tinted;

  /// Laisse apparaître le fond du parent.
  final bool transparent;

  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: transparent
        ? JoynTokens.ink.withValues(alpha: 0)
        : tinted
        ? JoynTokens.canvas
        : JoynTokens.paper,
    child: LayoutBuilder(
      builder: (context, constraints) {
        // Sélectionne une présentation compacte ou indique le mode de navigation mobile.
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

/// En-tête de section avec repère, titre sémantique et description facultative.
class SectionHeading extends StatelessWidget {
  /// Initialise les paramètres de SectionHeading ; les valeurs par défaut figurent dans la signature.
  const SectionHeading({
    super.key,
    required this.number,
    required this.title,
    this.description,
  });

  /// Repère éditorial placé avant le titre.
  final String number;

  /// Titre affiché dans cette composition.
  final String title;

  /// Texte de contexte associé au titre ou au lien.
  final String? description;

  /// Construit la présentation à partir de la configuration et de l’état courant.
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

/// Deux colonnes qui deviennent une pile lorsque la largeur manque.
class EditorialSplit extends StatelessWidget {
  /// Initialise les paramètres de EditorialSplit ; les valeurs par défaut figurent dans la signature.
  const EditorialSplit({
    super.key,
    required this.leading,
    required this.trailing,
  });

  /// Contenu de la première colonne.
  final Widget leading;

  /// Contenu de la seconde colonne.
  final Widget trailing;

  /// Construit la présentation à partir de la configuration et de l’état courant.
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

/// Couple libellé/valeur séparé par un filet horizontal.
class InformationRow extends StatelessWidget {
  /// Initialise les paramètres de InformationRow ; les valeurs par défaut figurent dans la signature.
  const InformationRow({super.key, required this.label, required this.value});

  /// Libellé présenté à l’utilisateur.
  final String label;

  /// Valeur reçue par le paramètre ou affichée dans la ligne, selon la portée.
  final String value;

  /// Construit la présentation à partir de la configuration et de l’état courant.
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
