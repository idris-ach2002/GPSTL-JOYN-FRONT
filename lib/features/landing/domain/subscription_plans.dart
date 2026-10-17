// Catalogue présenté dans la landing ; ne constitue pas un contrôle de droits.

/// Formule mensuelle avec prix en centimes et prestations cumulatives.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.monthlyCents,
    required this.intention,
    required this.features,
  });
  final String id;
  final String name;
  final int monthlyCents;
  final String intention;
  final List<(String, String)> features;

  /// Conserve la précision des centimes sans calcul flottant.
  String get price {
    if (monthlyCents == 0) {
      return 'Gratuit';
    }
    final euros = monthlyCents ~/ 100;
    final cents = monthlyCents % 100;
    return cents == 0
        ? '$euros €'
        : '$euros,${cents.toString().padLeft(2, '0')} €';
  }
}

/// Quatre niveaux pour organiser une recherche individuelle.
const candidatePlans = [
  SubscriptionPlan(
    id: 'candidate-basic',
    name: 'Basic',
    monthlyCents: 0,
    intention: 'Commencer avec les fonctions essentielles.',
    features: [
      ('Profil et CV', '1 CV associé au profil'),
      ('Recommandations', 'Offres correspondant au profil'),
      ('Candidatures', '5 candidatures par mois'),
      ('Favoris', '10 offres enregistrées'),
      ('Organisation', 'Suivi des statuts'),
    ],
  ),
  SubscriptionPlan(
    id: 'candidate-standard',
    name: 'Standard',
    monthlyCents: 1099,
    intention: 'Candidater sans limite de volume.',
    features: [
      ('Tout Basic', 'Profil, recommandations et suivi'),
      ('Candidatures', 'Sans limite mensuelle'),
      ('Favoris', 'Sans limite d’enregistrement'),
      ('CV', '3 versions pour préparer ses démarches'),
      ('Organisation', 'Notes privées par candidature'),
    ],
  ),
  SubscriptionPlan(
    id: 'candidate-plus',
    name: 'Plus',
    monthlyCents: 1999,
    intention: 'Structurer plusieurs recherches en parallèle.',
    features: [
      ('Tout Standard', 'Candidatures et favoris illimités'),
      ('CV', '5 versions disponibles'),
      ('Dossiers', 'Classement personnel des candidatures'),
      ('Tableau de bord', 'Vue par statut et par dossier'),
      ('Export', 'Export du suivi en CSV'),
    ],
  ),
  SubscriptionPlan(
    id: 'candidate-pro',
    name: 'Pro',
    monthlyCents: 3999,
    intention: 'Piloter sa recherche avec une vue complète.',
    features: [
      ('Tout Plus', 'Dossiers, tableau de bord et export'),
      ('CV', '10 versions disponibles'),
      ('Organisation', 'Tags et priorités personnalisés'),
      ('Analyse du suivi', 'Répartition des démarches par statut'),
      ('Export', 'Rapport de suivi PDF et CSV'),
    ],
  ),
];

/// Deux niveaux pour un recrutement individuel ou partagé en entreprise.
const companyPlans = [
  SubscriptionPlan(
    id: 'company-member',
    name: 'Membre',
    monthlyCents: 0,
    intention: 'Gérer un premier recrutement.',
    features: [
      ('Accès', '1 compte recruteur'),
      ('Publication', '1 offre active'),
      ('Profils', '20 profils consultables par mois'),
      ('Candidatures', 'Suivi des candidatures par offre'),
      ('Entreprise', 'Présentation de l’entreprise'),
    ],
  ),
  SubscriptionPlan(
    id: 'company-premium',
    name: 'Membre premium',
    monthlyCents: 10000,
    intention: 'Répartir les recrutements et leur administration.',
    features: [
      ('Tout Membre', 'Présentation et suivi des candidatures'),
      ('Accès', 'Jusqu’à 10 comptes recruteurs'),
      ('Publication', 'Jusqu’à 20 offres actives'),
      ('Profils', 'Consultation sans limite mensuelle'),
      ('Administration', 'Rôles et attribution des candidatures'),
      ('Pilotage', 'Tableau de bord partagé et exports CSV'),
    ],
  ),
];
