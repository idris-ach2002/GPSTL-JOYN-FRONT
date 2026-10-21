import 'package:flutter_test/flutter_test.dart';

import 'package:joyn_front/features/dashboard/domain/candidate_profile.dart';

void main() {
  test('calcule le nom complet et les initiales', () {
    const profile = CandidateProfile(firstName: 'Ariel', lastName: 'Benatsi');

    expect(profile.fullName, 'Ariel Benatsi');
    expect(profile.initials, 'BA');
  });

  test('renvoie null quand le nom est inconnu', () {
    const profile = CandidateProfile();

    expect(profile.fullName, isNull);
    expect(profile.initials, isNull);
  });
}
