// Décrit les groupes de navigation et les liens partagés entre les menus.
//
// Référence : doc/landing.md#landing_navigationdart.

/// Lien composé d’un libellé, d’une description et d’une cible de navigation.
class LandingLink {
  /// Initialise les paramètres de LandingLink ; les valeurs par défaut figurent dans la signature.
  const LandingLink(this.label, this.description, this.target);

  /// Libellé présenté à l’utilisateur.
  final String label;

  /// Texte de contexte associé au titre ou au lien.
  final String description;

  /// Cible d’ancre ou de route transmise à la navigation.
  final String target;
}

/// Groupe de liens accompagné d’un titre et d’un texte de contexte.
class LandingGroup {
  /// Initialise les paramètres de LandingGroup ; les valeurs par défaut figurent dans la signature.
  const LandingGroup(this.label, this.title, this.description, this.links);

  /// Libellé présenté à l’utilisateur.
  final String label;

  /// Titre affiché dans cette composition.
  final String title;

  /// Texte de contexte associé au titre ou au lien.
  final String description;

  /// Liens appartenant au groupe.
  final List<LandingLink> links;
}

/// Groupes éditoriaux partagés par les différentes présentations du menu.
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
        'Comprendre une offre',
        'Missions, conditions et candidature.',
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
    'Les avantages pour ta recherche.',
    'Profil, offres correspondantes et suivi des candidatures.',
    [
      LandingLink(
        'Avantages candidat',
        'Ce que JOYN apporte à chaque étape.',
        'benefices-candidat',
      ),
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
        'guide-entretien',
      ),
    ],
  ),
  LandingGroup(
    'RECRUTEURS',
    'Les avantages pour le recrutement.',
    'Offres, profils et organisation des candidatures.',
    [
      LandingLink(
        'Avantages recruteur',
        'Du besoin de recrutement au suivi.',
        'benefices-recruteur',
      ),
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
    'FORMULES',
    'Comparer les accès et les outils.',
    'Quatre formules candidat et deux formules entreprise, avec leurs tarifs mensuels.',
    [
      LandingLink(
        'Candidats',
        'Basic, Standard, Plus et Pro.',
        'plans-candidat',
      ),
      LandingLink(
        'Recruteurs',
        'Membre et Membre premium.',
        'plans-entreprise',
      ),
      LandingLink('Sur téléphone', 'Le parcours sur un petit écran.', 'mobile'),
    ],
  ),
];

/// Liens de l’aide, de la FAQ et des guides.
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

/// Liens de connexion et de consultation des services.
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
      'Comparer les tarifs et accès mensuels.',
      'offres',
    ),
  ],
);
