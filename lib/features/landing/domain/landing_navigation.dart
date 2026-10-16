class LandingLink {
  const LandingLink(this.label, this.description, this.target);
  final String label;
  final String description;
  final String target;
}

class LandingGroup {
  const LandingGroup(this.label, this.title, this.description, this.links);
  final String label;
  final String title;
  final String description;
  final List<LandingLink> links;
}

const landingGroups = [
  LandingGroup(
    'COMPRENDRE',
    'Le match avant la candidature.',
    'Les attentes sont plus faciles à comparer lorsqu’elles sont explicites.',
    [
      LandingLink(
        'Le principe JOYN',
        'Profil, offre et intérêt partagé.',
        'hero',
      ),
      LandingLink(
        'Les difficultés de recherche',
        'Rythme, mobilité, compétences et réponses.',
        'difficultes',
      ),
      LandingLink(
        'Avant / après',
        'Comparer une même recherche.',
        'comparaison',
      ),
      LandingLink(
        'Parcours candidat',
        'Du profil au premier échange.',
        'parcours',
      ),
      LandingLink(
        'Le matching expliqué',
        'Comprendre les recommandations.',
        'matching',
      ),
    ],
  ),
  LandingGroup(
    'FONCTIONNALITÉS',
    'Comprendre ce que chaque outil apporte.',
    'Profil, offres, candidatures et échanges : les étapes de ta recherche.',
    [
      LandingLink(
        'Profil et CV',
        'Un CV analysé à la création du profil.',
        'profil',
      ),
      LandingLink(
        'Critères de compatibilité',
        'Lieu, rythme et compétence.',
        'matching',
      ),
      LandingLink(
        'Favoris et alertes',
        'Filtrer et retrouver les offres.',
        'opportunites',
      ),
      LandingLink(
        'Messagerie réciproque',
        'Pourquoi faut-il deux intérêts ?',
        'reciprocite',
      ),
      LandingLink(
        'Suivi des candidatures',
        'Lire les prochaines actions.',
        'suivi',
      ),
    ],
  ),
  LandingGroup(
    'CANDIDATS',
    'Ton parcours, avec ton contexte.',
    'Un profil n’est pas uniquement une liste de technologies.',
    [
      LandingLink(
        'Construire mon profil',
        'Motivation, preuves et contraintes.',
        'profil',
      ),
      LandingLink(
        'Explorer les offres',
        'Comparer des exemples filtrables.',
        'opportunites',
      ),
      LandingLink(
        'Préparer le premier échange',
        'Questions concrètes pour l’entretien.',
        'ressources',
      ),
    ],
  ),
  LandingGroup(
    'RECRUTEURS',
    'Gérer les offres et les candidatures.',
    'Décrire le besoin, consulter les profils et suivre les candidatures.',
    [
      LandingLink(
        'Présenter un poste',
        'Missions, compétences et conditions du poste.',
        'entreprises',
      ),
      LandingLink(
        'Comprendre un profil',
        'Lire une motivation et ses critères.',
        'entreprises',
      ),
      LandingLink(
        'Gérer les candidatures',
        'Retrouver les candidatures par offre.',
        'suivi',
      ),
    ],
  ),
  LandingGroup(
    'RESSOURCES',
    'Des repères pour avancer.',
    'Des réponses pour préparer son profil et ses candidatures.',
    [
      LandingLink(
        'Guide du profil',
        'Décrire une compétence avec des preuves.',
        'guide-profil',
      ),
      LandingLink(
        'Comprendre un matching',
        'Comprendre les offres proposées.',
        'guide-matching',
      ),
      LandingLink(
        'Préparer un entretien',
        'Présenter un projet et poser ses questions.',
        'guide-entretien',
      ),
      LandingLink(
        'Questions fréquentes',
        'Candidats et recruteurs.',
        'questions',
      ),
      LandingLink(
        'Présentation de JOYN',
        'Le fonctionnement de JOYN.',
        'presentation',
      ),
    ],
  ),
  LandingGroup(
    'OFFRES',
    'Les services selon ton besoin.',
    'Profil candidat ou recrutement en entreprise : consulte les services associés.',
    [
      LandingLink(
        'Candidats',
        'Profil, offres et suivi des candidatures.',
        'offres',
      ),
      LandingLink(
        'Recruteurs',
        'Offres, profils et gestion des candidatures.',
        'offres',
      ),
      LandingLink('Sur téléphone', 'Le parcours sur un petit écran.', 'mobile'),
    ],
  ),
];

const assistanceGroup = LandingGroup(
  'ASSISTANCE',
  'Comment pouvons-nous t’aider ?',
  'Trouver une information ou obtenir de l’aide.',
  [
    LandingLink(
      'Centre d’aide',
      'Trouver une réponse par sujet.',
      'assistance',
    ),
    LandingLink(
      'Questions fréquentes',
      'Candidats et recruteurs.',
      'questions',
    ),
    LandingLink(
      'Guide du profil',
      'Relier compétences et réalisations.',
      'guide-profil',
    ),
    LandingLink(
      'Lire un matching',
      'Comprendre les recommandations.',
      'guide-matching',
    ),
    LandingLink(
      'Préparer un entretien',
      'Construire son récit et ses questions.',
      'guide-entretien',
    ),
  ],
);
const accountGroup = LandingGroup(
  'CONNEXION',
  'Ton espace JOYN.',
  'Choisis ton parcours pour voir le formulaire de connexion.',
  [
    LandingLink(
      'Se connecter',
      'Ouvrir l’interface de connexion.',
      'connexion',
    ),
    LandingLink(
      'Présenter mon profil',
      'Présenter son expérience et ses compétences.',
      'profil',
    ),
    LandingLink(
      'Comprendre les formules',
      'Consulter les services candidat et recruteur.',
      'offres',
    ),
  ],
);
