import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../domain/admin_company.dart';
import 'admin_company_repository.dart';

/// Choix du logo d'une entreprise.
abstract interface class CompanyLogoPicker {
  /// Logo choisi, ou `null` si l'utilisateur annule.
  /// Lève une [AdminCompanyException] si le fichier ne convient pas.
  Future<CompanyLogo?> pickLogo();
}

/// Ouvre le sélecteur d'images de l'appareil.
class DeviceCompanyLogoPicker implements CompanyLogoPicker {
  const DeviceCompanyLogoPicker();

  static const maxSizeInBytes = 2 * 1024 * 1024;
  static const extensions = ['png', 'jpg', 'jpeg', 'webp'];

  @override
  Future<CompanyLogo?> pickLogo() async {
    PlatformFile? file;
    try {
      file = await FilePicker.pickFile(
        dialogTitle: "Choisir le logo de l'entreprise",
        type: FileType.image,
      );
    } catch (error) {
      debugPrint('Sélecteur de fichiers indisponible : $error');
      throw const AdminCompanyException(
        "Impossible d'ouvrir le sélecteur de fichiers.",
      );
    }
    if (file == null) return null;

    final name = file.name;
    final dot = name.lastIndexOf('.');
    final extension = dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
    if (!extensions.contains(extension)) {
      throw const AdminCompanyException(
        'Format non pris en charge : PNG, JPG ou WebP.',
      );
    }
    final size = file.lengthSync() ?? await file.length() ?? 0;
    if (size > maxSizeInBytes) {
      throw const AdminCompanyException('Le logo dépasse 2 Mo.');
    }
    return CompanyLogo(bytes: await file.readAsBytes(), fileName: name);
  }
}
