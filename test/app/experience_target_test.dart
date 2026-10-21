import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/app/experience/experience_target.dart';

void main() {
  test('webOverride force explicitement le web', () {
    expect(ExperienceResolver.resolve(webOverride: true), ExperienceTarget.web);
  });

  test('webOverride force explicitement le mobile', () {
    expect(
      ExperienceResolver.resolve(webOverride: false),
      ExperienceTarget.mobile,
    );
  });

  test('viewport web téléphone utilise l\'expérience mobile', () {
    expect(ExperienceResolver.forWebWidth(390), ExperienceTarget.mobile);
  });

  test('viewport web desktop utilise l\'expérience web', () {
    expect(ExperienceResolver.forWebWidth(1440), ExperienceTarget.web);
  });
}
