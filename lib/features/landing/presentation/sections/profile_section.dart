// Permet de saisir une présentation et de mettre à jour un aperçu local du profil.
//
// Référence : doc/landing/fichiers/profile_section.md.

import 'package:flutter/material.dart';
import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/person_portrait.dart';
import '../widgets/product_atmosphere.dart';
/// Formulaire de présentation avec validation et aperçu indépendant des champs.
class ProfileSection extends StatefulWidget {
  /// Initialise les paramètres de ProfileSection ; les valeurs par défaut figurent dans la signature.
  const ProfileSection({super.key});
  /// Crée l’état local associé au widget.
  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}
/// État de ProfileSection ; définit ses données mutables et son rendu.
class _ProfileSectionState extends State<ProfileSection> {
  /// Clé du formulaire utilisée pour déclencher la validation de ses champs.
  final form = GlobalKey<FormState>();
  /// Contrôleur du prénom ou nom de la personne représentée, selon la portée.
  final name = TextEditingController(text: 'Camille');
  /// Contrôleur de la compétence saisie dans l’aperçu du profil.
  final skill = TextEditingController(text: 'Dart et interfaces web');
  /// Contrôleur de la réalisation saisie dans l’aperçu du profil.
  final project = TextEditingController(text: 'J’ai construit un outil de suivi de tâches et travaillé sa navigation.');
  /// Copie validée des trois champs affichée dans l’aperçu ; null représente un aperçu vide.
  (String, String, String)? snapshot = ('Camille', 'Dart et interfaces web', 'J’ai construit un outil de suivi de tâches et travaillé sa navigation.');
  /// Libère les ressources détenues par cet état avant sa destruction.
  @override
  void dispose() { name.dispose(); skill.dispose(); project.dispose(); super.dispose(); }
  /// Refuse une chaîne vide ou ne contenant que des espaces.
  String? requiredText(String? value) => value == null || value.trim().isEmpty ? 'Ajoute une information pour construire cet exemple.' : null;
  /// Renseigne les trois champs et actualise l’aperçu du profil.
  void fillExample() {
    name.text = 'Camille'; skill.text = 'Dart et interfaces web';
    project.text = 'J’ai construit un outil de suivi de tâches et travaillé sa navigation.';
    form.currentState?.validate();
    setState(() => snapshot = (name.text, skill.text, project.text));
  }
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => EditorialSection(tinted: true, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionHeading(number: '06 / PROFIL ET CV', title: 'Derrière un mot-clé,\nil y a ce que tu as fait.', description: 'Prévisualise la présentation de ton parcours. Les informations saisies dans cet aperçu ne sont pas enregistrées dans un compte.'),
    EditorialSplit(
      leading: Form(key: form, child: Column(children: [
        TextFormField(controller: name, validator: requiredText, decoration: const InputDecoration(labelText: 'Prénom')),
        const SizedBox(height: JoynTokens.md),
        TextFormField(controller: skill, validator: requiredText, decoration: const InputDecoration(labelText: 'Une compétence à présenter')),
        const SizedBox(height: JoynTokens.md),
        TextFormField(controller: project, validator: requiredText, maxLines: 4, decoration: const InputDecoration(labelText: 'Un exemple concret de réalisation')),
        const SizedBox(height: JoynTokens.md),
        Wrap(spacing: JoynTokens.sm, runSpacing: JoynTokens.sm, children: [
          FilledButton(onPressed: () { if (form.currentState!.validate()) { setState(() => snapshot = (name.text.trim(), skill.text.trim(), project.text.trim())); } }, child: const Text('METTRE À JOUR L’APERÇU')),
          TextButton(onPressed: fillExample, child: const Text('UTILISER L’EXEMPLE')),
          TextButton(onPressed: () { form.currentState?.reset(); name.clear(); skill.clear(); project.clear(); setState(() => snapshot = null); }, child: const Text('EFFACER')),
        ]),
      ])),
      trailing: Semantics(liveRegion: true, child: ProductSurface(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PersonPortrait(), const SizedBox(height: JoynTokens.md),
        Text(snapshot?.$1 ?? 'Le profil est encore vide.', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: JoynTokens.md),
        Text(snapshot?.$2 ?? 'Une compétence et une réalisation suffisent pour commencer cet aperçu.'),
        const SizedBox(height: JoynTokens.md), const Divider(), const SizedBox(height: JoynTokens.md),
        Text(snapshot?.$3 ?? 'Renseigne les champs pour prévisualiser la présentation.'),
        const SizedBox(height: JoynTokens.lg),
        const Text('Pour un CV : décrire sa contribution, préciser le contexte et choisir une preuve que l’on peut expliquer.'),
      ]))),
    ),
  ]));
}
