import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../domain/student_profile.dart';
import 'profile_repository.dart';

/// Choix des fichiers du profil : photo et CV.
abstract interface class ProfileFilePicker {
  /// Photo choisie, ou `null` si l'utilisateur annule.
  /// Lève une [ProfileException] si le fichier ne convient pas.
  Future<ProfilePhoto?> pickPhoto();

  /// CV choisi, ou `null` si l'utilisateur annule.
  /// Lève une [ProfileException] si le fichier ne convient pas.
  Future<ProfileCv?> pickCv();
}

/// Ouvre le vrai sélecteur de fichiers de l'appareil (web, Windows, Android…).
class DeviceProfileFilePicker implements ProfileFilePicker {
  const DeviceProfileFilePicker();

  static const maxSizeInBytes = 5 * 1024 * 1024;
  static const photoExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  static const cvExtensions = ['pdf', 'docx'];

  @override
  Future<ProfilePhoto?> pickPhoto() async {
    final file = await _pick(
      dialogTitle: 'Choisis ta photo de profil',
      type: FileType.image,
      extensions: photoExtensions,
      formatLabel: 'JPG, PNG ou WebP',
    );
    if (file == null) return null;
    return ProfilePhoto(bytes: await file.readAsBytes(), fileName: file.name);
  }

  @override
  Future<ProfileCv?> pickCv() async {
    final file = await _pick(
      dialogTitle: 'Choisis ton CV',
      type: FileType.custom,
      extensions: cvExtensions,
      formatLabel: 'PDF ou DOCX',
    );
    if (file == null) return null;
    return ProfileCv(
      fileName: file.name,
      updatedLabel: 'Mis à jour à l’instant',
    );
  }

  Future<PlatformFile?> _pick({
    required String dialogTitle,
    required FileType type,
    required List<String> extensions,
    required String formatLabel,
  }) async {
    PlatformFile? file;
    try {
      file = await FilePicker.pickFile(
        dialogTitle: dialogTitle,
        type: type,
        allowedExtensions: type == FileType.custom ? extensions : null,
      );
    } catch (error) {
      debugPrint('Sélecteur de fichiers indisponible : $error');
      throw const ProfileException(
        "Impossible d'ouvrir le sélecteur de fichiers. Réessaie.",
      );
    }
    if (file == null) return null;

    final name = file.name;
    final dot = name.lastIndexOf('.');
    final extension = dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
    if (!extensions.contains(extension)) {
      throw ProfileException(
        'Format non pris en charge : choisis un fichier $formatLabel.',
      );
    }

    final size = file.lengthSync() ?? await file.length() ?? 0;
    if (size > maxSizeInBytes) {
      throw const ProfileException(
        'Ton fichier dépasse 5 Mo : choisis-en un plus léger.',
      );
    }
    return file;
  }
}
