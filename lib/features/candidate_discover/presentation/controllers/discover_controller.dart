import 'package:flutter/foundation.dart';

import '../../data/recommended_offers_repository.dart';
import '../../domain/recommended_offer.dart';

enum DiscoverStatus { loading, ready, error }

/// Un geste déjà effectué, gardé pour pouvoir l'annuler.
class DiscoverHistoryEntry {
  const DiscoverHistoryEntry(this.offer, this.decision);

  final RecommendedOffer offer;
  final SwipeDecision decision;
}

/// État de la page « Matchs » : pile de cartes, gestes et annulation.
///
/// Partagé entre le Web et le Mobile. Les gestes sont **optimistes** : la
/// carte quitte la pile tout de suite, puis revient en tête si le backend
/// refuse.
class DiscoverController extends ChangeNotifier {
  DiscoverController(this._repository);

  final RecommendedOffersRepository _repository;

  DiscoverStatus _status = DiscoverStatus.loading;
  DiscoverStatus get status => _status;

  String? _errorMessage;

  /// Erreur de chargement de la pile.
  String? get errorMessage => _errorMessage;

  String? _actionError;

  /// Erreur du dernier geste (à afficher dans un SnackBar).
  String? get actionError => _actionError;

  List<RecommendedOffer> _offers = const [];

  /// Offres restantes ; la première est la carte du dessus.
  List<RecommendedOffer> get offers => List.unmodifiable(_offers);

  RecommendedOffer? get current => _offers.isEmpty ? null : _offers.first;

  DiscoverFilters _filters = const DiscoverFilters();
  DiscoverFilters get filters => _filters;

  int _totalCompatible = 0;

  /// Nombre d'offres compatibles annoncé dans le sous-titre.
  int get totalCompatible => _totalCompatible;

  final List<DiscoverHistoryEntry> _history = [];
  List<DiscoverHistoryEntry> get history => List.unmodifiable(_history);

  bool get canUndo => _history.isNotEmpty;

  int get interestedCount =>
      _history.where((e) => e.decision == SwipeDecision.interested).length;

  int get savedCount =>
      _history.where((e) => e.decision == SwipeDecision.save).length;

  bool _disposed = false;

  Future<void> load() async {
    _status = DiscoverStatus.loading;
    _errorMessage = null;
    _notify();
    try {
      final feed = await _repository.fetchFeed(filters: _filters);
      _offers = [...feed.offers];
      _filters = feed.filters;
      _totalCompatible = feed.totalCompatible;
      _history.clear();
      _status = DiscoverStatus.ready;
    } catch (_) {
      _errorMessage = 'Impossible de charger vos offres recommandées.';
      _status = DiscoverStatus.error;
    }
    _notify();
  }

  /// Applique [decision] à la carte du dessus.
  ///
  /// Renvoie `false` si le backend a refusé : la carte est alors remise en
  /// tête de pile et [actionError] est renseigné.
  Future<bool> decide(SwipeDecision decision) async {
    final offer = current;
    if (offer == null) return false;

    final entry = DiscoverHistoryEntry(offer, decision);
    _offers = [..._offers]..removeAt(0);
    _history.add(entry);
    _actionError = null;
    _notify();

    try {
      await _repository.submitDecision(offer.id, decision);
      return true;
    } catch (_) {
      _history.remove(entry);
      _offers = [offer, ..._offers];
      _actionError = switch (decision) {
        SwipeDecision.interested =>
          "L'offre n'a pas pu être ajoutée à vos candidatures.",
        SwipeDecision.save => "L'offre n'a pas pu être sauvegardée.",
        SwipeDecision.skip => "L'offre n'a pas pu être ignorée.",
      };
      _notify();
      return false;
    }
  }

  /// Annule le dernier geste et remet la carte sur le dessus de la pile.
  Future<bool> undo() async {
    if (_history.isEmpty) return false;
    final entry = _history.removeLast();
    _offers = [entry.offer, ..._offers];
    _actionError = null;
    _notify();

    try {
      await _repository.cancelDecision(entry.offer.id);
      return true;
    } catch (_) {
      _offers = [..._offers]..remove(entry.offer);
      _history.add(entry);
      _actionError = "Impossible d'annuler ce choix.";
      _notify();
      return false;
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
