import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/profile/data/fake_profile_repository.dart';
import 'package:joyn_front/features/profile/domain/student_profile.dart';
import 'package:joyn_front/features/profile/presentation/controllers/profile_controller.dart';
import 'package:joyn_front/features/profile/presentation/controllers/profile_edit_controller.dart';

void main() {
  late FakeProfileRepository repository;
  late ProfileEditController form;

  setUp(() async {
    repository = FakeProfileRepository(latency: Duration.zero);
    form = ProfileEditController(repository);
    await form.load();
  });

  tearDown(() => form.dispose());

  test('le brouillon est chargé et non modifié', () {
    expect(form.status, ProfileLoadStatus.ready);
    expect(form.draft.firstName, 'Ariel');
    expect(form.isDirty, isFalse);
  });

  test('une modification rend le brouillon « non enregistré »', () {
    form.setHeadline('Développeuse mobile');
    expect(form.isDirty, isTrue);
    expect(form.draft.headline, 'Développeuse mobile');
  });

  test('annuler revient à la version enregistrée', () {
    final revision = form.revision;
    form
      ..setFirstName('Inès')
      ..discard();
    expect(form.draft.firstName, 'Ariel');
    expect(form.isDirty, isFalse);
    expect(form.revision, greaterThan(revision));
  });

  test('enregistrer met à jour le dépôt', () async {
    form.setCity('Lyon');
    expect(await form.save(), isTrue);
    expect(form.isDirty, isFalse);
    expect((await repository.fetchProfile()).city, 'Lyon');
  });

  test('un e-mail invalide bloque l’enregistrement', () async {
    form.setEmail('pas-un-email');
    expect(form.visibleErrorFor(ProfileEditField.email), isNull);
    expect(await form.save(), isFalse);
    expect(
      form.visibleErrorFor(ProfileEditField.email),
      'Entre une adresse e-mail valide.',
    );
    expect((await repository.fetchProfile()).email, isNot('pas-un-email'));
  });

  test('compétences : ajout sans doublon, niveau et retrait', () {
    final count = form.draft.skills.length;
    expect(form.addSkill('Kotlin'), isTrue);
    expect(form.addSkill('kotlin'), isFalse);
    expect(form.addSkill('  '), isFalse);
    expect(form.draft.skills.length, count + 1);

    final index = form.draft.skills.length - 1;
    expect(form.draft.skills[index].level, ProfileSkillLevel.beginner);
    form.cycleSkillLevel(index);
    expect(form.draft.skills[index].level, ProfileSkillLevel.intermediate);

    form.removeSkill(index);
    expect(form.draft.skills.length, count);
  });

  test('les suggestions excluent les compétences déjà présentes', () {
    expect(form.suggestedSkills, isNot(contains('Docker')));
    expect(form.suggestedSkills, contains('AWS'));
  });

  test('expériences et formations', () {
    expect(form.addExperience(title: '  '), isFalse);
    expect(form.addExperience(title: 'Barista', organization: ''), isTrue);
    expect(form.draft.experiences.last.organization, '—');

    form
      ..addEducation(
        const ProfileEducation(title: 'BTS SIO', school: 'Lycée Jean-Jaurès'),
      )
      ..removeEducation(0);
    expect(form.draft.educations.last.title, 'BTS SIO');
  });

  test('disponibilité et visibilité', () {
    form
      ..setStart('Dès que possible')
      ..setDuration(12)
      ..setRhythm('1 sem / 1 sem')
      ..setVisibleToRecruiters(false);
    expect(form.draft.availability.start, 'Dès que possible');
    expect(form.draft.availability.durationMonths, 12);
    expect(form.draft.availability.rhythm, '1 sem / 1 sem');
    expect(form.draft.visibility.visibleToRecruiters, isFalse);
  });
}
