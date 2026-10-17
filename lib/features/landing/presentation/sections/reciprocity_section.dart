// Distingue les intérêts candidat et entreprise avant l’ouverture d’un échange illustré.
//
// Référence : doc/landing.md#reciprocity_sectiondart.

import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/person_portrait.dart';
import '../widgets/product_atmosphere.dart';

/// Présentation des quatre combinaisons d’intérêt candidat et entreprise.
class ReciprocitySection extends StatefulWidget {
  /// Initialise les paramètres de ReciprocitySection ; les valeurs par défaut figurent dans la signature.
  const ReciprocitySection({super.key});

  /// Crée l’état local associé au widget.
  @override
  State<ReciprocitySection> createState() => _ReciprocitySectionState();
}

/// État de ReciprocitySection ; définit ses données mutables et son rendu.
class _ReciprocitySectionState extends State<ReciprocitySection> {
  /// Intérêt exprimé du côté candidat dans la scène interactive.
  bool candidate = false;

  /// Intérêt exprimé du côté entreprise dans la scène interactive.
  bool company = false;

  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => EditorialSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          number: '09 / L’INTÉRÊT RÉCIPROQUE',
          title: 'Une conversation\nse commence à deux.',
          description: 'Teste chaque combinaison. L’intérêt pour un profil ne vaut pas promesse d’embauche.',
        ),
        EditorialSplit(
          leading: ProductSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PersonPortrait(),
                const SizedBox(height: JoynTokens.md),
                Text(
                  'Camille, candidate',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: JoynTokens.sm),
                const Text(
                  '« Les missions m’intéressent. Je veux comprendre comment l’équipe travaille. »',
                ),
                const SizedBox(height: JoynTokens.md),
                Semantics(
                  toggled: candidate,
                  child: OutlinedButton(
                    onPressed: () => setState(() => candidate = !candidate),
                    child: Text(
                      candidate
                          ? 'INTÉRÊT CANDIDAT EXPRIMÉ'
                          : 'EXPRIMER L’INTÉRÊT CANDIDAT',
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing: ProductSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PersonPortrait(recruiter: true),
                const SizedBox(height: JoynTokens.md),
                Text(
                  'Alex, recrutement',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: JoynTokens.sm),
                const Text(
                  '« Son projet donne envie de comprendre sa démarche et ses axes de progression. »',
                ),
                const SizedBox(height: JoynTokens.md),
                Semantics(
                  toggled: company,
                  child: OutlinedButton(
                    onPressed: () => setState(() => company = !company),
                    child: Text(
                      company
                          ? 'INTÉRÊT RECRUTEUR EXPRIMÉ'
                          : 'EXPRIMER L’INTÉRÊT RECRUTEUR',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: JoynTokens.lg),
        Semantics(
          liveRegion: true,
          child: ProductSurface(
            accent: candidate && company,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate && company
                      ? 'Les deux intérêts sont réunis.'
                      : 'La conversation attend encore un intérêt partagé.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: JoynTokens.md),
                Text(
                  candidate && company
                      ? 'Alex : « Peux-tu m’expliquer une décision prise sur ton projet ? »\nCamille : « Oui. J’ai notamment retravaillé la navigation pour que les tâches restent faciles à retrouver. »'
                      : 'Le scénario reste fermé tant que les deux boutons ne sont pas activés. Aucun message n’est envoyé.',
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
