import 'package:flutter/foundation.dart';

import '../../data/cv_repository.dart';
import '../../data/device_cv_repository.dart';
import '../../domain/cv_extraction.dart';

enum CvImportStatus { idle, analyzing, done, failed }

/// État de l'écran « Importe ton CV ».
class CvImportController extends ChangeNotifier {
  CvImportController({CvRepository? repository})
    : _repository = repository ?? DeviceCvRepository();

  final CvRepository _repository;

  CvImportStatus _status = CvImportStatus.idle;
  PickedCv? _file;
  double _progress = 0;
  CvExtraction? _extraction;
  String? _error;
  String? _pickError;
  int _analysisCount = 0;
  bool _disposed = false;

  CvImportStatus get status => _status;
  PickedCv? get file => _file;
  double get progress => _progress;
  String? get error => _error;

  /// Erreur au moment du choix du fichier (format, taille…). Elle n'efface
  /// pas le résultat précédent : l'étudiant·e peut simplement réessayer.
  String? get pickError => _pickError;

  /// Nombre d'analyses réussies : change à chaque nouveau CV analysé.
  int get analysisCount => _analysisCount;

  /// Données extraites, modifiables par l'étudiant·e.
  CvExtraction? get extraction => _extraction;

  bool get isAnalyzing => _status == CvImportStatus.analyzing;
  bool get hasResult => _status == CvImportStatus.done && _extraction != null;

  /// Ouvre le sélecteur puis lance l'analyse du fichier choisi.
  Future<void> pickAndAnalyze() async {
    if (isAnalyzing) return;

    _pickError = null;
    _notify();

    PickedCv? picked;
    try {
      picked = await _repository.pickFile();
    } on CvImportException catch (error) {
      _pickError = error.message;
      _notify();
      return;
    }
    if (picked == null) return;

    _file = picked;
    _progress = 0;
    _error = null;
    _extraction = null;
    _status = CvImportStatus.analyzing;
    _notify();

    try {
      final result = await _repository.analyze(
        picked,
        onProgress: (value) {
          _progress = value;
          _notify();
        },
      );
      _extraction = result;
      _progress = 1;
      _analysisCount++;
      _status = CvImportStatus.done;
      _notify();
    } on CvImportException catch (error) {
      _fail(error.message);
    }
  }

  void updateFullName(String value) => _edit((cv) => cv.copyWith(fullName: value));
  void updateEmail(String value) => _edit((cv) => cv.copyWith(email: value));
  void updateCity(String value) => _edit((cv) => cv.copyWith(city: value));

  void removeSkill(String skill) => _edit(
    (cv) => cv.copyWith(skills: cv.skills.where((s) => s != skill).toList()),
  );

  void addSkill(String skill) {
    final trimmed = skill.trim();
    final current = _extraction;
    if (trimmed.isEmpty || current == null) return;
    final exists = current.skills.any(
      (s) => s.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) return;
    _edit((cv) => cv.copyWith(skills: [...cv.skills, trimmed]));
  }

  void _edit(CvExtraction Function(CvExtraction cv) change) {
    final current = _extraction;
    if (current == null) return;
    _extraction = change(current);
    _notify();
  }

  void _fail(String message) {
    _status = CvImportStatus.failed;
    _error = message;
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
