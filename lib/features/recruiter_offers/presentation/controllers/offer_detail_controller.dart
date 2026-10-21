import 'package:flutter/foundation.dart';

import '../../data/recruiter_offers_repository.dart';
import '../../domain/job_offer.dart';
import '../../domain/recruiter_company.dart';

class OfferDetailController extends ChangeNotifier {
  OfferDetailController(this._repository, this.offerId);
  final RecruiterOffersRepository _repository;
  final int offerId;

  JobOffer? offer;
  RecruiterCompany? company;
  bool isLoading = false;
  bool isClosing = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      offer = await _repository.fetchOffer(offerId);
      if (offer == null) {
        errorMessage = 'Offre introuvable.';
      } else {
        final companies = await _repository.fetchCompanies();
        for (final item in companies) {
          if (item.id == offer!.companyId) company = item;
        }
      }
    } catch (_) {
      errorMessage = 'Impossible de charger cette offre.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> close({String? reason}) async {
    if (offer == null) return false;
    isClosing = true;
    notifyListeners();
    try {
      await _repository.closeOffer(offerId, reason: reason);
      offer = await _repository.fetchOffer(offerId);
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
