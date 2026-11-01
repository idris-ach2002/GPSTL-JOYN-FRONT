import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/profile/data/fake_profile_repository.dart';
import 'package:joyn_front/features/profile/data/profile_file_picker.dart';
import 'package:joyn_front/features/profile/data/profile_repository.dart';
import 'package:joyn_front/features/profile/domain/student_profile.dart';
import 'package:joyn_front/features/profile/presentation/controllers/profile_controller.dart';
import 'package:joyn_front/features/profile/presentation/controllers/profile_edit_controller.dart';

/// Sélecteur de test : renvoie des fichiers prédéfinis ou une erreur.
class _FakePicker implements ProfileFilePicker {
  _FakePicker({this.photo, this.cv, this.error});

  final ProfilePhoto? photo;
  final ProfileCv? cv;
  final String? error;

  @override
  Future<ProfilePhoto?> pickPhoto() async {
    if (error != null) throw ProfileException(error!);
    return photo;
  }

  @override
  Future<ProfileCv?> pickCv() async {
    if (error != null) throw ProfileException(error!);
    return cv;
  }
}

final _photo = ProfilePhoto(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'moi.png',
);
const _cv = ProfileCv(fileName: 'CV_2027.pdf', updatedLabel: 'À l’instant');

void main() {
  group('page profil', () {
    test('changer la photo l’enregistre directement', () async {
      final repository = FakeProfileRepository(latency: Duration.zero);
      final controller = ProfileController(
        repository,
        filePicker: _FakePicker(photo: _photo),
      );
      await controller.load();

      expect(await controller.changePhoto(), 'Photo de profil mise à jour.');
      expect(controller.profile?.photo?.fileName, 'moi.png');
      expect((await repository.fetchProfile()).photo?.fileName, 'moi.png');
      controller.dispose();
    });

    test('annuler le sélecteur ne change rien', () async {
      final controller = ProfileController(
        FakeProfileRepository(latency: Duration.zero),
        filePicker: _FakePicker(),
      );
      await controller.load();

      expect(await controller.replaceCv(), isNull);
      expect(controller.profile?.cv?.fileName, 'CV_Ariel_Benatsi.pdf');
      controller.dispose();
    });

    test('un fichier refusé renvoie le message d’erreur', () async {
      final controller = ProfileController(
        FakeProfileRepository(latency: Duration.zero),
        filePicker: _FakePicker(error: 'Ton fichier dépasse 5 Mo.'),
      );
      await controller.load();

      expect(await controller.replaceCv(), 'Ton fichier dépasse 5 Mo.');
      controller.dispose();
    });
  });

  group('modification du profil', () {
    test('photo : ajout puis suppression dans le brouillon', () async {
      final form = ProfileEditController(
        FakeProfileRepository(latency: Duration.zero),
        filePicker: _FakePicker(photo: _photo),
      );
      await form.load();

      expect(await form.pickPhoto(), isNull);
      expect(form.draft.photo?.fileName, 'moi.png');
      expect(form.isDirty, isTrue);

      form.removePhoto();
      expect(form.draft.photo, isNull);
      form.dispose();
    });

    test('CV : remplacé dans le brouillon', () async {
      final form = ProfileEditController(
        FakeProfileRepository(latency: Duration.zero),
        filePicker: _FakePicker(cv: _cv),
      );
      await form.load();

      expect(await form.pickCv(), isNull);
      expect(form.draft.cv?.fileName, 'CV_2027.pdf');
      form.dispose();
    });

    test('expérience avec description', () async {
      final form = ProfileEditController(
        FakeProfileRepository(latency: Duration.zero),
      );
      await form.load();

      form.addExperience(
        title: 'Développeuse mobile',
        organization: 'Entreprise Y',
        period: '2027',
        description: '  Application Flutter de réservation.  ',
      );
      expect(
        form.draft.experiences.last.description,
        'Application Flutter de réservation.',
      );
      form.dispose();
    });
  });
}
