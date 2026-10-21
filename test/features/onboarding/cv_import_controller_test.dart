import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/onboarding/data/mock_cv_repository.dart';
import 'package:joyn_front/features/onboarding/domain/cv_extraction.dart';
import 'package:joyn_front/features/onboarding/presentation/controllers/cv_import_controller.dart';

void main() {
  group('CvImportController', () {
    CvImportController controller() => CvImportController(
      repository: MockCvRepository(stepDelay: Duration.zero),
    );

    test(
      'l’analyse passe de idle à done avec une progression complète',
      () async {
        final cv = controller();
        expect(cv.status, CvImportStatus.idle);

        await cv.pickAndAnalyze();

        expect(cv.status, CvImportStatus.done);
        expect(cv.progress, 1);
        expect(cv.hasResult, isTrue);
        expect(cv.analysisCount, 1);
        expect(cv.extraction!.skills, contains('React'));
      },
    );

    test('les compétences extraites sont modifiables', () async {
      final cv = controller();
      await cv.pickAndAnalyze();
      final before = cv.extraction!.skills.length;

      cv.removeSkill('Docker');
      expect(cv.extraction!.skills, isNot(contains('Docker')));

      cv
        ..addSkill('Flutter')
        ..addSkill('flutter');
      expect(cv.extraction!.skills.length, before);
      expect(cv.extraction!.skills.last, 'Flutter');
    });

    test('la taille du fichier est lisible', () {
      const file = PickedCv(name: 'cv.pdf', sizeInBytes: 217088);
      expect(file.readableSize, '212 Ko');
      expect(file.extension, 'PDF');
    });
  });
}
