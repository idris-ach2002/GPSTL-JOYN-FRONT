import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/person_portrait.dart';
import '../widgets/product_atmosphere.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});
  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(text: 'Camille');
  final skill = TextEditingController(text: 'Dart et interfaces web');
  final project = TextEditingController(
    text: 'J’ai construit un outil de suivi de tâches et travaillé sa navigation.',
  );
  (String, String, String)? snapshot = (
    'Camille',
    'Dart et interfaces web',
    'J’ai construit un outil de suivi de tâches et travaillé sa navigation.',
  );
  @override
  void dispose() {
    name.dispose();
    skill.dispose();
    project.dispose();
    super.dispose();
  }

  String? requiredText(String? value) => value == null || value.trim().isEmpty
      ? 'Ajoute une information pour construire cet exemple.'
      : null;
  void fillExample() {
    name.text = 'Camille';
    skill.text = 'Dart et interfaces web';
    project.text = 'J’ai construit un outil de suivi de tâches et travaillé sa navigation.';
    form.currentState?.validate();
    setState(() => snapshot = (name.text, skill.text, project.text));
  }

  @override
  Widget build(BuildContext context) => EditorialSection(
    tinted: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          number: '06 / PROFIL ET CV',
          title: 'Derrière un mot-clé,\nil y a ce que tu as fait.',
          description: 'Prévisualise la présentation de ton parcours. Les informations saisies dans cet aperçu ne sont pas enregistrées dans un compte.',
        ),
        EditorialSplit(
          leading: Form(
            key: form,
            child: Column(
              children: [
                TextFormField(
                  controller: name,
                  validator: requiredText,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
                const SizedBox(height: JoynTokens.md),
                TextFormField(
                  controller: skill,
                  validator: requiredText,
                  decoration: const InputDecoration(
                    labelText: 'Une compétence à présenter',
                  ),
                ),
                const SizedBox(height: JoynTokens.md),
                TextFormField(
                  controller: project,
                  validator: requiredText,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Un exemple concret de réalisation',
                  ),
                ),
                const SizedBox(height: JoynTokens.md),
                Wrap(
                  spacing: JoynTokens.sm,
                  runSpacing: JoynTokens.sm,
                  children: [
                    FilledButton(
                      onPressed: () {
                        if (form.currentState!.validate()) {
                          setState(
                            () => snapshot = (
                              name.text.trim(),
                              skill.text.trim(),
                              project.text.trim(),
                            ),
                          );
                        }
                      },
                      child: const Text('METTRE À JOUR L’APERÇU'),
                    ),
                    TextButton(
                      onPressed: fillExample,
                      child: const Text('UTILISER L’EXEMPLE'),
                    ),
                    TextButton(
                      onPressed: () {
                        form.currentState?.reset();
                        name.clear();
                        skill.clear();
                        project.clear();
                        setState(() => snapshot = null);
                      },
                      child: const Text('EFFACER'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing: Semantics(
            liveRegion: true,
            child: ProductSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PersonPortrait(),
                  const SizedBox(height: JoynTokens.md),
                  Text(
                    snapshot?.$1 ?? 'Le profil est encore vide.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: JoynTokens.md),
                  Text(
                    snapshot?.$2 ?? 'Une compétence et une réalisation suffisent pour commencer cet aperçu.',
                  ),
                  const SizedBox(height: JoynTokens.md),
                  const Divider(),
                  const SizedBox(height: JoynTokens.md),
                  Text(
                    snapshot?.$3 ?? 'Renseigne les champs pour prévisualiser la présentation.',
                  ),
                  const SizedBox(height: JoynTokens.lg),
                  const Text(
                    'Pour un CV : décrire sa contribution, préciser le contexte et choisir une preuve que l’on peut expliquer.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
