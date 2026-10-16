// Filtre les questions et réponses, les pagine et transmet la recherche à l’assistance.
//
// Référence : doc/landing/fichiers/questions_section.md.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
/// Centre de questions et réponses avec catégories, recherche et pagination.
class QuestionsSection extends StatefulWidget {
  /// Initialise les paramètres de QuestionsSection ; les valeurs par défaut figurent dans la signature.
  const QuestionsSection({super.key});
  /// Crée l’état local associé au widget.
  @override
  State<QuestionsSection> createState() => _QuestionsSectionState();
}
/// État de QuestionsSection ; définit ses données mutables et son rendu.
class _QuestionsSectionState extends State<QuestionsSection> {
  /// Contrôleur du champ de recherche de ce composant ; libéré dans dispose.
  final search=TextEditingController();
  /// Indice de la réponse dépliée ; null ferme toutes les réponses.
  int? open;
  /// Indice de la page de résultats FAQ, à partir de zéro.
  int page=0;
  /// Nombre maximal de réponses affichées par page : cinq.
  static const pageSize=5;
  /// Catégorie active ; TOUT désactive la restriction par catégorie.
  String category='TOUT';
  /// Questions, catégories et réponses disponibles dans la FAQ.
  static const questions=[
    ('PROFIL ET CV','Quand mon CV est-il analysé ?','Le CV joint est analysé à la création de ton profil. Les informations recueillies servent à constituer ton profil candidat et à présenter ton parcours.'),
    ('PROFIL ET CV','Que présente mon profil ?','Ton profil rassemble les informations sur ton parcours et tes compétences. Il donne au recruteur les éléments nécessaires pour comprendre ton expérience en lien avec une offre.'),
    ('RECOMMANDATIONS','Pourquoi cette offre apparaît-elle dans ma sélection ?','Les offres présentées correspondent à ton profil candidat. Les recommandations servent à rapprocher ton parcours des besoins décrits dans les offres.'),
    ('RECOMMANDATIONS','Une recommandation garantit-elle un recrutement ?','Non. Une correspondance permet d’identifier une offre pertinente. La candidature, les échanges et la décision de recrutement restent des étapes distinctes.'),
    ('RECOMMANDATIONS','Pourquoi ne pas afficher toutes les offres ?','La sélection est centrée sur les offres correspondant à ton profil. Elle permet de consulter des postes en rapport avec ton parcours plutôt qu’une liste indifférenciée.'),
    ('CANDIDATURES','À quoi sert le suivi des candidatures ?','Il permet de retrouver les démarches engagées et leur statut. Le candidat suit ses candidatures ; le recruteur retrouve celles qui concernent ses offres.'),
    ('CANDIDATURES','Une offre enregistrée est-elle une candidature ?','Non. Enregistrer une offre permet de la retrouver. Cette action est différente de l’envoi d’une candidature.'),
    ('CANDIDATURES','Quand un échange peut-il commencer ?','L’intérêt réciproque distingue l’intérêt du candidat de celui du recruteur. Lorsque les deux sont exprimés, un échange permet de préciser les attentes de chacun.'),
    ('RECRUTEURS','Quelles informations préciser dans une offre ?','Décris les missions, les compétences attendues, la localisation, le contrat et l’organisation du travail. Ces informations aident le candidat à comprendre le poste et permettent de rapprocher l’offre des profils.'),
    ('RECRUTEURS','Comment organiser les candidatures ?','Le suivi par offre permet de replacer chaque candidature dans son contexte : le poste concerné, le profil et l’état de la démarche.'),
    ('FORMULES','Où trouver les informations sur les formules ?','La rubrique des services distingue l’usage candidat de l’usage entreprise. Pour une question sur les conditions d’une formule, consulte l’assistance.'),
    ('ASSISTANCE','Comment trouver une réponse à ma question ?','Saisis quelques mots dans la recherche ou sélectionne une catégorie. La recherche porte sur les questions et les réponses. Si aucun résultat ne correspond, ouvre l’assistance avec ta question.'),
  ];
  /// Met le texte en minuscules et remplace les accents pour la recherche FAQ.
  String normalize(String value) {
    // Texte normalisé ou valeur calculée dans la portée courante.
    var result=value.toLowerCase();
    // Table de remplacement des caractères accentués pour la recherche.
    const accents={'à':'a','â':'a','ä':'a','é':'e','è':'e','ê':'e','ë':'e','î':'i','ï':'i','ô':'o','ö':'o','ù':'u','û':'u','ü':'u','ç':'c','œ':'oe'};
    for(final entry in accents.entries) { result=result.replaceAll(entry.key,entry.value); }
    return result;
  }
  /// Libère les ressources détenues par cet état avant sa destruction.
  @override
  void dispose() { search.dispose();super.dispose(); }
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) {
    // Mots de recherche normalisés ; chaque mot doit apparaître dans la question ou sa réponse.
    final terms=normalize(search.text).trim().split(RegExp(r'\s+')).where((term) => term.isNotEmpty);
    // Éléments qui satisfont les filtres et la recherche.
    final results=[for(var i=0;i<questions.length;i++) if((category=='TOUT' || questions[i].$1==category) && terms.every((term) => normalize('${questions[i].$2} ${questions[i].$3}').contains(term))) i];
    // Nombre de pages de résultats, calculé par arrondi supérieur.
    final pages=(results.length/pageSize).ceil();
    return EditorialSection(tinted: true,child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
      const SectionHeading(number: 'QUESTIONS FRÉQUENTES',title: 'Ta question,\npar sujet ou par mot-clé.'),
      TextField(controller: search,onChanged: (_) => setState(() { page=0;open=null; }),decoration: const InputDecoration(labelText: 'Rechercher une question',hintText: 'CV, recommandations, candidature…')),
      const SizedBox(height: JoynTokens.md),
      Wrap(spacing: JoynTokens.sm,runSpacing: JoynTokens.xs,children: [for(final item in const ['TOUT','PROFIL ET CV','RECOMMANDATIONS','CANDIDATURES','RECRUTEURS','FORMULES','ASSISTANCE'])
        Semantics(selected: category==item,child: OutlinedButton(onPressed: () => setState(() { category=item;page=0;open=null; }),child: Text('$item${category==item ? ' —' : ''}'))),
      ]),const SizedBox(height: JoynTokens.md),
      Semantics(liveRegion: true,child: Text('${results.length} réponse(s)',key: const ValueKey('faq-count'))),
      const SizedBox(height: JoynTokens.md),
      if(results.isEmpty) const Text('Aucune réponse pour ces mots. Essaie une autre formulation ou consulte l’assistance.'),
      for(final i in results.skip(page*pageSize).take(pageSize)) ...[
        const Divider(),Semantics(expanded: open==i,child: SizedBox(width: double.infinity,child: TextButton(
          key: ValueKey('faq-question-$i'),style: const ButtonStyle(alignment: Alignment.centerLeft),onPressed: () => setState(() => open=open==i ? null : i),child: Text('${open==i ? '−' : '+'} ${questions[i].$2}')))),
        if(open==i) Padding(padding: const EdgeInsets.all(JoynTokens.md),child: Text(questions[i].$3)),
      ],const Divider(),
      if(pages>1) Wrap(spacing: JoynTokens.sm,crossAxisAlignment: WrapCrossAlignment.center,children: [
        OutlinedButton(onPressed: page>0 ? () => setState(() {page--;open=null;}) : null,child: const Text('PRÉCÉDENT')),
        Text('${page+1} / $pages',key: const ValueKey('faq-page')),
        OutlinedButton(onPressed: page+1<pages ? () => setState(() {page++;open=null;}) : null,child: const Text('SUIVANT')),
      ]),const SizedBox(height: JoynTokens.md),
      TextButton(onPressed: () => context.go(Uri(path:'/assistance',queryParameters: search.text.trim().isEmpty ? null : {'question':search.text.trim()}).toString()),child: const Text('POSER MA QUESTION À L’ASSISTANCE →')),
    ]));
  }
}
