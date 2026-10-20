import 'package:flutter/material.dart';

/// Vocabulaire partagé des deux sélecteurs, sans coupler leurs états d'interface.
enum Audience { candidate, company }

/// Une fonctionnalité publique liée à des cartes du backlog fourni.
/// Les références permettent d'auditer le contenu sans l'exposer dans l'UI.
@immutable
class LandingFeature {
  const LandingFeature({required this.title, required this.summary,
    required this.detail, required this.icon, required this.references,
    required this.steps});
  final String title;
  final String summary;
  final String detail;
  final IconData icon;
  final List<String> references;
  final List<String> steps;
}

/// Présentation de la cible produit décrite dans Trello, sans affirmer que les
/// services backend sont déjà déployés ou connectés à cette landing.
const candidateFeatures = [
  LandingFeature(title: 'Un profil qui te ressemble',
    summary: 'Tes compétences et ton parcours, au même endroit.',
    detail: 'Renseigne ton parcours, importe ton CV pour préremplir les informations '
      'disponibles, puis vérifie et complète ton profil avant de candidater.',
    icon: Icons.badge_outlined, references: ['CA29', 'CA53', 'CA56', 'CA68'],
    steps: ['Importer le CV', 'Vérifier les informations', 'Compléter le profil']),
  LandingFeature(title: 'Des offres recommandées',
    summary: 'Découvre des opportunités à partir de ton profil.',
    detail: 'Consulte les offres recommandées et leurs informations pour choisir '
      'les postes auxquels tu souhaites candidater.',
    icon: Icons.auto_awesome_outlined, references: ['CA20', 'CA33'],
    steps: ['Explorer les recommandations', 'Lire l’offre', 'Choisir un poste']),
  LandingFeature(title: 'Tes candidatures, sans te perdre',
    summary: 'Un espace pour retrouver tes envois et leurs statuts.',
    detail: 'Envoie ta candidature depuis une offre puis retrouve tes démarches '
      'dans ton tableau de bord et ta liste de candidatures.',
    icon: Icons.view_kanban_outlined, references: ['CA27', 'CA30', 'CA57', 'CA76'],
    steps: ['Candidater', 'Retrouver ses envois', 'Consulter les statuts']),
  LandingFeature(title: 'La conversation au bon endroit',
    summary: 'Échange avec le recruteur dans le contexte de ta candidature.',
    detail: 'Retrouve les conversations liées à une offre ou à une candidature, '
      'les messages échangés et leur état de lecture.',
    icon: Icons.forum_outlined, references: ['CO31', 'CO26'],
    steps: ['Ouvrir une conversation', 'Échanger', 'Retrouver les messages']),
];

const companyFeatures = [
  LandingFeature(title: 'Présentez votre entreprise',
    summary: 'Un espace pour votre identité et vos informations.',
    detail: 'Enregistrez votre entreprise et renseignez sa présentation. '
      'Le parcours prévoit une validation de l’entreprise par l’administration.',
    icon: Icons.apartment_rounded, references: ['R46', 'R59', 'R65', 'A62'],
    steps: ['Créer le compte', 'Présenter l’entreprise', 'Faire valider le profil']),
  LandingFeature(title: 'Pilotez vos offres',
    summary: 'De la création à la clôture, gardez la main.',
    detail: 'Créez une offre, mettez ses informations à jour et clôturez-la '
      'lorsque votre recrutement est terminé.',
    icon: Icons.work_outline_rounded, references: ['R38', 'R39', 'R58', 'R70', 'R71'],
    steps: ['Créer une offre', 'Mettre à jour', 'Clôturer le recrutement']),
  LandingFeature(title: 'Découvrez des candidats',
    summary: 'Des recommandations pour accompagner vos recherches.',
    detail: 'Consultez les profils recommandés pour vos recrutements et '
      'retrouvez les informations utiles dans votre tableau de bord.',
    icon: Icons.people_outline_rounded, references: ['R45', 'R34', 'R47', 'R49'],
    steps: ['Consulter les recommandations', 'Lire les profils', 'Sélectionner']),
  LandingFeature(title: 'Suivez chaque candidature',
    summary: 'Statuts et échanges réunis autour de vos recrutements.',
    detail: 'Mettez à jour le statut des candidatures reçues et échangez '
      'dans les conversations associées aux offres ou candidatures.',
    icon: Icons.fact_check_outlined, references: ['R72', 'R74', 'CO31', 'CO26'],
    steps: ['Lire les candidatures', 'Actualiser le statut', 'Échanger']),
];
