import 'package:flutter/foundation.dart';

import '../../data/recruiter_offers_repository.dart';
import '../../domain/job_offer.dart';
import '../../domain/recruiter_company.dart';

enum OfferSort { recent, oldest, title }

class OfferManagementController extends ChangeNotifier {
  OfferManagementController(this._repository);
  final RecruiterOffersRepository _repository;

  List<RecruiterCompany> companies = const [];
  List<JobOffer> offers = const [];
  bool isLoading = false;
  bool isClosing = false;
  String? errorMessage;

  int? companyFilter;
  JobOfferStatus? statusFilter;
  ContractType? contractFilter;
  OfferSort sort = OfferSort.recent;
  String query = '';

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.fetchCompanies(),
        _repository.fetchOffers(),
      ]);
      companies = results[0] as List<RecruiterCompany>;
      offers = results[1] as List<JobOffer>;
    } catch (_) {
      errorMessage = 'Impossible de charger vos offres.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  RecruiterCompany? companyFor(int id) {
    for (final company in companies) {
      if (company.id == id) return company;
    }
    return null;
  }

  List<JobOffer> get visibleOffers {
    final normalized = query.trim().toLowerCase();
    final result = offers.where((offer) {
      if (companyFilter != null && offer.companyId != companyFilter) {
        return false;
      }
      if (statusFilter != null && offer.status != statusFilter) return false;
      if (contractFilter != null && offer.contractType != contractFilter) {
        return false;
      }
      if (normalized.isNotEmpty) {
        final company = companyFor(offer.companyId)?.name.toLowerCase() ?? '';
        final haystack =
            '${offer.title} ${offer.location} ${offer.skills.join(' ')} $company'
                .toLowerCase();
        if (!haystack.contains(normalized)) return false;
      }
      return true;
    }).toList();
    switch (sort) {
      case OfferSort.recent:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case OfferSort.oldest:
        result.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case OfferSort.title:
        result.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }
    return result;
  }

  int count(JobOfferStatus status) =>
      offers.where((offer) => offer.status == status).length;
  int get totalCount => offers.length;

  void setCompanyFilter(int? value) {
    companyFilter = value;
    notifyListeners();
  }

  void setStatusFilter(JobOfferStatus? value) {
    statusFilter = value;
    notifyListeners();
  }

  void setContractFilter(ContractType? value) {
    contractFilter = value;
    notifyListeners();
  }

  void setSort(OfferSort value) {
    sort = value;
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  Future<bool> closeOffer(int id, {String? reason}) async {
    isClosing = true;
    notifyListeners();
    try {
      await _repository.closeOffer(id, reason: reason);
      offers = await _repository.fetchOffers();
      return true;
    } catch (_) {
      errorMessage = 'Impossible de clôturer cette offre.';
      return false;
    } finally {
      isClosing = false;
      notifyListeners();
    }
  }
}
