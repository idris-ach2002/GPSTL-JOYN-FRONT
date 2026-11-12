import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/admin_company_repository.dart';
import '../../data/company_logo_picker.dart';
import '../../domain/admin_company.dart';
import '../../domain/admin_company_options.dart';

enum AdminCompaniesStatus { loading, ready, error, forbidden }

/// Résultat d'une action : message de la notification et succès ou échec.
@immutable
class AdminActionResult {
  const AdminActionResult.success(this.message) : succeeded = true;
  const AdminActionResult.failure(this.message) : succeeded = false;

  final String message;
  final bool succeeded;
}

/// État de la page « Entreprises » de l'administration.
///
/// La recherche, les filtres, le tri et la pagination sont faits par le
/// serveur : chaque changement relance une requête sur la page concernée.
class AdminCompaniesController extends ChangeNotifier {
  AdminCompaniesController(
    this._repository, {
    CompanyLogoPicker? logoPicker,
    this._searchDebounce = AdminCompanyOptions.searchDebounce,
  }) : logoPicker = logoPicker ?? const DeviceCompanyLogoPicker();

  final AdminCompanyRepository _repository;

  /// Sélecteur de logo utilisé par le formulaire.
  final CompanyLogoPicker logoPicker;
  final Duration _searchDebounce;

  CompanyQuery _query = const CompanyQuery();
  CompanyPage? _page;
  AdminCompaniesStatus _status = AdminCompaniesStatus.loading;
  bool _refreshing = false;
  String? _error;
  final Set<String> _busyIds = {};
  Timer? _debounce;
  int _requestId = 0;
  bool _disposed = false;

  // ---------------------------------------------------------------------------
  // Lecture
  // ---------------------------------------------------------------------------

  CompanyQuery get query => _query;
  CompanyPage? get page => _page;
  List<AdminCompany> get companies => _page?.items ?? const [];
  AdminCompaniesStatus get status => _status;
  String? get error => _error;

  /// Squelettes : premier chargement ou changement de filtres.
  bool get showSkeleton => _status == AdminCompaniesStatus.loading;

  /// Rechargement discret après une action (la liste reste affichée).
  bool get isRefreshing => _refreshing;

  bool isBusy(String id) => _busyIds.contains(id);

  bool get hasActiveFilters =>
      _query.search.trim().isNotEmpty ||
      _query.status != CompanyStatusFilter.all ||
      _query.sector != null;

  // ---------------------------------------------------------------------------
  // Chargement, recherche, filtres, tri, pagination
  // ---------------------------------------------------------------------------

  /// Charge la page courante. [showSkeleton] à `false` garde la liste
  /// affichée pendant le rechargement.
  Future<void> load({bool showSkeleton = true}) async {
    final requestId = ++_requestId;
    if (showSkeleton) {
      _status = AdminCompaniesStatus.loading;
    } else {
      _refreshing = true;
    }
    _error = null;
    _notify();

    try {
      final page = await _repository.fetchCompanies(_query);
      if (requestId != _requestId) return;

      // Après une suppression, la dernière page peut être vide.
      if (page.items.isEmpty && page.page > 1 && page.total > 0) {
        _query = _query.copyWith(page: page.totalPages);
        await load(showSkeleton: showSkeleton);
        return;
      }
      _page = page;
      _status = AdminCompaniesStatus.ready;
    } on AdminCompanyException catch (error) {
      if (requestId != _requestId) return;
      _error = error.message;
      _status = error.isForbidden
          ? AdminCompaniesStatus.forbidden
          : AdminCompaniesStatus.error;
    } catch (_) {
      if (requestId != _requestId) return;
      _error = 'Impossible de charger les entreprises. Réessaie.';
      _status = AdminCompaniesStatus.error;
    }
    _refreshing = false;
    _notify();
  }

  /// Recherche sur le nom et le SIRET, lancée après une courte pause de
  /// saisie (debounce) pour ne pas interroger le serveur à chaque lettre.
  void setSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      if (text.trim() == _query.search.trim()) return;
      _query = _query.copyWith(search: text.trim(), page: 1);
      load();
    });
  }

  void setStatusFilter(CompanyStatusFilter filter) {
    if (filter == _query.status) return;
    _query = _query.copyWith(status: filter, page: 1);
    load();
  }

  /// `null` = tous les secteurs.
  void setSector(String? sector) {
    if (sector == _query.sector) return;
    _query = sector == null
        ? _query.copyWith(clearSector: true, page: 1)
        : _query.copyWith(sector: sector, page: 1);
    load();
  }

  void setSort(CompanySort sort) {
    if (sort == _query.sort) return;
    _query = _query.copyWith(sort: sort, page: 1);
    load();
  }

  void goToPage(int page) {
    final totalPages = _page?.totalPages ?? 1;
    final target = page.clamp(1, totalPages).toInt();
    if (target == _query.page) return;
    _query = _query.copyWith(page: target);
    load();
  }

  void resetFilters() {
    _debounce?.cancel();
    _query = CompanyQuery(sort: _query.sort);
    load();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<AdminActionResult> create(CompanyDraft draft) => _run(
    null,
    () => _repository.createCompany(draft),
    (company) => 'Entreprise « ${company.name} » ajoutée.',
  );

  Future<AdminActionResult> update(String id, CompanyDraft draft) => _run(
    id,
    () => _repository.updateCompany(id, draft),
    (company) => 'Modifications de « ${company.name} » enregistrées.',
  );

  /// Valide l'entreprise : ses offres deviennent visibles du public.
  Future<AdminActionResult> approve(AdminCompany company) => _run(
    company.id,
    () => _repository.updateStatus(company.id, CompanyStatus.approved),
    (updated) =>
        '« ${updated.name} » validée : ses offres sont maintenant visibles.',
  );

  Future<AdminActionResult> reject(AdminCompany company, String reason) => _run(
    company.id,
    () => _repository.updateStatus(
      company.id,
      CompanyStatus.rejected,
      reason: reason,
    ),
    (updated) => '« ${updated.name} » rejetée.${_notified(updated)}',
  );

  Future<AdminActionResult> suspend(AdminCompany company, String reason) =>
      _run(
        company.id,
        () => _repository.updateStatus(
          company.id,
          CompanyStatus.suspended,
          reason: reason,
        ),
        (updated) => '« ${updated.name} » suspendue.${_notified(updated)}',
      );

  Future<AdminActionResult> reactivate(AdminCompany company) => _run(
    company.id,
    () => _repository.updateStatus(company.id, CompanyStatus.approved),
    (updated) => '« ${updated.name} » réactivée.',
  );

  /// Suppression logique : l'entreprise et ses offres disparaissent du flux
  /// public, l'historique des candidatures est conservé.
  Future<AdminActionResult> delete(AdminCompany company) => _run(
    company.id,
    () async {
      await _repository.deleteCompany(company.id);
      return company;
    },
    (_) =>
        '« ${company.name} » supprimée. L’historique des candidatures est conservé.',
  );

  String _notified(AdminCompany company) => company.recruiterEmail == null
      ? ''
      : ' ${company.recruiterEmail} a été prévenu·e par e-mail.';

  Future<AdminActionResult> _run(
    String? id,
    Future<AdminCompany> Function() action,
    String Function(AdminCompany company) successMessage,
  ) async {
    if (id != null) {
      if (_busyIds.contains(id)) {
        return const AdminActionResult.failure('Action déjà en cours.');
      }
      _busyIds.add(id);
      _notify();
    }
    try {
      final company = await action();
      await load(showSkeleton: false);
      return AdminActionResult.success(successMessage(company));
    } on AdminCompanyException catch (error) {
      if (error.isForbidden) {
        _status = AdminCompaniesStatus.forbidden;
        _error = error.message;
      }
      return AdminActionResult.failure(error.message);
    } catch (_) {
      return const AdminActionResult.failure(
        'L’action a échoué. Réessaie dans un instant.',
      );
    } finally {
      if (id != null) _busyIds.remove(id);
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
