import 'package:flutter/foundation.dart';

import '../domain/cv_extraction.dart';
import 'cv_repository.dart';

/// Version fictive : simule le choix d'un fichier et son analyse.
///
/// Utilisée telle quelle dans les tests. Dans l'app, [DeviceCvRepository]
/// ouvre le vrai sélecteur de fichiers et réutilise seulement [analyze].
class MockCvRepository implements CvRepository {
  MockCvRepository({this.stepDelay = const Duration(milliseconds: 180)});

  /// Délai entre deux paliers de progression simulés.
  final Duration stepDelay;

  static const _sampleFile = PickedCv(
    name: 'CV_Yasmine_Kacimi_2026.pdf',
    sizeInBytes: 217088,
  );

  static const _sampleExtraction = CvExtraction(
    fullName: 'Yasmine Kacimi',
    email: 'yasmine.k@etu.exemple.fr',
    city: 'Paris 13e',
    educations: [
      CvEducation(
        title: 'Master 1 Informatique',
        school: 'Université Paris Cité',
        period: '2026 – 2027',
      ),
      CvEducation(
        title: 'Licence Informatique',
        school: 'Université Paris Cité',
        period: '2023 – 2026',
      ),
    ],
    experiences: [
      CvExperience(
        title: 'Stage développeuse web · 3 mois',
        company: '[Entreprise]',
        period: 'Été 2026',
        summary:
            "Refonte d'un back-office en React, API REST Node.js, tests unitaires.",
      ),
    ],
    skills: [
      'React',
      'TypeScript',
      'JavaScript',
      'Node.js',
      'Express',
      'Python',
      'SQL',
      'PostgreSQL',
      'Git',
      'Figma',
      'Docker',
      'Tests unitaires',
    ],
    languages: 'Français (natif) · Anglais (B2) · Arabe (courant)',
    isSample: true,
  );

  @override
  Future<PickedCv?> pickFile() async => _sampleFile;

  @override
  Future<CvExtraction> analyze(
    PickedCv file, {
    ValueChanged<double>? onProgress,
  }) async {
    const steps = 10;
    for (var i = 1; i <= steps; i++) {
      await Future<void>.delayed(stepDelay);
      onProgress?.call(i / steps);
    }
    return _sampleExtraction;
  }
}
