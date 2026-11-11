import '../domain/recommended_offer.dart';

/// Accès aux offres recommandées au candidat connecté.
///
/// Deux implémentations :
/// - `MockRecommendedOffersRepository` : données de démo, en mémoire ;
/// - `ApiRecommendedOffersRepository` : backend JOYN (contrat dans
///   `docs/candidate-discover.md`).
///
/// Le choix se fait dans `lib/app/bootstrap.dart` selon `JOYN_DATA_MODE`.
abstract interface class RecommendedOffersRepository {
  /// Offres à proposer, triées par compatibilité décroissante.
  ///
  /// Les offres déjà traitées (postulées, passées, sauvegardées) n'y figurent
  /// plus.
  Future<DiscoverFeed> fetchFeed({DiscoverFilters filters});

  /// Enregistre le geste du candidat sur une offre.
  ///
  /// [SwipeDecision.interested] crée une candidature au statut « intéressé »
  /// (non encore envoyée à l'entreprise).
  Future<void> submitDecision(String offerId, SwipeDecision decision);

  /// Annule le dernier geste (bouton « Annuler »).
  ///
  /// La candidature « intéressé » éventuellement créée est retirée.
  Future<void> cancelDecision(String offerId);
}
