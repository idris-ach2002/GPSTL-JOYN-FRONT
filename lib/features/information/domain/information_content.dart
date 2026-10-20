/// Contenus éditoriaux des pages publiques.
///
/// Les textes décrivent uniquement les parcours visibles dans le projet et les
/// règles de cette interface. Aucune identité juridique, durée de conservation
/// ou coordonnée absente des sources du dépôt n'est inventée.
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
    introduction:
        'Un profil clair, des opportunités pertinentes et un suivi continu.',
    sections: [
      InformationSection(
        '1. Construis ton profil',
        'Renseigne ta formation, tes compétences et tes préférences. L’import de CV accélère la saisie, puis tu gardes la main sur les informations affichées.',
      ),
      InformationSection(
        '2. Découvre les opportunités',
        'Les offres sont présentées avec les informations utiles pour comparer le poste, le rythme, la localisation et les compétences attendues.',
      ),
      InformationSection(
        '3. Suis tes candidatures',
        'Retrouve tes envois, leur statut et les conversations associées sans perdre le contexte de l’offre.',
      ),
    ],
    actionLabel: 'Créer mon profil',
    actionRoute: '/inscription',
  ),
  '/joyn-plus': InformationPage(
    eyebrow: 'Produit',
    title: 'Joyn+',
    introduction: 'Les accès essentiels de JOYN, avec davantage de visibilité et d’actions.',
    sections: [
      InformationSection(
        'Les fondamentaux restent inclus',
        'Profil, recommandations, suivi des candidatures et messagerie restent au cœur du parcours.',
      ),
      InformationSection(
        'Plus de possibilités',
        'La formule présentée inclut les « Intéressé » illimités, une mise en avant hebdomadaire et la visibilité sur les entreprises ayant consulté le profil.',
      ),
      InformationSection(
        'Une formule mensuelle',
        'La landing affiche JOYN+ à 15,99 € par mois avec sept jours offerts, conformément à la maquette fournie.',
      ),
    ],
    actionLabel: 'Découvrir JOYN+',
    actionRoute: '/inscription',
  ),
  '/matching': InformationPage(
    eyebrow: 'Produit',
    title: 'Le matching JOYN',
    introduction: 'Faire ressortir les critères qui rapprochent une opportunité et un profil.',
    sections: [
      InformationSection(
        'Côté candidat',
        'Le parcours de recommandation s’appuie sur le profil et les informations de l’offre pour ordonner les opportunités à découvrir.',
      ),
      InformationSection(
        'Côté entreprise',
        'Les recruteurs disposent du même principe de recommandation pour consulter des profils pertinents autour de leurs offres.',
      ),
      InformationSection(
        'Un point de départ, pas une décision',
        'La recommandation aide à prioriser la découverte. La candidature, l’échange et la décision de recrutement restent des étapes distinctes.',
      ),
    ],
  ),
  '/publier-offre': InformationPage(
    eyebrow: 'Entreprises',
    title: 'Publier une offre',
    introduction: 'Structurez votre besoin puis suivez le recrutement dans un espace unique.',
    sections: [
      InformationSection(
        'Présentez le poste',
        'Intitulé, contrat, localisation, rythme, missions et compétences attendues permettent de donner un cadre clair aux candidats.',
      ),
      InformationSection(
        'Pilotez sa visibilité',
        'Le parcours recruteur regroupe la création, la modification et la clôture d’une offre.',
      ),
      InformationSection(
        'Suivez les candidatures',
        'Les candidatures, leurs statuts et les conversations restent liées à l’offre concernée.',
      ),
    ],
    actionLabel: 'Créer un compte entreprise',
    actionRoute: '/inscription',
  ),
  '/guide-alternance': InformationPage(
    eyebrow: 'Ressources',
    title: 'Guide de l’alternance',
    introduction: 'Des repères simples pour rendre ta recherche plus claire et plus efficace.',
    sections: [
      InformationSection(
        'Prépare un profil concret',
        'Présente ta formation, tes projets et tes compétences avec des exemples. Ajoute ton rythme d’école, ta mobilité et ta date de disponibilité.',
      ),
      InformationSection(
        'Lis une offre avec méthode',
        'Sépare les missions, les compétences demandées, le lieu, le rythme et les conditions. Tu vois plus vite ce qui correspond réellement à ton projet.',
      ),
      InformationSection(
        'Prépare la conversation',
        'Choisis deux ou trois projets que tu sais expliquer : ton rôle, la difficulté rencontrée, la solution choisie et ce que tu en as appris.',
      ),
      InformationSection(
        'Un exemple simple',
        'Au lieu de dire « je connais Flutter », explique une interface que tu as réalisée, la contrainte rencontrée et le résultat obtenu.',
      ),
    ],
  ),
  '/questions-frequentes': InformationPage(
    eyebrow: 'Ressources',
    title: 'Questions fréquentes',
    introduction:
        'Les réponses essentielles pour comprendre les parcours JOYN.',
    sections: [
      InformationSection(
        'À qui s’adresse JOYN ?',
        'Aux candidats qui recherchent une alternance et aux entreprises qui recrutent.',
      ),
      InformationSection(
        'À quoi sert le matching ?',
        'À faire remonter des opportunités ou des profils à explorer en priorité. Il ne remplace ni la candidature ni la décision de recrutement.',
      ),
      InformationSection(
        'Où suivre une candidature ?',
        'Le parcours candidat prévoit une page dédiée aux candidatures envoyées, avec leur statut et l’accès aux échanges associés.',
      ),
      InformationSection(
        'Que peut gérer une entreprise ?',
        'Son profil, ses offres, les profils recommandés, les candidatures reçues, leurs statuts et les conversations liées au recrutement.',
      ),
    ],
  ),
  '/contact': InformationPage(
    eyebrow: 'Ressources',
    title: 'Centre d’aide',
    introduction: 'Retrouve rapidement le bon point d’entrée selon ton besoin.',
    sections: [
      InformationSection(
        'Je cherche une alternance',
        'Commence par ton profil, puis consulte les offres recommandées et le suivi de tes candidatures.',
      ),
      InformationSection(
        'Je recrute',
        'Crée ton espace entreprise, prépare une offre et utilise le tableau de suivi pour organiser les candidatures.',
      ),
      InformationSection(
        'J’ai une question sur le produit',
        'La page Questions fréquentes regroupe les réponses sur le matching, les candidatures et l’espace recruteur.',
      ),
    ],
    actionLabel: 'Voir les questions fréquentes',
    actionRoute: '/questions-frequentes',
  ),
  '/confidentialite': InformationPage(
    eyebrow: 'Légal',
    title: 'Confidentialité',
    introduction: 'Principes de confidentialité applicables à l’interface publique présentée ici.',
    sections: [
      InformationSection(
        'Données de la landing',
        'Les interactions des démonstrations de la landing restent dans l’état local de la page et ne déclenchent pas de candidature, d’offre ou de message réseau.',
      ),
      InformationSection(
        'Accès au compte',
        'Les routes de connexion et d’inscription sont séparées de la landing. La collecte et le traitement de données ne doivent commencer qu’au moment où un parcours de compte réellement connecté est utilisé.',
      ),
      InformationSection(
        'Principe de minimisation',
        'Une fonctionnalité ne doit demander que les informations nécessaires à son usage et les afficher uniquement dans le contexte prévu.',
      ),
      InformationSection(
        'Transparence',
        'Les informations juridiques propres à l’exploitant du service doivent être fournies par l’entité responsable avant toute mise en production publique.',
      ),
    ],
  ),
  '/conditions': InformationPage(
    eyebrow: 'Légal',
    title: 'Conditions d’utilisation',
    introduction: 'Règles d’usage de l’interface publique JOYN.',
    sections: [
      InformationSection(
        'Utilisation du site',
        'La landing permet de découvrir le produit, ses parcours et ses formules. Les démonstrations visuelles n’exécutent pas d’action métier sur un compte utilisateur.',
      ),
      InformationSection(
        'Comptes et contenus',
        'Les espaces candidat et recruteur sont destinés à des informations exactes, pertinentes et directement liées à la recherche d’alternance ou au recrutement.',
      ),
      InformationSection(
        'Décisions de recrutement',
        'Une recommandation ou un score de compatibilité sert à organiser la découverte. Il ne constitue ni une promesse d’entretien ni une décision d’embauche.',
      ),
      InformationSection(
        'Informations contractuelles',
        'Les mentions d’éditeur, de responsabilité, de juridiction et les conditions commerciales opposables relèvent de l’exploitant juridique du service.',
      ),
    ],
  ),
  '/cookies': InformationPage(
    eyebrow: 'Légal',
    title: 'Cookies',
    introduction: 'Fonctionnement de la landing concernant le stockage local et les traceurs.',
    sections: [
      InformationSection(
        'Démonstrations interactives',
        'Leur état est conservé uniquement en mémoire pendant l’affichage de la page. Cette implémentation n’écrit pas ces interactions dans un cookie ou un stockage persistant.',
      ),
      InformationSection(
        'Préférences du navigateur',
        'L’interface respecte notamment la préférence système de réduction des animations pour limiter les mouvements automatiques.',
      ),
      InformationSection(
        'Services externes',
        'Tout ajout futur d’outil de mesure, d’authentification externe ou de traceur doit être documenté dans cette page et soumis au mécanisme de consentement requis.',
      ),
    ],
  ),
};
