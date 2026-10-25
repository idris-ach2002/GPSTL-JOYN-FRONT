import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/profile/data/fake_profile_repository.dart';
import 'package:joyn_front/features/profile/domain/profile_completion.dart';
import 'package:joyn_front/features/profile/domain/student_profile.dart';

void main() {
  group('ProfileCompletion', () {
    test('un profil vide ne compte que la visibilité', () {
      final completion = ProfileCompletion.of(const StudentProfile());
      expect(completion.percent, 13);
      expect(completion.missing, isNot(contains(ProfileSection.visibility)));
      expect(completion.tip, startsWith('À compléter : Identité'));
    });

    test('le profil d’exemple est complet', () {
      final completion = ProfileCompletion.of(
        FakeProfileRepository.sampleProfile,
      );
      expect(completion.missing, isEmpty);
      expect(completion.percent, 100);
      expect(completion.tip, 'Ton profil est complet. Bravo !');
    });

    test('une présentation trop courte reste à compléter', () {
      final completion = ProfileCompletion.of(
        FakeProfileRepository.sampleProfile.copyWith(bio: 'Trop court.'),
      );
      expect(completion.isComplete(ProfileSection.presentation), isFalse);
      expect(completion.percent, 88);
    });
  });

  group('ProfileSkillLevel', () {
    test('le niveau tourne en boucle', () {
      expect(ProfileSkillLevel.beginner.next, ProfileSkillLevel.intermediate);
      expect(ProfileSkillLevel.advanced.next, ProfileSkillLevel.beginner);
    });
  });

  group('StudentProfile', () {
    test('initiales et noms, nom de famille d’abord', () {
      const profile = StudentProfile(firstName: 'ariel', lastName: 'benatsi');
      expect(profile.initials, 'BA');
      expect(profile.fullName, 'ariel benatsi');
      expect(profile.displayName, 'benatsi ariel');
      expect(const StudentProfile().initials, '?');
    });
  });
}
