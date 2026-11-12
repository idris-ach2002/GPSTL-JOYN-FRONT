import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/verification_repository.dart';
import '../../data/api_verification_repository.dart';
import '../../domain/company_verification.dart';

enum VerificationsStatus { loading, ready, error, forbidden }

/// Résultat d'une action : message de la notification et succès ou échec.
@immutable
class VerificationActionResult {
  const VerificationActionResult.success(this.message) : succeeded = true;
  const VerificationActionResult.failure(this.message) : succeeded = false;

  final String message;
  final bool succeeded;
}

/// État de l'écran « Vérifications » : file des entreprises dont la
/// vérification automatique (API SIRENE) n'a pas abouti.
class AdminVerificationsController extends ChangeNotifier {
  AdminVerificationsController(
    this._repository, {
    this.searchDebounce = VerificationOptions.searchDebounce,
  });

  final VerificationRepository _repository;
  bool get supportsReviewWorkflow => _repository is! ApiVerificationRepository;

  /// Délai de la recherche pendant la saisie (debounce).
  final Duration searchDebounce;

  VerificationFilter _filter = VerificationFilter.toReview;
  String _search = '';
  List<CompanyVerification> _items = const [];
  String? _selectedId;
  VerificationsStatus _status = VerificationsStatus.loading;
  bool _refreshing = false;
  String? _error;
  final Set<String> _busyIds = {};
  Timer? _debounce;
  int _requestId = 0;
  bool _disposed = false;

  VerificationFilter get filter => _filter;
  String get search => _search;
  List<CompanyVerification> get items => _items;
  VerificationsStatus get status => _status;
  bool get showSkeleton => _status == VerificationsStatus.loading;
  bool get isRefreshing => _refreshing;
  String? get error => _error;
  bool isBusy(String id) => _busyIds.contains(id);

  /// Demande affichée dans le panneau de détail.
  CompanyVerification? get selected {
    for (final item in _items) {
      if (item.id == _selectedId) return item;
    }
    return null;
  }

  Future<void> load({bool showSkeleton = true}) async {
    final requestId = ++_requestId;
    if (showSkeleton) {
      _status = VerificationsStatus.loading;
    } else {
      _refreshing = true;
    }
    _error = null;
    _notify();
    try {
      final items = await _repository.fetchVerifications(
        filter: _filter,
        search: _search,
      );
      if (requestId != _requestId) return;
      _items = items;
      // Garde la sélection si elle est toujours dans la liste, sinon la
      // première demande.
      if (selected == null) {
        _selectedId = items.isEmpty ? null : items.first.id;
      }
      _status = VerificationsStatus.ready;
    } on VerificationException catch (error) {
      if (requestId != _requestId) return;
      _error = error.message;
      _status = error.isForbidden
          ? VerificationsStatus.forbidden
          : VerificationsStatus.error;
    } catch (_) {
      if (requestId != _requestId) return;
      _error = 'Impossible de charger les vérifications. Réessaie.';
      _status = VerificationsStatus.error;
    }
    _refreshing = false;
    _notify();
  }

  void select(String id) {
    if (id == _selectedId) return;
    _selectedId = id;
    _notify();
  }

  void setFilter(VerificationFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    _selectedId = null;
    load();
  }

  void setSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(searchDebounce, () {
      if (text.trim() == _search) return;
      _search = text.trim();
      _selectedId = null;
      load();
    });
  }

  /// Relance la vérification automatique.
  Future<VerificationActionResult> retry(CompanyVerification item) => _run(
    item,
    () => _repository.retryAutomatic(item.id),
    (updated) => updated.status == VerificationStatus.verifiedAuto
        ? '« ${item.companyName} » a été vérifiée automatiquement.'
        : 'Relance effectuée : ${updated.issue.label.toLowerCase()}. Une décision manuelle est nécessaire.',
  );

  Future<VerificationActionResult> approve(
    CompanyVerification item, {
    String note = '',
  }) => _run(
    item,
    () => _repository.decide(item.id, VerificationDecision.approve, note: note),
    (_) =>
        '« ${item.companyName} » est vérifiée : ses offres deviennent visibles.',
  );

  Future<VerificationActionResult> requestDocument(
    CompanyVerification item,
    String note,
  ) => _run(
    item,
    () => _repository.decide(
      item.id,
      VerificationDecision.requestDocument,
      note: note,
    ),
    (_) => item.recruiterEmail == null
        ? 'Justificatif demandé.'
        : 'Justificatif demandé à ${item.recruiterEmail}.',
  );

  Future<VerificationActionResult> refuse(
    CompanyVerification item,
    String reason,
  ) => _run(
    item,
    () =>
        _repository.decide(item.id, VerificationDecision.refuse, note: reason),
    (_) => '« ${item.companyName} » est refusée. Le recruteur est prévenu.',
  );

  Future<VerificationActionResult> _run(
    CompanyVerification item,
    Future<CompanyVerification> Function() action,
    String Function(CompanyVerification updated) message,
  ) async {
    if (_busyIds.contains(item.id)) {
      return const VerificationActionResult.failure('Action déjà en cours.');
    }
    _busyIds.add(item.id);
    _notify();
    try {
      final updated = await action();
      await load(showSkeleton: false);
      return VerificationActionResult.success(message(updated));
    } on VerificationException catch (error) {
      if (error.isForbidden) {
        _status = VerificationsStatus.forbidden;
        _error = error.message;
      }
      return VerificationActionResult.failure(error.message);
    } catch (_) {
      return const VerificationActionResult.failure(
        'L’action a échoué. Réessaie dans un instant.',
      );
    } finally {
      _busyIds.remove(item.id);
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}
