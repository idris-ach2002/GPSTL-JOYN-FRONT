import 'package:flutter/foundation.dart';

import '../../data/recruiter_offers_repository.dart';
import '../../domain/job_offer.dart';
import '../../domain/job_offer_draft.dart';
import '../../domain/offer_options.dart';
import '../../domain/recruiter_company.dart';

enum CompanyLookupStatus { idle, loading, found, notFound }

class OfferEditorController extends ChangeNotifier {
  OfferEditorController(this._repository, {this.offerId});

  final RecruiterOffersRepository _repository;
  final int? offerId;

  List<RecruiterCompany> companies = const [];
  RecruiterCompany? selectedCompany;
  JobOffer? editingOffer;

  String title = 'Développeur·se Full-Stack en alternance';
  ContractType contractType = ContractType.apprenticeship;
  String location = 'Paris, France';
  RemoteMode remoteMode = RemoteMode.hybrid;
  ExperienceLevel experienceLevel = ExperienceLevel.junior;
  String description =
      'Vous rejoindrez une équipe tech dynamique pour développer de nouvelles fonctionnalités sur notre plateforme. '
      'Vous participerez à la conception, au développement et au déploiement de nos applications web, en collaboration avec les équipes produit et design.';
  double? salaryMin = 1200;
  double? salaryMax = 1800;
  String currency = 'EUR';
  SalaryPeriod salaryPeriod = SalaryPeriod.month;
  List<String> skills = ['React', 'TypeScript', 'PostgreSQL', 'Docker', 'Spring Boot'];
  String rhythmType = OfferOptions.rhythms.first;
  DateTime? startDate = DateTime(2027, 9, 1);
  int? durationMonths = 12;
  String degreeLevelRequired = 'BAC_5';

  bool isLoading = false;
  bool isSubmitting = false;
  bool hasSubmitted = false;
  String? submitError;
  JobOffer? savedOffer;

  int mobileStep = 0;

  CompanyLookupStatus companyLookupStatus = CompanyLookupStatus.idle;
  RecruiterCompany? companyLookupResult;
  String? companyLookupError;
  bool isCreatingCompany = false;

  final Map<String, String> _errors = {};
  Map<String, String> get errors => Map.unmodifiable(_errors);

  bool get isEditing => offerId != null;
  bool get isWorkStudy => contractType.isWorkStudy;
  bool get isLastMobileStep => mobileStep == 4;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      companies = await _repository.fetchCompanies();
      if (offerId != null) {
        editingOffer = await _repository.fetchOffer(offerId!);
        final offer = editingOffer;
        if (offer == null) {
          submitError = 'Cette offre est introuvable.';
        } else {
          _hydrate(offer);
        }
      } else if (companies.isNotEmpty) {
        selectedCompany = companies.first;
      }
    } catch (_) {
      submitError = 'Impossible de charger les données pour le moment.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _hydrate(JobOffer offer) {
    selectedCompany = companies.where((c) => c.id == offer.companyId).firstOrNull;
    title = offer.title;
    contractType = offer.contractType;
    location = offer.location;
    remoteMode = offer.remoteMode;
    experienceLevel = offer.experienceLevel;
    description = offer.description;
    salaryMin = offer.salaryMin;
    salaryMax = offer.salaryMax;
    currency = offer.currency;
    salaryPeriod = offer.salaryPeriod;
    skills = [...offer.skills];
    rhythmType = offer.rhythmType ?? OfferOptions.rhythms.first;
    startDate = offer.startDate;
    durationMonths = offer.durationMonths;
    degreeLevelRequired = offer.degreeLevelRequired ?? 'BAC_5';
  }

  void selectCompany(RecruiterCompany company) {
    selectedCompany = company;
    _errors.remove('company');
    notifyListeners();
  }

  void updateTitle(String value) { title = value; _errors.remove('title'); notifyListeners(); }
  void updateContractType(ContractType value) { contractType = value; notifyListeners(); }
  void updateLocation(String value) { location = value; _errors.remove('location'); notifyListeners(); }
  void updateRemoteMode(RemoteMode value) { remoteMode = value; notifyListeners(); }
  void updateExperienceLevel(ExperienceLevel value) { experienceLevel = value; notifyListeners(); }
  void updateDescription(String value) { description = value; _errors.remove('description'); notifyListeners(); }
  void updateSalaryMin(String value) { salaryMin = _parseAmount(value); _errors.remove('salary'); notifyListeners(); }
  void updateSalaryMax(String value) { salaryMax = _parseAmount(value); _errors.remove('salary'); notifyListeners(); }
  void updateCurrency(String value) { currency = value; notifyListeners(); }
  void updateSalaryPeriod(SalaryPeriod value) { salaryPeriod = value; notifyListeners(); }
  void updateRhythm(String value) { rhythmType = value; notifyListeners(); }
  void updateStartDate(DateTime? value) { startDate = value; notifyListeners(); }
  void updateDuration(String value) { durationMonths = int.tryParse(value.trim()); _errors.remove('duration'); notifyListeners(); }
  void updateDegree(String value) { degreeLevelRequired = value; notifyListeners(); }

  double? _parseAmount(String value) {
    final normalized = value.replaceAll(' ', '').replaceAll(',', '.').trim();
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  bool addSkill(String raw) {
    final value = raw.trim();
    if (value.isEmpty || value.length > 100) return false;
    if (skills.any((s) => s.toLowerCase() == value.toLowerCase())) return false;
    skills = [...skills, value];
    _errors.remove('skills');
    notifyListeners();
    return true;
  }

  void removeSkill(String skill) {
    skills = skills.where((item) => item != skill).toList(growable: false);
    notifyListeners();
  }

  bool validate() {
    _errors.clear();
    if (selectedCompany == null) _errors['company'] = 'Sélectionnez une entreprise.';
    if (title.trim().isEmpty) _errors['title'] = 'Indiquez un intitulé de poste.';
    if (title.trim().length > 200) _errors['title'] = 'Le titre ne doit pas dépasser 200 caractères.';
    if (location.trim().isEmpty) _errors['location'] = 'Indiquez une localisation.';
    if (description.trim().isEmpty) _errors['description'] = 'Décrivez le poste et le profil recherché.';
    if (skills.isEmpty) _errors['skills'] = 'Ajoutez au moins une compétence.';
    if (salaryMin != null && salaryMin! < 0 || salaryMax != null && salaryMax! < 0) {
      _errors['salary'] = 'Les montants doivent être positifs.';
    }
    if (salaryMin != null && salaryMax != null && salaryMax! < salaryMin!) {
      _errors['salary'] = 'Le salaire maximum doit être supérieur ou égal au minimum.';
    }
    if (isWorkStudy && durationMonths != null && (durationMonths! < 1 || durationMonths! > 60)) {
      _errors['duration'] = 'La durée doit être comprise entre 1 et 60 mois.';
    }
    notifyListeners();
    return _errors.isEmpty;
  }

  bool validateMobileStep() {
    _errors.clear();
    if (mobileStep == 0) {
      if (selectedCompany == null) {
        _errors['company'] = 'Sélectionnez une entreprise.';
      }
    } else if (mobileStep == 1) {
      if (title.trim().isEmpty) _errors['title'] = 'Indiquez un intitulé.';
      if (location.trim().isEmpty) {
        _errors['location'] = 'Indiquez une localisation.';
      }
    } else if (mobileStep == 2) {
      if (description.trim().isEmpty) {
        _errors['description'] = 'Ajoutez une description.';
      }
    } else if (mobileStep == 3) {
      if (skills.isEmpty) _errors['skills'] = 'Ajoutez une compétence.';
      if (salaryMin != null &&
          salaryMax != null &&
          salaryMax! < salaryMin!) {
        _errors['salary'] = 'Fourchette de salaire invalide.';
      }
    } else {
      return validate();
    }
    notifyListeners();
    return _errors.isEmpty;
  }

  void nextMobileStep() {
    if (!validateMobileStep()) return;
    if (mobileStep < 4) mobileStep += 1;
    notifyListeners();
  }

  void previousMobileStep() {
    if (mobileStep > 0) mobileStep -= 1;
    notifyListeners();
  }

  void jumpToMobileStep(int step) {
    mobileStep = step.clamp(0, 4).toInt();
    notifyListeners();
  }

  Future<JobOffer?> submit(JobOfferStatus status) async {
    hasSubmitted = true;
    submitError = null;
    if (!validate()) return null;
    isSubmitting = true;
    notifyListeners();
    try {
      final draft = _toDraft();
      savedOffer = isEditing
          ? await _repository.updateOffer(offerId!, draft)
          : await _repository.createOffer(draft, status);
      return savedOffer;
    } catch (_) {
      submitError = 'Une erreur est survenue. Vos informations ont été conservées.';
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  JobOfferDraft _toDraft() => JobOfferDraft(
    companyId: selectedCompany!.id,
    title: title.trim(),
    contractType: contractType,
    location: location.trim(),
    remoteMode: remoteMode,
    experienceLevel: experienceLevel,
    description: description.trim(),
    salaryMin: salaryMin,
    salaryMax: salaryMax,
    currency: currency,
    salaryPeriod: salaryPeriod,
    skills: List.unmodifiable(skills),
    rhythmType: isWorkStudy ? rhythmType : null,
    startDate: isWorkStudy ? startDate : null,
    durationMonths: isWorkStudy ? durationMonths : null,
    degreeLevelRequired: isWorkStudy ? degreeLevelRequired : null,
  );

  Future<void> lookupCompany(String siret) async {
    final normalized = siret.replaceAll(RegExp(r'\D'), '');
    companyLookupResult = null;
    companyLookupError = null;
    if (normalized.length != 14) {
      companyLookupStatus = CompanyLookupStatus.notFound;
      companyLookupError = 'Le SIRET doit contenir exactement 14 chiffres.';
      notifyListeners();
      return;
    }
    companyLookupStatus = CompanyLookupStatus.loading;
    notifyListeners();
    try {
      companyLookupResult = await _repository.findCompanyBySiret(normalized);
      companyLookupStatus = companyLookupResult == null ? CompanyLookupStatus.notFound : CompanyLookupStatus.found;
    } catch (_) {
      companyLookupStatus = CompanyLookupStatus.notFound;
      companyLookupError = 'Recherche impossible pour le moment.';
    }
    notifyListeners();
  }

  Future<RecruiterCompany?> createCompany(RecruiterCompanyDraft draft) async {
    companyLookupError = null;
    if (draft.name.trim().isEmpty || draft.sector.trim().isEmpty || draft.sizeRange.trim().isEmpty || draft.city.trim().isEmpty) {
      companyLookupError = 'Complétez les champs obligatoires de l’entreprise.';
      notifyListeners();
      return null;
    }
    isCreatingCompany = true;
    notifyListeners();
    try {
      final company = await _repository.createCompany(draft);
      companies = [...companies, company];
      selectedCompany = company;
      companyLookupResult = company;
      companyLookupStatus = CompanyLookupStatus.found;
      return company;
    } catch (_) {
      companyLookupError = 'Impossible de créer l’entreprise pour le moment.';
      return null;
    } finally {
      isCreatingCompany = false;
      notifyListeners();
    }
  }

  void chooseLookupCompany() {
    final result = companyLookupResult;
    if (result != null) selectCompany(result);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
