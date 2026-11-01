import 'package:flutter/foundation.dart';

import '../../data/profile_file_picker.dart';
import '../../data/profile_repository.dart';
import '../../domain/profile_completion.dart';
import '../../domain/student_profile.dart';

enum ProfileLoadStatus { loading, ready, error }

/// État de la page « Mon profil » (consultation).
class ProfileController extends ChangeNotifier {
  ProfileController(this._repository, {ProfileFilePicker? filePicker})
    : _filePicker = filePicker ?? const DeviceProfileFilePicker();

  final ProfileRepository _repository;
  final ProfileFilePicker _filePicker;

  ProfileLoadStatus _status = ProfileLoadStatus.loading;
  StudentProfile? _profile;
  String? _error;
  bool _updating = false;
  bool _disposed = false;

  ProfileLoadStatus get status => _status;
  StudentProfile? get profile => _profile;
  String? get error => _error;

  /// Une photo ou un CV est en cours d'enregistrement.
  bool get isUpdating => _updating;

  ProfileCompletion get completion =>
      ProfileCompletion.of(_profile ?? const StudentProfile());

  Future<void> load() async {
    _status = ProfileLoadStatus.loading;
    _error = null;
    _notify();
    try {
      _profile = await _repository.fetchProfile();
      _status = ProfileLoadStatus.ready;
    } on ProfileException catch (error) {
      _error = error.message;
      _status = ProfileLoadStatus.error;
    } catch (_) {
      _error = 'Impossible de charger ton profil. Réessaie dans un instant.';
      _status = ProfileLoadStatus.error;
    }
    _notify();
  }

  /// Choisit une nouvelle photo et l'enregistre.
  ///
  /// Renvoie le message à afficher, ou `null` si l'utilisateur a annulé.
  Future<String?> changePhoto() => _updateWithFile(
    pick: () async {
      final photo = await _filePicker.pickPhoto();
      return photo == null
          ? null
          : (StudentProfile p) => p.copyWith(photo: photo);
    },
    success: 'Photo de profil mise à jour.',
  );

  /// Choisit un nouveau CV et l'enregistre.
  ///
  /// Renvoie le message à afficher, ou `null` si l'utilisateur a annulé.
  Future<String?> replaceCv() => _updateWithFile(
    pick: () async {
      final cv = await _filePicker.pickCv();
      return cv == null ? null : (StudentProfile p) => p.copyWith(cv: cv);
    },
    success: 'CV remplacé.',
  );

  Future<String?> _updateWithFile({
    required Future<StudentProfile Function(StudentProfile)?> Function() pick,
    required String success,
  }) async {
    final current = _profile;
    if (current == null || _updating) return null;
    try {
      final change = await pick();
      if (change == null) return null;

      _updating = true;
      _notify();
      _profile = await _repository.saveProfile(change(current));
      return success;
    } on ProfileException catch (error) {
      return error.message;
    } catch (_) {
      return "L'enregistrement a échoué. Réessaie dans un instant.";
    } finally {
      _updating = false;
      _notify();
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
