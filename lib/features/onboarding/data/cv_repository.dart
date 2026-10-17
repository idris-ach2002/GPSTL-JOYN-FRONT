import 'package:flutter/foundation.dart';

import '../domain/cv_extraction.dart';

/// Erreur affichable lors du choix ou de l'analyse d'un CV.
class CvImportException implements Exception {
  const CvImportException(this.message);

  final String message;

  @override
  String toString() => 'CvImportException: $message';
}

/// Choix du fichier et analyse du CV.
abstract interface class CvRepository {
  /// Ouvre le sélecteur de fichiers. Renvoie `null` si l'utilisateur annule.
  Future<PickedCv?> pickFile();

  /// Analyse le CV. [onProgress] reçoit l'avancement entre 0 et 1.
  Future<CvExtraction> analyze(
    PickedCv file, {
    ValueChanged<double>? onProgress,
  });
}
