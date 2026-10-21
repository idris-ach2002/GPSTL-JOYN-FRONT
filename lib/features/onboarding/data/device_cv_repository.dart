import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../domain/cv_extraction.dart';
import 'cv_repository.dart';
import 'mock_cv_repository.dart';

/// Ouvre le vrai sélecteur de fichiers de l'appareil (web, Windows, Android…).
///
/// L'analyse du contenu reste simulée par [MockCvRepository] tant que
/// l'API d'extraction n'existe pas : seule cette méthode sera à remplacer.
class DeviceCvRepository implements CvRepository {
  DeviceCvRepository({MockCvRepository? analyzer})
    : _analyzer = analyzer ?? MockCvRepository();

  final MockCvRepository _analyzer;

  static const allowedExtensions = ['pdf', 'docx'];
  static const maxSizeInBytes = 5 * 1024 * 1024;

  @override
  Future<PickedCv?> pickFile() async {
    PlatformFile? file;
    try {
      file = await FilePicker.pickFile(
        dialogTitle: 'Choisis ton CV',
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
    } catch (error) {
      debugPrint('Sélecteur de fichiers indisponible : $error');
      throw const CvImportException(
        "Impossible d'ouvrir le sélecteur de fichiers. Réessaie.",
      );
    }
    if (file == null) return null;

    final name = file.name;
    final dot = name.lastIndexOf('.');
    final extension = dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      throw const CvImportException(
        'Format non pris en charge : choisis un fichier PDF ou DOCX.',
      );
    }

    final size = file.lengthSync() ?? await file.length() ?? 0;
    final picked = PickedCv(name: name, sizeInBytes: size);
    if (size > maxSizeInBytes) {
      throw CvImportException(
        'Ton fichier fait ${picked.readableSize} : la limite est de 5 Mo.',
      );
    }
    return picked;
  }

  @override
  Future<CvExtraction> analyze(
    PickedCv file, {
    ValueChanged<double>? onProgress,
  }) {
    return _analyzer.analyze(file, onProgress: onProgress);
  }
}
