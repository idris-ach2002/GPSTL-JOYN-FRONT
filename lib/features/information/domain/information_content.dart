/// Données éditoriales des pages publiques. Aucune politique juridique ou
/// coordonnée officielle absente des sources n'est inventée.
class InformationSection {
  const InformationSection(this.title, this.body);
  final String title;
  final String body;
}

class InformationPage {
  const InformationPage({
    required this.title,
    required this.eyebrow,
    required this.introduction,
    required this.sections,
    this.actionLabel,
    this.actionRoute,
    this.notice,
  });
  final String title;
  final String eyebrow;
  final String introduction;
  final List<InformationSection> sections;
  final String? actionLabel;
  final String? actionRoute;
  final String? notice;
}

/// Routes stables partagées entre le footer, le routeur et les tests.
const informationPages = <String, InformationPage>{
  '/comprendre': InformationPage(
    eyebrow: 'Produit',
    title: 'Comment ça marche',
    introduction: 'Un profil, des opportunités, puis une conversation.',
    sections: [
      InformationSection(
        '1. Présente ton parcours',
        'Renseigne ta formation et tes compétences. L’import de CV prévu dans le '
            'parcours permet de préremplir des informations, que tu gardes la main pour vérifier.',
      ),
      InformationSection(
        '2. Explore les offres',
        'Consulte les recommandations et lis les détails des offres avant de manifester ton intérêt.',
      ),
      InformationSection(
        '3. Suis la rencontre',
        'Retrouve tes candidatures, leurs statuts et les conversations associées dans ton espace.',
      ),
    ],
    actionLabel: 'Créer mon profil',
    actionRoute: '/inscription',
  ),
  '/joyn-plus': InformationPage(
    eyebrow: 'Produit',
    title: 'Joyn+',
    introduction: 'L’essentiel de JOYN, avec davantage de possibilités.',
    notice: 'Offre proposée : prix, essai et avantages à confirmer avant ouverture.',
    sections: [
      InformationSection(
        'Tous les accès essentiels',
        'Profil, recommandations, suivi des candidatures et messagerie restent inclus dans la proposition JOYN+.',
      ),
      InformationSection(
        'Davantage de visibilité',
        'La maquette prévoit les « Intéressé » illimités, une mise en avant hebdomadaire '
            'et la consultation des entreprises ayant vu ton profil.',
      ),
      InformationSection(
        'Le tarif de la maquette',
        '15,99 € par mois, avec un essai de sept jours présenté dans la référence. '
            'Aucun abonnement ni paiement n’est déclenché depuis cette page.',
      ),
    ],
    actionLabel: 'Découvrir mon espace',
    actionRoute: '/inscription',
  ),
  '/remplace-moi': InformationPage(
    eyebrow: 'Produit',
    title: 'Remplace-moi',
    introduction:
        'Faire circuler une opportunité au moment où une place se libère.',
    notice: 'Concept présent dans la maquette, dont les modalités restent à préciser.',
    sections: [
      InformationSection(
        'L’idée',
        'Un alternant en fin de parcours pourrait signaler une opportunité de remplacement '
            'pour aider un autre candidat à découvrir son entreprise.',
      ),
      InformationSection(
        'Un exemple concret',
        'Camille termine son alternance. L’idée serait de faire connaître la place '
            'qui se libère, puis de laisser l’entreprise conduire son recrutement.',
      ),
      InformationSection(
        'Disponibilité',
        'Ce parcours ne constitue pas une fonctionnalité active dans la version de présentation.',
      ),
    ],
  ),
  '/publier-offre': InformationPage(
    eyebrow: 'Entreprises',
    title: 'Publier une offre',
    introduction:
        'Présentez le poste, les attentes et le contexte de votre recrutement.',
    sections: [
      InformationSection(
        'Votre entreprise',
        'Le parcours recruteur prévoit un compte et une présentation de l’entreprise, avec une étape de validation.',
      ),
      InformationSection(
        'Votre offre',
        'Préparez les informations du poste, puis retrouvez ses étapes de création, modification et clôture dans votre espace.',
      ),
      InformationSection(
        'Vos candidatures',
        'Les candidatures reçues, leurs statuts et les échanges ont vocation à rester liés à l’offre concernée.',
      ),
    ],
    actionLabel: 'Créer un compte entreprise',
    actionRoute: '/inscription',
  ),
  '/guide-alternance': InformationPage(
    eyebrow: 'Ressources',
    title: 'Guide de l’alternance',
    introduction: 'Des repères simples pour préparer ta recherche.',
    sections: [
      InformationSection(
        'Préparer ton profil',
        'Présente ta formation, tes projets et tes compétences avec des exemples concrets. '
            'Vérifie aussi tes disponibilités et ton rythme de formation.',
      ),
      InformationSection(
        'Lire une offre',
        'Repère les missions, les compétences attendues, le lieu et le rythme. '
            'Prépare les questions que l’annonce laisse ouvertes.',
      ),
      InformationSection(
        'Préparer la conversation',
        'Choisis un projet que tu sais expliquer : ton rôle, les difficultés rencontrées et ce que tu as appris.',
      ),
      InformationSection(
        'Exemple',
        'Au lieu de « je connais Flutter », raconte une interface que tu as réalisée, '
            'la contrainte que tu as résolue et le résultat que tu peux montrer.',
      ),
    ],
  ),
  '/questions-frequentes': InformationPage(
    eyebrow: 'Ressources',
    title: 'Questions fréquentes',
    introduction: 'Les repères utiles pour découvrir JOYN.',
    sections: [
      InformationSection(
        'À qui s’adresse JOYN ?',
        'Aux candidats à une alternance et aux entreprises souhaitant recruter.',
      ),
      InformationSection(
        'Les démonstrations utilisent-elles mes données ?',
        'Les scènes de présentation utilisent des profils fictifs. Leurs interactions '
            'restent locales à la vue : elles ne soumettent aucune candidature.',
      ),
      InformationSection(
        'Le Boost remplace-t-il JOYN+ ?',
        'Le Boost de la maquette est un complément ponctuel de visibilité, pas un abonnement qui remplace la formule du compte.',
      ),
      InformationSection(
        'Puis-je déjà me connecter ?',
        'Les écrans d’accès sont réservés au futur parcours de compte. '
            'L’authentification n’est pas encore disponible dans cette version de présentation.',
      ),
    ],
  ),
  '/contact': InformationPage(
    eyebrow: 'Ressources',
    title: 'Contact',
    introduction: 'Une question, une idée ou une envie de participer à JOYN ?',
    sections: [
      InformationSection(
        'Les coordonnées officielles',
        'Elles seront communiquées à l’ouverture du service.',
      ),
      InformationSection(
        'Pour découvrir le projet',
        'La landing présente les parcours candidat et entreprise. Les questions '
            'fréquentes expliquent aussi les limites de cette version de présentation.',
      ),
    ],
    actionLabel: 'Consulter les questions fréquentes',
    actionRoute: '/questions-frequentes',
  ),
  '/confidentialite': InformationPage(
    eyebrow: 'Légal',
    title: 'Confidentialité',
    introduction: 'La politique officielle de confidentialité sera publiée ici avant ouverture du service.',
    notice: 'Document officiel non fourni. Cette page ne constitue pas une politique de confidentialité validée.',
    sections: [
      InformationSection(
        'La version de présentation',
        'Les laboratoires de la landing utilisent des données fictives. '
            'Le message saisi dans une démonstration reste dans l’état local de cette vue.',
      ),
      InformationSection(
        'La suite',
        'Les informations officielles concernant les traitements de données, '
            'les interlocuteurs et les modalités applicables restent à compléter.',
      ),
    ],
  ),
  '/conditions': InformationPage(
    eyebrow: 'Légal',
    title: 'Conditions d’utilisation',
    introduction: 'Les conditions officielles du service seront accessibles ici avant son ouverture.',
    notice: 'Les conditions contractuelles ne sont pas disponibles dans cette version de présentation.',
    sections: [
      InformationSection(
        'Découvrir JOYN',
        'Les démonstrations illustrent les parcours envisagés. Elles ne publient '
            'pas d’offre, ne soumettent pas de candidature et ne créent pas d’abonnement.',
      ),
      InformationSection(
        'Offres et disponibilité',
        'Les montants candidat reprennent la maquette. Les modalités commerciales '
            'et les accès entreprise sont encore à confirmer.',
      ),
    ],
  ),
  '/cookies': InformationPage(
    eyebrow: 'Légal',
    title: 'Cookies',
    introduction: 'Les informations officielles concernant les cookies seront présentées ici.',
    notice:
        'L’inventaire des cookies de l’hébergement final n’a pas été fourni.',
    sections: [
      InformationSection(
        'Les démonstrations locales',
        'Leur état n’est pas enregistré par cette implémentation dans des cookies ou un stockage persistant.',
      ),
      InformationSection(
        'L’hébergement du service',
        'Les informations relatives à l’environnement final et, le cas échéant, '
            'aux choix proposés seront complétées avant ouverture.',
      ),
    ],
  ),
};
