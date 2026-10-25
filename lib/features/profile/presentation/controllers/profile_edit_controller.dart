import 'package:flutter/foundation.dart';

import '../../data/profile_file_picker.dart';
import '../../data/profile_repository.dart';
import '../../domain/profile_completion.dart';
import '../../domain/profile_options.dart';
import '../../domain/student_profile.dart';
import 'profile_controller.dart';

/// Champs du profil qui peuvent bloquer l'enregistrement.
enum ProfileEditField { firstName, lastName, email }

/// État de la page « Modifier mon profil ».
///
/// Les modifications portent sur un brouillon : rien n'est envoyé tant que
/// l'étudiant·e n'a pas cliqué sur « Enregistrer », et « Annuler » revient
/// à la dernière version enregistrée.
class ProfileEditController extends ChangeNotifier {
  ProfileEditController(this._repository, {ProfileFilePicker? filePicker})
    : _filePicker = filePicker ?? const DeviceProfileFilePicker();

  final ProfileRepository _repository;
  final ProfileFilePicker _filePicker;

  static final RegExp _emailFormat = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  ProfileLoadStatus _status = ProfileLoadStatus.loading;
  StudentProfile _original = const StudentProfile();
  StudentProfile _draft = const StudentProfile();
  bool _dirty = false;
  bool _saving = false;
  bool _saveAttempted = false;
  String? _loadError;
  String? _saveError;
  int _revision = 0;
  bool _disposed = false;

  // ---------------------------------------------------------------------------
  // Lecture
  // ---------------------------------------------------------------------------

  ProfileLoadStatus get status => _status;
  String? get loadError => _loadError;

  /// Brouillon en cours de modification.
  StudentProfile get draft => _draft;

  /// Des modifications n'ont pas encore été enregistrées.
  bool get isDirty => _dirty;
  bool get isSaving => _saving;
  String? get saveError => _saveError;

  /// Change quand le brouillon est remplacé d'un bloc (chargement,
  /// annulation) : les champs texte doivent alors être réinitialisés.
  int get revision => _revision;

  ProfileCompletion get completion => ProfileCompletion.of(_draft);

  /// Compétences suggérées que l'étudiant·e n'a pas encore.
  List<String> get suggestedSkills => [
    for (final name in ProfileOptions.suggestedSkills)
      if (!_hasSkill(name)) name,
  ];

  String? errorFor(ProfileEditField field) {
    return switch (field) {
      ProfileEditField.firstName =>
        _draft.firstName.trim().isEmpty ? 'Indique ton prénom.' : null,
      ProfileEditField.lastName =>
        _draft.lastName.trim().isEmpty ? 'Indique ton nom.' : null,
      ProfileEditField.email =>
        _emailFormat.hasMatch(_draft.email.trim())
            ? null
            : 'Entre une adresse e-mail valide.',
    };
  }

  /// Erreur à afficher : seulement après une tentative d'enregistrement.
  String? visibleErrorFor(ProfileEditField field) =>
      _saveAttempted ? errorFor(field) : null;

  bool get isValid =>
      ProfileEditField.values.every((field) => errorFor(field) == null);

  // ---------------------------------------------------------------------------
  // Chargement, annulation, enregistrement
  // ---------------------------------------------------------------------------

  Future<void> load() async {
    _status = ProfileLoadStatus.loading;
    _loadError = null;
    _notify();
    try {
      _original = await _repository.fetchProfile();
      _draft = _original;
      _dirty = false;
      _revision++;
      _status = ProfileLoadStatus.ready;
    } on ProfileException catch (error) {
      _loadError = error.message;
      _status = ProfileLoadStatus.error;
    } catch (_) {
      _loadError =
          'Impossible de charger ton profil. Réessaie dans un instant.';
      _status = ProfileLoadStatus.error;
    }
    _notify();
  }

  /// Revient à la dernière version enregistrée.
  void discard() {
    _draft = _original;
    _dirty = false;
    _saveAttempted = false;
    _saveError = null;
    _revision++;
    _notify();
  }

  /// Enregistre le brouillon. Renvoie `true` en cas de succès.
  Future<bool> save() async {
    if (_saving) return false;
    _saveAttempted = true;
    _saveError = null;
    if (!isValid) {
      _notify();
      return false;
    }

    _saving = true;
    _notify();
    try {
      _original = await _repository.saveProfile(_draft);
      _draft = _original;
      _dirty = false;
      _saveAttempted = false;
      return true;
    } on ProfileException catch (error) {
      _saveError = error.message;
      return false;
    } catch (_) {
      _saveError = "L'enregistrement a échoué. Réessaie dans un instant.";
      return false;
    } finally {
      _saving = false;
      _notify();
    }
  }

  // ---------------------------------------------------------------------------
  // Identité et présentation
  // ---------------------------------------------------------------------------

  void setFirstName(String value) => _edit((p) => p.copyWith(firstName: value));
  void setLastName(String value) => _edit((p) => p.copyWith(lastName: value));
  void setHeadline(String value) => _edit((p) => p.copyWith(headline: value));
  void setCity(String value) => _edit((p) => p.copyWith(city: value));
  void setEmail(String value) => _edit((p) => p.copyWith(email: value));
  void setBio(String value) => _edit((p) => p.copyWith(bio: value));

  // ---------------------------------------------------------------------------
  // Formation et expériences
  // ---------------------------------------------------------------------------

  void addEducation(ProfileEducation education) =>
      _edit((p) => p.copyWith(educations: [...p.educations, education]));

  void removeEducation(int index) =>
      _edit((p) => p.copyWith(educations: [...p.educations]..removeAt(index)));

  /// Ajoute une expérience. Renvoie `false` si l'intitulé est vide.
  bool addExperience({
    required String title,
    String organization = '',
    String period = '',
    String description = '',
  }) {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return false;
    final experience = ProfileExperience(
      title: cleanTitle,
      organization: organization.trim().isEmpty ? '—' : organization.trim(),
      period: period.trim(),
      description: description.trim(),
    );
    _edit((p) => p.copyWith(experiences: [...p.experiences, experience]));
    return true;
  }

  void removeExperience(int index) => _edit(
    (p) => p.copyWith(experiences: [...p.experiences]..removeAt(index)),
  );

  // ---------------------------------------------------------------------------
  // Photo et CV
  // ---------------------------------------------------------------------------

  /// Choisit une photo (appliquée au brouillon).
  /// Renvoie un message d'erreur, ou `null` si tout va bien ou si annulé.
  Future<String?> pickPhoto() async {
    try {
      final photo = await _filePicker.pickPhoto();
      if (photo != null) _edit((p) => p.copyWith(photo: photo));
      return null;
    } on ProfileException catch (error) {
      return error.message;
    }
  }

  void removePhoto() => _edit((p) => p.copyWith(clearPhoto: true));

  /// Choisit un CV (appliqué au brouillon).
  /// Renvoie un message d'erreur, ou `null` si tout va bien ou si annulé.
  Future<String?> pickCv() async {
    try {
      final cv = await _filePicker.pickCv();
      if (cv != null) _edit((p) => p.copyWith(cv: cv));
      return null;
    } on ProfileException catch (error) {
      return error.message;
    }
  }

  // ---------------------------------------------------------------------------
  // Compétences
  // ---------------------------------------------------------------------------

  /// Ajoute une compétence (niveau débutant). Renvoie `false` si elle est
  /// vide ou déjà présente.
  bool addSkill(String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty || _hasSkill(cleanName)) return false;
    _edit(
      (p) => p.copyWith(
        skills: [
          ...p.skills,
          ProfileSkill(cleanName, ProfileSkillLevel.beginner),
        ],
      ),
    );
    return true;
  }

  /// Passe au niveau suivant (Débutant → Intermédiaire → Avancé → Débutant).
  void cycleSkillLevel(int index) => _edit((p) {
    final skills = [...p.skills];
    skills[index] = skills[index].withLevel(skills[index].level.next);
    return p.copyWith(skills: skills);
  });

  void removeSkill(int index) =>
      _edit((p) => p.copyWith(skills: [...p.skills]..removeAt(index)));

  bool _hasSkill(String name) => _draft.skills.any(
    (skill) => skill.name.toLowerCase() == name.trim().toLowerCase(),
  );

  // ---------------------------------------------------------------------------
  // Liens, disponibilité, visibilité
  // ---------------------------------------------------------------------------

  void setGithub(String value) =>
      _edit((p) => p.copyWith(links: p.links.copyWith(github: value)));
  void setLinkedin(String value) =>
      _edit((p) => p.copyWith(links: p.links.copyWith(linkedin: value)));
  void setPortfolio(String value) =>
      _edit((p) => p.copyWith(links: p.links.copyWith(portfolio: value)));

  void setStart(String value) => _edit(
    (p) => p.copyWith(availability: p.availability.copyWith(start: value)),
  );
  void setDuration(int months) => _edit(
    (p) => p.copyWith(
      availability: p.availability.copyWith(durationMonths: months),
    ),
  );
  void setRhythm(String value) => _edit(
    (p) => p.copyWith(availability: p.availability.copyWith(rhythm: value)),
  );
  void setMaxCommute(int minutes) => _edit(
    (p) => p.copyWith(
      availability: p.availability.copyWith(maxCommuteMinutes: minutes),
    ),
  );

  void setVisibleToRecruiters(bool value) => _edit(
    (p) => p.copyWith(
      visibility: p.visibility.copyWith(visibleToRecruiters: value),
    ),
  );
  void setHiddenFromCurrentEmployer(bool value) => _edit(
    (p) => p.copyWith(
      visibility: p.visibility.copyWith(hiddenFromCurrentEmployer: value),
    ),
  );
  void setOpenToReplacement(bool value) => _edit(
    (p) =>
        p.copyWith(visibility: p.visibility.copyWith(openToReplacement: value)),
  );

  void _edit(StudentProfile Function(StudentProfile profile) change) {
    _draft = change(_draft);
    _dirty = true;
    _saveError = null;
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
