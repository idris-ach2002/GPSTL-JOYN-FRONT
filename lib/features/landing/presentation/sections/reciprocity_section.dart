import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/person_portrait.dart';
import '../widgets/product_atmosphere.dart';

class ReciprocitySection extends StatefulWidget {
  const ReciprocitySection({super.key});
  @override
  State<ReciprocitySection> createState() => _ReciprocitySectionState();
}

class _ReciprocitySectionState extends State<ReciprocitySection> {
  bool candidate = false;
  bool company = false;
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
