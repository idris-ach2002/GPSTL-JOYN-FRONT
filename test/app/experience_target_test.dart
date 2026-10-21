import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/app/experience/experience_target.dart';

void main() {
  test('webOverride force explicitement le web', () {
    expect(
      ExperienceResolver.resolve(webOverride: true),
      ExperienceTarget.web,
    );
  });

  test('webOverride force explicitement le mobile', () {
    expect(
      ExperienceResolver.resolve(webOverride: false),
      ExperienceTarget.mobile,
    );
  });
}
