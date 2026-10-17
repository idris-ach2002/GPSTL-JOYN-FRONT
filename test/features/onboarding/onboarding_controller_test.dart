import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/onboarding/data/profile_repository.dart';
import 'package:joyn_front/features/onboarding/domain/cv_extraction.dart';
import 'package:joyn_front/features/onboarding/domain/onboarding_options.dart';
import 'package:joyn_front/features/onboarding/presentation/controllers/onboarding_controller.dart';

const _cv = CvExtraction(
  fullName: 'Yasmine Kacimi',
  email: 'yasmine@etu.exemple.fr',
  city: 'Paris 13e',
  educations: [
    CvEducation(
      title: 'Master 1 Informatique',
      school: 'Université Paris Cité',
      period: '2026 – 2027',
    ),
  ],
  experiences: [],
  skills: ['React', 'Python'],
  languages: 'Français (natif)',
);

void main() {
  group('OnboardingController', () {
    test('la navigation reste entre les étapes 1 et 5', () {
      final form = OnboardingController();
      expect(form.step, 1);

      form.previousStep();
      expect(form.step, 1);

      for (var i = 0; i < 10; i++) {
        form.nextStep();
      }
      expect(form.step, OnboardingController.stepCount);
      expect(form.isLastStep, isTrue);
    });

    test('on ne peut pas choisir plus de 5 domaines', () {
      final form = OnboardingController();
      for (final domain in OnboardingOptions.domains) {
        form.toggleDomain(domain);
      }
      expect(form.domains.length, OnboardingOptions.maxDomains);
      expect(form.domainLimitReached, isTrue);

      form.toggleDomain(form.domains.first);
      expect(form.domains.length, OnboardingOptions.maxDomains - 1);
    });

    test('une technologie déjà présente n’est pas ajoutée deux fois', () {
      final form = OnboardingController()
        ..addSkill('React')
        ..addSkill('react')
        ..addSkill('   ');
      expect(form.skills.keys, ['React']);
      expect(form.skills['React'], SkillLevel.intermediate);
    });

    test('le CV pré-remplit sans écraser la saisie manuelle', () {
      final form = OnboardingController()..setSchool('Sorbonne Université');
      form.applyCv(_cv);

      expect(form.degreeTitle, 'Master 1 Informatique');
      expect(form.school, 'Sorbonne Université');
      expect(form.city, 'Paris 13e');
      expect(form.skills.keys, containsAll(['React', 'Python']));
      expect(form.prefilledFromCv, isTrue);
    });

    test('finish enregistre le profil', () async {
      final repository = MockProfileRepository(latency: Duration.zero);
      final form = OnboardingController(repository: repository)
        ..setDesiredSalary('1 400')
        ..toggleDomain('Mobile');

      expect(await form.finish(), isTrue);
      expect(repository.lastSaved?.desiredMonthlySalary, 1400);
      expect(repository.lastSaved?.domains, ['Mobile']);
    });
  });
}
