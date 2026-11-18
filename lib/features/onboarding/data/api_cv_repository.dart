import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/cv_extraction.dart';
import 'cv_repository.dart';
import 'device_cv_repository.dart';

/// Extraction réelle. Aucun résultat de démonstration en cas d'échec serveur.
class ApiCvRepository implements CvRepository {
  ApiCvRepository(this.api);
  final ApiClient api;
  final _picker = DeviceCvRepository();
  @override
  Future<PickedCv?> pickFile() async {
    final file = await _picker.pickFile();
    if (file != null && file.extension != 'PDF') {
      throw const CvImportException(
        'L’analyse accepte uniquement les CV PDF contenant du texte.',
      );
    }
    return file;
  }

  @override
  Future<CvExtraction> analyze(
    PickedCv file, {
    ValueChanged<double>? onProgress,
  }) async {
    if (file.bytes == null || file.bytes!.isEmpty || file.extension != 'PDF') {
      throw const CvImportException('Sélectionnez un CV PDF valide.');
    }
    try {
      final raw = await api.sendMultipart(
        'POST',
        '/api/v1/resumes/parse',
        fileField: 'file',
        requestTimeout: const Duration(seconds: 60),
        fileBytes: file.bytes,
        fileName: file.name,
      );
      return mapExtraction(Map<String, dynamic>.from(raw as Map));
    } on ApiException catch (e) {
      throw CvImportException(switch (e.statusCode) {
        400 => 'Ce PDF est illisible ou ne contient pas de texte exploitable.',
        413 => 'Le CV dépasse la taille autorisée de 5 Mo.',
        502 => 'Le service d’analyse du CV est indisponible. Réessayez ou remplissez votre profil manuellement.',
        _ => 'L’analyse a échoué. Réessayez ou complétez votre profil manuellement.',
      });
    } catch (_) {
      throw const CvImportException(
        'La réponse d’analyse est invalide. Réessayez.',
      );
    }
  }

  static CvExtraction mapExtraction(Map<String, dynamic> j) {
    final contact = j['contactInfo'] as Map? ?? const {};
    String period(Map item) => [
      item['startDate'],
      item['endDate'],
    ].where((v) => v != null && '$v'.isNotEmpty).join(' – ');
    return CvExtraction(
      fullName: [
        contact['firstName'],
        contact['lastName'],
      ].whereType<String>().join(' '),
      email: '${contact['email'] ?? ''}',
      city: '${contact['city'] ?? ''}',
      educations: [
        for (final e in j['education'] as List? ?? const [])
          CvEducation(
            title: '${e['degree'] ?? ''}',
            school: '${e['institution'] ?? ''}',
            period: period(e as Map),
          ),
      ],
      experiences: [
        for (final e in j['experiences'] as List? ?? const [])
          CvExperience(
            title: '${e['jobTitle'] ?? ''}',
            company: '${e['company'] ?? ''}',
            period: period(e as Map),
            summary: '',
          ),
      ],
      skills: (j['skills'] as List? ?? const []).whereType<String>().toList(),
      languages: '',
    );
  }
}
