/// Contenu commercial de présentation, sans valeur d'autorisation backend.
///
/// Les prix candidat sont repris de la maquette. Les droits et offres entreprise
/// sont une proposition éditoriale : aucun endpoint de facturation n'est fourni.
class PricingPlan {
  const PricingPlan({required this.name, required this.price,
    required this.period, required this.subtitle, required this.features,
    required this.action, this.highlighted = false, this.badge});
  final String name;
  final String price;
  final String period;
  final String subtitle;
  final List<String> features;
  final String action;
  final bool highlighted;
  final String? badge;
}

const candidateBaseAccess = [
  'Profil et import de CV',
  'Offres recommandées',
  'Suivi des candidatures',
  'Messagerie liée aux candidatures',
];
const companyBaseAccess = [
  'Compte recruteur',
  'Présentation de l’entreprise',
  'Gestion des informations de l’entreprise',
];

const candidatePlans = [
  PricingPlan(name: 'joyn', price: '0 €', period: 'Pour toujours',
    subtitle: 'Tout l’essentiel pour chercher ta place.',
    features: [...candidateBaseAccess, '10 « Intéressé » par jour'],
    action: 'Créer mon profil gratuit'),
  PricingPlan(name: 'joyn+', price: '15,99 €', period: '/ mois',
    subtitle: 'Plus de possibilités pour faire le bon match.',
    features: [...candidateBaseAccess, '« Intéressé » illimités',
      'Profil mis en avant chaque semaine',
      'Voir les entreprises ayant consulté ton profil'],
    action: 'Découvrir JOYN+', highlighted: true, badge: '7 jours offerts'),
  PricingPlan(name: 'Boost 48 h', price: '4,99 €', period: '/ 48 h',
    subtitle: 'Un coup de projecteur ponctuel sur ton profil.',
    features: ['Complément à ton compte JOYN ou JOYN+',
      'Mise en avant pendant 48 heures',
      'Paiement unique, sans changement de formule'],
    action: 'Découvrir le boost'),
];

const companyPlans = [
  PricingPlan(name: 'Membre', price: '0 €', period: 'Pour démarrer',
    subtitle: 'Présentez votre entreprise et préparez vos recrutements.',
    features: companyBaseAccess, action: 'Créer mon espace entreprise'),
  PricingPlan(name: 'Membre premium', price: 'Sur devis', period: 'Tarif à définir',
    subtitle: 'Un espace pour conduire vos recrutements.',
    features: [...companyBaseAccess, 'Publication et gestion des offres',
      'Recommandations de candidats', 'Suivi et statuts des candidatures',
      'Messagerie liée aux recrutements'],
    action: 'Découvrir l’espace recruteur', highlighted: true,
    badge: 'Pour recruter'),
];
