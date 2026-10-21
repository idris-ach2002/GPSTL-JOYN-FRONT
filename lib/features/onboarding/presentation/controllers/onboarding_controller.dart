import 'package:flutter/foundation.dart';

import '../../data/profile_repository.dart';
import '../../domain/cv_extraction.dart';
import '../../domain/onboarding_options.dart';
import '../../domain/student_profile_draft.dart';

/// État de l'onboarding étudiant en 5 étapes.
///
/// Partagé entre l'onboarding et l'import du CV (voir `OnboardingScope`) :
/// un CV analysé pré-remplit directement les étapes.
class OnboardingController extends ChangeNotifier {
  OnboardingController({ProfileRepository? repository})
    : _repository = repository ?? MockProfileRepository();

  final ProfileRepository _repository;

  static const int stepCount = 5;

  int _step = 1;

  // Étape 1 — Formation
  String _searchKind = OnboardingOptions.searchKinds.first;
  String _degreeTitle = '';
  String _school = '';
  String? _level;
  int? _graduationYear;

  // Étape 2 — Localisation & rythme
  String _city = '';
  String _availableFrom = '';
  int _maxCommuteMinutes = 45;
  String? _rhythm;

  // Étape 3 — Domaines
  final List<String> _domains = [];

  // Étape 4 — Compétences
  final Map<String, SkillLevel> _skills = {};
  final List<String> _softSkills = ['Travail en équipe', 'Autonomie', 'Curiosité'];

  // Étape 5 — Préférences
  String? _remoteMode;
  final List<String> _companySizes = [];
  String _desiredSalary = '';

  bool _prefilledFromCv = false;
  bool _isSaving = false;
  bool _disposed = false;

  // ---------------------------------------------------------------------------
  // Lecture
  // ---------------------------------------------------------------------------

  int get step => _step;
  bool get isFirstStep => _step == 1;
  bool get isLastStep => _step == stepCount;

  /// Avancement de 0.2 (étape 1) à 1 (étape 5).
  double get progress => _step / stepCount;

  String get searchKind => _searchKind;
  String get degreeTitle => _degreeTitle;
  String get school => _school;
  String? get level => _level;
  int? get graduationYear => _graduationYear;
  String get city => _city;
  String get availableFrom => _availableFrom;
  int get maxCommuteMinutes => _maxCommuteMinutes;
  String? get rhythm => _rhythm;
  List<String> get domains => List.unmodifiable(_domains);
  Map<String, SkillLevel> get skills => Map.unmodifiable(_skills);
  List<String> get softSkills => List.unmodifiable(_softSkills);
  String? get remoteMode => _remoteMode;
  List<String> get companySizes => List.unmodifiable(_companySizes);
  String get desiredSalary => _desiredSalary;
  bool get prefilledFromCv => _prefilledFromCv;
  bool get isSaving => _isSaving;

  bool get domainLimitReached => _domains.length >= OnboardingOptions.maxDomains;

  bool isDomainSelected(String domain) => _domains.contains(domain);
  bool isCompanySizeSelected(String size) => _companySizes.contains(size);

  // ---------------------------------------------------------------------------
  // Navigation entre étapes
  // ---------------------------------------------------------------------------

  void goToStep(int step) =>
      _update(() => _step = step.clamp(1, stepCount).toInt());
  void nextStep() => goToStep(_step + 1);
  void previousStep() => goToStep(_step - 1);

  // ---------------------------------------------------------------------------
  // Modifications
  // ---------------------------------------------------------------------------

  void setSearchKind(String value) => _update(() => _searchKind = value);
  void setDegreeTitle(String value) => _update(() => _degreeTitle = value);
  void setSchool(String value) => _update(() => _school = value);
  void setLevel(String value) => _update(() => _level = value);
  void setGraduationYear(int value) => _update(() => _graduationYear = value);

  void setCity(String value) => _update(() => _city = value);
  void setAvailableFrom(String value) => _update(() => _availableFrom = value);
  void setMaxCommute(int minutes) => _update(
    () => _maxCommuteMinutes = minutes
        .clamp(OnboardingOptions.minCommute, OnboardingOptions.maxCommute)
        .toInt(),
  );
  void setRhythm(String value) => _update(() => _rhythm = value);

  /// Ajoute ou retire un domaine. Sans effet au-delà de la limite.
  void toggleDomain(String domain) => _update(() {
    if (_domains.remove(domain)) return;
    if (!domainLimitReached) _domains.add(domain);
  });

  /// Ajoute une technologie (niveau intermédiaire par défaut).
  void addSkill(String name, [SkillLevel level = SkillLevel.intermediate]) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final exists = _skills.keys.any(
      (key) => key.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) return;
    _update(() => _skills[trimmed] = level);
  }

  void setSkillLevel(String name, SkillLevel level) =>
      _update(() => _skills[name] = level);
  void removeSkill(String name) => _update(() => _skills.remove(name));

  void addSoftSkill(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _softSkills.contains(trimmed)) return;
    _update(() => _softSkills.add(trimmed));
  }

  void removeSoftSkill(String name) => _update(() => _softSkills.remove(name));

  void setRemoteMode(String value) => _update(() => _remoteMode = value);

  void toggleCompanySize(String size) => _update(() {
    if (!_companySizes.remove(size)) _companySizes.add(size);
  });

  void setDesiredSalary(String value) => _update(() => _desiredSalary = value);

  /// Reprend les informations d'un CV analysé.
  ///
  /// Les champs déjà remplis à la main ne sont pas écrasés.
  void applyCv(CvExtraction cv) => _update(() {
    if (cv.educations.isNotEmpty) {
      final latest = cv.educations.first;
      if (_degreeTitle.trim().isEmpty) _degreeTitle = latest.title;
      if (_school.trim().isEmpty) _school = latest.school;
    }
    if (_city.trim().isEmpty) _city = cv.city;
    for (final skill in cv.skills) {
      final exists = _skills.keys.any(
        (key) => key.toLowerCase() == skill.toLowerCase(),
      );
      if (!exists) _skills[skill] = SkillLevel.intermediate;
    }
    _prefilledFromCv = true;
  });

  /// Enregistre le profil. Renvoie `true` en cas de succès.
  Future<bool> finish() async {
    if (_isSaving) return false;
    _isSaving = true;
    _notify();
    try {
      await _repository.saveProfile(toDraft());
      return true;
    } finally {
      _isSaving = false;
      _notify();
    }
  }

  StudentProfileDraft toDraft() {
    final salary = int.tryParse(_desiredSalary.replaceAll(RegExp(r'[^0-9]'), ''));
    return StudentProfileDraft(
      searchKind: _searchKind,
      degreeTitle: _degreeTitle.trim(),
      school: _school.trim(),
      level: _level,
      graduationYear: _graduationYear,
      city: _city.trim(),
      availableFrom: _availableFrom.trim(),
      maxCommuteMinutes: _maxCommuteMinutes,
      rhythm: _rhythm,
      domains: List.unmodifiable(_domains),
      skills: Map.unmodifiable(_skills),
      softSkills: List.unmodifiable(_softSkills),
      remoteMode: _remoteMode,
      companySizes: List.unmodifiable(_companySizes),
      desiredMonthlySalary: salary,
    );
  }

  void _update(VoidCallback change) {
    change();
    _notify();
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
