# `landing_navigation.dart`

Décrit les groupes de navigation et les liens partagés entre les menus.

[Code source](../../../lib/features/landing/domain/landing_navigation.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `LandingLink` | `Bibliothèque` | Lien composé d’un libellé, d’une description et d’une cible de navigation. | `class LandingLink` |
| `LandingLink` | `LandingLink` | Initialise les paramètres de LandingLink ; les valeurs par défaut figurent dans la signature. | `const LandingLink(this.label, this.description, this.target)` |
| `LandingGroup` | `Bibliothèque` | Groupe de liens accompagné d’un titre et d’un texte de contexte. | `class LandingGroup` |
| `LandingGroup` | `LandingGroup` | Initialise les paramètres de LandingGroup ; les valeurs par défaut figurent dans la signature. | `const LandingGroup(this.label, this.title, this.description, this.links)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `label` | `LandingLink` | Libellé présenté à l’utilisateur. | `final String label` |
| `description` | `LandingLink` | Texte de contexte associé au titre ou au lien. | `final String description` |
| `target` | `LandingLink` | Cible d’ancre ou de route transmise à la navigation. | `final String target` |
| `label` | `LandingGroup` | Libellé présenté à l’utilisateur. | `final String label` |
| `title` | `LandingGroup` | Titre affiché dans cette composition. | `final String title` |
| `description` | `LandingGroup` | Texte de contexte associé au titre ou au lien. | `final String description` |
| `links` | `LandingGroup` | Liens appartenant au groupe. | `final List<LandingLink> links` |
| `landingGroups` | `Bibliothèque` | Groupes éditoriaux partagés par les différentes présentations du menu. | `landingGroups = [ LandingGroup('COMPRENDRE', 'Le match avant la candidature.', 'Les attentes sont plus faciles à comparer lorsqu’elles sont explicites.', [ LandingLink('Le principe JOYN', 'Profil, offre et intérêt partagé.', 'hero'), LandingLink('Les difficultés de recherche', 'Rythme, mobilité, compétences et réponses.', 'difficultes'), LandingLink('Avant / après', 'Comparer une même recherche.', 'comparaison'), LandingLink('Parcours candidat', 'Du profil au premier échange.', 'parcours'), LandingLink('Le matching expliqué', 'Comprendre les recommandations.', 'matching'), ]), LandingGroup('FONCTIONNALITÉS', 'Comprendre ce que chaque outil apporte.', 'Profil, offres, candidatures et échanges : les étapes de ta recherche.', [ LandingLink('Profil et CV', 'Un CV analysé à la création du profil.', 'profil'), LandingLink('Critères de compatibilité', 'Lieu, rythme et compétence.', 'matching'), LandingLink('Favoris et alertes', 'Filtrer et retrouver les offres.', 'opportunites'), LandingLink('Messagerie réciproque', 'Pourquoi faut-il deux intérêts ?', 'reciprocite'), LandingLink('Suivi des candidatures', 'Lire les prochaines actions.', 'suivi'), ]), LandingGroup('CANDIDATS', 'Ton parcours, avec ton contexte.', 'Un profil n’est pas uniquement une liste de technologies.', [ LandingLink('Construire mon profil', 'Motivation, preuves et contraintes.', 'profil'), LandingLink('Explorer les offres', 'Comparer des exemples filtrables.', 'opportunites'), LandingLink('Préparer le premier échange', 'Questions concrètes pour l’entretien.', 'ressources'), ]), LandingGroup('RECRUTEURS', 'Gérer les offres et les candidatures.', 'Décrire le besoin, consulter les profils et suivre les candidatures.', [ LandingLink('Présenter un poste', 'Missions, compétences et conditions du poste.', 'entreprises'), LandingLink('Comprendre un profil', 'Lire une motivation et ses critères.', 'entreprises'), LandingLink('Gérer les candidatures', 'Retrouver les candidatures par offre.', 'suivi'), ]), LandingGroup('RESSOURCES', 'Des repères pour avancer.', 'Des réponses pour préparer son profil et ses candidatures.', [ LandingLink('Guide du profil', 'Décrire une compétence avec des preuves.', 'guide-profil'), LandingLink('Comprendre un matching', 'Comprendre les offres proposées.', 'guide-matching'), LandingLink('Préparer un entretien', 'Présenter un projet et poser ses questions.', 'guide-entretien'), LandingLink('Questions fréquentes', 'Candidats et recruteurs.', 'questions'), LandingLink('Présentation de JOYN', 'Le fonctionnement de JOYN.', 'presentation'), ]), LandingGroup('OFFRES', 'Les services selon ton besoin.', 'Profil candidat ou recrutement en entreprise : consulte les services associés.', [ LandingLink('Candidats', 'Profil, offres et suivi des candidatures.', 'offres'), LandingLink('Recruteurs', 'Offres, profils et gestion des candidatures.', 'offres'), LandingLink('Sur téléphone', 'Le parcours sur un petit écran.', 'mobile'), ]), ]` |
| `assistanceGroup` | `Bibliothèque` | Liens de l’aide, de la FAQ et des guides. | `assistanceGroup = LandingGroup('ASSISTANCE', 'Comment pouvons-nous t’aider ?', 'Trouver une information ou obtenir de l’aide.', [ LandingLink('Centre d’aide', 'Trouver une réponse par sujet.', 'assistance'), LandingLink('Questions fréquentes', 'Candidats et recruteurs.', 'questions'), LandingLink('Guide du profil', 'Relier compétences et réalisations.', 'guide-profil'), LandingLink('Lire un matching', 'Comprendre les recommandations.', 'guide-matching'), LandingLink('Préparer un entretien', 'Construire son récit et ses questions.', 'guide-entretien'), ])` |
| `accountGroup` | `Bibliothèque` | Liens de connexion et de consultation des services. | `accountGroup = LandingGroup('CONNEXION', 'Ton espace JOYN.', 'Choisis ton parcours pour voir le formulaire de connexion.', [ LandingLink('Se connecter', 'Ouvrir l’interface de connexion.', 'connexion'), LandingLink('Présenter mon profil', 'Présenter son expérience et ses compétences.', 'profil'), LandingLink('Comprendre les formules', 'Consulter les services candidat et recruteur.', 'offres'), ])` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `this.label` | `LandingLink` | Libellé présenté à l’utilisateur. |
| `this.description` | `LandingLink` | Texte de contexte associé au titre ou au lien. |
| `this.target` | `LandingLink` | Cible d’ancre ou de route transmise à la navigation. |
| `this.label` | `LandingGroup` | Libellé présenté à l’utilisateur. |
| `this.title` | `LandingGroup` | Titre affiché dans cette composition. |
| `this.description` | `LandingGroup` | Texte de contexte associé au titre ou au lien. |
| `this.links` | `LandingGroup` | Liens appartenant au groupe. |

