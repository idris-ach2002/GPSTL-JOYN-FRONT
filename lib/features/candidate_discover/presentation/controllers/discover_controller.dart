import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/recommended_offers_repository.dart';
import '../../domain/recommended_offer.dart';

enum DiscoverStatus { loading, ready, error }

class DiscoverHistoryEntry {
  const DiscoverHistoryEntry(this.offer, this.decision);

  final RecommendedOffer offer;
  final SwipeDecision decision;
}

class DiscoverController extends ChangeNotifier {
  DiscoverController(this._repository);

  final RecommendedOffersRepository _repository;

  static const int _pageSize = 10;

  DiscoverStatus _status = DiscoverStatus.loading;
  DiscoverStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _actionError;
  String? get actionError => _actionError;

  List<RecommendedOffer> _offers = const [];

  List<RecommendedOffer> get offers => List.unmodifiable(_offers);

  RecommendedOffer? get current => _offers.isEmpty ? null : _offers.first;

  DiscoverFilters _filters = const DiscoverFilters();
  DiscoverFilters get filters => _filters;

  int _totalCompatible = 0;
  int get totalCompatible => _totalCompatible;

  final List<DiscoverHistoryEntry> _history = [];

  List<DiscoverHistoryEntry> get history => List.unmodifiable(_history);

  bool get canUndo => _history.isNotEmpty;

  int get interestedCount => _history
      .where((entry) => entry.decision == SwipeDecision.interested)
      .length;

  int get savedCount =>
      _history.where((entry) => entry.decision == SwipeDecision.save).length;

  bool _hasMore = false;
  bool _loadingMore = false;

  bool get loadingMore => _loadingMore;
  bool get hasMore => _hasMore;

  bool _disposed = false;
  int _loadVersion = 0;

  Future<void> applyFilters(DiscoverFilters value) async {
    _filters = value;
    await load();
  }

  // Charge une petite page de recommandations.

  Future<DiscoverFeed> _fetchSmallPage() {
    final repository = _repository;

    if (repository is PaginatedRecommendedOffersRepository) {
      final paginated = repository as PaginatedRecommendedOffersRepository;

      return paginated.fetchPage(filters: _filters, page: 1, limit: _pageSize);
    }

    return repository.fetchFeed(filters: _filters);
  }

  // Chargement initial de l'écran Découvrir.
  Future<void> load() async {
    final version = ++_loadVersion;

    _status = DiscoverStatus.loading;
    _errorMessage = null;
    _loadingMore = false;
    _hasMore = false;

    _notify();

    try {
      final feed = await _fetchSmallPage();

      if (_disposed || version != _loadVersion) {
        return;
      }

      _offers = [...feed.offers];
      _filters = feed.filters;
      _totalCompatible = feed.totalCompatible;
      _hasMore = feed.hasNext;

      _history.clear();
      _status = DiscoverStatus.ready;
    } catch (_) {
      if (_disposed || version != _loadVersion) {
        return;
      }

      _errorMessage = 'Impossible de charger vos offres recommandées.';

      _status = DiscoverStatus.error;
    }

    _notify();
  }

  // Préchargement des prochaines offres.
  Future<void> loadMore() async {
    if (_disposed ||
        _loadingMore ||
        !_hasMore ||
        _status != DiscoverStatus.ready) {
      return;
    }

    final version = _loadVersion;

    _loadingMore = true;
    _notify();

    try {
      final feed = await _fetchSmallPage();

      if (_disposed || version != _loadVersion) {
        return;
      }

      // Évite d'ajouter deux fois la même offre.
      final alreadySeen = <String>{
        for (final offer in _offers) offer.id,
        for (final entry in _history) entry.offer.id,
      };

      final newOffers = [
        for (final offer in feed.offers)
          if (alreadySeen.add(offer.id)) offer,
      ];

      _offers = [..._offers, ...newOffers];

      _totalCompatible = feed.totalCompatible;
      _hasMore = feed.hasNext;
      _errorMessage = null;
    } catch (_) {
      if (_disposed || version != _loadVersion) {
        return;
      }

      _errorMessage = 'Impossible de charger davantage d’offres.';
    } finally {
      if (!_disposed && version == _loadVersion) {
        _loadingMore = false;
        _notify();
      }
    }
  }

  // Enregistre un swipe sur la carte courante.
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

      // Préchargement lorsque la pile devient petite.
      if (_offers.length <= 3 && _hasMore) {
        unawaited(loadMore());
      }

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

  // Annule le dernier geste.
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
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
