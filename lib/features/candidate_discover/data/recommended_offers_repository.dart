import '../domain/recommended_offer.dart';

/// Accès aux offres recommandées au candidat connecté.
abstract interface class RecommendedOffersRepository {
  /// Charge les offres recommandées.
  Future<DiscoverFeed> fetchFeed({DiscoverFilters filters});

  /// Enregistre le geste du candidat.
  Future<void> submitDecision(String offerId, SwipeDecision decision);

  /// Annule le dernier geste.
  Future<void> cancelDecision(String offerId);
}

/// Contrat supplémentaire pour les repositories qui
/// prennent en charge la pagination côté serveur.
///
/// Les anciens repositories et les tests peuvent continuer
/// à utiliser RecommendedOffersRepository.
abstract interface class PaginatedRecommendedOffersRepository {
  Future<DiscoverFeed> fetchPage({
    DiscoverFilters filters = const DiscoverFilters(),
    int page = 1,
    int limit = 10,
  });
}
